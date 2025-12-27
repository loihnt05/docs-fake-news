#set par(justify: true)
 
= Cơ chế Học và Ra quyết định - Phiên bản Mở rộng

Sau khi hệ thống đã có khả năng tìm kiếm thông tin, trích xuất đặc trưng và xác minh từng bằng chứng, chúng ta đến với thành phần quan trọng nhất, thứ biến hệ thống từ một công cụ phân tích tĩnh thành một hệ thống thông minh có khả năng tự tiến hóa. Chương này sẽ đi sâu vào cách hệ thống tổng hợp thông tin, đưa ra quyết định cuối cùng và quan trọng hơn cả, cách nó học hỏi từ chính những trường hợp không chắc chắn để trở nên thông minh hơn theo thời gian.

== Tại sao không sử dụng luật cứng (Hard Rules)?

Trước khi đi vào chi tiết về cơ chế ra quyết định của hệ thống, chúng ta cần hiểu tại sao một cách tiếp cận đơn giản hơn, đó là sử dụng các luật cứng, lại không phù hợp với bài toán phát hiện tin giả.

=== Cách tiếp cận bằng luật cứng là gì?

Một hệ thống dựa trên luật cứng hoạt động theo logic if-then đơn giản. Ví dụ, chúng ta có thể định nghĩa các luật như sau: "Nếu bài viết chứa từ khóa 'chữa khỏi ung thư' và đến từ một trang web không nằm trong danh sách các nguồn y khoa uy tín thì đánh dấu là tin giả" hoặc "Nếu tiêu đề sử dụng chữ in hoa toàn bộ và chứa từ 'NÓNG HỔI' thì có xác suất cao là tin giả".

Cách tiếp cận này trông có vẻ hợp lý vì nó dễ hiểu, dễ triển khai và minh bạch. Một người không chuyên về công nghệ vẫn có thể đọc và hiểu được tại sao hệ thống lại đưa ra một quyết định nhất định. Tuy nhiên, trong thực tế, phương pháp này có những hạn chế nghiêm trọng khiến nó không thể hoạt động hiệu quả trong môi trường thông tin phức tạp và luôn thay đổi như hiện nay.

=== Vấn đề Overfitting - Quá khớp với dữ liệu cũ

Hãy tưởng tượng bạn là một giáo viên đang dạy học sinh nhận biết hoa quả. Thay vì dạy cho học sinh các đặc điểm chung của quả táo (tròn, có cuống, thường có màu đỏ hoặc xanh, vỏ mịn), bạn lại cho học sinh ghi nhớ từng quả táo cụ thể mà các em đã thấy: "Quả táo số một có màu đỏ, nặng 150 gram, có một vết lõm nhỏ ở phía dưới". Học sinh của bạn sẽ nhận diện chính xác những quả táo mà các em đã gặp, nhưng sẽ bối rối khi gặp một quả táo có màu vàng hoặc nặng 200 gram.

Đây chính xác là vấn đề của luật cứng trong phát hiện tin giả. Các luật này về bản chất là việc "ghi nhớ" các mẫu cụ thể của tin giả đã xuất hiện trong quá khứ. Chúng bị quá khớp (overfitting) vào những đặc điểm rất cụ thể và thiếu khả năng tổng quát hóa sang các trường hợp mới.

Giả sử bạn phát hiện ra rằng nhiều tin giả về chính trị thường sử dụng cụm từ "nguồn tin đáng tin cậy cho biết" mà không cung cấp nguồn cụ thể. Bạn tạo ra luật: "Nếu bài viết chứa cụm từ này mà không có trích dẫn cụ thể thì đánh dấu là tin giả". Người tạo tin giả chỉ cần thay đổi một chút thành "theo một nguồn uy tín" hoặc "chúng tôi được biết từ nguồn tin" là đã vượt qua được luật này. Họ có thể thay đổi vô số biến thể với rất ít công sức, trong khi bạn phải liên tục cập nhật hàng trăm, hàng nghìn luật mới để bắt kịp.

Vấn đề trở nên tồi tệ hơn khi các luật này tích lũy theo thời gian. Sau một năm, hệ thống của bạn có thể có hàng nghìn luật được thêm vào. Nhiều luật trong số này đã lỗi thời vì chúng phản ánh các kiểu tấn công cũ mà người tạo tin giả không còn sử dụng nữa. Nhưng chúng vẫn tồn tại trong hệ thống và có thể gây ra các phân loại sai. Việc quản lý, cập nhật và đảm bảo các luật này không xung đột với nhau trở thành một cơn ác mộng về bảo trì.

=== False Certainty - Sự tự tin sai lầm nguy hiểm

Có một vấn đề tinh vi nhưng có lẽ còn nghiêm trọng hơn cả overfitting, đó là các luật cứng tạo ra một ảo giác về sự chắc chắn. Chúng hoạt động theo logic nhị phân tuyệt đối: hoặc là đúng, hoặc là sai, không có vùng xám ở giữa.

Hãy xem xét tình huống sau: một nhà báo viết một bài phân tích chuyên sâu về các chiến thuật của tin giả, trong đó trích dẫn nhiều ví dụ về các tin giả để phân tích. Bài viết này có thể vô tình kích hoạt nhiều luật cứng của bạn vì nó chứa các từ khóa, cụm từ điển hình của tin giả. Hệ thống sẽ đánh dấu bài viết này là tin giả với độ tự tin một trăm phần trăm, mặc dù đó hoàn toàn là một bài phân tích nghiêm túc về tin giả.

Tương tự, một bài báo châm biếm (satire) cố tình sử dụng các yếu tố của tin giả để chế nhạo hoặc phê phán cũng sẽ bị đánh giá sai. Một người đọc thông thường có thể nhận ra đó là châm biếm dựa vào ngữ cảnh, giọng văn và nguồn xuất bản, nhưng hệ thống luật cứng không có khả năng này.

Điều nguy hiểm nhất là hệ thống sẽ báo cáo kết quả này với sự tự tin tuyệt đối. Nó không thể nói rằng "Tôi không chắc lắm về trường hợp này". Người dùng nhìn thấy một kết quả dứt khoát và có thể nghĩ rằng hệ thống rất chắc chắn, trong khi thực tế hệ thống chỉ đang áp dụng một luật máy móc mà không hiểu ngữ cảnh.

Ngược lại, một hệ thống dựa trên xác suất và học máy có thể biểu thị sự không chắc chắn một cách trung thực. Nó có thể nói: "Tôi khá chắc chắn đây là tin giả với xác suất 95%" hoặc "Tôi thấy một số dấu hiệu đáng ngờ nhưng chỉ tự tin 55%, nên cần kiểm tra thêm". Điều này không chỉ trung thực hơn mà còn hữu ích hơn rất nhiều. Người dùng biết được mức độ tin cậy của kết quả và có thể quyết định có nên tìm hiểu thêm hay không. Các hệ thống tự động khác có thể đặt ngưỡng để chỉ hành động với các kết quả có độ tự tin cao.

=== Thiếu khả năng thích nghi

Môi trường thông tin là một hệ thống đối kháng (adversarial system). Khi bạn phát triển một phương pháp phát hiện tin giả, những người tạo tin giả sẽ học cách đối phó với nó. Đây là một cuộc chạy đua vũ trang không ngừng nghỉ.

Các luật cứng về cơ bản là tĩnh. Chúng phản ánh hiểu biết của bạn về tin giả tại một thời điểm cụ thể. Để cập nhật chúng, bạn cần can thiệp thủ công: quan sát các mẫu mới, viết luật mới, kiểm tra xem chúng không làm hỏng các luật cũ. Quá trình này chậm, tốn kém và đòi hỏi chuyên môn.

Trong khi đó, một hệ thống học máy có khả năng tự điều chỉnh khi được cung cấp dữ liệu mới. Nó có thể phát hiện ra các mẫu mới mà ngay cả chuyên gia cũng chưa nhận ra. Nó có thể điều chỉnh trọng số của các đặc trưng khác nhau khi môi trường thay đổi, tất cả một cách tự động.

== Bộ máy quyết định (Decision Engine) - Tổng hợp thông minh các tín hiệu

Bây giờ chúng ta hiểu tại sao luật cứng không phù hợp, hãy xem xét cách hệ thống thực sự đưa ra quyết định. Bộ máy quyết định này là nơi tất cả các thông tin từ các giai đoạn trước được tổng hợp lại để tạo ra một đánh giá cuối cùng.

=== Bài toán tổng hợp đa bằng chứng

Hãy nhớ lại rằng khi một claim được đưa vào hệ thống, nó không chỉ được so sánh với một bằng chứng duy nhất. Trong chương 4, chúng ta đã mô tả việc tìm kiếm top-k bằng chứng (thường k bằng 3 hoặc 5) có liên quan nhất đến claim đó. Mỗi bằng chứng sau đó được đưa vào mô hình Natural Language Inference để xác định mối quan hệ với claim.

Điều này có nghĩa là với một claim duy nhất, chúng ta có thể có một tập hợp các kết quả như sau. Giả sử claim là "Việt Nam đã thắng Indonesia với tỷ số 3-0 trong trận chung kết AFF Cup 2024":

Bằng chứng một từ VnExpress báo cáo: "Tuyển Việt Nam chiến thắng Indonesia 3-0 trong trận đấu lịch sử tại chung kết AFF Cup". Mô hình NLI cho kết quả Ủng hộ (Entailment) với xác suất 0.98.

Bằng chứng hai từ báo Thái Lan: "Indonesia bất ngờ để thua Việt Nam trong trận chung kết khu vực". Mô hình NLI cho kết quả Ủng hộ với xác suất 0.87 (thấp hơn một chút vì câu không nói rõ tỷ số).

Bằng chứng ba từ một blog cá nhân không rõ nguồn: "Trận đấu diễn ra căng thẳng và kịch tính". Mô hình NLI cho kết quả Trung lập (Neutral) với xác suất 0.92 vì câu này không xác nhận cũng không bác bỏ tỷ số cụ thể.

Bây giờ, làm thế nào để tổng hợp ba tín hiệu này thành một quyết định cuối cùng? Đây không phải là một bài toán tầm thường. Chúng ta không thể chỉ đơn giản lấy kết quả xuất hiện nhiều nhất (majority voting) vì không phải tất cả các bằng chứng đều có giá trị như nhau. Chúng ta cũng không thể chỉ tin vào bằng chứng có xác suất cao nhất vì có thể có những bằng chứng khác cung cấp thông tin quan trọng.

=== Chiến lược ưu tiên sự bác bỏ (Priority of Contradiction)

Hệ thống áp dụng một nguyên tắc bất đối xứng quan trọng: sự bác bỏ được ưu tiên cao hơn sự ủng hộ. Nguyên tắc này xuất phát từ một quan sát thực tế về cách thông tin sai lệch lan truyền.

Hãy suy nghĩ về cách chúng ta xác minh thông tin trong cuộc sống hàng ngày. Nếu một người bạn nói với bạn rằng họ đã thấy một ngôi sao điện ảnh nổi tiếng tại một quán cà phê, bạn có thể tin hoặc không tin. Nhưng nếu bạn tìm kiếm và phát hiện ra rằng ngôi sao đó đang ở một quốc gia hoàn toàn khác vào thời điểm đó (có bằng chứng từ mạng xã hội được xác minh của chính người đó), thì bạn biết chắc chắn rằng câu chuyện của bạn bè là sai. Chỉ cần một bằng chứng bác bỏ mạnh là đủ để phủ nhận một tuyên bố.

Trong hệ thống của chúng ta, chiến lược này được thực hiện như sau: Nếu có bất kỳ bằng chứng nào cho kết quả Bác bỏ (Contradiction) với xác suất cao (ví dụ trên 0.85) và đặc biệt nếu bằng chứng đó đến từ một nguồn có độ tin cậy cao, claim sẽ được đánh giá nghiêng về phía FAKE ngay cả khi có nhiều bằng chứng khác cho kết quả Ủng hộ hoặc Trung lập.

Để hiểu tại sao điều này hợp lý, hãy xem xét một ví dụ cụ thể. Giả sử có một claim: "Tổng thống Mỹ đã đến thăm Việt Nam vào ngày 15 tháng 10". Chúng ta tìm thấy:

Ba bài báo địa phương đưa tin về sự kiện này (Ủng hộ).

Hai bài viết trên mạng xã hội chia sẻ hình ảnh (Ủng hộ).

Một bài báo từ Reuters nói rõ ràng rằng Tổng thống Mỹ đang ở Washington DC tham dự họp Quốc hội vào ngày đó, có video trực tiếp (Bác bỏ với xác suất 0.96).

Trong trường hợp này, mặc dù có năm bằng chứng có vẻ ủng hộ claim và chỉ một bằng chứng bác bỏ, hệ thống sẽ đánh giá claim là FAKE. Lý do là bằng chứng bác bỏ đến từ một nguồn uy tín cao, có độ chính xác cao và cung cấp một alibi không thể bác bỏ được. Logic này tuân theo nguyên tắc "một lời nói dối có thể làm hỏng cả một câu chuyện thật" hoặc trong triết học khoa học, "một phản ví dụ duy nhất có thể bác bỏ một giả thuyết".

Tuy nhiên, chúng ta cần cẩn thận với việc áp dụng nguyên tắc này. Không phải mọi bác bỏ đều có trọng lượng như nhau. Hệ thống cần xem xét độ tin cậy của nguồn và độ tự tin của mô hình NLI. Một bằng chứng bác bỏ từ một blog không rõ nguồn gốc với xác suất chỉ 0.6 không đủ mạnh để vượt qua nhiều bằng chứng ủng hộ từ các nguồn tin cậy.

=== Yêu cầu đồng thuận cho sự ủng hộ (Consensus for Entailment)

Ngược lại với việc ưu tiên bác bỏ, để một claim được xác nhận là REAL, hệ thống đòi hỏi một chuẩn mực cao hơn: phải có sự đồng thuận từ nhiều bằng chứng và quan trọng là không có bác bỏ mạnh nào.

Điều này phản ánh một nguyên tắc thận trọng trong báo chí và nghiên cứu: xác nhận một điều gì đó là sự thật đòi hỏi nhiều bằng chứng hội tụ cùng một kết luận. Một nguồn duy nhất, dù uy tín đến đâu, cũng có thể mắc lỗi. Nhưng khi nhiều nguồn độc lập đều đưa ra cùng một thông tin, khả năng nó đúng tăng lên đáng kể.

Trong thực tế, hệ thống có thể áp dụng một ngưỡng như sau: Để gán nhãn REAL với độ tự tin cao, cần ít nhất 60% các bằng chứng top-k cho kết quả Ủng hộ với xác suất trung bình trên 0.8, và không có bằng chứng nào cho kết quả Bác bỏ với xác suất trên 0.7.

Các bằng chứng Trung lập (Neutral) đóng vai trò như những "phiếu trắng". Chúng không ủng hộ cũng không bác bỏ claim, thường vì chúng đề cập đến cùng một chủ đề nhưng không cung cấp thông tin cụ thể liên quan đến claim. Trong hầu hết các trường hợp, các bằng chứng này được bỏ qua trong quá trình tổng hợp. Tuy nhiên, nếu tất cả các bằng chứng tìm được đều là Trung lập, điều này là một tín hiệu rõ ràng rằng hệ thống không có đủ thông tin để đưa ra quyết định, và claim sẽ được gán nhãn UNDEFINED.

=== Đầu ra nhận biết độ tự tin (Confidence-aware Output)

Một trong những đổi mới quan trọng nhất của hệ thống là nó không chỉ đưa ra một nhãn nhị phân REAL hay FAKE. Thay vào đó, mỗi quyết định đều đi kèm với một điểm số độ tự tin (confidence score), tạo thành một cặp kết quả dạng (label, confidence_score).

Điểm tự tin này không phải là một con số được gán một cách tùy tiện. Nó được tính toán một cách có nguyên tắc dựa trên các yếu tố sau:

Đầu tiên, xác suất softmax từ mô hình NLI. Khi mô hình NLI xử lý một cặp claim-evidence, đầu ra của nó không chỉ là một nhãn mà là một phân phối xác suất trên ba nhãn có thể: Ủng hộ, Bác bỏ, Trung lập. Ví dụ, đầu ra có thể là {Ủng hộ: 0.92, Bác bỏ: 0.05, Trung lập: 0.03}. Xác suất của nhãn được chọn (trong trường hợp này là 0.92) phản ánh mức độ chắc chắn của mô hình.

Thứ hai, sự nhất quán giữa các bằng chứng. Nếu tất cả các bằng chứng đều cho cùng một kết quả (ví dụ, tất cả đều Ủng hộ với xác suất cao), điểm tự tin tổng thể sẽ cao. Ngược lại, nếu các bằng chứng cho kết quả mâu thuẫn nhau (một số Ủng hộ, một số Bác bỏ), điểm tự tin sẽ thấp hơn ngay cả khi chúng ta có thể đưa ra một nhãn cuối cùng.

Thứ ba, độ tin cậy của nguồn. Bằng chứng từ Reuters hoặc BBC sẽ được gán trọng số cao hơn bằng chứng từ một blog cá nhân. Điều này được tích hợp vào quá trình tính toán điểm tự tin.

Thứ tư, số lượng bằng chứng tìm được. Nếu hệ thống chỉ tìm được một hoặc hai bằng chứng thay vì năm bằng chứng như mong đợi, điều này gợi ý rằng thông tin về chủ đề này còn khan hiếm, và điểm tự tin nên được điều chỉnh giảm.

Kết quả cuối cùng có thể trông như thế này: (FAKE, 0.94) hoặc (REAL, 0.73) hoặc (UNDEFINED, 0.99). Mỗi kết quả này kể một câu chuyện khác nhau.

Kết quả (FAKE, 0.94) nói rằng: "Hệ thống rất chắc chắn đây là thông tin sai lệch. Có bằng chứng bác bỏ mạnh từ nhiều nguồn đáng tin cậy."

Kết quả (REAL, 0.73) nói rằng: "Hệ thống nghĩ thông tin này có khả năng đúng, nhưng không hoàn toàn chắc chắn. Có thể có một số mâu thuẫn nhỏ hoặc thiếu bằng chứng từ các nguồn uy tín nhất."

Kết quả (UNDEFINED, 0.99) nói rằng: "Hệ thống rất chắc chắn rằng nó không có đủ thông tin để đưa ra đánh giá. Đây là một lĩnh vực mà hệ thống cần thêm dữ liệu."

=== Tại sao điểm tự tin quan trọng đến vậy?

Việc cung cấp điểm tự tin mang lại nhiều lợi ích thiết thực:

Đối với người dùng cuối cùng, nó tạo ra sự minh bạch. Thay vì chỉ nhìn thấy một nhãn "Tin giả" và phải tin tưởng hoàn toàn vào hệ thống, người dùng có thể thấy mức độ chắc chắn. Điều này giúp họ đưa ra quyết định sáng suốt hơn về việc có nên tìm hiểu thêm hay không. Nếu một bài báo được đánh dấu (FAKE, 0.55), người dùng biết rằng đây là một trường hợp biên giới và có thể đáng để họ tự kiểm tra thêm.

Đối với các hệ thống tự động hoặc biên tập viên, điểm tự tin cho phép họ thiết lập các ngưỡng hành động. Ví dụ, một nền tảng mạng xã hội có thể quyết định chỉ tự động gắn cảnh báo lên các bài viết được đánh giá là tin giả với độ tự tin trên 0.85. Các trường hợp có độ tự tin thấp hơn có thể được chuyển cho con người xem xét. Điều này cân bằng giữa tự động hóa và sự cẩn thận cần thiết.

Đối với việc cải thiện hệ thống, điểm tự tin cung cấp một tín hiệu về nơi hệ thống đang gặp khó khăn. Nếu nhiều claim được gán nhãn với độ tự tin thấp (ví dụ trong khoảng 0.5-0.7), điều này cho thấy hệ thống đang phải đối mặt với nhiều trường hợp khó khăn và có thể cần thêm dữ liệu huấn luyện hoặc cải thiện thuật toán.

Từ góc độ đạo đức và pháp lý, việc thừa nhận sự không chắc chắn là rất quan trọng. Một hệ thống đưa ra các quyết định nhị phân tuyệt đối có thể tạo ra hậu quả nghiêm trọng nếu nó sai. Nhưng một hệ thống nói rõ "Tôi có 75% chắc chắn" đang thể hiện sự khiêm tốn trí tuệ phù hợp với giới hạn của công nghệ hiện tại.

== Vòng đời của một nhãn (Label Lifecycle) - Cơ chế tự tiến hóa

Đây là phần quan trọng nhất của toàn bộ hệ thống, nơi thể hiện rõ nhất tư duy hệ thống và khả năng tự học hỏi. Vòng đời nhãn mô tả cách một claim đi từ trạng thái không chắc chắn, qua sự can thiệp của con người, và cuối cùng trở thành một phần của tri thức mà hệ thống có thể tái sử dụng trong tương lai.

=== Giai đoạn 1: Trạng thái khởi đầu UNDEFINED

Hãy tưởng tượng một tình huống thực tế. Một sự kiện chính trị quan trọng vừa xảy ra vào sáng nay, chẳng hạn như một cuộc họp cấp cao bất ngờ giữa các nhà lãnh đạo. Trong vòng một giờ, hàng chục claim về sự kiện này xuất hiện trên mạng xã hội. Một claim cụ thể nói rằng "Hai nhà lãnh đạo đã ký một thỏa thuận thương mại trị giá 50 tỷ đô la".

Khi claim này được đưa vào hệ thống, nó gặp phải một thách thức cơ bản: sự kiện này quá mới. Cơ sở tri thức của hệ thống, dù được cập nhật thường xuyên, vẫn chủ yếu chứa thông tin đến từ ngày hôm qua trở về trước. Các bài báo chính thống về sự kiện này có thể vẫn đang được viết. Các fact-checkers chuyên nghiệp chưa kịp điều tra.

Khi mô hình truy xuất thông tin tìm kiếm các bằng chứng liên quan, nó có thể tìm thấy một vài bài viết đề cập đến cuộc họp, nhưng không có bài nào nói rõ về thỏa thuận thương mại cụ thể hay con số 50 tỷ đô la. Kết quả là, tất cả các bằng chứng đều được mô hình NLI đánh giá là Trung lập - chúng liên quan đến cùng một chủ đề nhưng không xác nhận cũng không bác bỏ claim cụ thể.

Bộ máy quyết định, khi đối mặt với tình huống này, đưa ra kết luận hợp lý nhất: (UNDEFINED, 0.99). Điểm tự tin cao (0.99) không có nghĩa là hệ thống chắc chắn claim này đúng hay sai, mà có nghĩa là hệ thống rất chắc chắn rằng nó không có đủ thông tin để đưa ra đánh giá. Đây là một sự khác biệt quan trọng.

Trạng thái UNDEFINED không phải là một thất bại của hệ thống. Thực tế, đó là một tín hiệu có giá trị. Nó nói rằng "Đây là một lĩnh vực mà tôi cần học thêm". Trong một hệ thống cứng nhắc hơn, hệ thống có thể buộc phải đưa ra một đánh giá ngay cả khi không chắc chắn, dẫn đến nhiều lỗi sai. Việc thừa nhận sự không biết là dấu hiệu của một hệ thống trưởng thành.

=== Giai đoạn 2: Kích hoạt cơ chế Human-in-the-loop

Các claim được gán nhãn UNDEFINED không đơn giản nằm yên trong cơ sở dữ liệu. Chúng được đẩy vào một hàng đợi ưu tiên (priority queue) để chờ được xem xét bởi các chuyên gia fact-checker.

Hàng đợi này không hoạt động theo nguyên tắc "đến trước được phục vụ trước" (first-come-first-served). Thay vào đó, nó sử dụng một thuật toán ưu tiên thông minh dựa trên nhiều yếu tố:

Tần suất truy cập hoặc mức độ viral: Nếu một claim UNDEFINED đang được chia sẻ rộng rãi trên mạng xã hội (hệ thống có thể theo dõi điều này thông qua API của các nền tảng hoặc số lượng truy vấn đến hệ thống), nó sẽ được ưu tiên cao. Một claim được xem bởi hàng triệu người có tác động tiềm ẩn lớn hơn nhiều so với một claim chỉ được một vài người thấy.

Thời gian tồn tại: Các claim mới hơn được ưu tiên cao hơn. Thông tin sai lệch lan truyền nhanh nhất trong những giờ đầu tiên sau khi xuất hiện. Can thiệp sớm có thể ngăn chặn sự lan truyền.

Chủ đề nhạy cảm: Các claim liên quan đến y tế, khẩn cấp, bầu cử hoặc các chủ đề có thể gây hại nghiêm trọng được tự động tăng mức độ ưu tiên.

Nguồn gốc: Nếu một claim đến từ một tài khoản có lịch sử lan truyền thông tin sai lệch, nó sẽ được chú ý nhiều hơn.

Giao diện dashboard (được triển khai trong dashboard/app.py) được thiết kế đặc biệt cho quy trình này. Khi một chuyên gia đăng nhập, họ nhìn thấy danh sách các claim UNDEFINED được sắp xếp theo mức độ ưu tiên. Mỗi claim được hiển thị cùng với:

- Nội dung claim đầy đủ
- Các bằng chứng mà hệ thống đã tìm thấy (kể cả các bằng chứng Trung lập)
- Lý do tại sao hệ thống đánh giá UNDEFINED
- Các metadata như thời gian xuất hiện, số lượt xem, nguồn gốc
- Các claim tương tự đã được xử lý trước đó (nếu có)

Giao diện này không chỉ hiển thị thông tin mà còn cung cấp các công cụ hỗ trợ cho chuyên gia. Ví dụ, một nút "Tìm kiếm thêm bằng chứng" cho phép chuyên gia chạy các truy vấn tìm kiếm tùy chỉnh. Một phần "Ghi chú" cho phép họ ghi lại quá trình suy luận của mình, điều này có giá trị không chỉ cho quyết định hiện tại mà còn cho việc huấn luyện các chuyên gia khác trong tương lai.

=== Giai đoạn 3: Thu thập phản hồi từ chuyên gia

Giờ đây, một chuyên gia fact-checker đã nhận claim về thỏa thuận thương mại 50 tỷ đô la. Họ bắt đầu quá trình điều tra, sử dụng các kỹ năng và công cụ chuyên nghiệp của mình.

Chuyên gia có thể kiểm tra các nguồn tin chính thức: trang web chính phủ, thông cáo báo chí từ các văn phòng lãnh đạo, các hãng thông tấn uy tín. Họ có thể liên hệ trực tiếp với các phát ngôn viên hoặc nguồn tin nội bộ. Họ có thể so sánh với các tài liệu lịch sử để xem liệu con số 50 tỷ đô la có hợp lý trong bối cảnh các thỏa thuận trước đây không.

Sau một thời gian điều tra, chuyên gia xác định rằng claim này là sai. Thực tế, trong cuộc họp đã có một thảo luận về hợp tác thương mại, nhưng không có thỏa thuận chính thức nào được ký. Con số 50 tỷ đô la có vẻ là một sự phóng đại hoặc hiểu nhầm từ một nguồn tin không xác thực.

Chuyên gia quay lại dashboard và cập nhật thông tin:

- Nhãn cuối cùng: FAKE
- Độ tin cậy của đánh giá: 0.95 (chuyên gia cũng có thể biểu thị sự không chắc chắn của họ)
- Bằng chứng chính: Link đến thông cáo báo chí chính thức phủ nhận thông tin này
- Bằng chứng bổ sung: Link đến các bài phân tích từ báo chí uy tín giải thích nguồn gốc của sự nhầm lẫn
- Ghi chú: Một đoạn văn ngắn giải thích logic đằng sau quyết định

Điều quan trọng là nhãn do chuyên gia cung cấp không chỉ là một ý kiến cá nhân. Nó được xem là "sự thật vàng" (ground truth) vì nó đến từ một quá trình điều tra chuyên nghiệp, có căn cứ. Tuy nhiên, hệ thống cũng ghi nhận rằng ngay cả chuyên gia cũng có thể sai. Vì vậy, các nhãn này có thể được xem xét lại nếu có thông tin mới.

=== Giai đoạn 4: Đóng vòng lặp và chuẩn bị cho học tập

Ngay khi chuyên gia xác nhận nhãn, một loạt các hành động được kích hoạt trong hệ thống:

Đầu tiên, cặp dữ liệu (claim, ground_truth_label) cùng với tất cả các bằng chứng liên quan được lưu vào một bộ dữ liệu chuyên biệt dành cho việc huấn luyện lại. Bộ dữ liệu này được tổ chức cẩn thận với metadata đầy đủ: thời gian tạo, chuyên gia đánh giá, lý do đánh giá, các bằng chứng được sử dụng.

Thứ hai, các bằng chứng mới mà chuyên gia tìm thấy (như thông cáo báo chí chính thức) được thêm vào cơ sở tri thức của hệ thống. Điều này có hiệu quả ngay lập tức: nếu một claim tương tự xuất hiện trong những ngày tới, hệ thống sẽ có thể tìm thấy bằng chứng này và có khả năng đưa ra đánh giá đúng mà không cần can thiệp của con người.

Thứ ba, claim ban đầu trong cơ sở dữ liệu được cập nhật trạng thái từ UNDEFINED sang FAKE. Nếu người dùng kiểm tra lại claim này, họ sẽ nhìn thấy đánh giá mới cùng với các bằng chứng mà chuyên gia đã cung cấp.

Thứ tư, một bản ghi được tạo trong hệ thống tracking để phục vụ mục đích audit và phân tích. Bản ghi này ghi lại toàn bộ hành trình của claim: khi nào nó xuất hiện, khi nào được gán UNDEFINED, khi nào được chuyên gia xem xét, và kết quả cuối cùng. Thông tin này có giá trị để đánh giá hiệu suất của hệ thống và xác định các mẫu.

=== Giai đoạn 5: Hệ thống tiến hóa - Chu kỳ huấn luyện lại

Chu kỳ huấn luyện lại là nơi mà toàn bộ vòng đời nhãn được hoàn thành, biến thông tin từ sự can thiệp của con người thành khả năng tự động của máy.

Hệ thống sử dụng Apache Airflow để điều phối các tác vụ huấn luyện định kỳ. DAG (Directed Acyclic Graph) có tên weekly_retrain_dag.py định nghĩa một pipeline chạy mỗi tuần (hoặc có thể điều chỉnh tần suất tùy thuộc vào lượng dữ liệu mới).

Pipeline này thực hiện các bước sau:

Bước 1: Thu thập dữ liệu mới. Script sẽ truy vấn cơ sở dữ liệu để lấy tất cả các điểm dữ liệu mới đã được chuyên gia đánh giá từ lần huấn luyện trước đó. Giả sử trong tuần vừa qua, có 500 claim mới được xử lý bởi các chuyên gia.

Bước 2: Kiểm tra chất lượng dữ liệu. Không phải mọi điểm dữ liệu đều có giá trị như nhau. Script sẽ lọc ra các trường hợp có vấn đề: claims quá ngắn, claims thiếu bằng chứng đi kèm, hoặc các trường hợp mà nhiều chuyên gia đánh giá mâu thuẫn nhau (điều này gợi ý rằng claim đó có thể không rõ ràng).

Bước 3: Kết hợp với dữ liệu cũ. 500 điểm dữ liệu mới được thêm vào bộ dữ liệu huấn luyện hiện có. Tuy nhiên, chúng ta không chỉ đơn giản ghép chúng lại. Dữ liệu cũ có thể đã lỗi thời hoặc kém chất lượng hơn. Hệ thống áp dụng một chiến lược cân bằng: dữ liệu mới được gán trọng số cao hơn trong quá trình huấn luyện, phản ánh sự tin tưởng rằng chúng phù hợp hơn với môi trường thông tin hiện tại.

Bước 4: Huấn luyện lại các mô hình. Script retrain_pipeline.py được kích hoạt. Nó huấn luyện lại nhiều thành phần của hệ thống:

- Mô hình NLI được fine-tune thêm trên dữ liệu mới. Điều này giúp nó học cách nhận diện các mẫu ngôn ngữ mới, các cách thức diễn đạt mới của tin giả, hoặc các lĩnh vực mới mà nó trước đây chưa gặp.

- Mô hình truy xuất thông tin có thể được cập nhật embedding để phản ánh các chủ đề và từ khóa mới xuất hiện.

- Các tham số của bộ máy quyết định có thể được điều chỉnh. Ví dụ, nếu dữ liệu mới cho thấy hệ thống đang quá thận trọng (gán UNDEFINED quá nhiều), ngưỡng có thể được điều chỉnh.

Bước 5: Đánh giá trên tập kiểm tra. Trước khi triển khai mô hình mới, nó phải được đánh giá kỹ lưỡng. Hệ thống giữ một tập validation chứa các claim đã được xác minh. Mô hình mới phải đạt được hiệu suất tốt hơn hoặc ít nhất là không tệ hơn mô hình cũ trên tập này.

Bước 6: A/B testing trong môi trường production. Ngay cả sau khi vượt qua tập validation, mô hình mới không được triển khai hoàn toàn ngay lập tức. Thay vào đó, hệ thống chạy A/B testing: một phần nhỏ traffic (ví dụ 10%) được định hướng đến mô hình mới, trong khi phần lớn vẫn sử dụng mô hình cũ. Các metrics được theo dõi chặt chẽ: độ chính xác, tỷ lệ UNDEFINED, thời gian xử lý, và quan trọng nhất, phản hồi từ người dùng.

Bước 7: Triển khai hoàn toàn hoặc rollback. Nếu mô hình mới hoạt động tốt trong A/B test, nó sẽ dần dần được mở rộng ra toàn bộ hệ thống. Nếu có vấn đề, hệ thống có thể rollback về mô hình cũ một cách tự động.

=== Kết quả của vòng đời: Hệ thống đã "học" được điều gì?

Hãy quay lại với ví dụ về thỏa thuận thương mại 50 tỷ đô la. Sau chu kỳ huấn luyện, hệ thống đã trải qua những thay đổi cụ thể sau:

Thứ nhất, cơ sở tri thức hiện có thêm bằng chứng về sự kiện này. Khi một claim tương tự xuất hiện trong tương lai (ví dụ, "Thỏa thuận 50 tỷ giữa hai nước đã được ký kết"), mô hình truy xuất sẽ tìm thấy thông cáo báo chí chính thức phủ nhận thông tin này. Mô hình NLI sẽ nhận ra sự Bác bỏ và hệ thống có thể tự tin gán nhãn FAKE mà không cần can thiệp của con người.

Thứ hai, mô hình NLI đã được tinh chỉnh với điểm dữ liệu mới này. Nó không chỉ ghi nhớ claim cụ thể này, mà học được các đặc điểm tổng quát. Ví dụ, nó có thể học được rằng các claim về thỏa thuận thương mại với con số cụ thể nhưng không có nguồn chính thức thường là đáng ngờ. Nó có thể học được các mẫu ngôn ngữ điển hình của loại tin giả này.

Thứ ba, hệ thống có thể đã điều chỉnh các tham số của bộ máy quyết định. Nếu nhiều claim kiểu này đã được xác minh là FAKE, hệ thống có thể tăng trọng số cho việc yêu cầu bằng chứng từ nguồn chính thức đối với các claim về chính sách hoặc thỏa thuận quốc tế.

Lần tới, khi một claim tương tự xuất hiện - có thể về một quốc gia khác, một con số khác, nhưng cùng một pattern - hệ thống có khả năng cao hơn nhiều để đưa ra đánh giá đúng một cách tự động. Điều này không có nghĩa là nó sẽ không bao giờ gặp UNDEFINED nữa, nhưng có nghĩa là phạm vi kiến thức của nó đã được mở rộng. Các trường hợp mà trước đây cần con người giờ đây có thể được xử lý tự động, giải phóng chuyên gia để tập trung vào các thách thức mới, khó khăn hơn.

=== Tại sao vòng đời này quan trọng?

Vòng đời nhãn này là trái tim của sự khác biệt giữa một hệ thống tĩnh và một hệ thống thông minh. Nó giải quyết một nghịch lý cơ bản: chúng ta muốn hệ thống tự động để tiết kiệm thời gian và chi phí, nhưng các hệ thống tự động hoàn toàn sẽ mắc lỗi và không thể xử lý các tình huống mới.

Vòng đời này tạo ra một giải pháp thanh lịch cho nghịch lý đó:

Trong ngắn hạn, con người bù đắp cho những gì máy móc không biết. Các trường hợp UNDEFINED được chuyển cho chuyên gia, đảm bảo rằng ngay cả với thông tin mới, hệ thống vẫn có thể cung cấp câu trả lời chính xác (mặc dù không ngay lập tức).

Trong dài hạn, máy móc học từ con người và mở rộng khả năng tự động hóa. Mỗi lần con người giải quyết một trường hợp UNDEFINED, nó không chỉ là một câu trả lời đơn lẻ mà là một cơ hội học tập cho toàn bộ hệ thống.

Quan trọng hơn, vòng đời này tạo ra một hệ thống có khả năng thích nghi. Môi trường thông tin thay đổi liên tục. Các chiến thuật tạo tin giả tiến hóa. Các chủ đề mới xuất hiện. Một hệ thống tĩnh sẽ dần dần trở nên lỗi thời. Nhưng với vòng đời này, hệ thống liên tục hấp thụ thông tin mới và điều chỉnh chính nó.

== Thách thức trong triển khai Human-in-the-loop

Mặc dù cơ chế Human-in-the-loop mang lại nhiều lợi ích, việc triển khai nó trong thực tế đối mặt với nhiều thách thức.

=== Thách thức về nguồn lực con người

Chuyên gia fact-checker là một nguồn lực khan hiếm và đắt đỏ. Họ cần có kiến thức chuyên môn, kỹ năng điều tra và phải được đào tạo bài bản. Việc duy trì một đội ngũ chuyên gia đủ lớn để xử lý hàng trăm claim UNDEFINED mỗi ngày là một thách thức lớn về mặt tài chính và tổ chức.

Để giảm thiểu vấn đề này, hệ thống cần có các cơ chế thông minh để tối ưu hóa việc sử dụng nguồn lực con người:

Ưu tiên thông minh như đã mô tả, đảm bảo rằng chuyên gia tập trung vào các claim có tác động cao nhất.

Hỗ trợ công cụ tốt để giảm thời gian cần thiết cho mỗi đánh giá. Nếu một chuyên gia có thể xử lý claim trong 5 phút thay vì 20 phút nhờ có công cụ tốt, năng suất tăng gấp bốn lần.

Phân tầng chuyên môn: Không phải mọi claim đều cần một chuyên gia cấp cao. Các claim đơn giản có thể được xử lý bởi các contributor với ít kinh nghiệm hơn, được giám sát bởi chuyên gia cấp cao.

Crowdsourcing có kiểm soát: Đối với một số loại claim, có thể sử dụng mô hình crowdsourcing nơi nhiều người đóng góp đánh giá, sau đó được tổng hợp và xác thực bởi chuyên gia.

=== Đảm bảo chất lượng và nhất quán

Khi nhiều chuyên gia tham gia, một thách thức lớn là đảm bảo tính nhất quán trong đánh giá. Hai chuyên gia khác nhau có thể đưa ra kết luận khác nhau cho cùng một claim, đặc biệt trong các trường hợp biên giới hoặc các chủ đề gây tranh cãi.

Để giải quyết điều này, hệ thống cần:

Các hướng dẫn rõ ràng về tiêu chuẩn đánh giá. Khi nào nên gán FAKE vs MISLEADING? Mức độ bằng chứng cần thiết để xác nhận REAL là gì?

Quy trình xem xét kép (double-check) cho các trường hợp nhạy cảm. Các claim có tác động cao nên được ít nhất hai chuyên gia độc lập xem xét.

Theo dõi các metrics về sự đồng thuận giữa các chuyên gia. Nếu hai chuyên gia thường xuyên không đồng ý, đây có thể là dấu hiệu của việc cần đào tạo thêm hoặc làm rõ hướng dẫn.

Cơ chế khiếu nại và xem xét lại. Nếu một quyết định sau này được phát hiện là sai, cần có quy trình để sửa chữa và học hỏi từ lỗi đó.

=== Vấn đề độ trễ (Latency)

Một trong những hạn chế lớn nhất của Human-in-the-loop là thời gian. Trong khi một hệ thống tự động có thể trả về kết quả trong vài giây, việc chờ chuyên gia xem xét có thể mất vài giờ hoặc thậm chí vài ngày.

Đối với các claim không cấp bách, độ trễ này có thể chấp nhận được. Nhưng trong các tình huống khẩn cấp - ví dụ, thông tin sai lệch về một thảm họa tự nhiên đang diễn ra - vài giờ có thể có ý nghĩa sống còn.

Một số chiến lược để giảm độ trễ:

Đội chuyên gia hoạt động 24/7 với ca luân phiên, ít nhất cho các chủ đề quan trọng.

Phân loại tự động mức độ khẩn cấp để đảm bảo các claim quan trọng được xem xét ngay lập tức.

Cung cấp kết quả tạm thời: Người dùng nhìn thấy UNDEFINED ngay lập tức nhưng được thông báo rằng claim đang được xem xét và kết quả sẽ có sớm.

Trong các trường hợp cực kỳ khẩn cấp, hệ thống có thể sử dụng các quy tắc nhanh (fast rules) để đưa ra đánh giá sơ bộ trong khi chờ xác nhận từ chuyên gia.

== Học liên tục và quản lý mô hình (Continuous Learning and Model Management)

Việc huấn luyện lại định kỳ là quan trọng, nhưng nó cũng mang theo nhiều thách thức kỹ thuật và tổ chức.

=== Quyết định tần suất huấn luyện lại

Một câu hỏi quan trọng là: Nên huấn luyện lại hệ thống bao lâu một lần? Huấn luyện quá thường xuyên có thể lãng phí tài nguyên tính toán và tạo ra sự không ổn định. Huấn luyện quá ít có thể khiến hệ thống lỗi thời.

Quyết định này phụ thuộc vào nhiều yếu tố:

Lượng dữ liệu mới: Nếu chỉ có 10 điểm dữ liệu mới trong một tuần, việc huấn luyện lại có thể không cần thiết. Nhưng nếu có 1000 điểm dữ liệu mới, đó là một tín hiệu mạnh rằng nên cập nhật.

Tốc độ thay đổi của môi trường: Trong thời kỳ bầu cử hoặc khi có sự kiện lớn, môi trường thông tin thay đổi nhanh chóng. Có thể cần huấn luyện lại thường xuyên hơn, thậm chí hàng ngày.

Hiệu suất hiện tại: Nếu hệ thống monitoring phát hiện ra tỷ lệ UNDEFINED tăng đột biến hoặc độ chính xác giảm, đây là dấu hiệu cần huấn luyện lại ngay cả khi chưa đến chu kỳ định kỳ.

Chi phí tính toán: Huấn luyện các mô hình ngôn ngữ lớn tốn kém. Cần cân nhắc giữa lợi ích của việc cập nhật thường xuyên và chi phí.

Một chiến lược cân bằng là có hai loại huấn luyện: Huấn luyện nhẹ (light retraining) hàng ngày hoặc vài ngày một lần, chỉ cập nhật các lớp cuối của mô hình hoặc điều chỉnh các tham số nhỏ. Đây là quá trình nhanh và ít tốn kém . Huấn luyện đầy đủ (full retraining) hàng tuần hoặc hàng tháng, cập nhật toàn bộ mô hình từ đầu với tất cả dữ liệu. Đây là quá trình tốn kém nhưng đảm bảo mô hình không bị drift.

=== Quản lý phiên bản mô hình

Khi hệ thống liên tục tạo ra các phiên bản mô hình mới, việc quản lý chúng trở nên quan trọng. Chúng ta cần:

Hệ thống version control cho mô hình: Giống như code được quản lý trong Git, các mô hình cần được tracking với các phiên bản rõ ràng. Mỗi phiên bản nên có metadata về thời gian tạo, dữ liệu huấn luyện được sử dụng, và các metrics hiệu suất.

Khả năng rollback: Nếu một mô hình mới gây ra vấn đề trong production, cần có khả năng quay lại phiên bản cũ một cách nhanh chóng và đáng tin cậy.

So sánh hiệu suất giữa các phiên bản: Dashboard nên hiển thị rõ ràng cách mỗi phiên bản mô hình hoạt động trên các metrics quan trọng, cho phép đội ngũ quyết định xem có nên triển khai phiên bản mới không.

Lưu trữ và archiving: Không cần giữ mọi phiên bản mô hình mãi mãi. Cần có chính sách về những phiên bản nào nên được lưu trữ dài hạn (ví dụ, các phiên bản milestones hoặc có hiệu suất đặc biệt tốt) và những phiên bản nào có thể xóa để tiết kiệm storage.

=== Xử lý Catastrophic Forgetting

Một vấn đề tinh vi trong học liên tục là catastrophic forgetting - hiện tượng mô hình "quên" kiến thức cũ khi học thông tin mới. Ví dụ, khi mô hình được huấn luyện lại với nhiều dữ liệu về chính trị, nó có thể giảm hiệu suất trên các claim về y tế vì các trọng số đã được điều chỉnh quá nhiều theo hướng chính trị.

Để giảm thiểu vấn đề này:

Replay buffer: Giữ một tập các điểm dữ liệu quan trọng từ quá khứ và luôn bao gồm chúng trong mỗi lần huấn luyện lại. Điều này đảm bảo mô hình không quên các bài học quan trọng.

Regularization techniques: Sử dụng các kỹ thuật như Elastic Weight Consolidation (EWC) giúp bảo vệ các trọng số quan trọng khỏi bị thay đổi quá nhiều.

Continual evaluation: Luôn đánh giá mô hình mới trên toàn bộ tập validation, không chỉ dữ liệu mới, để phát hiện kịp thời nếu có regression trong các lĩnh vực cũ.

Domain-specific sub-models: Thay vì có một mô hình duy nhất cho mọi thứ, có thể có các sub-models chuyên về các lĩnh vực khác nhau (chính trị, y tế, khoa học) và một router để quyết định sub-model nào nên được sử dụng cho mỗi claim.

== Metrics và Đánh giá hiệu suất

Để biết rằng hệ thống đang cải thiện theo thời gian, chúng ta cần các metrics rõ ràng để đo lường hiệu suất.

=== Metrics cho độ chính xác
Các metrics truyền thống như precision, recall, và F1-score vẫn quan trọng, nhưng trong bài toán này chúng cần được điều chỉnh:

Precision cho nhãn FAKE: Trong số các claim được hệ thống đánh giá là FAKE, bao nhiêu phần trăm thực sự là FAKE? Đây là metric quan trọng vì việc đánh giá sai một thông tin đúng là FAKE có hậu quả nghiêm trọng (kiểm duyệt nội dung hợp pháp).

Recall cho nhãn FAKE: Trong số các claim thực sự là FAKE, hệ thống bắt được bao nhiêu phần trăm? Đây đo lường khả năng của hệ thống trong việc không bỏ sót tin giả.

Tuy nhiên, cần nhớ rằng các metrics này chỉ có thể được tính toán trên tập dữ liệu đã có ground truth. Trong thực tế production, phần lớn claims không có ground truth ngay lập tức.

=== Metrics cho độ không chắc chắn

Tỷ lệ UNDEFINED: Bao nhiêu phần trăm claims được gán nhãn UNDEFINED? Một tỷ lệ quá cao cho thấy hệ thống đang thiếu kiến thức hoặc quá thận trọng. Một tỷ lệ quá thấp có thể cho thấy hệ thống đang quá tự tin và có thể đang mắc nhiều lỗi.

Thời gian giải quyết UNDEFINED: Trung bình mất bao lâu để một claim UNDEFINED được chuyên gia xem xét và cập nhật? Đây đo lường hiệu quả của quy trình Human-in-the-loop.

Conversion rate: Trong số các claim UNDEFINED, bao nhiêu phần trăm cuối cùng được xác định là FAKE, REAL, hay các nhãn khác? Pattern này có thể tiết lộ các xu hướng thú vị.

=== Metrics cho trải nghiệm người dùng

Thời gian phản hồi: Bao lâu hệ thống mất để trả về kết quả cho một claim? Điều này ảnh hưởng trực tiếp đến trải nghiệm người dùng.

Confidence calibration: Khi hệ thống nói nó 90% tự tin, nó có đúng 90% thời gian không? Một hệ thống được calibrate tốt có correlation cao giữa độ tự tin báo cáo và độ chính xác thực tế.

User feedback metrics: Tỷ lệ thumbs up/down từ người dùng, số lượng khiếu nại, và các tín hiệu khác về mức độ hài lòng.

== Kết luận chương

Chương này đã mô tả chi tiết cách hệ thống đưa ra quyết định thông minh và quan trọng hơn, cách nó học hỏi và tiến hóa theo thời gian. Những điểm chính cần nhớ:

Từ chối luật cứng: Hệ thống không sử dụng các luật if-then cứng nhắc vì chúng bị overfitting, tạo ra false certainty, và không thích nghi được. Thay vào đó, nó sử dụng các mô hình xác suất linh hoạt.

Bộ máy quyết định thông minh: Tổng hợp nhiều bằng chứng với chiến lược ưu tiên bác bỏ và yêu cầu đồng thuận cho ủng hộ. Quan trọng nhất, nó cung cấp đầu ra nhận biết độ tự tin, không chỉ nhãn nhị phân.

Vòng đời nhãn - trái tim của hệ thống: UNDEFINED không phải là thất bại mà là cơ hội học tập. Human-in-the-loop biến sự không chắc chắn thành tri thức. Chu kỳ huấn luyện lại biến tri thức đó thành khả năng tự động.

Thách thức thực tế: Từ việc quản lý nguồn lực con người, đảm bảo chất lượng, xử lý độ trễ, đến quản lý mô hình và tránh catastrophic forgetting.

Đo lường và cải thiện: Cần các metrics toàn diện không chỉ về độ chính xác mà còn về độ không chắc chắn, trải nghiệm người dùng, và khả năng thích nghi.

Với cơ chế học và ra quyết định này, hệ thống không chỉ là một công cụ phát hiện tin giả tĩnh, mà là một hệ sinh thái thông minh có khả năng tự cải thiện, thích nghi với môi trường thay đổi, và ngày càng trở nên hiệu quả hơn theo thời gian. Đây chính là sự khác biệt giữa một sản phẩm và một hệ thống bền vững.