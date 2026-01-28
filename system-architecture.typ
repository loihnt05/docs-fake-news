#set par(justify: true)
= Thiết kế hệ thống

== Tổng quan Pipeline

Hệ thống xác minh tin giả hoạt động qua 4 tầng chính với kiến trúc ba lớp bảo vệ (Triple-Layer Protection):

*Luồng xử lý:* Người dùng → API Gateway → Instant Filter (Layer 0) → Claim Extraction → Evidence Retrieval (Layer 1) → Cross-Encoder Verification (Layer 2) → Kết quả

=== Sơ đồ kiến trúc tổng thể

#image("assets/image.png")
=== Các thành phần chính

1. *FastAPI Backend* (`backend/main.py`): REST API với CORS, xử lý request từ Extension/Dashboard
2. *Instant Filter* (`backend/instant_filter.py`): Chặn nội dung nguy hiểm ngay lập tức bằng pattern matching  
3. *AdvancedFactChecker* (`backend/verifier.py`): Core verification engine với 3 lớp bảo vệ
4. *PostgreSQL Database*: Lưu trữ claims, user reports, feedback data với pgvector extension
5. *FAISS Vector DB* (`dataset/`): Semantic search trên knowledge base  
6. *Airflow DAGs* (`dags/`): Tự động hóa crawling và retraining
7. *Kafka Queue*: Message broker cho data pipeline (producer/consumer pattern)
8. *Go Scraper Binary*: Thu thập bài báo từ VnExpress với tốc độ cao

=== Docker Stack

Hệ thống chạy trên Docker Compose với 12 services:

*Infrastructure:*
- `db`: PostgreSQL 15 + pgvector extension
- `pgadmin`: Database admin UI (port 5050)
- `zookeeper`: Kafka coordination
- `kafka`: Message broker
- `kafka-ui`: Kafka monitoring (port 8888)

*Application:*
- `backend`: FastAPI server (port 8000)
- `consumer`: Kafka consumer xử lý real-time
- `dashboard`: Streamlit admin panel (port 8501)

*Workflow:*
- `airflow-init`: Khởi tạo DB và user
- `airflow-webserver`: Web UI (port 8080)
- `airflow-scheduler`: Chạy DAGs theo lịch

== Layer 0: Instant Filter - Chặn ngay lập tức (< 1ms)

*Mục đích:* Chặn nội dung nguy hiểm trước khi tốn tài nguyên AI xử lý.

*Cơ chế hoạt động:*

#image("assets/image-1.png")

*Pattern Categories:*
- `MEDICAL_MIRACLE`: Tuyên bố chữa ung thư, mù, liệt không cần y tế
- `CULT_MEDICAL`: Pháp Luân Công chữa bệnh kỳ diệu
- `POLITICAL_CONSPIRACY`: Âm mưu đàn áp, che đậy
- `DANGEROUS_MEDICAL`: Khuyến khích ngừng điều trị
- `FAKE_TESTIMONIAL`: Câu chuyện không thể xác minh
- `BLOCKED_SOURCE`: Domain trong blacklist (dkn.tv, epochtimes, phapluan.org)

*Suspicion Score Calculation:*
```python
score = Σ(keyword_count × category_weight) / max_possible_score

Weights:
- cult_related: 2.0 (cao nhất)
- anti_vaccine: 2.0
- medical_claims: 1.5
- conspiracy: 1.2
```

*Output Example:*
```json
{
  "should_block": true,
  "severity": "CRITICAL",
  "reasons": ["Tuyên bố chữa khỏi bệnh nan y mà không có bằng chứng y khoa"],
  "matched_patterns": [{
    "type": "MEDICAL_MIRACLE",
    "matched": "chữa khỏi ung thư hoàn toàn không dùng thuốc",
    "severity": "CRITICAL"
  }],
  "suspicion_score": 0.85
}
```

*Ưu điểm:* 
- Cực nhanh (< 1ms), không cần GPU
- Ngăn chặn 100% các mẫu đã biết
- Tiết kiệm chi phí tính toán
- Có thể cập nhật pattern real-time

*Code:* `backend/instant_filter.py` (338 dòng, 100+ patterns)

== Layer 1: Claim Extraction & Evidence Retrieval

=== Trích xuất Claims

*Công cụ:* `underthesea.sent_tokenize()` - rule-based Vietnamese segmentation

*Quy trình:*
1. Làm sạch text: `clean_text()` loại bỏ ký tự đặc biệt, chuẩn hóa khoảng trắng
2. Tách câu: `sent_tokenize()` phân tích dấu câu và context
3. Lọc câu quá ngắn: `len(sentence.split()) > 5`
4. Mỗi câu → 1 claim candidate

*Đơn giản hóa:* Không cần classifier phức tạp - coi mỗi câu đủ dài là claim tiềm năng, để Cross-Encoder quyết định độ liên quan sau.

*Code snippet:*
```python
def extract_claims(self, text):
    cleaned_text = self.clean_text(text)
    sentences = sent_tokenize(cleaned_text)
    return [s.strip() for s in sentences if len(s.split()) > 5]
```

=== Evidence Retrieval - Dual-Branch Search

Hệ thống sử dụng chiến lược tìm kiếm 2 nhánh:

#image("assets/image-2.png")

*Branch 1: Memory Check (Known Fakes)*
- Mục đích: Phát hiện claims tương tự tin giả đã biết
- Query: Tìm claim gần nhất trong bảng `claims` với `system_label='FAKE'`
- Threshold: `distance < 0.15` (tương tự > 85%)
- Action: Chặn ngay lập tức, không cần AI verification
- Benefit: Ngăn tin giả tái xuất hiện với wording khác

*Branch 2: Evidence Check (Real Knowledge)*
- Mục đích: Tìm bằng chứng ủng hộ/bác bỏ từ nguồn uy tín
- Query: Tìm claim gần nhất với `system_label='REAL'`
- Threshold: `distance < 0.45` (liên quan tương đối)
- Action: Gửi pair (claim, evidence) đến Cross-Encoder

*Mô hình Bi-Encoder:* 
- Model: `bkai-foundation-models/vietnamese-bi-encoder` 
- Input: Vietnamese text
- Output: 768-dim dense vector
- Advantage: Encode một lần, search nhanh với vector operations

*PostgreSQL pgvector:*
```sql
-- Distance operator: <=> (L2 distance)
SELECT id, content, (embedding <=> %s::vector) as distance
FROM claims
WHERE system_label = 'FAKE'
ORDER BY distance ASC
LIMIT 1;
```

*Performance:*
- Vector encoding: ~10ms
- PostgreSQL search: ~20-30ms
- Total Layer 1: ~40-50ms

== Layer 2: Cross-Encoder Verification - Đánh giá cuối cùng

*Mô hình:* Cross-Encoder (`my_model_v7/`) - fine-tuned từ `vinai/phobert-base`

*Khác với Bi-Encoder và NLI truyền thống:*

#image("assets/image-4.png")

*Ưu điểm Cross-Encoder:*
- Attention mechanism trực tiếp giữa claim và evidence
- Hiểu ngữ cảnh sâu hơn (không chỉ cosine similarity)
- Phát hiện contradiction tinh tế (negation, temporal inconsistency)

*Quy trình:*
1. Với mỗi claim, tạo pairs: `(claim, evidence_1), (claim, evidence_2), ...`
2. Cross-Encoder tokenize: `[CLS] claim [SEP] evidence [SEP]`
3. PhoBERT forward pass → logits cho 3 classes
4. Softmax → probabilities: `[P(REFUTED), P(SUPPORTED), P(NEI)]`
5. Tổng hợp scores từ multiple evidence

*Aggregation Logic với Source Credibility:*

```python
def make_final_decision(self, details):
    # Ưu tiên REFUTED - nếu có bất kỳ evidence nào bác bỏ → FAKE
    refuted = [d for d in details if d['status'] == 'REFUTED']
    supported = [d for d in details if d['status'] == 'SUPPORTED']
    
    if refuted:
        # Lấy cái có confidence cao nhất
        top = max(refuted, key=lambda x: x['score'])
        return {
            "status": "FAKE",
            "confidence": top['score'],
            "explanation": f"Mâu thuẫn với: '{top['evidence']}'"
        }
    
    # Cần ít nhất 50% claims được support
    elif len(supported) >= len(details) * 0.5:
        avg_conf = sum(d['score'] for d in supported) / len(supported)
        return {
            "status": "REAL",
            "confidence": avg_conf,
            "explanation": "Khớp với dữ liệu đã xác thực"
        }
    
    else:
        return {"status": "NEUTRAL", "confidence": 0.5}
```


*Training Data:* 
- Positive pairs: (claim, supporting_evidence) → SUPPORTED
- Negative pairs: (claim, contradicting_evidence) → REFUTED
- Unrelated pairs: (claim, random_article) → NEI
- Source: UIT-ViWikiFC, UIT-ViCoV19QA, tự thu thập từ user reports

*Inference Time:*
- Single pair: ~200ms (GPU) / ~1000ms (CPU)
- Batch của 5 pairs: ~250ms (GPU)
- Optimization: Batch processing multiple claims

== Lớp Thu thập Dữ liệu - Data Pipeline

=== Kiến trúc Data Flow
#image("assets/image-5.png")

=== Airflow DAG Orchestration

*File:* `dags/daily_crawl_dag.py`, `dags/weekly_retrain_dag.py`

*Daily Crawl DAG:*
```python
with DAG('1_daily_news_ingestion',
         schedule_interval='0 6 * * *',  # 6:00 AM daily
         catchup=False) as dag:
    
    # Task 1: Run Go scraper binary
    crawl_task = BashOperator(
        task_id='run_crawler',
        bash_command='python crawler/batch_crawler.py',
        env={'KAFKA_SERVER': 'kafka:9093'}
    )
    
    # Task 2: Rebuild vector DB after new articles
    rebuild_kb_task = BashOperator(
        task_id='rebuild_knowledge_base',
        bash_command='python processor/rebuild_knowledge_base.py'
    )
    
    crawl_task >> rebuild_kb_task  # Sequential execution
```

*Weekly Retrain DAG:*
- Lấy user reports từ PostgreSQL
- Filter: chỉ lấy reports có `user_feedback != ai_label` (disagreement)
- Augment training data với negative mining
- Fine-tune Cross-Encoder 2-3 epochs
- Validate trên held-out set
- Save checkpoint nếu accuracy tăng

*Monitoring:*
- Airflow Web UI (port 8080): DAG runs, task logs, failure alerts
- Retry logic: 1 retry với delay 5 phút
- Email alert khi DAG fail

=== Batch Crawler - Go Implementation

*Why Go?*
- Concurrency: Goroutines cho parallel scraping
- Performance: Nhanh hơn Python 5-10x
- Memory: Efficient memory usage
- Static binary: Dễ deploy trong Docker


*Indexes:*
- `claims.embedding`: IVFFlat index cho vector search
- `claims.system_label`: B-tree cho filtered queries
- `user_reports.claim_id`: Foreign key index
- `articles.url`: Unique index tránh duplicate

*Human-in-the-loop Flow:*
1. User disagree với AI → Submit report qua Extension
2. Backend lưu vào `user_reports` với full context
3. Weekly retrain DAG query reports để augment training data
4. Model học từ disagreement → cải thiện accuracy
5. User reputation score tăng nếu feedback đúng (validated sau)
