#set par(justify: true)

= Conclusion and Future Work

== Conclusion

Giải pháp nổi bật ở ba điểm chính. Thứ nhất, *pipeline học liên tục* được triển khai thực tế, tự động thu thập phản hồi, huấn luyện lại và cập nhật mô hình mà không gián đoạn hệ thống. Thứ hai, *cơ chế phản hồi có trọng số theo độ uy tín*, giúp tận dụng tri thức chuyên gia và giảm tác động của nhiễu hoặc tấn công đầu độc dữ liệu. Thứ ba, *kiến trúc hybrid streaming–batch* tách biệt suy luận thời gian thực và huấn luyện theo lô, đảm bảo vừa phản hồi nhanh cho người dùng vừa cải thiện mô hình dài hạn.

Về ý nghĩa thực tiễn, hệ thống hỗ trợ cá nhân kiểm chứng thông tin nhanh chóng, góp phần giảm lan truyền tin giả ở cấp cộng đồng, đồng thời cung cấp dữ liệu giá trị cho nghiên cứu và hoạch định chính sách. Ở góc độ khoa học, đề tài đưa ra một mô hình tham chiếu cho các hệ thống AI cần thích ứng với trôi dạt dữ liệu và kết hợp hiệu quả giữa trí tuệ máy và con người.

== Future Work

=== Học chủ động
Thay vì học thụ động từ phản hồi ngẫu nhiên, hệ thống sẽ ưu tiên các luận điểm mà mô hình còn thiếu chắc chắn. Những trường hợp “biên giới” này được đưa cho chuyên gia kiểm duyệt trước, giúp tối ưu hóa thời gian con người và cải thiện nhanh chất lượng mô hình, đặc biệt ở các vùng dữ liệu khó.

=== Xác minh đa nguồn có trọng số
Thay vì đếm số lượng bằng chứng, hệ thống tương lai sẽ đánh giá *độ uy tín và tính độc lập của nguồn tin*. Các nguồn đáng tin (tổ chức khoa học, báo chí chính thống) sẽ có trọng số cao hơn nguồn không rõ ràng. Điều này giúp xử lý tốt các trường hợp bằng chứng xung đột và giảm phụ thuộc vào số lượng thuần túy.

=== Thứ ba, mở rộng đa ngôn ngữ
Bằng cách sử dụng mô hình ngôn ngữ đa ngôn ngữ (như XLM-R), hệ thống có thể hỗ trợ nhiều ngôn ngữ ngoài tiếng Việt. Kiến trúc module hóa cho phép mở rộng thu thập dữ liệu, cơ sở tri thức và xác minh xuyên ngôn ngữ, từ đó phát hiện các chiến dịch tin giả lan truyền toàn cầu.

=== Thứ tư, tăng cường khả năng giải thích
Mỗi phán quyết sẽ đi kèm trích dẫn bằng chứng cụ thể và nguồn gốc, giúp người dùng hiểu lý do kết luận. Điều này nâng cao lòng tin, hỗ trợ giáo dục tư duy phản biện, đồng thời giúp đội phát triển phân tích lỗi và cải thiện mô hình.

