#set par(justify: true)

= Định nghĩa bài toán

Trước khi có thể xây dựng một hệ thống kiểm chứng thông tin hiệu quả, chúng ta cần phải hiểu rõ bản chất của vấn đề mình đang cố gắng giải quyết. Điều này giống như việc một bác sĩ cần chẩn đoán chính xác bệnh trước khi kê đơn thuốc. Chương này sẽ đi sâu vào việc định nghĩa các khái niệm cốt lõi, xác định các đơn vị xử lý cơ bản, và phân tích chi tiết những thách thức mang tính đặc thù của bài toán kiểm chứng thông tin trong môi trường thực tế.

== Định nghĩa Claim - Đơn vị cơ bản của xác minh

=== Khái niệm Claim

Trong bối cảnh của dự án này, chúng tôi định nghĩa một claim (luận điểm) là một phát biểu mang tính xác quyết về một sự thật hoặc sự kiện trong thế giới thực, và quan trọng hơn, nó có thể được kiểm chứng về tính đúng hoặc sai thông qua các bằng chứng khách quan có thể tìm thấy. Hãy nghĩ về claim như một mệnh đề logic mà chúng ta có thể kiểm tra tính chân thực của nó bằng cách tìm kiếm các nguồn thông tin đáng tin cậy.

Ví dụ cụ thể về các claim hợp lệ bao gồm: "Giá vàng trong nước hôm nay tăng 500,000 đồng mỗi lượng", "Thủ tướng Chính phủ đã ký quyết định về chính sách thuế mới vào ngày 15 tháng 3", hoặc "Nghiên cứu cho thấy vaccine X có hiệu quả 95% trong việc ngăn ngừa bệnh Y". Những phát biểu này đều có thể được kiểm chứng thông qua các nguồn như báo chí chính thống, văn bản chính phủ, hoặc các công bố khoa học.

Ngược lại, những phát biểu như "Chính sách này là tốt nhất cho đất nước" hoặc "Tôi nghĩ rằng giá vàng sẽ tăng trong tương lai" không phải là claim theo định nghĩa của chúng tôi. Phát biểu đầu tiên là một ý kiến chủ quan không thể kiểm chứng khách quan, trong khi phát biểu thứ hai là một dự đoán về tương lai chưa xảy ra.

#align(center)[
  #image("images/extract-2.png", width: 400pt)
]
=== Tại sao Claim khác biệt với Article (Bài báo)?

Một sai lầm phổ biến mà nhiều hệ thống kiểm chứng thông tin giai đoạn đầu mắc phải là coi toàn bộ một bài báo như một đơn vị nguyên khối để xác minh. Cách tiếp cận này có nhiều hạn chế nghiêm trọng và không phản ánh đúng bản chất phức tạp của thông tin.

Hãy xem xét một bài báo thực tế. Một bài viết về một sự kiện chính trị có thể bao gồm nhiều thành phần khác nhau: nó có thể bắt đầu bằng việc trích dẫn chính xác một phát ngôn của một quan chức (đây là thông tin thật), tiếp theo là phân tích của tác giả về ý nghĩa của phát ngôn đó (đây là ý kiến), sau đó là một số thống kê về tình hình kinh tế (có thể đúng hoặc sai tùy thuộc vào nguồn), và cuối cùng là các dự đoán về tương lai (không thể kiểm chứng tại thời điểm hiện tại). Nếu chúng ta gán nhãn "FAKE" cho toàn bộ bài báo này chỉ vì một vài số liệu thống kê không chính xác, chúng ta sẽ đánh giá sai về những phần thông tin xác thực trong bài viết.

Hơn nữa, một bài báo có thể chứa đựng nhiều luận điểm độc lập với nhau. Một bài viết về dịch bệnh có thể đồng thời đưa ra claim về số ca nhiễm mới (có thể chính xác), về hiệu quả của một loại thuốc (có thể sai lệch), và về chính sách của chính phủ (có thể đúng một phần). Việc xử lý toàn bộ bài viết như một khối thông tin duy nhất khiến chúng ta mất đi độ chi tiết và độ chính xác trong việc đánh giá.

=== Claim là đơn vị xác minh cơ bản trong hệ thống

Chính vì những lý do trên, chúng tôi xác định claim là đơn vị thông tin nhỏ nhất, cơ bản nhất và hợp lý nhất cho quá trình xác minh. Thay vì cố gắng trả lời câu hỏi mơ hồ "Bài báo này có thật không?", hệ thống của chúng tôi tập trung vào việc trả lời câu hỏi cụ thể và rõ ràng hơn: "Luận điểm này có thật không?".

Để hiện thực hóa phương pháp tiếp cận này, chúng tôi đã phát triển một module chuyên biệt gọi là Claim Detector. Module này, được triển khai thông qua các thành phần như claim_detector_model và phobert_claim_extractor, hoạt động như một bộ lọc thông minh. Nó có khả năng tự động quét qua một đoạn văn bản dài và trích xuất ra các luận điểm riêng lẻ cần được kiểm chứng. Quá trình này tương tự như cách một nhà báo kinh nghiệm đọc một bài viết và gạch chân những phần thông tin quan trọng cần được xác minh.

Quy trình trích xuất claim diễn ra như sau: khi một bài viết mới được đưa vào hệ thống, Claim Detector sử dụng mô hình ngôn ngữ đã được huấn luyện (dựa trên PhoBERT cho tiếng Việt) để phân tích cấu trúc ngữ pháp và ngữ nghĩa của từng câu. Nó tìm kiếm các mẫu câu mang tính khẳng định về sự thật, loại bỏ các câu hỏi, các câu mệnh lệnh, và các câu chỉ chứa ý kiến thuần túy. Kết quả là một danh sách các claim độc lập, mỗi claim là một đơn vị hoàn chỉnh có thể được xác minh riêng biệt. Đây là bước tiền xử lý tối quan trọng, tạo nền tảng vững chắc cho toàn bộ quá trình xác minh phía sau, giúp hệ thống trở nên tập trung và chính xác hơn rất nhiều so với việc xử lý nguyên văn cả bài báo.

== Nhãn phân loại (Labels) - Ngôn ngữ của sự thật

Sau khi một claim được trích xuất và đi qua giai đoạn truy xuất bằng chứng, hệ thống cần phải đưa ra một kết luận rõ ràng về tính xác thực của nó. Đây là lúc mô hình Suy luận Ngôn ngữ Tự nhiên (Natural Language Inference - NLI) của hệ thống bước vào, được triển khai thông qua module retrain_nli.py. Mô hình này sẽ phân tích mối quan hệ giữa claim và các bằng chứng tìm được, sau đó gán cho claim một trong ba nhãn chính xác sau đây.

=== REAL (Thật) - Khi bằng chứng ủng hộ mạnh mẽ

Nhãn REAL được gán cho một claim khi hệ thống tìm thấy các bằng chứng đáng tin cậy có độ tương quan cao và ủng hộ mạnh mẽ (trong thuật ngữ NLI, đây gọi là quan hệ Entailment) cho luận điểm được đưa ra. Điều này có nghĩa là các nguồn thông tin đáng tin cậy xác nhận rằng sự kiện hoặc thông tin trong claim thực sự đã xảy ra hoặc là sự thật.

Để một claim nhận được nhãn REAL, không chỉ cần có bằng chứng ủng hộ mà bằng chứng đó còn phải đáp ứng nhiều tiêu chí nghiêm ngặt. Thứ nhất, bằng chứng phải đến từ các nguồn có độ uy tín cao, được định nghĩa trước trong hệ thống (chẳng hạn như các cơ quan báo chí chính thống, trang web chính phủ, hoặc các tổ chức nghiên cứu uy tín). Thứ hai, nội dung của bằng chứng phải có sự trùng khớp ngữ nghĩa cao với claim, không chỉ về mặt từ ngữ mà còn về mặt ý nghĩa. Thứ ba, trong trường hợp lý tưởng, nên có nhiều nguồn bằng chứng độc lập cùng ủng hộ claim đó, tạo nên sự đồng thuận mạnh mẽ.

Ví dụ, nếu claim là "Ngân hàng Nhà nước Việt Nam tăng lãi suất điều hành lên 6% vào ngày 10 tháng 5 năm 2024" và hệ thống tìm thấy thông cáo báo chí chính thức từ trang web của Ngân hàng Nhà nước cùng với các bài viết xác nhận từ VnExpress và Tuổi Trẻ, tất cả đều nêu rõ thông tin tương tự, thì claim này sẽ nhận được nhãn REAL với độ tin cậy rất cao.

=== FAKE (Giả) - Khi bằng chứng mâu thuẫn

Ngược lại, nhãn FAKE được gán khi các bằng chứng đáng tin cậy mâu thuẫn hoặc bác bỏ (trong thuật ngữ NLI, đây gọi là quan hệ Contradiction) luận điểm. Điều này có nghĩa là các nguồn thông tin uy tín cho thấy sự kiện mà claim đưa ra không đúng với thực tế hoặc đã bị bóp méo.

Việc gán nhãn FAKE cũng đòi hỏi sự thận trọng tương tự. Hệ thống phải chắc chắn rằng bằng chứng bác bỏ đến từ nguồn đáng tin cậy và có sự mâu thuẫn rõ ràng, trực tiếp với claim. Ví dụ, nếu một claim nói rằng "Vaccine COVID-19 gây ra tỷ lệ tử vong 30% trong số người tiêm" nhưng các nghiên cứu y khoa được công bố trên các tạp chí uy tín và số liệu từ Bộ Y tế cho thấy tỷ lệ tác dụng phụ nghiêm trọng chỉ là 0.001% và không có trường hợp tử vong trực tiếp, thì đây là một mâu thuẫn rõ ràng và claim sẽ được gán nhãn FAKE.

Điều quan trọng là hệ thống phải phân biệt được giữa việc một claim bị bác bỏ hoàn toàn với việc một claim chỉ bị phản bác một phần hoặc có sắc thái khác. Ví dụ, nếu claim nói "Giá xăng tăng 10,000 đồng/lít" nhưng thực tế giá chỉ tăng 8,000 đồng/lít, đây là một sự sai lệch về chi tiết nhưng vẫn là thông tin sai và có thể được gán nhãn FAKE. Tuy nhiên, hệ thống cũng nên cung cấp bối cảnh rõ ràng về mức độ sai lệch để người dùng hiểu đầy đủ.

=== UNDEFINED (Không xác định) - Sự trung thực của hệ thống

Đây là một nhãn cực kỳ quan trọng và thể hiện triết lý thiết kế cốt lõi của hệ thống: sự trung thực và thận trọng. Thay vì ép buộc mọi claim vào hai nhãn REAL hoặc FAKE, chúng tôi cho phép hệ thống thừa nhận khi nó không thể đưa ra kết luận chắc chắn. Đây là một điểm khác biệt quan trọng so với nhiều hệ thống khác, và nó giúp xây dựng niềm tin lâu dài với người dùng.

Một claim có thể nhận được nhãn UNDEFINED trong nhiều tình huống khác nhau, mỗi tình huống phản ánh một khía cạnh khác nhau của sự phức tạp trong thông tin:

*Thiếu bằng chứng (Insufficient Evidence)*: Đây là trường hợp phổ biến nhất. Hệ thống đã tìm kiếm trong toàn bộ cơ sở tri thức của mình (được xây dựng thông qua module build_vector_db.py) nhưng không tìm thấy bất kỳ thông tin liên quan nào có thể xác minh claim. Điều này đặc biệt hay xảy ra với các sự kiện vừa mới xảy ra mà chưa có đủ thời gian để các nguồn tin đáng tin cậy công bố thông tin, hoặc với các chủ đề quá hẹp, quá chuyên môn mà không có nhiều nguồn tham khảo. Ví dụ, một claim về một vụ tai nạn giao thông nhỏ xảy ra cách đây 2 giờ tại một tỉnh xa có thể chưa có trong bất kỳ nguồn tin đáng tin cậy nào.

*Bằng chứng mơ hồ (Ambiguous Evidence)*: Trong trường hợp này, hệ thống đã tìm thấy các bằng chứng có liên quan đến claim, nhưng mối quan hệ giữa chúng không đủ rõ ràng để xác định ủng hộ hay bác bỏ. Trong thuật ngữ NLI, kết quả là Neutral - tức là bằng chứng không mâu thuẫn với claim nhưng cũng không trực tiếp xác nhận nó. Ví dụ, một claim nói "Công ty X dự định sa thải 1000 nhân viên" nhưng bằng chứng tìm được chỉ nói rằng "Công ty X đang trong quá trình tái cấu trúc" mà không đề cập cụ thể đến số lượng nhân viên. Hai thông tin có liên quan nhưng không đủ để kết luận chắc chắn.

*Bằng chứng xung đột (Conflicting Evidence)*: Đây là tình huống thú vị và phức tạp. Hệ thống tìm thấy nhiều nguồn bằng chứng đều đáng tin cậy về mặt nguồn, nhưng chúng lại đưa ra thông tin trái ngược nhau. Ví dụ, một claim về số lượng người tham dự một sự kiện: một báo nói là 10,000 người, một báo khác nói là 15,000 người, và một nguồn thứ ba nói là 8,000 người. Tất cả đều là nguồn tin uy tín nhưng thông tin không nhất quán. Trong trường hợp này, thay vì tùy tiện chọn một nguồn để tin, hệ thống trung thực thừa nhận rằng có sự không chắc chắn và gán nhãn UNDEFINED.

*Claim không thể kiểm chứng về bản chất*: Đây là trường hợp mà claim về cơ bản không phù hợp với định nghĩa của một luận điểm có thể kiểm chứng. Nó có thể là một ý kiến chủ quan ("Bộ phim này hay nhất năm"), một dự đoán về tương lai chưa xảy ra ("Đội tuyển Việt Nam sẽ vô địch AFF Cup năm sau"), hoặc một câu hỏi tu từ không đưa ra khẳng định cụ thể. Mặc dù Claim Detector lý tưởng nên lọc ra những trường hợp này trước khi chúng đến giai đoạn xác minh, nhưng một số trường hợp biên có thể vượt qua và cần được gán nhãn UNDEFINED.

Việc thừa nhận sự "không chắc chắn" thông qua nhãn UNDEFINED không chỉ là một lựa chọn kỹ thuật mà còn là một lựa chọn đạo đức. Nó giúp hệ thống tránh đưa ra các kết luận vội vàng, sai lầm có thể gây hậu quả nghiêm trọng. Hơn nữa, nó giáo dục người dùng về thực tế rằng không phải mọi thông tin đều có thể được xác minh ngay lập tức với độ chắc chắn tuyệt đối. Điều này giúp xây dựng được thói quen tư duy phản biện và sự tin tưởng dài hạn nơi người dùng, vì họ biết rằng hệ thống sẽ không bao giờ đánh lừa họ bằng những kết luận giả tạo.

== Các thách thức (Challenges) - Vượt qua rào cản thực tế

Bài toán kiểm chứng thông tin trong môi trường thực tế không chỉ là một bài toán kỹ thuật đơn thuần. Nó là sự giao thoa phức tạp giữa xử lý ngôn ngữ tự nhiên, học máy, quản lý dữ liệu, và các yếu tố con người. Mỗi thách thức dưới đây đại diện cho một khía cạnh khó khăn của bài toán, và kiến trúc của dự án được thiết kế một cách có chủ đích để trực diện giải quyết từng thách thức này.

=== Concept Drift (Sự trôi dạt khái niệm) - Kẻ thù thầm lặng

Concept Drift là một trong những thách thức lớn nhất và thường bị đánh giá thấp trong việc xây dựng các hệ thống AI trong thế giới thực. Để hiểu về nó, chúng ta cần hiểu rằng thế giới thông tin không bao giờ đứng im. Những gì đúng hôm nay có thể trở nên lỗi thời vào ngày mai. Những chủ đề quan trọng trong tháng này có thể không còn ai nhắc đến trong tháng sau. Cách mà người ta diễn đạt thông tin, từ ngữ họ sử dụng, và ngay cả định nghĩa của "tin giả" cũng có thể thay đổi theo thời gian.

Hãy tưởng tượng bạn huấn luyện một mô hình vào tháng Một năm 2024 để phát hiện tin giả về COVID-19. Mô hình này học được các mẫu ngôn ngữ và nội dung liên quan đến vaccine, biến thể virus, và các chính sách phong tỏa. Đến tháng Sáu cùng năm, khi tình hình dịch bệnh thay đổi, các thuật ngữ mới xuất hiện, các chính sách mới được ban hành, và các chiến thuật lan truyền tin giả cũng tiến hóa để tránh bị phát hiện. Mô hình cũ của bạn, dù từng rất hiệu quả, giờ đây hoạt động kém đi đáng kể vì nó không "biết" về những thay đổi mới này. Đây chính xác là hiện tượng Concept Drift - các "khái niệm" mà mô hình học được đã "trôi dạt" khỏi thực tế hiện tại.

Vấn đề này còn nghiêm trọng hơn trong lĩnh vực kiểm chứng thông tin vì tốc độ thay đổi cực kỳ nhanh. Các tác nhân tung tin giả có động lực mạnh mẽ để liên tục thay đổi chiến thuật. Nếu họ phát hiện một mẫu ngôn ngữ nào đó thường bị hệ thống gắn cờ, họ sẽ nhanh chóng thay đổi cách diễn đạt. Nếu một chủ đề trở nên nhạy cảm và được giám sát chặt chẽ, họ sẽ chuyển sang chủ đề khác. Đây là một cuộc chạy đua vũ trang không bao giờ kết thúc giữa hệ thống phát hiện và các tác nhân tung tin giả.

*Giải pháp của dự án*: Đây là thách thức trung tâm mà toàn bộ kiến trúc Continuous Learning (Học liên tục) của chúng tôi được thiết kế để giải quyết. Thay vì xem việc huấn luyện mô hình như một hoạt động một lần, chúng tôi xây dựng nó thành một quy trình liên tục, tự động và có chu kỳ.

Hệ thống hoạt động như sau: Mỗi ngày, các tác vụ thu thập dữ liệu (được định nghĩa trong daily_crawl_dag.py) tự động chạy để thu thập thông tin mới nhất từ các nguồn tin tức, mạng xã hội, và các trang web khác. Dữ liệu này không chỉ được sử dụng ngay lập tức cho việc xác minh mà còn được lưu trữ và tích lũy. Sau đó, vào một lịch trình đều đặn (ví dụ hàng tuần), hệ thống kích hoạt quy trình huấn luyện lại tự động (weekly_retrain_dag.py).

Trong quá trình huấn luyện lại này, các mô hình hiện tại được cập nhật bằng cách học từ dữ liệu mới nhất. Mô hình NLI được huấn luyện lại thông qua retrain_nli.py, trong khi toàn bộ pipeline cũng được tối ưu hóa qua retrain_pipeline.py. Điều quan trọng là hệ thống không chỉ đơn thuần thêm dữ liệu mới mà còn điều chỉnh trọng số để cân bằng giữa việc ghi nhớ kiến thức cũ (tránh catastrophic forgetting) và học hỏi kiến thức mới.

Kết quả là một hệ thống có khả năng "진화" liên tục. Mỗi tuần, mô hình trở nên thông minh hơn một chút, hiểu rõ hơn về các chủ đề mới, và thích ứng tốt hơn với các chiến thuật lan truyền thông tin sai lệch mới. Đây không phải là một hệ thống tĩnh mà là một hệ thống sống, luôn học hỏi và phát triển cùng với môi trường thông tin xung quanh nó.
#align(center)[
  #image("images/Concept-Drift .png", width: 400pt)
]
=== Data Sparsity (Sự thưa thớt của dữ liệu) - Khi thông tin khan hiếm

Data Sparsity là một thách thức cơ bản trong machine learning, nhưng nó đặc biệt nghiêm trọng trong lĩnh vực kiểm chứng thông tin. Vấn đề xuất hiện khi hệ thống phải xử lý các sự kiện vừa mới xảy ra hoặc các chủ đề rất hẹp, nơi mà lượng dữ liệu đáng tin cậy sẵn có cực kỳ ít hoặc thậm chí không tồn tại.

Hãy nghĩ về một tin tức breaking news vừa xảy ra cách đây 30 phút. Một chính trị gia quan trọng vừa đưa ra một tuyên bố gây tranh cãi. Trong vòng vài phút, hàng chục phiên bản khác nhau của câu chuyện này xuất hiện trên mạng xã hội, một số chính xác nhưng nhiều cái đã bị bóp méo hoặc hiểu sai. Tại thời điểm này, các nguồn tin chính thống và đáng tin cậy có thể chưa kịp xác minh và công bố thông tin. Đây chính là tình huống Data Sparsity cấp độ thời gian - chúng ta có một claim cần xác minh nhưng chưa có đủ bằng chứng đáng tin cậy.

Một dạng khác của Data Sparsity là về phạm vi chủ đề. Ví dụ, một claim về một loại thuốc hiếm dùng để điều trị một bệnh không phổ biến, hoặc về một sự kiện xảy ra ở một vùng địa lý rất cụ thể và hẻo lánh. Với những chủ đề như vậy, ngay cả khi sự kiện đã xảy ra từ lâu, lượng thông tin đáng tin cậy có sẵn vẫn rất hạn chế vì không có nhiều người quan tâm và viết về nó.

Data Sparsity không chỉ ảnh hưởng đến giai đoạn xác minh (khi không có đủ bằng chứng) mà còn ảnh hưởng đến giai đoạn huấn luyện mô hình. Các mô hình machine learning cần một lượng lớn ví dụ để học các mẫu hiệu quả. Nếu dữ liệu huấn luyện chỉ tập trung vào một vài chủ đề phổ biến, mô hình sẽ hoạt động kém với các chủ đề ít gặp

#align(center)[
  #image("images/Data-Sparsity.jpg", width: 400pt)
]