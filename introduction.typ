
#set par(justify: true)

= Giới thiệu

== Giới thiệu đề tài

Sự phát triển mạnh của mạng xã hội tại Việt Nam kéo theo vấn đề lan truyền tin giả ngày càng nghiêm trọng. Các phương pháp kiểm duyệt thủ công hoặc mô hình máy học tĩnh không còn đủ khả năng theo kịp môi trường thông tin luôn thay đổi.

Đề tài này đề xuất xây dựng *hệ thống thông minh phát hiện và xác minh thông tin tiếng Việt* có khả năng *học liên tục*, tự thích ứng với các xu hướng và chiến thuật tin giả mới.

== Bối cảnh

Tin giả lan truyền với tốc độ rất cao trên mạng xã hội, trong khi quy trình fact-checking truyền thống tốn thời gian và khó mở rộng. Các chiến dịch thông tin sai lệch ngày càng tinh vi, liên tục thay đổi nội dung và cách biểu đạt để né tránh hệ thống phát hiện.


== Vấn đề cốt lõi

Môi trường thông tin luôn biến động khiến *mô hình học máy tĩnh nhanh chóng lỗi thời*. Khi xuất hiện sự kiện mới, thuật ngữ mới hoặc cách diễn đạt mới, hiệu suất phát hiện tin giả suy giảm rõ rệt. Do đó cần một hệ thống có khả năng *cập nhật kiến thức liên tục*.


== Mục tiêu nghiên cứu

1. *Xây dựng pipeline tự động* phát hiện và xác minh thông tin tiếng Việt: trích xuất luận điểm, tìm chứng cứ từ nguồn tin cậy và đưa ra kết luận.
2. *Triển khai cơ chế học liên tục*, cho phép mô hình tự cập nhật khi có dữ liệu mới.
3. *Tích hợp human-in-the-loop*, tận dụng phản hồi từ người dùng và chuyên gia để cải thiện hệ thống.

#image("images/info-overload.jpg", width: 400pt)
