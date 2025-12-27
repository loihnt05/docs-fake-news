  Chương 5: Cơ chế Học và Ra quyết định

  Sau khi đã có các thành phần xử lý cơ bản, hệ thống cần một "bộ não" để tổng hợp thông tin, đưa ra quyết định cuối cùng và quan trọng nhất là có khảd năng tự cải thiện theo thời gian. Chương này mô tả logic ra quyết định và vòng đời học
  tập của hệ thống.

  5.1. Tại sao không sử dụng luật cứng (Hard Rules)?

  Một cách tiếp cận sơ khai để phát hiện tin giả là sử dụng một tập các luật cứng, ví dụ: "nếu bài viết chứa từ khóa X và đến từ nguồn Y thì là tin giả". Tuy nhiên, phương pháp này tỏ ra không hiệu quả trong môi trường thông tin động vì
  những lý do sau:

   * Overfitting (Quá khớp): Các luật cứng về bản chất là một dạng "ghi nhớ" các đặc điểm của tin giả đã biết trong quá khứ. Chúng bị quá khớp vào các mẫu cụ thể và không có khả năng tổng quát hóa. Kẻ xấu có thể dễ dàng thay đổi một vài từ
     ngữ hoặc phương thức biểu đạt để "lách" qua các luật này, khiến hệ thống trở nên vô dụng trước các biến thể tin giả mới.
   * False Certainty (Sự chắc chắn sai lầm): Luật cứng hoạt động theo logic nhị phân (đúng/sai tuyệt đối), chúng không có khả năng biểu thị sự không chắc chắn. Một bài báo châm biếm hoặc một bài phân tích phê bình tin giả có thể vô tình
     chứa các từ khóa nằm trong luật, dẫn đến việc bị phân loại sai một cách oan uổng. Hệ thống sẽ báo cáo kết quả với sự tự tin 100% dù nó đã sai. Điều này tạo ra sự chắc chắn sai lầm và làm xói mòn nghiêm trọng lòng tin của người dùng.
     Ngược lại, một hệ thống dựa trên xác suất có thể nói rằng: "Tôi khá chắc chắn đây là tin giả (95%)" hoặc "Tôi không chắc lắm (55%)", điều này hữu ích và trung thực hơn nhiều.

  5.2. Bộ máy quyết định (Decision Engine)

  Thay vì luật cứng, hệ thống sử dụng một bộ máy quyết định thông minh để tổng hợp các tín hiệu từ mô hình xác minh (4.4) và đưa ra kết quả cuối cùng.

   * Aggregation (Tổng hợp kết quả): Một claim có thể có nhiều bằng chứng liên quan (top-k evidence), mỗi bằng chứng lại cho một kết quả NLI (Ủng hộ, Bác bỏ, Trung lập) khác nhau. Bộ máy quyết định phải tổng hợp các tín hiệu này lại. Một
     chiến lược tổng hợp hiệu quả được áp dụng như sau:
       * Ưu tiên sự Bác bỏ (Priority of Contradiction): Chỉ cần một bằng chứng mạnh, đến từ một nguồn uy tín, cho kết quả Bác bỏ, claim đó có khả năng cao sẽ được gán nhãn FAKE. Logic này dựa trên nguyên tắc "một lời nói dối có thể làm
         hỏng cả một câu chuyện thật".
       * Cần sự đồng thuận để Ủng hộ (Consensus for Entailment): Để được gán nhãn REAL, một claim cần có sự Ủng hộ từ nhiều bằng chứng và quan trọng là không có bằng chứng nào bác bỏ nó một cách mạnh mẽ.
       * Các bằng chứng Trung lập thường được bỏ qua, trừ khi đó là loại bằng chứng duy nhất tìm được, trường hợp này sẽ dẫn đến nhãn UNDEFINED.

   * Confidence-aware Output (Đầu ra nhận biết độ tự tin): Hệ thống không chỉ trả về một nhãn REAL hay FAKE. Nó trả về một cặp (label, confidence_score). Điểm tự tin này được tính toán trực tiếp từ xác suất đầu ra (softmax) của mô hình
     NLI. Ví dụ, kết quả có thể là (FAKE, 0.95). Việc cung cấp điểm tự tin này là cực kỳ quan trọng:
       * Nó cho phép người dùng cuối hiểu được mức độ chắc chắn của hệ thống.
       * Nó cho phép các hệ thống khác (hoặc các chuyên gia) đặt ra một ngưỡng (threshold) để chỉ hành động dựa trên các kết quả có độ tự tin cao.

  5.3. Vòng đời của một nhãn (Label Lifecycle)

  Đây là phần cốt lõi thể hiện tư duy hệ thống, kết nối cơ chế "Human-in-the-loop" và "Continuous Learning". Nó mô tả cách hệ thống biến một "sự không chắc chắn" thành một "tri thức" có thể tái sử dụng. Vòng đời này là cơ chế tự cải tiến
  chính của toàn bộ hệ thống.

  UNDEFINED → (Phản hồi của con người) → REAL / FAKE

   1. Trạng thái khởi đầu: `UNDEFINED`
       * Một claim về một sự kiện nóng, vừa mới xảy ra được đưa vào hệ thống. Do sự kiện còn mới, cơ sở tri thức của hệ thống chưa có nhiều thông tin (thách thức Data Sparsity).
       * Mô hình xác minh không tìm thấy bằng chứng mạnh nào. Bộ máy quyết định (5.2) đưa ra kết luận hợp lý nhất là (UNDEFINED, 0.99).

   2. Kích hoạt Human-in-the-loop
       * Các claim được gán nhãn UNDEFINED, đặc biệt là những claim có lượng truy cập cao, sẽ tự động được đẩy vào một hàng đợi ưu tiên để các chuyên gia đánh giá. Giao diện dashboard/app.py được thiết kế cho mục đích này.

   3. Thu thập Phản hồi từ Chuyên gia
       * Một chuyên gia fact-checker sẽ nhận claim này, sử dụng các kỹ năng nghiệp vụ để điều tra và tìm ra sự thật.
       * Chuyên gia sau đó sẽ cập nhật nhãn cho claim này trong hệ thống (ví dụ, REAL) và có thể đính kèm link tới bằng chứng xác thực mà họ tìm thấy. Nhãn do chuyên gia cung cấp được xem là "sự thật vàng" (ground truth).

   4. Đóng vòng lặp & Chuẩn bị cho chu kỳ học mới
       * Cặp dữ liệu (claim, ground_truth_label) cùng với bằng chứng mới sẽ được lưu vào một bộ dữ liệu đặc biệt dành cho việc huấn luyện lại.

   5. Hệ thống tiến hóa
       * Trong chu kỳ huấn luyện tiếp theo, được điều phối bởi dags/weekly_retrain_dag.py, các mô hình (retrain_pipeline.py) sẽ được huấn luyện lại có bao gồm cả điểm dữ liệu mới, chất lượng cao này.
       * Kết quả là, hệ thống đã "học" được về sự kiện mới này. Lần tới khi một claim tương tự xuất hiện, hệ thống đã có sẵn bằng chứng trong cơ sở tri thức và mô hình NLI cũng đã được tinh chỉnh. Nó giờ đây có thể tự tin đưa ra nhãn REAL
         mà không cần đến sự can thiệp của con người nữa.
