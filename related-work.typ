#set par(justify: true)

= Các nghiên cứu liên quan

== Tình hình nghiên cứu trên thế giới

Các nghiên cứu phát hiện tin giả trên mạng xã hội chủ yếu sử dụng *học có giám sát*, trong khi phương pháp bán giám sát và không giám sát còn hạn chế.

*Học máy truyền thống* như SVM, Naive Bayes, Logistic Regression, Random Forest thường được dùng làm mô hình cơ sở.

*Học sâu* giữ vai trò chủ đạo với RNN, LSTM, GRU nhờ khả năng nắm bắt ngữ cảnh dài hạn. CNN cũng phổ biến trong phân loại văn bản. Nhiều nghiên cứu kết hợp BiLSTM + CNN và cơ chế Attention để tăng hiệu quả. Các mô hình này đạt kết quả tốt trên các bộ dữ liệu như LIAR, FEVER.

*Tiếp cận tu từ (RST)* phân tích cấu trúc diễn ngôn của văn bản để xác định tính nhất quán và vai trò ngữ nghĩa, sau đó biểu diễn văn bản dưới dạng vector để phân loại.

*Thu thập bằng chứng* dựa trên bài toán Nhận diện Quan hệ Văn bản (RTE/NLI), tìm các câu ủng hộ hoặc phản bác từ nguồn tin cậy để xác minh thông tin. Phương pháp này hiệu quả khi có tập dữ liệu kèm chứng cứ như FEVER.

Dù nhiều mô hình đạt độ chính xác cao, vấn đề thích ứng với môi trường thông tin thay đổi liên tục vẫn còn là thách thức.

#image("images/related-world.png", width: 400pt)


== Tình hình nghiên cứu ở Việt Nam

Tại Việt Nam, nghiên cứu phát hiện tin giả ngày càng được quan tâm do sự pha trộn giữa tin thật và tin sai trên mạng xã hội.

Cuộc thi *VLSP 2020* về phát hiện tin giả là dấu mốc quan trọng. Nhóm Cao-Nguyen-Minh đạt AUC 0.9523 với mô hình ensemble SVM + LightGBM, khai thác cả nội dung và đặc trưng mạng xã hội (like, comment, thời gian đăng).

Một hướng tiếp cận gần đây sử dụng *mô hình ngôn ngữ tiền huấn luyện vELECTRA* kết hợp đặc trưng thủ công và siêu dữ liệu. Phương pháp này đạt AUC 0.9575 trên tập ReINTEL, vượt nhiều mô hình BERT tinh chỉnh.

Nhìn chung, các nghiên cứu trong nước đã đạt kết quả tốt nhưng vẫn chủ yếu dựa trên mô hình tĩnh, chưa tập trung mạnh vào cơ chế học liên tục.

#image("images/related-vnvn.png", width: 400pt)

