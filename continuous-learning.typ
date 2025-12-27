
#set par(justify: true)

  Chương 7: Pipeline Học Liên tục (Continuous Learning Pipeline - CORE)

  Đây là chương lõi, mô tả quy trình trung tâm giúp hệ thống khác biệt: khả năng tự tiến hóa và thích ứng với môi trường thông tin luôn biến động. Pipeline này tích hợp các kết quả từ hệ thống Phản hồi & Độ uy tín (Chương 6) để tạo ra các
  phiên bản mô hình ngày càng thông minh hơn.

  7.1. Khi nào Mô hình học?

  Việc lựa chọn thời điểm và phương thức học ảnh hưởng trực tiếp đến sự ổn định và hiệu quả của cả hệ thống.

   * Không học Real-time: Hệ thống được thiết kế để không học trong thời gian thực (tức là cập nhật lại mô hình ngay sau mỗi phản hồi). Cách tiếp cận real-time tiềm ẩn nhiều rủi ro nghiêm trọng:
       * Thiếu ổn định: Mô hình có thể biến động thất thường chỉ vì một vài phản hồi đơn lẻ, có thể đúng hoặc sai, làm suy giảm trải nghiệm của tất cả người dùng.
       * Chi phí tính toán: Huấn luyện lại một mô hình ngôn ngữ lớn như PhoBERT là một tác vụ rất nặng. Thực hiện nó liên tục sẽ cực kỳ tốn kém và không thực tế.
       * Trạng thái không nhất quán: Các máy chủ khác nhau có thể cập nhật mô hình ở những thời điểm khác nhau, dẫn đến việc người dùng nhận được kết quả không nhất quán.

   * Batch Retraining (Huấn luyện lại theo lô): Giải pháp của chúng tôi là huấn luyện lại theo lô định kỳ. Tác vụ này được định nghĩa và điều phối bởi Apache Airflow, cụ thể là `dags/weekly_retrain_dag.py`. Hàng tuần, Airflow sẽ tự động
     kích hoạt một pipeline huấn luyện. Phương pháp này đảm bảo:
       * Ổn định: Mô hình chỉ được cập nhật sau khi đã tích lũy đủ một lượng lớn dữ liệu phản hồi đã qua kiểm duyệt, giúp quá trình học ổn định và đáng tin cậy.
       * Hiệu quả: Tối ưu hóa việc sử dụng tài nguyên tính toán bằng cách chỉ chạy tác vụ huấn luyện nặng một lần mỗi chu kỳ.
       * Nhất quán: Tất cả các máy chủ sản xuất sẽ được cập nhật lên cùng một phiên bản mô hình mới cùng một lúc.

  7.2. Lựa chọn Dữ liệu Huấn luyện (Training Data Selection)

  Chất lượng của mô hình mới phụ thuộc hoàn toàn vào chất lượng dữ liệu được chọn để huấn luyện. Quy trình retrain_pipeline.py bắt đầu bằng một bước lựa chọn dữ liệu cực kỳ cẩn trọng.

   * Approved Reports Only (Chỉ dùng báo cáo đã được duyệt): Nguồn dữ liệu chính cho việc học liên tục đến từ các báo cáo của người dùng. Tuy nhiên, chỉ những báo cáo đã đi qua luồng kiểm duyệt (6.3) và được các chuyên gia đánh dấu là
     "Approved" mới được đưa vào bộ dữ liệu huấn luyện. Đây là lớp "tường lửa" quan trọng nhất để đảm bảo chất lượng dữ liệu.

   * Exclude Undefined (Loại trừ các nhãn không xác định): Mục tiêu của việc học là dạy cho mô hình cách xử lý những trường hợp khó mà trước đây nó không chắc chắn. Do đó, bộ dữ liệu huấn luyện sẽ tập trung vào các cặp (claim,
     corrected_label) nơi mà corrected_label là REAL hoặc FAKE do con người cung cấp, đặc biệt là các trường hợp có nhãn gốc là UNDEFINED. Chúng ta không huấn luyện mô hình trên những thứ mà ngay cả con người cũng chưa xác định được.

  7.3. Huấn luyện có Trọng số (Weighted Training)

  Sau khi đã có bộ dữ liệu "sạch", quá trình huấn luyện vẫn cần sự thông minh để tận dụng tối đa thông tin về độ uy tín.

   * Oversampling theo Độ uy tín (Reputation-based Oversampling): Thay vì chỉ coi mỗi mẫu dữ liệu là như nhau, chúng tôi áp dụng kỹ thuật lấy mẫu có trọng số. Trong quá trình tạo các lô dữ liệu (data batch) để đưa vào mô hình, một mẫu dữ
     liệu đến từ người dùng có điểm uy tín cao sẽ có xác suất được chọn cao hơn. Ví dụ, một phản hồi từ chuyên gia (điểm uy tín 1000) sẽ có cơ hội xuất hiện trong các lô huấn luyện nhiều hơn hàng trăm lần so với phản hồi từ người dùng
     thường (điểm uy tín 10). Kỹ thuật này "buộc" mô hình phải chú ý nhiều hơn đến dữ liệu từ các nguồn đáng tin cậy.

   * Không Hard Filter (Không lọc cứng): Hệ thống không áp dụng một bộ lọc cứng như "chỉ học từ người dùng có điểm > 50". Thay vào đó, nó sử dụng toàn bộ phổ điểm uy tín như một cơ chế "lọc mềm" thông qua việc lấy mẫu có trọng số. Một
     người dùng có điểm thấp vẫn đóng góp cho hệ thống, dù tác động của họ là rất nhỏ. Cách tiếp cận này giúp tận dụng "trí tuệ đám đông" một cách an toàn, trong khi vẫn đảm bảo sự chi phối của các chuyên gia.

  7.4. Quản lý Phiên bản Mô hình (Model Versioning)

  Quản lý vòng đời của các mô hình là một phần tối quan trọng của MLOps để đảm bảo sự ổn định cho sản phẩm.

   * v1 → v2 → vN: Sau mỗi chu kỳ huấn luyện thành công, pipeline không ghi đè lên mô hình cũ. Thay vào đó, nó lưu phiên bản mô hình mới vào một thư mục riêng biệt, có đánh số phiên bản. Cấu trúc thư mục checkpoints/model_1,
     checkpoints/model_2,... checkpoints/model_9 chính là minh chứng cho việc này. Sau khi lưu, một file cấu hình trung tâm sẽ được cập nhật để trỏ ứng dụng (backend/main.py) đến phiên bản mô hình mới nhất.

   * Rollback Strategy (Chiến lược Quay lui): Điều gì sẽ xảy ra nếu mô hình v2, dù được huấn luyện tốt, lại hoạt động kém hơn v1 trên môi trường thực tế vì một lý do không lường trước? Hệ thống cần có một phương án dự phòng.
       * Nhờ vào việc quản lý phiên bản một cách tường minh, việc quay lui (rollback) về phiên bản ổn định trước đó trở nên cực kỳ đơn giản. Đội ngũ vận hành chỉ cần thay đổi một dòng trong file cấu hình để trỏ hệ thống về lại thư mục
         checkpoints/model_1 và khởi động lại ứng dụng.
       * Chiến lược này mang lại sự an toàn tuyệt đối, cho phép hệ thống liên tục thử nghiệm các phiên bản mô hình mới mà không sợ làm ảnh hưởng đến sự ổn định của toàn bộ sản phẩm. Đây là một tư duy vận hành chuyên nghiệp, đảm bảo hệ
         thống luôn ở trạng thái tốt nhất.
