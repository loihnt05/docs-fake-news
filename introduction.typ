#set par(justify: true)

= Giới thiệu

== Giới thiệu đề tài

Trong bối cảnh công nghệ thông tin phát triển mạnh mẽ, mạng xã hội đã trở thành kênh truyền thông chính cho hàng triệu người Việt Nam. Tuy nhiên, cùng với những lợi ích to lớn, không gian mạng cũng trở thành môi trường màu mỡ cho sự lan truyền của thông tin sai lệch và tin giả. Đề tài nghiên cứu này tập trung vào việc phát triển một hệ thống thông minh có khả năng tự động phát hiện và xác minh thông tin trên không gian mạng tiếng Việt. Khác với các phương pháp truyền thống dựa vào kiểm duyệt thủ công hay các mô hình máy học tĩnh, hệ thống được đề xuất có khả năng học liên tục và thích ứng với môi trường thông tin luôn thay đổi. Điều này đặc biệt quan trọng trong bối cảnh các chiến dịch thông tin giả ngày càng tinh vi và biến đổi không ngừng.

== Bối cảnh
Tin giả đang gia tăng với tốc độ báo động trên không gian mạng tiếng Việt. Sự bùng nổ của mạng xã hội đã tạo ra một môi trường mà thông tin có thể lan truyền với quy mô và tốc độ chưa từng có, vượt xa khả năng xử lý của bất kỳ phương pháp kiểm duyệt thủ công nào. Điều đáng lo ngại hơn là các chiến dịch tung tin giả ngày càng trở nên tinh vi và có tổ chức. Chúng liên tục thay đổi chủ đề, điều chỉnh phương thức lan truyền và thay đổi sắc thái biểu đạt để né tránh các công cụ phát hiện. Trong khi đó, quy trình fact-checking truyền thống dựa vào các nhà báo và chuyên gia, mặc dù đáng tin cậy về mặt chất lượng, nhưng lại tốn rất nhiều thời gian và nguồn lực, khiến nó không thể mở rộng quy mô để đáp ứng luồng thông tin khổng lồ xuất hiện mỗi ngày.

== Vấn đề cốt lõi

Trung tâm của thách thức này nằm ở một thực tế đơn giản nhưng quan trọng: các mô hình tĩnh không thể tồn tại lâu dài trong môi trường thông tin động. Hãy tưởng tượng một mô hình máy học được huấn luyện vào tháng Một để phát hiện tin giả về một chủ đề cụ thể. Đến tháng Sáu, khi các sự kiện mới diễn ra, thuật ngữ mới xuất hiện và chiến thuật lan truyền thông tin sai lệch thay đổi, mô hình đó sẽ nhanh chóng trở nên lỗi thời. Hiệu suất của nó suy giảm nghiêm trọng theo thời gian, dẫn đến việc người dùng mất niềm tin vào hệ thống. Đây chính là vấn đề mà nghiên cứu này hướng đến giải quyết.

== Mục tiêu nghiên cứu
Để giải quyết căn bản vấn đề trên, dự án đặt ra ba mục tiêu nghiên cứu chính, mỗi mục tiêu đóng vai trò như một trụ cột hỗ trợ cho cả hệ thống.

Mục tiêu đầu tiên là xây dựng một pipeline tự động có khả năng phát hiện và xác minh thông tin một cách thông minh. Pipeline này cần có khả năng đọc hiểu văn bản tiếng Việt, trích xuất ra những luận điểm cần được kiểm chứng, sau đó tự động tìm kiếm bằng chứng từ các nguồn tin cậy và đưa ra kết luận về tính đúng đắn của thông tin. Quá trình này cần diễn ra nhanh chóng để có thể xử lý khối lượng lớn thông tin trong thời gian thực.

Mục tiêu thứ hai tập trung vào khả năng học liên tục từ dữ liệu mới. Thay vì huấn luyện một lần rồi để mô hình hoạt động mãi mãi như các hệ thống truyền thống, hệ thống này cần có kiến trúc cho phép tự động cập nhật kiến thức và cải thiện các mô hình học máy khi có dữ liệu mới xuất hiện. Điều này đảm bảo hệ thống luôn bắt kịp với thực tại đang thay đổi, giống như cách một người liên tục học hỏi từ kinh nghiệm mới.

Mục tiêu thứ ba là tận dụng sức mạnh của yếu tố con người thông qua cơ chế "human-in-the-loop". Hệ thống cần có khả năng thu thập và học hỏi từ phản hồi của người dùng cuối cũng như các chuyên gia trong lĩnh vực. Bằng cách này, tri thức và kinh nghiệm của con người trở thành một phần không thể tách rời của quá trình cải thiện hệ thống, tạo ra một vòng lặp học tập tích cực.

== Tính ứng dụng

Hệ thống được đề xuất mang lại giá trị ứng dụng thiết thực trên nhiều phương diện. Về mặt xã hội, nó góp phần bảo vệ cộng đồng mạng khỏi những tác hại của tin giả, đặc biệt trong các lĩnh vực nhạy cảm như sức khỏe, chính trị và kinh tế. Người dùng thông thường có thể sử dụng extension trình duyệt để kiểm tra nhanh độ tin cậy của thông tin họ đọc trên mạng xã hội, giúp họ đưa ra quyết định sáng suốt hơn. Các tổ chức truyền thông và báo chí có thể tích hợp hệ thống vào quy trình biên tập để kiểm tra thông tin nhanh chóng trước khi công bố. Các nền tảng mạng xã hội cũng có thể sử dụng hệ thống để tự động gắn cảnh báo hoặc hạn chế lan truyền các nội dung có khả năng chứa thông tin sai lệch. Từ góc độ nghiên cứu, kiến trúc học liên tục được đề xuất có thể được áp dụng cho nhiều bài toán khác ngoài phát hiện tin giả, mở ra hướng nghiên cứu mới cho các hệ thống AI cần thích ứng với môi trường thay đổi liên tục.

== Thách thức

Phát triển một hệ thống như vậy đặt ra nhiều thách thức kỹ thuật và thực tiễn đáng kể. Thách thức lớn nhất là cân bằng giữa tốc độ xử lý thời gian thực và độ chính xác của kết quả xác minh. Một hệ thống quá nhanh có thể cho kết quả không chính xác, trong khi một hệ thống quá chậm sẽ không đáp ứng được nhu cầu thực tế. Việc xử lý ngôn ngữ tiếng Việt cũng mang đến những khó khăn riêng do tính phức tạp về ngữ nghĩa, đa nghĩa của từ và cách diễn đạt linh hoạt. Hơn nữa, việc duy trì chất lượng dữ liệu huấn luyện là một thách thức liên tục - hệ thống cần có cơ chế lọc và đánh giá độ tin cậy của dữ liệu mới để tránh học từ những thông tin sai lệch. Chi phí tính toán cho việc huấn luyện lại mô hình thường xuyên cũng cần được tối ưu hóa để hệ thống có thể hoạt động bền vững. Cuối cùng, việc thiết kế giao diện và quy trình thu thập phản hồi từ người dùng sao cho họ sẵn lòng tham gia và đóng góp tri thức cũng đòi hỏi sự cân nhắc kỹ lưỡng về trải nghiệm người dùng.

== Đóng góp

Để vượt qua những thách thức nêu trên và đạt được các mục tiêu nghiên cứu, dự án mang lại ba đóng góp khoa học và kỹ thuật chính.

Đóng góp đầu tiên là việc đề xuất và hiện thực hóa một pipeline kiểm chứng thông tin tự động với khả năng học liên tục thực sự. Chúng tôi xây dựng một hệ thống khép kín được điều phối bởi Apache Airflow, trong đó các giai đoạn xử lý được tổ chức thành các luồng công việc có thể theo dõi và quản lý. Pipeline bắt đầu từ việc thu thập dữ liệu hàng ngày, sau đó trích xuất các luận điểm cần kiểm chứng từ văn bản, truy xuất chứng cứ từ cơ sở tri thức vector, và cuối cùng sử dụng mô hình NLI để xác minh. Điểm đột phá nằm ở quy trình huấn luyện lại hàng tuần tự động sử dụng dữ liệu mới và các phản hồi thu thập được để cập nhật các mô hình, đảm bảo hệ thống không bao giờ ngừng tiến hóa và thích ứng với môi trường mới.

Đóng góp thứ hai là thiết kế kiến trúc hybrid độc đáo kết hợp xử lý luồng và huấn luyện lại theo lô. Kiến trúc này hoạt động ở hai chế độ song song nhưng bổ trợ cho nhau. Ở chế độ streaming, các thành phần producer và consumer xử lý các bài viết mới ngay khi chúng xuất hiện, cho phép người dùng nhận được kết quả xác minh gần như ngay lập tức thông qua extension trình duyệt. Đồng thời, ở chế độ batch, quy trình huấn luyện lại được thực thi theo lô định kỳ, xử lý khối lượng lớn dữ liệu tích lũy để tạo ra các phiên bản mô hình mới với hiệu suất cải thiện. Cách tiếp cận này cân bằng hoàn hảo giữa nhu cầu đáp ứng tức thời của người dùng và việc cải thiện hiệu suất bền vững dài hạn của hệ thống.

Đóng góp thứ ba là việc xây dựng cơ chế học tập có trọng số dựa trên độ uy tín của nguồn. Để chống lại nhiễu từ dữ liệu kém chất lượng, một vấn đề thường gặp trong học máy, hệ thống được thiết kế để gán trọng số khác nhau cho các nguồn dữ liệu đầu vào. Phản hồi từ các chuyên gia hoặc người dùng có độ tin cậy cao được xác minh sẽ có ảnh hưởng lớn hơn trong quá trình huấn luyện lại mô hình. Tương tự, chứng cứ từ các nguồn tin tức uy tín được định nghĩa rõ ràng trong cơ sở dữ liệu sẽ có trọng số cao hơn khi mô hình NLI đưa ra quyết định xác minh. Cơ chế này giúp hệ thống tập trung học hỏi từ những nguồn tri thức đáng tin cậy nhất, đồng thời giảm thiểu tác động tiêu cực từ dữ liệu nhiễu hoặc không chính xác.