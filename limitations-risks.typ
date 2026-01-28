#set par(justify: true)

= Các Hạn chế và Rủi ro

Hệ thống phát hiện tin giả tiếng Việt sử dụng PhoBERT và kiến trúc microservices với Kafka, PostgreSQL, và Airflow. Mặc dù được thiết kế với nhiều lớp phòng thủ, hệ thống vẫn có những hạn chế và rủi ro cần được nhận diện và giảm thiểu.

== Chất lượng Dữ liệu Huấn luyện

=== Vấn đề chính

Hệ thống phụ thuộc vào dữ liệu người dùng báo cáo (`user_reports`) và dữ liệu được kiểm duyệt (`training_data`). Chất lượng dữ liệu ảnh hưởng trực tiếp đến độ chính xác của mô hình PhoBERT.

*Các nguồn gây nhiễu*:
- *Báo cáo sai từ người dùng*: Người dùng thiếu chuyên môn hoặc có thiên kiến cá nhân
- *Lỗi kiểm duyệt*: Quản trị viên có thể nhầm lẫn với luận điểm phức tạp
- *Thông tin lỗi thời*: Sự thật thay đổi theo thời gian nhưng nhãn cũ không được cập nhật

*Ví dụ*:
```
Claim: "Vaccine COVID-19 gây tử vong cho 0.001%"
→ Có thể đúng về mặt thống kê (correlation)
→ Nhưng sai về mặt nhân quả (causation)
→ Cần chuyên môn y khoa để đánh giá chính xác
```

=== Giải pháp đang áp dụng

*1. Hệ thống reputation*
```
backend/schemas.py - User reputation system
Người dùng mới có trọng số thấp
Trọng số tăng dần qua các báo cáo chính xác
```

*2. Dashboard kiểm duyệt*
```
dashboard/app.py
Quản trị viên review báo cáo trước khi thêm vào training_data
```
*3. Weekly retrain*
```
dags/weekly_retrain_dag.py
Chỉ sử dụng dữ liệu đã được kiểm duyệt và phê duyệt
```

== Độ Trễ Cập Nhật Mô Hình

=== Vấn đề chính

Hệ thống sử dụng batch retraining định kỳ thay vì online learning để đảm bảo tính ổn định.

*Tần suất hiện tại*:
- Mô hình PhoBERT: Huấn luyện lại *1 lần/tuần* (`weekly_retrain_dag.py`)
- Cơ sở tri thức: Cập nhật *hàng ngày* (`daily_crawl_dag.py`)

*Gap nguy hiểm*: Trong 7 ngày, mô hình không học được các pattern mới mặc dù knowledge base được cập nhật hàng ngày.

=== Kịch bản tổn thương

```
Thứ Hai (00:00): Chiến dịch tin giả mới xuất hiện
  → Mô hình: UNVERIFIED (chưa học pattern này)
  
Thứ Hai (12:00): Knowledge base crawl fact-check mới
  → Evidence matching hoạt động
  → Nhưng model vẫn không nhận dạng được pattern
  
Thứ Ba → Thứ Bảy: Tin giả lan truyền
  → Model vẫn chưa học
  
Chủ Nhật (08:00): Model mới deployed sau weekly retrain
  → Cuối cùng có thể detect tự động
  
→ Window of vulnerability: ~7 ngày
```

*Lý do thiết kế*:
- Chi phí tính toán: Training PhoBERT tốn 4-8 giờ GPU
- Stability: Batch learning ổn định hơn online learning
- Quality control: Có thể validate kỹ trước khi deploy

== Khả Năng Mở Rộng Hệ Thống

*1. Database throughput*
```yaml
Current: PostgreSQL single instance
Bottleneck: ~10,000 writes/second

Solutions:
  - Sharding by user_id or claim_id
  - Read replicas for query load
  - Redis caching for hot data
  - Archive old data to cold storage
```

*2. ML inference latency*
```
Current: 
  Latency: ~100ms per request
  Throughput: ~10 requests/second

Optimizations:
  - Model quantization (FP32 → INT8)
  - Batch inference
  - GPU acceleration
  - Multi-region deployment
```

*3. Kafka message processing*
```python
# processor/consumer.py
Current: Single consumer instance
At scale: Need consumer group with multiple instances
```

*4. Vector database*
```python
# dataset/build_vector_db.py using pgvector
Current: Works well for <1M vectors
At scale: Consider specialized vector DB (Milvus, Weaviate)
```

== Các Rủi ro Khác

*1. Adversarial attacks*
- Input perturbation: "Vacc1ne C0VID-19" để bypass detection
- Giảm thiểu: Text normalization, character-level analysis

*2. Sybil attacks*
- Tạo nhiều tài khoản giả để manipulate reports
- Giảm thiểu: Reputation system, bot detection, rate limiting
