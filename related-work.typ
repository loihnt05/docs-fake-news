#set par(justify: true)

= Các nghiên cứu liên quan 
== Tình hình nghiên cứu trên thế giới
Tính đến thời điểm hiện tại, nghiên cứu về nhận diện sự tin cậy của tin tức trên mạng
xã hội đã chủ yếu tập trung vào việc sử dụng các phương pháp giám sát, trong khi
các phương pháp bán giám sát hoặc không giám sát ít được áp dụng. Các mô hình
sau là những mô hình phân loại thường được sử dụng trong các bài toán:
Phương pháp học máy truyền thống: Các mô hình phân loại phổ biến như Máy Vector
Hỗ Trợ (SVM) hay Mô Hình Phân loại Naive Bayes (NBC) thường được sử dụng và
thường được coi là các mô hình cơ sở. Đôi khi, các mô hình như cây quyết định như
Random Forest Classifier (RFC) và hồi quy Logistic (LR) và cũng được sử dụng
trong bài toán.
Phương pháp học sâu: Mô hình Mạng Nơ-ron Tái Phát (RNN) đặc biệt là Long Short-
Term Memory (LSTM) hay Gate Recurrent-Unit (GRU) đã chiếm vị trí quan trọng.
Sự phổ biến của LSTM trong lĩnh vực xử lý ngôn ngữ tự nhiên (NLP) đồng nghĩa với
khả năng giải quyết vấn đề biến mất độ dốc, từ đó, mô hình có khả năng nắm bắt được
các phụ thuộc dài hạn trong ngôn ngữ. Các nghiên cứu tiên tiến đã chứng minh hiệu
suất ưu việt của các mô hình dựa trên LSTM khi áp dụng cho các tập dữ liệu như
LIAR và FEVER. Ngoài ra, Mạng Nơ-ron tích chập (CNN) cũng là một lựa chọn phổ
biến, đặc biệt là trong việc xử lý các nhiệm vụ phân loại văn bản. Các mô hình sử
dụng CNN, như mô hình dựa trên công trình của Kim (2014), đã đạt hiệu suất ấn
tượng. Đặc biệt, việc kết hợp các biểu diễn văn bản từ LSTM hai chiều cùng với CNN
đã mang lại kết quả tốt. Các cơ chế chú ý (Attention Mechanisms) thường được tích
hợp vào mô hình mạng nơ-ron để cải thiện khả năng hiểu bài toán và từ đó cải thiện
hiệu suất.
Tiếp Cận Rhetorical: Lý thuyết Cấu Trúc Tu từ (RST), đôi khi kết hợp với Mô Hình
Không Gian Vector (VSM), cũng được áp dụng để nhận diện tin giả. RST là một
khung phân tích cho tính nhất quán của một câu chuyện và thông qua định nghĩa vai
trò ngữ nghĩa của các đơn vị văn bản, nó có thể xác định ý chính và phân tích đặc
14
tính của văn bản đầu vào. Phương pháp này đưa ra kết quả bằng cách sử dụng VSM
để chuyển đổi văn bản tin tức thành vector, sau đó so sánh chúng với trung tâm của
tin tức đúng và tin tức giả trong không gian RST nhiều chiều.
Thu Thập Bằng Chứng: Phương pháp dựa trên Nhận Diện Văn Bản Trình Bày (RTE)
thường được sử dụng để thu thập và sử dụng bằng chứng. RTE là nhiệm vụ nhận diện
mối quan hệ giữa các câu. Bằng cách thu thập các câu ủng hộ hoặc phản đối từ nguồn
dữ liệu như bài báo, chúng ta có thể dự đoán xem thông tin đầu vào có đúng hay
không. Phương pháp này yêu cầu có bằng chứng văn bản để kiểm tra sự đúng đắn,
do đó chỉ thích hợp khi tập dữ liệu bao gồm bằng chứng, như FEVER và Emergent.
Bảng mô tả kết quả hiện tại của một số nghiên cứu trên tập dữ liệu LIAR. Các kết
quả này thể hiện hiệu suất của các mô hình, bao gồm cả mô hình sử dụng SVMs,
CNNs, LSTM, và các mô hình kết hợp khác nhau.
với một số mô hình đạt độ chính xác khá cao. Tuy nhiên, vẫn còn nhiều thách thức
và cơ hội nghiên cứu mà các nhóm nghiên cứu đang tập trung giải quyết.

#image("images/related-world.png", width: 400pt)

== Tình hình nghiên cứu ở Việt Nam
Hiện nay, việc xác định sự chính xác của thông tin trên mạng và trên các trang tin tức
ở Việt Nam ngày càng trở nên phổ biến và quan trọng hơn. Các tổ chức và trường đại
học ở Việt Nam đang tích cực tham gia vào việc nghiên cứu vấn đề này. Môi trường
truyền thông xã hội và các trang tin tức đang đăng tải thông tin một cách không rõ
ràng, gây hiện tượng thông tin thật và tin giả giao nhau. Sự cần thiết của việc giải
quyết bài toán này ở Việt Nam đang ngày càng tăng lên.
VLSP 2020 [2] tổ chức một cuộc thi về phát hiện tin giả, với mục tiêu đánh giá tính
đáng tin cậy của thông tin được chia sẻ trên mạng xã hội Việt Nam. Cuộc thi này
cung cấp cơ hội cho các cá nhân quan tâm đến vấn đề này, để góp phần nâng cao tri
thức và cải thiện môi trường trực tuyến vì mục tiêu xã hội tốt đẹp. Trong cuộc thi,
nhóm của Hieu Cao-Nguyen-Minh đã đoạt giải với điểm cao nhất trên tập dữ liệu
kiểm thử riêng tư, sử dụng phương pháp Weighted ensemble SVM + LightGBM và
đạt được điểm AUC là 0.9523. Nhóm tác giả đã tiến hành phân tích các đặc trưng
như nội dung, số lượt thích, lượt bình luận và thời gian đăng bài viết để đạt được kết
quả này.
Gần đây, nhóm của Khoa Dang-Pham cũng đã cố gắng cải thiện này giới thiệu một
phương pháp kết hợp sử dụng mô hình ngôn ngữ được huấn luyện trước gọi là
vELECTRA kết hợp với các đặc trưng được tạo bằng tay để nhận diện thông tin đáng
tin cậy trên các trang mạng xã hội tại Việt Nam. Nghiên cứu này sử dụng hai phương
pháp chính, bao gồm: điều chỉnh mô hình bằng việc sử dụng dữ liệu văn bản một
16
cách độc lập và kết hợp thông tin siêu dữ liệu bổ sung với văn bản để tạo biểu diễn
đầu vào cho mô hình. Kết quả của phương pháp này cho kết quả nhỉnh hơn so với các
phương pháp BERT tinh chỉnh khác và đạt được kết quả tốt nhất trên tập dữ liệu
ReINTEL được công bố bởi VLSP năm 2020 với thang đo AUC đạt 0.9575.
#image("images/related-vnvn.png", width: 400pt)
