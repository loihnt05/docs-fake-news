#set par(justify: true)
  Chương 11: Hướng phát triển trong tương lai (Future Work)

  Hệ thống hiện tại đã đặt một nền móng vững chắc cho việc kiểm chứng thông tin một cách tự động và có khả năng học hỏi. Tuy nhiên, lĩnh vực xử lý thông tin sai lệch vẫn còn rất nhiều thách thức và cơ hội. Dưới đây là những hướng phát
  triển tiềm năng để tiếp tục nâng cao năng lực và giá trị của dự án.

  11.1. Học chủ động (Active Learning)

  Hệ thống hiện tại hoạt động theo cơ chế học thụ động (passive learning), tức là nó học từ những phản hồi mà người dùng ngẫu nhiên cung cấp. Hướng đi tiếp theo là chuyển sang mô hình Học chủ động.

   * Ý tưởng: Thay vì chờ đợi, hệ thống sẽ chủ động xác định những luận điểm mà nó "phân vân" nhất (ví dụ: những claim có điểm tự tin gần ngưỡng 0.5). Sau đó, nó sẽ tự động đẩy những ca khó này vào hàng đợi ưu tiên trên `dashboard/app.py`
     để các chuyên gia gán nhãn.
   * Lợi ích: Phương pháp này tối ưu hóa nguồn lực quý giá nhất của hệ thống: thời gian của các chuyên gia. Thay vì lãng phí công sức vào việc kiểm duyệt những báo cáo dễ hoặc trùng lặp, các chuyên gia sẽ tập trung vào việc giải quyết
     những ca "hóc búa" nhất, những ca có thể mang lại nhiều thông tin nhất cho mô hình. Điều này sẽ giúp đẩy nhanh đáng kể tốc độ học và cải thiện hiệu suất tổng thể.

  11.2. Xác minh đa nguồn (Multi-source Verification)

  Bộ máy quyết định (5.2) hiện tại tổng hợp kết quả từ các bằng chứng một cách khá đơn giản. Một phiên bản nâng cao có thể thực hiện việc xác minh một cách tinh vi hơn, gần với cách làm của một nhà báo điều tra.

   * Ý tưởng:
       * Phân tích sự đa dạng của nguồn: Hệ thống sẽ kiểm tra xem các bằng chứng ủng hộ một claim đến từ nhiều nguồn độc lập hay chỉ là một nguồn tin tự trích dẫn lại chính mình. Một claim được xác nhận bởi New York Times, BBC, và Reuters
         sẽ đáng tin cậy hơn nhiều so với một claim chỉ được xác nhận bởi ba bài viết khác nhau trên cùng một blog.
       * Phân giải xung đột dựa trên uy tín nguồn: Khi có bằng chứng xung đột (một nguồn ủng hộ, một nguồn bác bỏ), thay vì chỉ gán nhãn UNDEFINED, hệ thống có thể phân tích độ uy tín của các nguồn tin để đưa ra một quyết định có trọng số.
         Bằng chứng từ một hãng thông tấn quốc tế uy tín sẽ có "sức nặng" hơn một bài viết từ một trang web vô danh.
   * Lợi ích: Giúp hệ thống đưa ra những nhận định sâu sắc và đáng tin cậy hơn, giảm số lượng các trường hợp UNDEFINED và xử lý các tình huống phức tạp một cách hiệu quả hơn.

  11.3. Mở rộng đa ngôn ngữ (Multilingual Expansion)

  Hệ thống hiện tại được tối ưu cho tiếng Việt (sử dụng `PhoBERT`). Tuy nhiên, kiến trúc module hóa cho phép nó có thể được mở rộng để hỗ trợ nhiều ngôn ngữ khác.

   * Ý tưởng:
       * Thay thế các mô hình ngôn ngữ đơn ngữ (như PhoBERT) bằng các mô hình đa ngôn ngữ mạnh mẽ (như XLM-RoBERTa hay mBERT) ở cả hai module Trích xuất Luận điểm và Xác minh.
       * Mở rộng lớp thu thập dữ liệu (scraper) để có thể thu thập tin tức từ các trang báo quốc tế.
       * Xây dựng và duy trì các cơ sở tri thức vector riêng biệt cho từng ngôn ngữ.
   * Lợi ích: Hướng đi này sẽ biến dự án từ một giải pháp cho khu vực thành một nền tảng có quy mô toàn cầu, đóng góp vào cuộc chiến chống tin giả trên phạm vi quốc tế.

  11.4. Tăng cường khả năng giải thích (Explainability - XAI)

  Để xây dựng lòng tin tuyệt đối nơi người dùng, việc chỉ đưa ra một nhãn là không đủ. Hệ thống cần phải có khả năng giải thích tại sao nó lại đưa ra quyết định đó.

   * Ý tưởng: Khi hệ thống trả về kết quả, ví dụ FAKE, giao diện trên `extension/popup.html` không chỉ hiển thị nhãn, mà còn hiển thị một đoạn trích dẫn ngắn gọn từ bằng chứng đã được dùng để bác bỏ claim.
       * Ví dụ:
           * Luận điểm: "Vaccine gây ra biến đổi gen."
           * Kết quả: FAKE (Độ tự tin: 98%)
           * Giải thích: "Luận điểm này bị bác bỏ bởi bằng chứng từ Tổ chức Y tế Thế giới (WHO): '...vaccine mRNA hoạt động trong tế bào chất và không tương tác với DNA trong nhân tế bào...'"
   * Lợi ích: Hướng phát triển này biến hệ thống từ một "hộp đen" phán xét thành một công cụ minh bạch và có tính giáo dục. Người dùng không chỉ biết thông tin là thật hay giả, mà còn hiểu được lý do tại sao, qua đó nâng cao nhận thức và
     kỹ năng kiểm chứng thông tin của chính họ.
