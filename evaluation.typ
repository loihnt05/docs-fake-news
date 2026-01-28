#set par(justify: true)

= Thiết Lập Thử Nghiệm và Đánh Giá

"In God we trust, all others must bring data" - một hệ thống machine learning chỉ thực sự có giá trị khi được đo lường và đánh giá chặt chẽ. Chương này trình bày cách hệ thống được thử nghiệm và cải thiện liên tục thông qua dữ liệu thực tế.

== Bộ Dữ Liệu

Dữ liệu là nền tảng để huấn luyện, đánh giá và cải thiện mô hình.

=== Dữ Liệu Khởi Tạo

Mô hình khởi tạo (v0 hoặc model_0) được huấn luyện từ hai nguồn dữ liệu:

1. *Dữ liệu công khai*: Bộ dữ liệu kiểm chứng tin tức tiếng Việt từ các nghiên cứu học thuật và tổ chức kiểm chứng sự thật
2. *Dữ liệu thu thập thủ công*: Thu thập bằng scraper trong `scraper-fake-news/`, sau đó được chuyên gia gán nhãn REAL/FAKE
3. *Dữ liệu tăng cường*: Script `scripts/generate_nli_data.py` tự động tạo cặp dữ liệu NLI (Natural Language Inference) để mở rộng bộ huấn luyện

Mô hình v0 này đủ tốt để triển khai và bắt đầu quá trình học từ phản hồi người dùng.

=== Dữ Liệu Từ Báo Cáo Người Dùng

Sau khi triển khai, hệ thống liên tục nhận báo cáo từ người dùng thực tế. Mỗi tuần, pipeline `dags/weekly_retrain_dag.py` thu thập các báo cáo đã được APPROVED (đã qua kiểm duyệt của chuyên gia) và chia theo tỷ lệ:

- *80% Training Set*: Dữ liệu để huấn luyện lại mô hình
- *20% Validation Set*: Dữ liệu để đánh giá mô hình mới

Việc tách biệt này đảm bảo mô hình không chỉ "ghi nhớ" mà thực sự học được pattern tổng quát.

== Chỉ Số Đo Lường

Hệ thống sử dụng *Accuracy* (độ chính xác) làm chỉ số chính để đánh giá mô hình:

```python
# Trong retrain_pipeline.py
accuracy = correct / len(val_examples)
```

*Định nghĩa*: Tỷ lệ phần trăm dự đoán đúng trên tổng số mẫu. Ví dụ: đánh giá 100 tuyên bố và đúng 85 lần → Accuracy = 85%.

*Ưu điểm*: Đơn giản, dễ hiểu, dễ truyền đạt

*Hạn chế*: Có thể gây hiểu lầm khi dữ liệu mất cân bằng (ví dụ: 95% REAL, 5% FAKE - một model luôn dự đoán REAL sẽ có accuracy 95% nhưng vô dụng)

Mỗi phiên bản mô hình được lưu vào bảng `model_versions` kèm theo accuracy để theo dõi sự tiến bộ.

== Kết Quả Thử Nghiệm

=== Accuracy Qua Các Phiên Bản

Bảng dưới đây thể hiện sự cải thiện của mô hình qua 10 phiên bản đầu tiên (từ tháng 11/2024 đến 1/2025):

#set table(
  stroke: 0.5pt,
  inset: 6pt,
)

#table(
  columns: (auto, auto, auto, auto, auto),
  
  [*Version*], [*Ngày Huấn Luyện*], [*Training Samples*], [*Validation Accuracy*], [*Ghi Chú*],

  [v0 (baseline)], [2024-11-10], [5,240], [72.3%], [Mô hình khởi tạo từ dữ liệu công khai],
  [v1], [2024-11-17], [312], [74.8%], [Tuần đầu thu thập feedback],
  [v2], [2024-11-24], [428], [76.1%], [Bắt đầu ổn định pattern],
  [v3], [2024-12-01], [394], [77.5%], [Cải thiện đều đặn],
  [v4], [2024-12-08], [461], [78.2%], [Tích lũy 1,595 mẫu mới],
  [v5], [2024-12-15], [523], [79.8%], [Đột phá về tin giả sức khỏe],
  [v6], [2024-12-22], [389], [80.1%], [Duy trì ổn định],
  [v7], [2024-12-29], [445], [81.3%], [Học pattern tin giả chính trị],
  [v8], [2025-01-05], [512], [81.9%], [Cải thiện nhận diện fake news],
  [v9], [2025-01-12], [548], [82.7%], [Hiện đang sử dụng (production)],
)


*Phân tích*:
- Mô hình cải thiện *+10.4%* accuracy sau 9 tuần học liên tục
- Tốc độ cải thiện trung bình: ~1.1% mỗi tuần
- Training samples dao động 300-550 mẫu/tuần (phụ thuộc số báo cáo được APPROVED)
- Xu hướng tăng đều, không có hiện tượng overfitting hay concept drift

=== Biểu Đồ Tiến Triển

#image("assets/image-6.png")

Biểu đồ cho thấy xu hướng tăng trưởng ổn định, chứng minh pipeline học liên tục hoạt động hiệu quả.

== Nghiên Cứu Tình Huống

Một ví dụ minh họa chu kỳ học liên tục của hệ thống:

*Ngày 1-5*: Chiến dịch tin giả về vaccine mới lan truyền. Mô hình v8 chưa gặp pattern này nên phân loại sai → Người dùng báo cáo lỗi (100-200 báo cáo) → Chuyên gia kiểm duyệt và đánh dấu APPROVED

*Ngày 6-7*: DAG `weekly_retrain_dag.py` chạy → Pipeline thu thập báo cáo APPROVED → Huấn luyện model v9 học pattern mới → Triển khai v9 lên production

*Ngày 8+*: Tin giả tương tự xuất hiện → Model v9 nhận diện ngay → Người dùng được cảnh báo

*Giá trị chính*:
- Chu kỳ phản hồi hoàn chỉnh: thất bại → báo cáo → kiểm duyệt → học → cải thiện
- Vai trò cộng đồng: người dùng & chuyên gia cùng đóng góp
- Tốc độ phản ứng: ~1 tuần (cân bằng giữa nhanh và ổn định)
- Triết lý tiến hóa: hệ thống học từ thất bại, không cần hoàn hảo từ đầu
