#align(center, text(
  size: 20pt,
  weight: "bold",
block[
  Terminology
]))
#set par(justify: true)

#set table(
  inset: 8pt,
  stroke: 0.8pt,
)

#table(
  columns: (28%, 72%),
  fill: (gray.lighten(90%), none),

  // Header
  [*Thuật ngữ*], [*Ý Nghĩa*],

  // Rows
  [Embedding],
  [Biểu diễn dữ liệu (văn bản, hình ảnh, âm thanh) dưới dạng vector số để phục vụ tìm kiếm và so khớp ngữ nghĩa.],

  [Fine-tuning],
  [Quá trình huấn luyện lại mô hình ngôn ngữ trên tập dữ liệu chuyên biệt nhằm cải thiện hiệu năng cho bài toán cụ thể.],

  [PhoBERT],
  [Mô hình ngôn ngữ dựa trên kiến trúc BERT, được huấn luyện cho tiếng Việt.],

  [Vector Database],
  [Hệ quản trị cơ sở dữ liệu dùng để lưu trữ và truy vấn vector embedding.],

  [RAG (Retrieval-Augmented Generation)],
  [Kỹ thuật kết hợp truy xuất tri thức bên ngoài với mô hình sinh để cải thiện độ chính xác của câu trả lời.],

  [Claim],
  [Một phát biểu cụ thể có thể kiểm chứng về một sự kiện hoặc thực thể trong thế giới thực; đơn vị cơ bản để xác minh trong hệ thống.],

  [Evidence],
  [Đoạn văn, bài báo, hoặc nguồn thông tin được sử dụng để ủng hộ hoặc bác bỏ một claim.],

  [NLI (Natural Language Inference)],
  [Nhiệm vụ xác định mối quan hệ logic giữa hai đoạn văn (ví dụ: ủng hộ, bác bỏ, trung lập).],

  [Precision],
  [Tỷ lệ kết quả truy vấn/phan loại được trả về là chính xác (true positives / (true positives + false positives)).],

  [F1-score],
  [Trung bình điều hòa giữa Precision và Recall: 2 * (precision * recall) / (precision + recall).],

  [Batch Retraining],
  [Chiến lược huấn luyện lại mô hình được lên lịch theo đợt để đảm bảo ổn định và tiết kiệm tài nguyên.],

  [Knowledge Base],
  [Tập hợp các nguồn tin đáng tin cậy, tài liệu và dữ liệu có cấu trúc dùng làm kho chứng cứ cho việc truy xuất.],

  [Transformer],
  [Kiến trúc mạng nơ-ron dựa trên cơ chế attention, nền tảng cho các mô hình ngôn ngữ lớn hiện đại.],

  [Confidence Score],
  [Giá trị thể hiện mức độ tự tin của mô hình về dự đoán; dùng để lọc hoặc ưu tiên các trường hợp cho human review.],
)
