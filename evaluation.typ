  Chương 8: Thiết lập Thử nghiệm và Đánh giá (Experimental Setup & Evaluation)

  Một hệ thống phức tạp không thể chứng minh được giá trị của nó nếu không có một quy trình đánh giá và đo lường chặt chẽ. Chương này trình bày về các bộ dữ liệu được sử dụng, các chỉ số đo lường hiệu suất, và các phân tích chuyên sâu để
  kiểm chứng giả thuyết cốt lõi: hệ thống có khả năng học liên tục và chống lại hiện tượng trôi dạt khái niệm.

  8.1. Bộ dữ liệu (Dataset)

  Hệ thống sử dụng hai loại dữ liệu chính cho việc huấn luyện và đánh giá:

   * Initial Data (Dữ liệu Khởi tạo): Để xây dựng phiên bản mô hình đầu tiên (v0), chúng tôi đã tổng hợp một bộ dữ liệu "hạt giống". Dữ liệu này đến từ hai nguồn: (1) Các bộ dữ liệu công khai về kiểm chứng tin tức tiếng Việt (nếu có) và
     (2) Dữ liệu được đội ngũ dự án thu thập (scraper-fake-news) và gán nhãn thủ công trong giai đoạn đầu. Các kịch bản như scripts/generate_nli_data.py cũng được sử dụng để tăng cường bán tự động bộ dữ liệu suy luận ngôn ngữ (NLI) ban
     đầu.

   * User Reports (Dữ liệu từ Báo cáo Người dùng): Đây là nguồn dữ liệu sống, liên tục phát triển, được thu thập từ hệ thống Phản hồi & Độ uy tín (Chương 6). Sau mỗi chu kỳ (ví dụ: hàng tuần), tập hợp các báo cáo đã được "Chấp thuận" sẽ
     được chia thành hai phần:
       * Training Set (80%): Được sử dụng để huấn luyện lại và tạo ra phiên bản mô hình tiếp theo.
       * Evaluation Set (20%): Được giữ lại, không dùng để huấn luyện. Bộ dữ liệu này dùng để đánh giá hiệu suất của các phiên bản mô hình trong tương lai, đảm bảo việc so sánh được công bằng.

  8.2. Các chỉ số đo lường (Metrics)

  Chúng tôi sử dụng một bộ các chỉ số để có cái nhìn toàn diện về hiệu suất của hệ thống.

   * Accuracy (Độ chính xác tổng thể): Tỷ lệ phần trăm các dự đoán đúng trên tổng số dự đoán. Đây là chỉ số cơ bản nhưng có thể gây hiểu nhầm nếu dữ liệu mất cân bằng.

   * Precision / Recall / F1-Score: Các chỉ số này đặc biệt quan trọng để đánh giá lớp FAKE.
       * Precision (Độ chuẩn xác): Trong tất cả các claim bị hệ thống gán nhãn FAKE, có bao nhiêu claim thực sự là FAKE? Precision cao thể hiện hệ thống không "kết tội" nhầm, yếu tố then chốt để giữ vững niềm tin của người dùng.
       * Recall (Độ phủ): Trong tất cả các claim FAKE có trong thực tế, hệ thống đã phát hiện được bao nhiêu? Recall cao thể hiện khả năng "bắt" tin giả của hệ thống.
       * F1-Score: Trung bình điều hòa của Precision và Recall, cho một con số duy nhất đại diện cho sự cân bằng giữa hai chỉ số trên.

   * Stability Over Time (Độ ổn định theo thời gian): Đây là chỉ số đo lường khả năng chống lại Concept Drift.
       * Phương pháp: Chúng tôi giữ lại một bộ dữ liệu kiểm thử "vàng" (golden test set) cố định qua nhiều tháng. Sau mỗi chu kỳ huấn luyện lại, phiên bản mô hình mới nhất (v1, v2, ... vN) sẽ được đánh giá trên bộ dữ liệu vàng này.
       * Biểu đồ kỳ vọng: Nếu vẽ một biểu đồ đường với trục hoành là thời gian (tuần 1, 2, ... N) và trục tung là F1-Score, một hệ thống không có học liên tục sẽ cho thấy đường F1-Score giảm dần theo thời gian (mô hình ngày càng lỗi thời).
         Ngược lại, hệ thống của chúng tôi được kỳ vọng sẽ cho một đường F1-Score đi ngang hoặc tăng nhẹ, chứng tỏ pipeline học liên tục đang hoạt động hiệu quả, giúp mô hình duy trì và thậm chí cải thiện hiệu suất của nó.

  8.3. Phân tích Hiện tượng Trôi dạt Khái niệm (Concept Drift Analysis)

  Đây là các thử nghiệm cụ thể để chứng minh giá trị của việc huấn luyện lại định kỳ.

   * So sánh Trước và Sau khi Huấn luyện lại:
       * Phương pháp: Vào cuối mỗi tuần, chúng tôi lấy toàn bộ dữ liệu mới thu thập trong tuần đó làm một bộ kiểm thử tạm thời. Đầu tiên, chúng tôi dùng mô hình của tuần trước (v(N-1)) để đánh giá trên bộ dữ liệu này. Sau đó, chúng tôi
         chạy pipeline huấn luyện lại để tạo ra mô hình mới (vN) và cũng đánh giá nó trên cùng bộ dữ liệu đó.
       * Biểu đồ kỳ vọng: Một biểu đồ cột sẽ được sử dụng để so sánh F1-Score của v(N-1) và vN. Kết quả được kỳ vọng là cột "Sau khi Retrain" sẽ cao hơn đáng kể so với cột "Trước khi Retrain". Biểu đồ này trực quan hóa lợi ích tức thời của
         việc học hỏi từ dữ liệu mới, cho thấy mô hình đã nhanh chóng thích ứng với các chủ đề và khái niệm mới của tuần đó.

   * Nghiên cứu Tình huống một Tin giả mới (Case Study):
      Chúng tôi thực hiện một nghiên cứu tình huống định tính để mô tả toàn bộ vòng đời phản ứng của hệ thống.
       1. Ngày 1: Một chiến dịch tin giả mới về chủ đề "Y" xuất hiện. Mô hình hiện tại vN chưa từng gặp loại tin này, do đó nó phân loại sai nhiều claim, hoặc gán nhãn UNDEFINED.
       2. Ngày 2-5: Người dùng và các chuyên gia bắt đầu báo cáo các lỗi sai này thông qua extension và dashboard. Hệ thống Phản hồi & Độ uy tín ghi nhận và kiểm duyệt các báo cáo này.
       3. Ngày 6 (Cuối tuần): Pipeline dags/weekly_retrain_dag.py được kích hoạt. Nó sử dụng các báo cáo đã được duyệt về chủ đề "Y" để huấn luyện lại mô hình.
       4. Ngày 7: Mô hình mới v(N+1) được tạo ra và triển khai.
       5. Ngày 8: Khi các tin giả tương tự về chủ đề "Y" xuất hiện, mô hình v(N+1) giờ đây đã có thể nhận diện chúng một cách chính xác với độ tự tin cao.

      Tình huống này kể một câu chuyện hoàn chỉnh: từ lúc hệ thống thất bại, sau đó học hỏi từ chính sai lầm của mình thông qua phản hồi của con người, và cuối cùng là tiến hóa để trở nên mạnh mẽ hơn. Đây chính là minh chứng thuyết phục
  nhất cho sức mạnh của kiến trúc học liên tục đã được thiết kế.
