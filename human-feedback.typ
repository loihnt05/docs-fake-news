#set par(justify: true)
  Chương 6: Hệ thống Phản hồi và Độ uy tín (Human Feedback & Reputation System)

  Để giải quyết các thách thức về Concept Drift và Adversarial Users, một hệ thống chỉ học từ dữ liệu mới là không đủ. Nó phải có khả năng học hỏi từ chính những người dùng của mình một cách thông minh và an toàn. Chương này mô tả kiến
  trúc của hệ thống Phản hồi và Độ uy tín, một thành phần cốt lõi giúp hệ thống tự hoàn thiện và chống lại các cuộc tấn công phá hoại.

  6.1. Cơ chế Báo cáo từ Người dùng (User Reporting Mechanism)

  Cơ chế này là cầu nối trực tiếp giữa trải nghiệm của người dùng và quá trình học của hệ thống.

   * Extension (Tiện ích mở rộng): Giao diện chính để người dùng tương tác với hệ thống là thông qua tiện ích mở rộng trên trình duyệt (extension/popup.html, popup.js). Bên cạnh việc hiển thị kết quả xác minh (label, confidence_score),
     tiện ích này cung cấp một nút bấm rõ ràng, ví dụ như "Báo cáo không chính xác".

   * Report Content (Nội dung Báo cáo): Khi người dùng thực hiện một báo cáo, tiện ích sẽ thu thập một gói thông tin (payload) và gửi về cho máy chủ (backend/main.py). Gói tin này bao gồm:
       * Claim ID: Mã định danh duy nhất của luận điểm đang được báo cáo.
       * Hệ thống dự đoán: Nhãn và điểm tự tin mà hệ thống đã đưa ra (ví dụ: FAKE, 0.95).
       * Người dùng đề xuất: Nhãn mà người dùng cho là đúng (ví dụ: REAL).
       * Nguồn tham khảo (Tùy chọn): Một trường để người dùng có thể dán URL của một bài viết hoặc nguồn tin đáng tin cậy để chứng minh cho đề xuất của họ.
       * User Token: Mã định danh của người dùng để theo dõi và cập nhật điểm uy tín.

  6.2. Mô hình hóa Độ uy tín (Reputation Modeling)

  Đây là "bộ não" của hệ thống phản hồi, quyết định xem phản hồi nào là đáng tin cậy. Hệ thống không coi mọi phản hồi đều có giá trị như nhau.

   * Score Update (Cập nhật điểm): Mỗi người dùng được gán một điểm uy tín (reputation score).
       * Người dùng mới sẽ có một điểm khởi tạo (ví dụ: 1.0).
       * Sau khi phản hồi của họ được các quản trị viên xem xét (mục 6.3), điểm số sẽ được cập nhật:
           * Nếu phản hồi được chấp thuận (Approved), điểm uy tín của người dùng sẽ tăng lên.
           * Nếu phản hồi bị từ chối (Rejected), điểm uy tín sẽ bị trừ đi.
       * Mức độ thay đổi điểm có thể phụ thuộc vào độ khó của ca báo cáo, ví dụ, sửa một lỗi sai có độ tự tin cao của hệ thống sẽ được thưởng nhiều điểm hơn.

   * Anti-Spam: Để ngăn chặn việc người dùng gửi hàng loạt báo cáo chất lượng thấp nhằm phá hoại, hệ thống áp dụng:
       * Rate Limiting: Giới hạn tần suất gửi báo cáo của mỗi người dùng trên API backend.
       * Score-based Filtering: Các báo cáo từ những người dùng có điểm uy tín quá thấp (hoặc âm) có thể bị tự động bỏ qua hoặc được gán một trọng số gần bằng không trong quá trình huấn luyện.

   * Expert Dominance (Sự chi phối của Chuyên gia): Đây là nguyên tắc thiết kế quan trọng nhất. Hệ thống phân biệt rõ hai vai trò: người dùng thông thường (USER) và chuyên gia (EXPERT). Chuyên gia là những người được quản trị viên chỉ định
     và xác thực.
       * Điểm uy tín của chuyên gia được xem như vô hạn hoặc được gán một giá trị cực lớn và không đổi.
       * Trong quá trình huấn luyện lại (model/retrain_pipeline.py), mỗi mẫu dữ liệu từ phản hồi của người dùng sẽ được nhân với một trọng số tương ứng với điểm uy tín của người đó. Một phản hồi từ chuyên gia sẽ có tác động lên mô hình lớn
         hơn hàng ngàn lần so với phản hồi từ một người dùng mới. Điều này đảm bảo rằng tri thức của chuyên gia luôn là kim chỉ nam cho sự phát triển của mô hình.

  6.3. Quản trị và Kiểm duyệt (Admin Moderation)

  Đây là lớp phòng thủ cuối cùng, đảm bảo chỉ có những phản hồi chất lượng cao được đưa vào chu trình học của hệ thống.

   * Approval Workflow (Luồng công việc Chấp thuận):
       1. Tất cả phản hồi từ người dùng sẽ được đưa vào một hàng đợi "Chờ xem xét" (Pending Review).
       2. Các quản trị viên/chuyên gia sử dụng một giao diện dashboard chuyên biệt (dashboard/app.py) để truy cập vào hàng đợi này.
       3. Dashboard hiển thị đầy đủ thông tin của mỗi báo cáo, cho phép chuyên gia nhanh chóng đưa ra quyết định: Chấp thuận hoặc Từ chối.
       4. Hành động này ngay lập tức cập nhật điểm uy tín cho người dùng tương ứng.
       5. Những phản hồi được "Chấp thuận" sẽ được chuyển sang bộ dữ liệu "sạch" và sẵn sàng cho chu kỳ huấn luyện tiếp theo, được điều phối bởi Airflow (dags/weekly_retrain_dag.py).

   * Poisoning Prevention (Ngăn chặn Tấn công Đầu độc):
      Toàn bộ kiến trúc này tạo thành một hệ thống phòng thủ đa lớp vững chắc. Luồng kiểm duyệt của quản trị viên hoạt động như một bức tường lửa, ngăn chặn dữ liệu thô, chưa được kiểm chứng từ người dùng lọt vào bộ dữ liệu huấn luyện.
  Cùng lúc đó, hệ thống trọng số uy tín hoạt động như một bộ lọc thông minh, đảm bảo rằng ngay cả khi có một vài dữ liệu xấu vượt qua được tường lửa, tác động của chúng lên mô hình cũng sẽ không đáng kể. Sự kết hợp này làm cho vòng đời học
  tập của hệ thống trở nên cực kỳ mạnh mẽ trước các cuộc tấn công đầu độc, một yếu tố khác biệt hoàn toàn so với các đồ án thông thường chỉ đơn thuần huấn luyện lại trên dữ liệu mới.
