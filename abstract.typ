#align(center, text(
  size: 20pt,
  weight: "bold",
block[
  TÓM TẮT
]))
#set par(justify: true)

  #strong[Bài toán]
  Trong kỷ nguyên số, sự bùng nổ của mạng xã hội và các phương tiện truyền thông trực tuyến đã tạo ra một môi trường lan truyền thông tin với tốc độ chóng mặt. Tuy nhiên, mặt trái của nó là sự gia tăng của thông tin sai lệch
  (misinformation) và tin giả (fake news), gây ra những hệ lụy nghiêm trọng cho xã hội, từ chính trị, kinh tế đến sức khỏe cộng đồng. Đối với người dùng cuối, việc xác minh tính xác thực của một thông tin đòi hỏi nhiều thời gian và kỹ
  năng, trong khi các công cụ hiện có thường tập trung vào ngôn ngữ tiếng Anh và không đủ nhanh nhạy để đối phó với bối cảnh tin tức thay đổi liên tục tại Việt Nam.

  Bài toán đặt ra là xây dựng một hệ thống kiểm chứng thông tin (fact-checking) toàn diện, tự động và đáng tin cậy dành riêng cho không gian mạng tiếng Việt. Hệ thống cần có khả năng:
   - Thu thập và xử lý một lượng lớn dữ liệu từ nhiều nguồn tin tức.
   - Phân tích và xác định các luận điểm (claims) cần kiểm chứng trong một bài viết.
   - Tìm kiếm và đối chiếu với các nguồn tin xác thực để đưa ra kết luận.
   - Cung cấp kết quả kiểm chứng cho người dùng một cách trực quan và kịp thời.

  #strong[Cách tiếp cận]

  Để giải quyết bài toán phức tạp này, dự án áp dụng một cách tiếp cận đa thành phần, xây dựng một pipeline xử lý tự động từ đầu đến cuối (end-to-end), bao gồm các module chính sau:

   1. Module Thu thập Dữ liệu (Crawler & Scraper): Sử dụng các producer và consumer (trong thư mục crawler/ và processor/), hệ thống liên tục thu thập dữ liệu bài viết mới từ các trang tin tức, blog và mạng xã hội. Tác vụ này được lên lịch
      và điều phối tự động bằng Apache Airflow (dags/daily_crawl_dag.py), đảm bảo nguồn dữ liệu luôn được cập nhật.

   2. Module Trích xuất Luận điểm (Claim Extraction): Thay vì phân loại toàn bộ bài viết là thật hay giả, hệ thống đi sâu vào việc xác định các luận điểm cụ thể, có thể kiểm chứng được. Dựa trên các mô hình như phobert_claim_extractor,
      module này sẽ quét qua văn bản và rút ra những câu, mệnh đề chứa thông tin cần xác thực.

   3. Module Truy xuất Chứng cứ (Evidence Retrieval): Với mỗi luận điểm được trích xuất, hệ thống sử dụng một cơ sở tri thức (knowledge base) lớn được xây dựng từ các nguồn tin uy tín. Bằng cách tận dụng cơ sở dữ liệu vector
      (dataset/build_vector_db.py), hệ thống có thể tìm kiếm các bài viết, đoạn văn bản liên quan (chứng cứ) một cách cực kỳ nhanh chóng và hiệu quả dựa trên sự tương đồng về ngữ nghĩa.

   4. Module Xác thực (Verification): Đây là lõi của hệ thống. Một mô hình Suy luận Ngôn ngữ Tự nhiên (Natural Language Inference - NLI) được huấn luyện (model/retrain_nli.py) để xác định mối quan hệ giữa luận điểm và chứng cứ tìm được.
      Kết quả sẽ là một trong ba loại: Ủng hộ (Entailment), Bác bỏ (Contradiction), hoặc Trung lập (Neutral). Dựa trên kết quả này, hệ thống sẽ đưa ra đánh giá tổng thể về tính xác thực của luận điểm.

   5. Giao diện người dùng (User Interface): Kết quả kiểm chứng được cung cấp cho người dùng thông qua một tiện ích mở rộng (extension) trên trình duyệt (extension/popup.html, popup.js), cho phép họ kiểm tra thông tin ngay trên trang web
      đang đọc.

  #strong[Đóng góp chính]

  Dự án mang lại những đóng góp quan trọng và khác biệt:

   1. Hệ thống End-to-End tự động cho tiếng Việt: Xây dựng một pipeline hoàn chỉnh từ thu thập dữ liệu, xử lý, phân tích đến trả kết quả, được thiết kế chuyên biệt cho đặc thù của ngôn ngữ và bối cảnh thông tin tại Việt Nam (ví dụ: sử dụng
      PhoBERT).

   2. Kiến trúc Học liên tục (Continuous Learning): Đây là một trong những điểm cốt lõi của hệ thống. Thông qua việc sử dụng Apache Airflow để tự động hóa các quy trình (dags/weekly_retrain_dag.py), hệ thống không bị lỗi thời. Nó liên tục
      cập nhật cơ sở tri thức với tin tức mới và quan trọng hơn là tự động huấn luyện lại (retrain) các mô hình học máy định kỳ. Điều này giúp hệ thống thích ứng với các chủ đề mới, các dạng tin giả mới và ngày càng trở nên chính xác hơn
      theo thời gian.

   3. Tích hợp Con người trong vòng lặp (Human-in-the-Loop): Để giải quyết tính phức tạp và sự tinh vi của thông tin, hệ thống không hoàn toàn phụ thuộc vào máy móc. Thông qua các giao diện (như extension hoặc dashboard nội bộ), người dùng
      hoặc các chuyên gia fact-checker có thể cung cấp phản hồi về các kết quả của mô hình. Phản hồi này (ví dụ: một kết luận bị đánh giá sai) sẽ được thu thập và trở thành dữ liệu vàng để đưa vào chu trình huấn luyện lại tiếp theo. Cơ chế
      này tạo ra một vòng lặp cải tiến liên tục, giúp hệ thống học hỏi từ chính những sai sót của mình và ngày càng thông minh hơn.

   4. Phương pháp xác thực dựa trên Luận điểm và Chứng cứ: Thay vì cách tiếp cận phân loại nhị phân "thật/giả" đơn giản, hệ thống áp dụng một quy trình tinh vi hơn: trích xuất luận điểm, tìm kiếm chứng cứ và suy luận logic. Cách làm này
      gần với quy trình làm việc của các fact-checker chuyên nghiệp, giúp tăng tính minh bạch và độ tin cậy của kết quả.

  #strong[Kết quả sơ bộ]

   - Hệ thống đã triển khai thành công pipeline thu thập dữ liệu tự động, có khả năng xử lý hàng ngàn bài viết mỗi ngày từ nhiều nguồn đa dạng.
   - Mô hình trích xuất luận điểm và mô hình NLI cho thấy độ chính xác đầy hứa hẹn trên các tập dữ liệu thử nghiệm, chứng minh tính hiệu quả của việc sử dụng các mô hình ngôn ngữ lớn cho tiếng Việt.
   - Cơ sở dữ liệu vector cho phép truy xuất chứng cứ với tốc độ phản hồi dưới một giây, đáp ứng yêu cầu kiểm chứng trong thời gian thực.
   - Sản phẩm mẫu (prototype) dưới dạng extension trình duyệt đã hoạt động ổn định, chứng minh tính khả thi của việc đưa một công cụ fact-checking mạnh mẽ đến tay người dùng cuối một cách tiện lợi.

  Nhìn chung, dự án đã xây dựng thành công một nền tảng vững chắc cho một hệ thống phát hiện tin giả thông minh, có khả năng tự cải tiến và thích ứng, hứa hẹn trở thành một công cụ hữu ích trong cuộc chiến chống lại thông tin sai lệch tại
  Việt Nam.