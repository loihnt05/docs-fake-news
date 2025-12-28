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

  [Retrieval],
  [Quá trình tìm kiếm các tài liệu hoặc đoạn văn liên quan đến một truy vấn (claim) từ kho tri thức.],

  [Precision],
  [Tỷ lệ kết quả truy vấn/phan loại được trả về là chính xác (true positives / (true positives + false positives)).],

  [Recall],
  [Tỷ lệ các trường hợp thực sự dương được phát hiện (true positives / (true positives + false negatives)).],

  [F1-score],
  [Trung bình điều hòa giữa Precision và Recall: 2 * (precision * recall) / (precision + recall).],

  [Concept Drift],
  [Sự thay đổi theo thời gian của phân phối dữ liệu hoặc mối quan hệ giữa dữ liệu và nhãn, làm giảm hiệu năng mô hình nếu không cập nhật.],

  [Active Learning],
  [Kỹ thuật chọn lọc mẫu thông minh để con người gán nhãn nhằm tối ưu hiệu quả huấn luyện với ít dữ liệu nhãn hơn.],

  [Batch Retraining],
  [Chiến lược huấn luyện lại mô hình được lên lịch theo đợt để đảm bảo ổn định và tiết kiệm tài nguyên.],

  [Human-in-the-loop],
  [Cơ chế tích hợp phản hồi con người (chuyên gia hoặc người dùng) vào quá trình huấn luyện và đánh giá mô hình.],

  [Ground Truth],
  [Nhãn chuẩn được coi là đúng để đánh giá mô hình hoặc làm mục tiêu huấn luyện.],

  [Knowledge Base],
  [Tập hợp các nguồn tin đáng tin cậy, tài liệu và dữ liệu có cấu trúc dùng làm kho chứng cứ cho việc truy xuất.],

  [Cosine Similarity],
  [Thước đo độ tương đồng giữa hai vector embedding dựa trên góc giữa chúng; thường dùng trong truy vấn ngữ nghĩa.],

  [Transformer],
  [Kiến trúc mạng nơ-ron dựa trên cơ chế attention, nền tảng cho các mô hình ngôn ngữ lớn hiện đại.],

  [Tokenization],
  [Quá trình phân chia văn bản thành các đơn vị nhỏ (tokens) để mô hình xử lý; có thể là từ, subword hoặc ký tự.],

  [Confidence Score],
  [Giá trị thể hiện mức độ tự tin của mô hình về dự đoán; dùng để lọc hoặc ưu tiên các trường hợp cho human review.],

  [Provenance],
  [Nguồn gốc và lịch sử của một bằng chứng (ai xuất bản, khi nào, phương pháp thu thập), quan trọng cho đánh giá độ tin cậy.],

  [Reputation Weight],
  [Trọng số gán cho nguồn thông tin hoặc người đóng góp dựa trên uy tín của họ, dùng để điều chỉnh ảnh hưởng trong huấn luyện và tổng hợp kết quả.]
)
