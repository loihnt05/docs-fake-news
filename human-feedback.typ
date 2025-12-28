#set par(justify: true)

= Hệ thống Phản hồi và Độ uy tín - Kiến trúc Học từ Cộng đồng có Kiểm soát

Trong chương trước, chúng ta đã thấy cách hệ thống học từ các chuyên gia thông qua cơ chế Human-in-the-loop. Tuy nhiên, đó chỉ là một nửa của câu chuyện. Một hệ thống thực sự thông minh cần có khả năng học từ chính những người sử dụng nó hàng ngày, những người đang đối mặt trực tiếp với thông tin sai lệch trên mạng xã hội và các nền tảng web. Họ là những người đầu tiên phát hiện ra khi hệ thống mắc lỗi, và họ có thể cung cấp những góc nhìn quý giá mà ngay cả chuyên gia cũng có thể bỏ lỡ.

Nhưng việc mở cửa cho phản hồi từ người dùng cũng tạo ra một lỗ hổng lớn. Làm thế nào để phân biệt giữa phản hồi chân thành từ người dùng muốn giúp đỡ và các báo cáo độc hại từ những kẻ muốn phá hoại hệ thống? Làm sao để đảm bảo rằng việc học từ cộng đồng không làm suy yếu mà thực sự củng cố hệ thống?

Chương này giải quyết những câu hỏi này bằng cách trình bày một kiến trúc phức tạp và tinh vi, nơi mà phản hồi từ người dùng được chào đón nhưng cũng được kiểm soát chặt chẽ. Đây là một hệ thống phản hồi có trọng số, nơi không phải mọi ý kiến đều có giá trị như nhau, và nơi uy tín được xây dựng dần dần thông qua những đóng góp có chất lượng.
#align(center)[
  #image("images/human-in-loop.jpg", width: 400pt)
]
== Cơ chế Báo cáo từ Người dùng - Cầu nối giữa Thực tế và Hệ thống

Hãy bắt đầu bằng cách tưởng tượng trải nghiệm của một người dùng thông thường, chúng ta sẽ gọi cô ấy là Mai. Mai đang lướt Facebook và thấy một bài đăng về một phương pháp chữa bệnh kỳ diệu. Cô ấy cảm thấy nghi ngờ, vì vậy cô ấy sao chép đoạn text và dán vào tiện ích mở rộng của hệ thống chúng ta. Trong vài giây, hệ thống trả về kết quả: "REAL, 0.73". Hệ thống nói rằng thông tin này có khả năng đúng với độ tự tin bảy mươi ba phần trăm.

Nhưng Mai là một bác sĩ, và cô ấy biết chắc chắn rằng phương pháp này không có cơ sở khoa học. Cô ấy có thông tin từ các nghiên cứu y khoa mới nhất mà hệ thống có thể chưa cập nhật. Đây chính xác là tình huống mà cơ chế báo cáo từ người dùng được thiết kế để xử lý.

=== Giao diện tiện ích mở rộng - Nơi phản hồi bắt đầu

Tiện ích mở rộng trình duyệt, được triển khai trong extension/popup.html và popup.js, là điểm tiếp xúc chính giữa người dùng và hệ thống. Khi Mai nhìn thấy kết quả xác minh, cô ấy không chỉ thấy nhãn và điểm số. Giao diện được thiết kế cẩn thận để khuyến khích phản hồi có chất lượng.

Ngay bên dưới kết quả, có một nút rõ ràng với nhãn "Báo cáo không chính xác". Nút này không được ẩn đi hoặc khó tìm. Nó luôn hiển thị, ngay cả với những kết quả có độ tự tin cao, vì chúng ta hiểu rằng không có hệ thống nào là hoàn hảo. Màu sắc và vị trí của nút được thiết kế để dễ nhận biết nhưng không quá nổi bật đến mức làm người dùng nghĩ rằng hệ thống đang không tự tin về kết quả của mình.

Khi Mai nhấp vào nút này, một form nhỏ gọn xuất hiện. Form này không yêu cầu quá nhiều thông tin đến mức người dùng cảm thấy nản lòng, nhưng cũng đủ để thu thập dữ liệu có giá trị. Cụ thể, form yêu cầu các thông tin sau, và việc thiết kế mỗi trường đều có lý do riêng của nó.

Trường đầu tiên là một menu dropdown đơn giản hỏi "Theo bạn, nhãn đúng nên là gì?". Menu này hiển thị các lựa chọn: REAL, FAKE, MISLEADING, SATIRE, và UNDEFINED. Việc cung cấp các lựa chọn cụ thể thay vì một trường text tự do có nhiều lợi ích. Nó làm cho dữ liệu có cấu trúc và dễ xử lý. Nó cũng giúp người dùng suy nghĩ rõ ràng hơn về loại lỗi mà họ tin rằng hệ thống đã mắc phải.

Trường thứ hai, và đây là trường quan trọng nhất, là "Nguồn tham khảo". Đây là một trường text tùy chọn nơi Mai có thể dán URL của một bài báo, một nghiên cứu khoa học, hoặc bất kỳ nguồn tin đáng tin cậy nào hỗ trợ cho đề xuất của cô ấy. Việc làm cho trường này tùy chọn là cố ý. Chúng ta không muốn tạo ra rào cản cao đến mức ngăn cản người dùng báo cáo. Một người có thể không có nguồn tham khảo ngay lúc đó nhưng vẫn có intuition hợp lý rằng có điều gì đó không đúng.

Tuy nhiên, việc có trường này, ngay cả khi tùy chọn, tạo ra một hiệu ứng tâm lý quan trọng. Nó khuyến khích người dùng suy nghĩ kỹ hơn trước khi gửi báo cáo. Nếu bạn không thể nghĩ ra bất kỳ nguồn nào hỗ trợ quan điểm của mình, có thể bạn nên xem xét lại xem mình có thực sự chắc chắn không. Điều này giúp lọc bớt các báo cáo chất lượng thấp hoặc bốc đồng ngay từ phía người dùng.

Cuối cùng, có một trường text tự do nhỏ cho "Ghi chú bổ sung". Đây là nơi người dùng có thể giải thích lý do của họ bằng lời. Mai, với tư cách là bác sĩ, có thể viết một câu ngắn gọn: "Là bác sĩ tim mạch, tôi xác nhận rằng phương pháp này không có căn cứ khoa học và đã bị FDA cảnh báo". Thông tin định tính như thế này, mặc dù không được sử dụng trực tiếp trong việc huấn luyện mô hình, lại vô cùng quý giá cho các quản trị viên khi họ xem xét báo cáo.
#align(center)[
  #image("images/feedback.png", width: 400pt)
]
=== Payload - Gói thông tin được gửi về máy chủ

Khi Mai nhấn nút "Gửi báo cáo", JavaScript trong popup.js bắt đầu đóng gói thông tin. Điều quan trọng là phải hiểu chính xác những gì được gửi về máy chủ và tại sao.

Claim ID là mã định danh duy nhất của claim đang được xem xét. Đây là khóa chính liên kết báo cáo này với tất cả các thông tin khác trong hệ thống về claim đó, bao gồm văn bản gốc, các bằng chứng đã tìm được, và lịch sử đánh giá.

Dự đoán của hệ thống, bao gồm cả nhãn và confidence score, cũng được gửi kèm. Tại sao chúng ta cần gửi thông tin mà hệ thống đã biết rồi? Bởi vì nó cung cấp context quan trọng. Một báo cáo về một kết quả có confidence 0.95 có ý nghĩa rất khác với báo cáo về kết quả có confidence 0.55. Nếu hệ thống đã không chắc chắn và người dùng xác nhận rằng nó sai, đó là một tín hiệu yếu hơn so với việc hệ thống rất tự tin nhưng vẫn sai.

Đề xuất của người dùng, tức nhãn mà họ tin là đúng, là trái tim của báo cáo. Đây là ground truth mới tiềm năng mà hệ thống sẽ xem xét.

Nguồn tham khảo, nếu được cung cấp, là vô cùng quý giá. Nó không chỉ giúp xác thực đề xuất của người dùng mà còn có thể được thêm vào cơ sở tri thức của hệ thống như một bằng chứng mới. Nếu Mai cung cấp một link đến một nghiên cứu của FDA, hệ thống có thể crawl và index trang đó, khiến cho lần tới khi một claim tương tự xuất hiện, hệ thống đã có bằng chứng này sẵn sàng.

User Token là một mã định danh được tạo ra khi người dùng lần đầu cài đặt tiện ích. Nó là ẩn danh ở nghĩa là không liên kết trực tiếp với tên thật hoặc email của người dùng, nhưng nó cho phép hệ thống theo dõi lịch sử báo cáo của mỗi người dùng và quan trọng nhất, duy trì điểm uy tín của họ. Đây là nền tảng cho toàn bộ hệ thống reputation mà chúng ta sẽ thảo luận tiếp theo.

Timestamp của báo cáo cũng được ghi lại. Điều này quan trọng cho nhiều mục đích: phát hiện spam (nhiều báo cáo trong thời gian ngắn từ cùng một người dùng), hiểu xu hướng theo thời gian, và trong một số trường hợp, ưu tiên các báo cáo mới hơn về các sự kiện đang phát triển.

Tất cả thông tin này được đóng gói thành một JSON payload và được gửi đến backend thông qua một POST request đến endpoint /api/report trong backend/main.py. Việc truyền tải này được mã hóa bằng HTTPS để bảo vệ quyền riêng tư của người dùng.

=== Xử lý phía backend - Tiếp nhận và lưu trữ

Khi payload đến backend, một chuỗi xử lý được kích hoạt. Đầu tiên, API endpoint thực hiện validation cơ bản. Nó kiểm tra xem tất cả các trường bắt buộc có mặt không, các giá trị có đúng định dạng không, và quan trọng nhất, User Token có hợp lệ không.

Validation của User Token không chỉ đơn giản là kiểm tra xem nó có tồn tại trong database hay không. Hệ thống cũng kiểm tra xem token này có bị đánh dấu là spam hay bị cấm không. Nếu một người dùng đã bị phát hiện là đang gửi spam hoặc các báo cáo độc hại trong quá khứ, token của họ có thể bị đưa vào blacklist, và các báo cáo mới từ họ sẽ bị từ chối ngay từ đầu.

Nếu validation thành công, một bản ghi mới được tạo trong bảng user_reports trong database. Bảng này có cấu trúc cẩn thận để lưu trữ tất cả thông tin cần thiết cho các giai đoạn xử lý sau này. Mỗi báo cáo có một trạng thái, khởi tạo là "PENDING" (đang chờ xem xét). Trạng thái này sẽ thay đổi thành "APPROVED" hoặc "REJECTED" sau khi được quản trị viên xem xét.

Backend cũng thực hiện một số xử lý bổ sung. Nếu người dùng cung cấp một URL nguồn tham khảo, hệ thống có thể ngay lập tức thử crawl URL đó để lấy nội dung và xác minh rằng nó thực sự tồn tại và có thể truy cập được. Điều này giúp phát hiện sớm các báo cáo có nguồn giả mạo.

== Mô hình hóa Độ uy tín - Không phải mọi tiếng nói đều bằng nhau

Đây là nơi hệ thống trở nên thực sự tinh vi. Một insight quan trọng từ các nền tảng cộng đồng thành công như Stack Overflow, Reddit, hoặc Wikipedia là không phải mọi người dùng đều có cùng mức độ expertise và đáng tin cậy. Một người dùng đã đóng góp hàng trăm chỉnh sửa chất lượng cao nên có tiếng nói nặng ký hơn một người mới tham gia.

Hệ thống reputation của chúng ta được thiết kế dựa trên nguyên tắc này, nhưng với những điều chỉnh cẩn thận cho bối cảnh cụ thể của phát hiện tin giả, nơi mà stakes cao hơn nhiều và rủi ro bị lợi dụng là đáng kể.

=== Khởi tạo và cập nhật điểm uy tín

Mỗi người dùng, khi lần đầu sử dụng hệ thống và tạo User Token, được gán một điểm uy tín khởi tạo. Việc chọn con số này là một quyết định quan trọng. Nếu quá cao, người dùng mới có thể gây thiệt hại trước khi hệ thống nhận ra họ không đáng tin cậy. Nếu quá thấp, người dùng tốt có thể cảm thấy nản lòng khi đóng góp của họ không được coi trọng.

Một giá trị hợp lý là 1.0, được coi là điểm "trung lập". Đây là điểm mà một báo cáo từ người dùng này sẽ được xem xét nghiêm túc nhưng không có trọng số đặc biệt. Nó phản ánh tư tưởng "innocent until proven guilty" - chúng ta cho người dùng lợi ích của sự nghi ngờ cho đến khi họ chứng minh là đáng tin hoặc không đáng tin.

Sau khi báo cáo của người dùng được xem xét bởi quản trị viên (một quá trình chúng ta sẽ thảo luận chi tiết trong phần 6.3), điểm uy tín sẽ được cập nhật theo một công thức cẩn thận. Hãy xem xét logic đằng sau việc cập nhật này.

Nếu báo cáo được chấp thuận, điều đó có nghĩa là người dùng đã cung cấp thông tin chính xác và hữu ích. Điểm uy tín của họ nên tăng lên. Nhưng tăng bao nhiêu? Đây là nơi chúng ta cần một số nuance. Không phải mọi báo cáo được chấp thuận đều có giá trị như nhau.

Xem xét hai tình huống: Trong tình huống A, hệ thống đưa ra kết quả (FAKE, 0.51) - một kết quả rất không chắc chắn, gần như là đoán. Một người dùng báo cáo rằng claim thực sự là REAL và cung cấp bằng chứng tốt. Quản trị viên xác nhận người dùng đúng. Trong tình huống B, hệ thống đưa ra (FAKE, 0.97) - một kết quả rất tự tin. Một người dùng báo cáo rằng hệ thống sai và claim thực sự là REAL, cung cấp bằng chứng thuyết phục. Quản trị viên xác nhận người dùng đúng.

Tình huống nào đáng giá hơn? Rõ ràng là tình huống B. Người dùng trong tình huống B đã phát hiện ra một lỗi nghiêm trọng của hệ thống, một lỗi mà hệ thống rất tự tin về. Họ đã cung cấp thông tin có giá trị hơn nhiều. Việc sửa một lỗi như thế này giúp hệ thống cải thiện mạnh mẽ hơn việc làm rõ một trường hợp mà hệ thống đã không chắc chắn.

Do đó, mức độ tăng điểm có thể phụ thuộc vào confidence score của dự đoán ban đầu của hệ thống. Công thức có thể trông như thế này:

Điểm tăng = Điểm cơ bản × (1 + Confidence của hệ thống)

Với điểm cơ bản có thể là 0.1, điều này có nghĩa là sửa một lỗi confidence 0.97 sẽ tăng 0.1 × (1 + 0.97) = 0.197 điểm, trong khi sửa lỗi confidence 0.51 chỉ tăng 0.1 × (1 + 0.51) = 0.151 điểm. Sự khác biệt không quá lớn nhưng đủ để thưởng cho những đóng góp có giá trị hơn.

Ngược lại, nếu báo cáo bị từ chối, điểm uy tín bị trừ. Lý do của việc từ chối có thể khác nhau: người dùng có thể đơn giản là sai, họ có thể đã hiểu nhầm claim, hoặc trong trường hợp xấu nhất, họ có thể đang cố tình gửi thông tin sai lệch.

Việc trừ điểm cũng cần được cân nhắc cẩn thận. Nếu trừ quá nhiều, người dùng tốt có thể bị phạt quá nặng cho một lỗi trung thực, khiến họ ngần ngại đóng góp trong tương lai. Nếu trừ quá ít, các bad actors có thể spam hàng trăm báo cáo xấu và vẫn duy trì điểm uy tín tích cực.

Một chiến lược cân bằng là trừ điểm với mức độ nhẹ hơn một chút so với tăng điểm cho các lỗi trung thực (ví dụ, trừ 0.08 thay vì trừ 0.1), nhưng có cơ chế phát hiện spam để nhanh chóng đưa điểm của spammer xuống rất thấp. Cụ thể, nếu nhiều báo cáo liên tiếp từ cùng một người dùng bị từ chối trong một khoảng thời gian ngắn, hệ thống có thể áp dụng một penalty lớn hơn, phản ánh nghi ngờ rằng đây không phải là lỗi ngẫu nhiên mà là hành vi có chủ ý.

=== Phòng chống spam - Các lớp bảo vệ

Spam và abuse là mối đe dọa luôn hiện hữu đối với bất kỳ hệ thống nào chấp nhận input từ người dùng. Trong ngữ cảnh của chúng ta, spam không chỉ là phiền nhiễu mà có thể là một cuộc tấn công có chủ đích nhằm làm suy yếu hệ thống.

Hãy tưởng tượng một kịch bản tấn công: một nhóm người có tổ chức quyết định họ muốn làm cho hệ thống tin rằng một loại thông tin sai lệch cụ thể thực ra là đúng. Họ tạo ra hàng nghìn tài khoản và mỗi tài khoản gửi nhiều báo cáo sai lệch. Nếu không có cơ chế phòng thủ, ngay cả khi mỗi báo cáo có trọng số thấp, số lượng lớn có thể áp đảo các tín hiệu tốt.

Lớp phòng thủ đầu tiên là Rate Limiting ở cấp độ API. Hệ thống theo dõi số lượng requests từ mỗi User Token trong một cửa sổ thời gian. Ví dụ, một người dùng có thể bị giới hạn không quá 10 báo cáo mỗi giờ và 50 báo cáo mỗi ngày. Những con số này được chọn để đủ cao cho một người dùng tích cực nhưng trung thực, nhưng đủ thấp để ngăn chặn spam quy mô lớn.

Nếu một người dùng vượt quá giới hạn, các requests bổ sung sẽ bị từ chối với HTTP status code 429 (Too Many Requests). Tiện ích mở rộng có thể hiển thị một thông báo lịch sự cho người dùng giải thích rằng họ đã đạt giới hạn và có thể thử lại sau. Đối với người dùng trung thực, đây là một sự bất tiện nhỏ. Đối với spammer, đây là một rào cản đáng kể.

Nhưng rate limiting chỉ dựa trên số lượng không đủ. Một attacker tinh vi có thể gửi báo cáo với tốc độ chậm để tránh kích hoạt giới hạn. Đây là lúc lớp phòng thủ thứ hai vào cuộc: Score-based Filtering.

Hệ thống theo dõi điểm uy tín của mỗi người dùng theo thời gian thực. Nếu điểm uy tín của một người dùng rơi xuống dưới một ngưỡng nhất định, ví dụ 0.3, hệ thống bắt đầu xử lý báo cáo của họ khác đi. Báo cáo từ họ vẫn được chấp nhận và lưu trữ, nhưng chúng không còn được đưa vào hàng đợi xem xét với độ ưu tiên cao nữa. Thay vào đó, chúng có thể được đánh dấu là "cần xác minh bổ sung" hoặc trong một số trường hợp, được tự động assigned một trọng số gần bằng không trong quá trình huấn luyện.

Nếu điểm uy tín rơi xuống 0 hoặc âm, đây là một tín hiệu rất mạnh rằng người dùng này là problematic. Trong trường hợp này, User Token có thể tự động bị đưa vào một watchlist. Các báo cáo từ các token trong watchlist này vẫn được xử lý nhưng với sự giám sát cao hơn. Nếu hành vi xấu tiếp tục, token có thể bị ban hoàn toàn.

Một kỹ thuật phòng thủ bổ sung là phát hiện patterns đáng ngờ. Hệ thống có thể phân tích xem nhiều User Tokens có đang gửi các báo cáo rất giống nhau không, có thể là dấu hiệu của một cuộc tấn công có tổ chức sử dụng nhiều tài khoản. Nếu 20 tài khoản khác nhau đều báo cáo về cùng một claim với cùng một đề xuất và các ghi chú gần như giống hệt nhau trong vòng một giờ, đây là một red flag rõ ràng.

=== Sự thống trị của chuyên gia - Nguyên tắc thiết kế cốt lõi

Đây là phần quan trọng nhất của toàn bộ hệ thống reputation, và nó thể hiện một insight sâu sắc về cách cân bằng giữa crowdsourcing và chuyên môn.

Trong nhiều hệ thống crowdsourced, có một giả định ngầm rằng "wisdom of the crowd" - trí tuệ của đám đông - luôn đúng. Nếu đủ nhiều người đồng ý về một điều gì đó, thì nó có thể là đúng. Đối với một số loại vấn đề, điều này hoạt động tốt. Nhưng đối với các vấn đề đòi hỏi chuyên môn sâu, đặc biệt là trong lĩnh vực như y tế, khoa học, hoặc fact-checking, đám đông có thể sai một cách tập thể.

Hãy xem xét một ví dụ cụ thể. Một claim về vaccine xuất hiện trên mạng xã hội với một số thông tin sai lệch tinh vi. Hàng trăm người dùng, nhiều người trong số họ tin vào thuyết âm mưu về vaccine, báo cáo rằng hệ thống sai khi đánh giá claim là FAKE. Họ cho rằng claim là REAL và cung cấp links đến các blogs và videos hỗ trợ quan điểm của họ. Nếu chúng ta đơn giản cộng dồn tất cả các báo cáo này với trọng số như nhau, hệ thống có thể bị thuyết phục sai rằng thông tin sai lệch là đúng.

Đây là lý do tại sao hệ thống phân biệt rõ ràng giữa hai loại người dùng: USER thông thường và EXPERT. Experts là những người đã được quản trị viên hệ thống xác thực. Họ có thể là các nhà báo fact-checker chuyên nghiệp, các nhà khoa học trong lĩnh vực liên quan, bác sĩ y khoa, hoặc các chuyên gia được công nhận trong các lĩnh vực cụ thể.

Quá trình để trở thành một expert không phải là tự động. Nó đòi hỏi một quy trình verification nghiêm ngặt. Một người dùng có thể apply để trở thành expert bằng cách cung cấp thông tin chứng minh credentials của họ, credentials này sau đó được xác minh bởi đội ngũ quản trị. Một bác sĩ có thể cần cung cấp giấy phép hành nghề. Một nhà báo có thể cần chứng minh họ làm việc cho một tổ chức tin cậy. Quá trình này có thể mất vài ngày và đòi hỏi sự giám sát của con người, nhưng nó đảm bảo chất lượng.

Một khi được xác nhận là expert, điểm uy tín của người dùng đó được set thành một giá trị đặc biệt, thực tế là vô hạn hoặc một con số rất lớn (ví dụ, 1000.0 trong khi người dùng thông thường có điểm từ 0-10). Quan trọng hơn, điểm này không thay đổi theo các báo cáo cá nhân. Nó là một trạng thái, không phải một số liệu động.

Trong quá trình huấn luyện lại mô hình, được điều phối bởi retrain_pipeline.py, mỗi điểm dữ liệu từ phản hồi người dùng được nhân với trọng số bằng với điểm uy tín của người dùng đó. Công thức đơn giản nhưng mạnh mẽ:

Trọng số mẫu dữ liệu = reputation_score của người dùng

Điều này có nghĩa là một báo cáo duy nhất từ một expert (reputation 1000) có tác động bằng một nghìn báo cáo từ người dùng mới (reputation 1.0). Ngay cả nếu có một trăm người dùng thông thường báo cáo một cách, và một expert duy nhất báo cáo cách khác, expert sẽ thắng.

Đây không phải là elitism hay không tôn trọng người dùng thông thường. Đây là một nhận thức thực tế rằng trong các vấn đề kỹ thuật phức tạp, chuyên môn quan trọng. Một bác sĩ hiểu về y học tốt hơn một trăm người không có training y khoa. Một nhà vật lý hiểu về vật lý tốt hơn một nghìn người có ý kiến về vật lý trên internet.

Tuy nhiên, điều này không có nghĩa là người dùng thông thường không quan trọng. Ngược lại, họ vô cùng quan trọng vì nhiều lý do. Thứ nhất, họ có số lượng lớn hơn nhiều và do đó có thể phủ sóng rộng hơn. Một expert không thể xem xét mọi claim, nhưng hàng nghìn người dùng thông thường có thể. Thứ hai, người dùng thông thường có thể phát hiện ra các vấn đề mà expert bỏ lỡ, đặc biệt trong các lĩnh vực local hoặc niche. Thứ ba, hệ thống reputation cho phép người dùng thông thường build credibility theo thời gian. Một người dùng bắt đầu với điểm 1.0 nhưng sau hàng trăm báo cáo chất lượng cao có thể có điểm 5.0 hoặc 8.0, making their voice progressively more important.

=== Dynamics phức tạp của hệ thống reputation

Một hệ thống reputation tốt không phải là tĩnh. Nó cần phản ánh một cách động sự phát triển của người dùng và thay đổi của môi trường. Hãy xem xét một số dynamics phức tạp mà hệ thống cần xử lý.

Time decay là một yếu tố quan trọng. Một người dùng có điểm uy tín cao vì những đóng góp ba năm trước có nên vẫn giữ điểm cao đó không nếu họ không còn active nữa? Có lẽ là không, hoặc ít nhất là điểm nên giảm dần. Điều này ngăn chặn việc một người xây dựng reputation rồi sau đó "bán" tài khoản của họ cho bad actors.

Domain expertise là một dimension khác. Một expert về y học có thể không phải là expert về chính trị hay công nghệ. Một hệ thống tinh vi hơn có thể theo dõi reputation riêng biệt cho các domains khác nhau. Khi một báo cáo được gửi về một claim y tế, hệ thống sẽ xem xét reputation của người dùng đó cụ thể trong lĩnh vực y tế. Điều này phức tạp hơn về mặt implementation nhưng cho phép một sự nuance quý giá hơn.

Reputation inflation cũng là một vấn đề tiềm ẩn. Nếu hệ thống có xu hướng thưởng nhiều hơn là phạt, theo thời gian tất cả mọi người sẽ có điểm uy tín cao, và hệ thống mất khả năng phân biệt. Để tránh điều này, các parameters của thuật toán cập nhật điểm cần được calibrated cẩn thận và điều chỉnh định kỳ dựa trên dữ liệu thực tế.

== Quản trị và Kiểm duyệt - Lá chắn cuối cùng

Mặc dù hệ thống reputation tạo ra một cơ chế tự điều chỉnh mạnh mẽ, nó không phải là hoàn hảo. Vẫn cần có sự can thiệp của con người để đảm bảo chất lượng cuối cùng của dữ liệu vào vòng lặp học tập. Đây là vai trò của hệ thống quản trị và kiểm duyệt.

=== Luồng công việc chấp thuận - Admin workflow
Tất cả các báo cáo từ người dùng, bất kể reputation score của họ là bao nhiêu, đều bắt đầu trong trạng thái "PENDING" - chờ xem xét. Điều này có thể nghe có vẻ như một bottleneck, nhưng thực tế nó là cần thiết để đảm bảo chất lượng.

Các quản trị viên và experts truy cập vào một giao diện dashboard chuyên biệt, được implement trong dashboard/app.py. Dashboard này không chỉ là một danh sách đơn giản các báo cáo. Nó là một công cụ tinh vi được thiết kế để làm cho quá trình review hiệu quả và chính xác nhất có thể.

Khi một admin đăng nhập vào dashboard, họ nhìn thấy một queue các báo cáo được sắp xếp theo nhiều tiêu chí. Mặc định, báo cáo được sắp xếp theo một priority score được tính dựa trên nhiều yếu tố:

Reputation của người báo cáo: Báo cáo từ người dùng có reputation cao hơn được ưu tiên xem xét. Nếu một expert gửi báo cáo, nó cần được xem xét nhanh chóng. Nếu một người dùng có history tốt gửi báo cáo, đó cũng là một tín hiệu quan trọng. Ngược lại, báo cáo từ người dùng mới hoặc có reputation thấp có thể chờ lâu hơn.

Độ bất đồng với hệ thống: Nếu hệ thống rất tự tin về một kết quả (confidence 0.95) và người dùng báo cáo rằng nó sai, đây là một priority cao vì nó có thể chỉ ra một lỗi hệ thống nghiêm trọng. Ngược lại, nếu hệ thống không chắc chắn (confidence 0.55) và người dùng đưa ra một đề xuất, điều này ít cấp bách hơn.

Impact tiềm năng: Một số claims quan trọng hơn những claims khác. Một claim về một vấn đề y tế cấp bách hoặc một sự kiện chính trị lớn cần được xem xét nhanh hơn một claim về một chủ đề ít ảnh hưởng.

Thời gian: Các báo cáo cũ hơn thường được ưu tiên để tránh để chúng bị quên. Nếu một báo cáo đã nằm trong queue được vài ngày, nó cần được addressed.

Khi admin click vào một báo cáo để xem xét, họ thấy một interface hiển thị đầy đủ context:

Phía trái màn hình hiển thị claim gốc, kết quả mà hệ thống đưa ra, và tất cả các evidence mà hệ thống đã sử dụng. Điều này cho phép admin hiểu tại sao hệ thống đưa ra quyết định đó.

Phía giữa hiển thị thông tin về báo cáo của người dùng: nhãn họ đề xuất, nguồn tham khảo nếu có, và ghi chú của họ. Nó cũng hiển thị reputation hiện tại của người dùng và lịch sử báo cáo trước đây của họ, điều này giúp admin đánh giá credibility.

Phía phải cung cấp các công cụ cho admin. Có thể có một công cụ tìm kiếm nhanh để admin có thể tự verify thông tin. Có thể có một timeline cho thấy claim này đã được xử lý như thế nào theo thời gian. Và quan trọng nhất, có các nút quyết định rõ ràng: "Approve", "Reject", và có thể "Need More Information".

Quá trình review của admin không phải là tùy tiện. Họ cần tuân theo các hướng dẫn rõ ràng đã được thiết lập. Ví dụ, để approve một báo cáo, admin cần xác nhận rằng:

- Đề xuất của người dùng có vẻ chính xác dựa trên evidence.
- Nếu người dùng cung cấp nguồn tham khảo, nguồn đó là đáng tin cậy và relevant.
- Không có dấu hiệu của spam hoặc hành vi độc hại.

Để reject một báo cáo, admin cần xác định lý do: người dùng sai về mặt sự thật, nguồn tham khảo không đáng tin cậy, hoặc báo cáo có vẻ là spam.

Khi admin nhấn "Approve" hoặc "Reject", một loạt các hành động được trigger ngay lập tức:

Trạng thái của báo cáo trong database được cập nhật từ PENDING sang APPROVED hoặc REJECTED.

Điểm reputation của người dùng được cập nhật theo công thức đã thảo luận trong phần 6.2.1.

Nếu báo cáo được approved, dữ liệu (claim, corrected_label, evidence) được di chuyển sang một dataset riêng biệt gọi là "approved_user_feedback" dataset. Đây là dataset "sạch" mà sẽ được sử dụng trong chu kỳ huấn luyện tiếp theo.

Nếu báo cáo được approved và có nguồn tham khảo mới, URL đó được thêm vào crawl queue để hệ thống có thể index nó và thêm vào knowledge base.

Người dùng nhận được một notification (trong lần tiếp theo họ mở tiện ích) về kết quả review của báo cáo họ. Điều này tạo ra một feedback loop, giúp người dùng học hỏi và cải thiện chất lượng báo cáo của họ.

=== Xử lý khối lượng lớn - Batching và prioritization

Một hệ thống thành công có thể nhận được hàng trăm hoặc hàng nghìn báo cáo mỗi ngày. Không có đội ngũ admin nào có thể manually review từng báo cáo một nếu không có các công cụ và strategies thông minh.

Batch processing là một kỹ thuật quan trọng. Thay vì xem xét từng báo cáo độc lập, admin có thể xem xét các nhóm báo cáo tương tự cùng lúc. Ví dụ, nếu 50 người dùng cùng báo cáo về một claim cụ thể, admin không cần xem xét cả 50 báo cáo riêng lẻ. Họ có thể xem xét claim đó một lần, đưa ra quyết định, và apply quyết định đó cho tất cả 50 báo cáo. Dashboard có thể group các báo cáo về cùng một claim và hiển thị một summary, cho phép bulk actions.

Auto-approval cho một số trường hợp đơn giản cũng có thể được implement. Nếu một báo cáo đến từ một expert có reputation rất cao và họ cung cấp một nguồn tham khảo từ một tổ chức tin cậy đã được verify, báo cáo đó có thể được tự động approved mà không cần human review. Điều này giải phóng admin để tập trung vào các trường hợp khó khăn hơn và không rõ ràng hơn.

Delegated moderation là một strategy khác. Không phải mọi admin cần có cùng mức độ quyền. Có thể có junior moderators chịu trách nhiệm xử lý các trường hợp đơn giản và rõ ràng, trong khi senior moderators xử lý các trường hợp phức tạp hoặc có tranh cãi. Các quyết định của junior moderators có thể được senior moderators spot-check để đảm bảo chất lượng.

=== Ngăn chặn Data Poisoning - Phòng thủ nhiều lớp

Bây giờ chúng ta có thể thấy rõ cách toàn bộ kiến trúc này tạo thành một hệ thống phòng thủ vững chắc chống lại data poisoning attacks.

Layer một là Rate Limiting và Score-based Filtering ở tầng API. Điều này ngăn chặn các cuộc tấn công volume-based, nơi attacker cố gắng overwhelm hệ thống với số lượng lớn báo cáo độc hại.

Layer hai là Reputation System. Ngay cả khi một attacker vượt qua được layer một và gửi được nhiều báo cáo, những báo cáo từ accounts có reputation thấp sẽ có impact rất nhỏ. Và nếu báo cáo của họ được rejected, reputation của họ giảm nhanh chóng, làm cho các báo cáo tương lai của họ càng ít ảnh hưởng hơn.

Layer ba là Human Moderation. Mọi dữ liệu trước khi vào training dataset đều phải qua mắt người. Một admin có kinh nghiệm có thể phát hiện patterns đáng ngờ mà các automated systems bỏ lỡ.

Layer bốn là Expert Dominance trong training. Ngay cả trong trường hợp xấu nhất mà một số dữ liệu poisoned vượt qua được tất cả các layers trên và vào training dataset, impact của nó bị minimize bởi trọng số thấp. Trong khi đó, dữ liệu từ experts với trọng số cao sẽ dominate quá trình learning.

Layer năm là Monitoring và Auditing post-training. Sau khi một mô hình mới được train, nó phải pass qua một validation set trước khi được deploy. Nếu hiệu suất giảm đột ngột, điều này trigger một investigation để xác định xem có phải dữ liệu training bị nhiễm không.

Sự kết hợp của tất cả các layers này tạo ra một hệ thống rất khó để compromise. Một attacker cần phải vượt qua nhiều barriers, mỗi barrier được thiết kế độc lập và hoạt động theo principles khác nhau. Đây là defense in depth - một nguyên tắc cơ bản của security.

== Tích hợp với vòng lặp học tập

Bây giờ chúng ta hiểu cách feedback được thu thập, filtered, và approved, hãy xem cách nó được tích hợp vào vòng lặp học tập của hệ thống.

=== Data pipeline từ feedback đến training
Chu kỳ huấn luyện lại được điều phối bởi weekly_retrain_dag.py trong Airflow. Một trong những tasks đầu tiên trong DAG này là collect_user_feedback_task.

Task này query database để lấy tất cả các báo cáo đã được approved kể từ lần training trước đó. Mỗi bản ghi bao gồm:

- Claim ID và text của claim
- Nhãn gốc mà hệ thống đưa ra
- Nhãn corrected do người dùng đề xuất và admin approved
- Evidence mới nếu người dùng cung cấp
- Reputation score của người dùng tại thời điểm báo cáo

Dữ liệu này sau đó được transform thành định dạng phù hợp cho training. Quan trọng nhất, mỗi sample được gán một sample_weight bằng với reputation score của người dùng đã cung cấp feedback đó.

```python
for feedback in approved_feedbacks:
    training_sample = {
        'claim': feedback.claim_text,
        'label': feedback.corrected_label,
        'evidence': feedback.evidence,
        'sample_weight': feedback.user_reputation
    }
    training_data.append(training_sample)
```

Dataset này sau đó được combined với dữ liệu từ các nguồn khác: dữ liệu từ expert fact-checkers (từ human-in-the-loop workflow trong chương 5), dữ liệu từ các tổ chức fact-checking đối tác, và dữ liệu training gốc.

=== Weighted training - Làm cho reputation matter

Trong quá trình training, framework machine learning (có thể là PyTorch hoặc TensorFlow) hỗ trợ weighted samples. Khi tính loss function, loss của mỗi sample được nhân với sample_weight của nó.

Điều này có nghĩa là khi mô hình học, nó "quan tâm" nhiều hơn về việc làm đúng những samples có weight cao. Một sample từ một expert với weight 1000 có impact lên gradient update bằng một nghìn samples với weight 1.

Đây là cách hệ thống đảm bảo rằng expertise được respect trong quá trình học. Mô hình không chỉ đơn giản học từ majority vote của người dùng, mà học từ weighted consensus nơi ý kiến của experts matter hơn nhiều.

=== Continuous improvement - Feedback loop đóng

Sau khi mô hình mới được train với dữ liệu bao gồm user feedback, nó được evaluated và deployed. Bây giờ, khi users tiếp tục sử dụng hệ thống và gửi feedback mới, họ đang tương tác với một mô hình đã học từ feedback của họ và những người khác trước đây.

Điều này tạo ra một virtuous cycle. Một hệ thống tốt hơn khiến users hài lòng hơn, users hài lòng hơn sẵn sàng cung cấp feedback chất lượng cao hơn, feedback chất lượng cao giúp hệ thống trở nên tốt hơn nữa.

Đồng thời, reputation system đảm bảo rằng users có động lực để cung cấp feedback tốt. Khi reputation của họ tăng, voice của họ được heard nhiều hơn. Điều này tạo ra một sense of ownership và investment trong hệ thống.

== Metrics và Monitoring

Để đảm bảo hệ thống feedback đang hoạt động tốt, cần tracking nhiều metrics khác nhau.

=== Metrics về user engagement
Số lượng báo cáo mỗi ngày: Tracking trend này giúp hiểu mức độ tích cực của cộng đồng. Một sự giảm đột ngột có thể chỉ ra vấn đề với UX hoặc users mất niềm tin vào hệ thống.

Tỷ lệ báo cáo có nguồn tham khảo: Đây là một indicator của chất lượng feedback. Reports có nguồn tham khảo thường valuable hơn.

Distribution của reports theo reputation score: Nếu hầu hết reports đến từ users có reputation thấp, có thể cần strategies để engage users có kinh nghiệm hơn. Nếu quá nhiều reports từ users có reputation âm, có thể có vấn đề spam.

=== Metrics về moderation efficiency

Thời gian xem xét trung bình: Một report trung bình mất bao lâu để được reviewed? Nếu số này quá cao, users có thể frustrated và ngừng gửi feedback.

Approval rate: Bao nhiêu phần trăm reports được approved vs rejected? Một approval rate quá thấp (ví dụ < 30%) có thể chỉ ra rằng users không hiểu rõ tiêu chuẩn hoặc instructions cần được clarified. Một rate quá cao (>95%) có thể chỉ ra rằng moderation không đủ strict.

Inter-rater agreement: Khi nhiều moderators review cùng một loại reports, họ có đồng ý với nhau không? Low agreement có thể chỉ ra cần training thêm hoặc guidelines rõ ràng hơn.

=== Metrics về impact trên mô hình

Model performance on user-corrected examples: Sau khi training, model mới perform thế nào trên các examples đã được users correct? Nếu model vẫn mắc những lỗi tương tự, có thể training procedure cần được điều chỉnh.

Reputation score distribution in training data: Bao nhiêu phần trăm training data đến từ experts vs regular users? Nếu quá ít data từ experts, có thể cần recruit thêm.

False positive rate for poisoning detection: Hệ thống có đang quá paranoid và reject quá nhiều legitimate feedback không? Balance giữa security và usability là quan trọng.

== Những thách thức và cân nhắc đạo đức

Hệ thống này, mặc dù mạnh mẽ, cũng đặt ra một số questions và challenges cần được addressed.

=== Bias và công bằng
Một concern là liệu hệ thống reputation có tạo ra echo chambers không. Nếu experts dominates quá nhiều, liệu có những perspectives hợp lệ từ non-experts bị ignored không?

Để address điều này, hệ thống cần đảm bảo diversity trong expert pool. Experts nên đến từ nhiều backgrounds, perspectives, và specializations khác nhau. Và regular users vẫn cần có path để build reputation và có voice ngay cả khi they don't start as experts.

=== Privacy

Hệ thống track behavior của users qua User Token. Mặc dù token là anonymous, vẫn có concerns về privacy. Users cần được inform rõ ràng về việc data của họ được sử dụng như thế nào.

Policies cần được establish về retention của user data. Có lẽ sau một khoảng thời gian, detailed history có thể được aggregated hoặc anonymized thêm.

=== Transparency

Users nên hiểu cách reputation system hoạt động. Nếu reputation của họ giảm, họ nên biết tại sao. Nếu report của họ bị rejected, họ nên nhận được explanation.

Dashboard có thể include một phần "My Reputation" nơi users có thể xem history của họ, hiểu cách điểm của họ được calculated, và xem feedback từ moderators về reports của họ.

== Kết luận chương

Chương này đã trình bày một hệ thống sophisticated cho phép hệ thống học từ users trong khi bảo vệ chống lại abuse. Các takeaways chính:

Cơ chế báo cáo được thiết kế cẩn thận không chỉ để thu thập data mà để khuyến khích quality feedback. Form design, required fields, và UX đều quan trọng.

Reputation system tạo ra differentiation giữa users dựa trên track record của họ. Điều này không phải là elitism mà là recognition rằng expertise matters, đặc biệt trong technical domains.

Expert dominance là core principle đảm bảo rằng crowdsourcing không dẫn đến "wisdom of the mob" overriding actual expertise.

Defense in depth: Multiple layers of protection (rate limiting, reputation filtering, human moderation, weighted training) tạo ra một hệ thống resilient chống lại poisoning attacks.

Human moderation remains essential: Mặc dù có nhiều automated safeguards, final quality control vẫn cần human judgment.

Tích hợp vào training loop: Feedback không chỉ nằm im trong database mà actively shapes cách model học và improves.

Hệ thống này biến community từ một nguồn tiềm ẩn của noise và attacks thành một asset quý giá. Nó cho phép hệ thống scale beyond những gì một team nhỏ experts có thể handle, trong khi vẫn duy trì quality standards cao. Đây là một ví dụ về cách công nghệ có thể amplify human intelligence thay vì thay thế nó.