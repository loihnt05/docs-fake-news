#set par(justify: true)

= Thiết Lập Thử Nghiệm và Đánh Giá - Nghệ Thuật Chứng Minh Khoa Học

Có một câu nói nổi tiếng trong khoa học máy tính: "In God we trust, all others must bring data" - tạm dịch là "Chỉ có Thượng đế là chúng ta tin tưởng vô điều kiện, tất cả những người khác phải mang dữ liệu đến". Câu nói này nắm bắt được tinh thần cốt lõi của chương này. Bạn có thể xây dựng một hệ thống kỹ thuật tinh vi đến đâu, có kiến trúc đẹp đến mức nào, nhưng nếu không có một quy trình đánh giá và đo lường chặt chẽ, tất cả chỉ là những lời hứa rỗng tuếch.

Chương này là nơi mà những tuyên bố táo bạo về khả năng "học liên tục" và "chống lại concept drift" của hệ thống được đưa lên bàn cân của khoa học thực nghiệm. Chúng ta sẽ không chỉ nói về những gì hệ thống có thể làm, mà sẽ chứng minh rằng nó thực sự làm được những điều đó thông qua dữ liệu cụ thể, chỉ số đo lường rõ ràng, và các thí nghiệm có thể lặp lại.

== Bộ Dữ Liệu - Nền Tảng Của Mọi Thí Nghiệm

Trong machine learning, dữ liệu không chỉ là nguyên liệu thô để huấn luyện mô hình. Nó còn là cơ sở để đánh giá, so sánh, và chứng minh tính hiệu quả của hệ thống. Việc lựa chọn, tổ chức và quản lý dữ liệu thử nghiệm phải được thực hiện với sự cẩn trọng khoa học tương tự như thiết kế một thí nghiệm y học lâm sàng.

=== Dữ Liệu Khởi Tạo - Mầm Mống Đầu Tiên
Mọi hành trình đều bắt đầu từ một bước đi đầu tiên. Đối với hệ thống của chúng ta, bước đầu tiên đó là việc tạo ra phiên bản mô hình khởi tạo, thường được gọi là v0 hoặc model_0. Đây là phiên bản mô hình trước khi hệ thống bắt đầu học từ phản hồi của người dùng thực tế, nên nó cần một bộ dữ liệu "hạt giống" để khởi động.

Bộ dữ liệu hạt giống này được tổng hợp từ hai nguồn chính, mỗi nguồn có vai trò và giá trị riêng. Nguồn đầu tiên là các bộ dữ liệu công khai về kiểm chứng tin tức tiếng Việt. Đây là những tập dữ liệu đã được các nhà nghiên cứu hoặc tổ chức khác thu thập và công bố, thường đi kèm với các nhãn đã được xác minh. Ví dụ có thể là các bộ dữ liệu từ các nghiên cứu học thuật về phát hiện tin giả ở Việt Nam, hoặc từ các tổ chức kiểm chứng sự thật như AFP Fact Check hay các cơ quan truyền thông uy tín. Việc sử dụng dữ liệu công khai không chỉ tiết kiệm thời gian mà còn cho phép so sánh với các nghiên cứu trước đó.

Tuy nhiên, dữ liệu công khai thường có một số hạn chế. Chúng có thể không đủ lớn, có thể tập trung vào các chủ đề cụ thể mà bỏ qua những lĩnh vực khác, hoặc định dạng của chúng có thể không hoàn toàn phù hợp với nhu cầu của hệ thống. Đây là lúc nguồn thứ hai trở nên quan trọng: dữ liệu được đội ngũ dự án thu thập và gán nhãn thủ công.

Quá trình thu thập này được thực hiện thông qua các công cụ tự động như scraper được định nghĩa trong thư mục `scraper-fake-news`. Các scraper này quét qua các trang web tin tức, diễn đàn, và mạng xã hội để thu thập các tuyên bố và tin tức. Sau đó, đội ngũ chuyên gia của dự án - những người có kiến thức về kiểm chứng sự thật và hiểu biết về bối cảnh Việt Nam - sẽ xem xét từng mẫu dữ liệu và gán nhãn thủ công. Họ quyết định xem một tuyên bố cụ thể là REAL, FAKE, hay quá mơ hồ để phân loại. Đây là một công việc tốn thời gian và đòi hỏi sự tập trung cao, nhưng nó tạo ra dữ liệu chất lượng cao với nhãn chính xác.

Ngoài ra, hệ thống còn sử dụng các kỹ thuật bán tự động để tăng cường dữ liệu. Ví dụ, script `scripts/generate_nli_data.py` được thiết kế để tự động tạo ra các cặp dữ liệu suy luận ngôn ngữ tự nhiên, hay còn gọi là Natural Language Inference. NLI là một tác vụ quan trọng trong xử lý ngôn ngữ tự nhiên, nơi mô hình phải xác định mối quan hệ logic giữa hai câu: một câu có kéo theo, mâu thuẫn, hay trung lập với câu kia. Bằng cách tự động tạo các cặp câu có quan hệ logic rõ ràng từ dữ liệu hiện có, chúng ta có thể mở rộng bộ dữ liệu huấn luyện một cách đáng kể mà không cần gán nhãn thủ công cho từng mẫu.

Kết quả của giai đoạn này là một bộ dữ liệu khởi tạo vừa đủ lớn và đa dạng để huấn luyện phiên bản mô hình đầu tiên. Mô hình v0 này có thể không hoàn hảo - nó chưa được tinh chỉnh bởi phản hồi thực tế từ người dùng - nhưng nó đủ tốt để triển khai và bắt đầu quá trình học liên tục.

=== Dữ Liệu Từ Báo Cáo Người Dùng - Dòng Chảy Sống Của Kiến Thức

Sau khi hệ thống được triển khai và người dùng bắt đầu sử dụng, một nguồn dữ liệu hoàn toàn khác bắt đầu chảy vào: các báo cáo từ người dùng thực tế. Đây không phải là dữ liệu tĩnh được tạo một lần rồi quên, mà là một dòng chảy liên tục, phản ánh những gì đang thực sự xảy ra trong môi trường thông tin của Việt Nam.

Mỗi tuần (hoặc theo bất kỳ chu kỳ nào được cấu hình), hệ thống thu thập tất cả các báo cáo đã được chấp thuận trong giai đoạn đó. Nhớ lại từ Chương 6 rằng "được chấp thuận" có nghĩa là báo cáo đã đi qua luồng kiểm duyệt và được các chuyên gia xác nhận là chính xác. Đây là dữ liệu có chất lượng cao, vì nó đã trải qua một quy trình kiểm soát chất lượng nghiêm ngặt.

Tuy nhiên, không phải tất cả dữ liệu được chấp thuận đều được sử dụng cho cùng một mục đích. Đây là nơi một nguyên tắc cơ bản trong machine learning được áp dụng: tách biệt dữ liệu huấn luyện và dữ liệu đánh giá. Nếu bạn sử dụng cùng một bộ dữ liệu để cả huấn luyện và đánh giá mô hình, bạn sẽ không thể biết được mô hình thực sự đã học được những pattern tổng quát hay chỉ đơn giản là "ghi nhớ" các mẫu cụ thể trong dữ liệu huấn luyện.

Do đó, tập hợp các báo cáo được chấp thuận trong mỗi chu kỳ được chia thành hai phần theo tỷ lệ tám mươi-hai mươi. Tám mươi phần trăm dữ liệu tạo thành Training Set, được sử dụng để huấn luyện lại mô hình và tạo ra phiên bản tiếp theo. Đây là dữ liệu mà mô hình được phép "nhìn thấy" và học từ đó. Hai mươi phần trăm còn lại tạo thành Evaluation Set, được giữ lại và không bao giờ được sử dụng trong quá trình huấn luyện. Bộ dữ liệu này hoạt động như một bài kiểm tra công bằng, cho phép chúng ta đo lường xem mô hình mới có thực sự tốt hơn các phiên bản trước đó hay không.

Điều thú vị là Evaluation Set từ tuần này có thể được sử dụng để đánh giá không chỉ mô hình được tạo ra trong tuần này, mà còn các mô hình trong tương lai. Điều này cho phép chúng ta theo dõi hiệu suất của hệ thống theo thời gian trên các bộ dữ liệu cố định, một kỹ thuật quan trọng để phát hiện concept drift mà chúng ta sẽ thảo luận sau.

== Các Chỉ Số Đo Lường - Ngôn Ngữ Của Hiệu Suất

Trong khoa học thực nghiệm, việc đo lường là then chốt. Bạn không thể quản lý những gì bạn không thể đo lường, và bạn không thể cải thiện những gì bạn không thể đánh giá. Đối với hệ thống phát hiện tin giả của chúng ta, việc lựa chọn các chỉ số đo lường phù hợp là một quyết định chiến lược quan trọng. Mỗi chỉ số kể một câu chuyện khác nhau về hiệu suất của hệ thống, và cùng nhau, chúng tạo nên một bức tranh toàn diện.

=== Accuracy - Chỉ Số Cơ Bản Nhưng Đầy Bẫy
Chỉ số đầu tiên và có lẽ quen thuộc nhất là Accuracy, hay độ chính xác tổng thể. Định nghĩa của nó rất đơn giản: trong tất cả các dự đoán mà hệ thống đưa ra, có bao nhiêu phần trăm là đúng? Nếu hệ thống đánh giá một trăm tuyên bố và đúng tám mươi lần, accuracy là tám mươi phần trăm.

Tính đơn giản của Accuracy làm cho nó trở thành một con số dễ hiểu và dễ truyền đạt. Khi bạn nói với một người không chuyên rằng hệ thống có độ chính xác chín mươi phần trăm, họ ngay lập tức hiểu được rằng hệ thống đúng chín lần trong mười lần. Đây là một ưu điểm lớn trong giao tiếp.

Tuy nhiên, Accuracy có một điểm yếu nghiêm trọng mà mọi kỹ sư machine learning đều phải hiểu: nó có thể gây hiểu nhầm sâu sắc khi dữ liệu mất cân bằng. Hãy tưởng tượng một tình huống cực đoan: trong tập dữ liệu của bạn, chín mươi lăm phần trăm tuyên bố là REAL và chỉ năm phần trăm là FAKE. Bây giờ, giả sử bạn có một mô hình cực kỳ lười biếng mà luôn dự đoán mọi thứ là REAL, không bao giờ bận tâm phân tích nội dung. Mô hình này sẽ có accuracy là chín mươi lăm phần trăm! Nghe có vẻ ấn tượng, nhưng nó hoàn toàn vô dụng vì nó không bao giờ phát hiện được tin giả - đúng là mục đích chính của hệ thống.

Trong bối cảnh phát hiện tin giả, dữ liệu mất cân bằng là hiện thực thường gặp. May mắn thay, phần lớn thông tin chúng ta gặp hàng ngày là chính xác hoặc ít nhất là không cố ý gây hiểu lầm. Tin giả, mặc dù nguy hiểm, vẫn là thiểu số. Do đó, chúng ta không thể chỉ dựa vào Accuracy để đánh giá hệ thống.

=== Precision, Recall và F1-Score - Bộ Ba Quyền Lực

Để có cái nhìn sâu sắc hơn về hiệu suất, đặc biệt là với lớp FAKE - lớp quan trọng nhất mà chúng ta cần phát hiện - chúng ta sử dụng ba chỉ số mạnh mẽ hơn: Precision, Recall và F1-Score.

Hãy bắt đầu với Precision, hay độ chuẩn xác. Precision trả lời câu hỏi: trong tất cả các tuyên bố mà hệ thống đã dán nhãn là FAKE, có bao nhiêu tuyên bố thực sự là FAKE? Đây là thước đo sự đáng tin cậy của những cáo buộc của hệ thống. Một Precision cao nghĩa là khi hệ thống nói "đây là tin giả", bạn có thể tin tưởng cao rằng nó thực sự là tin giả.

Tại sao Precision lại quan trọng đến vậy? Hãy nghĩ về ảnh hưởng tâm lý và xã hội. Nếu hệ thống liên tục "kết tội nhầm" các tin tức chính xác là tin giả, điều gì sẽ xảy ra? Người dùng sẽ nhanh chóng mất niềm tin. Họ sẽ nghĩ: "Hệ thống này thường xuyên sai, tôi không thể tin nó được". Tệ hơn nữa, các tổ chức truyền thông chính thống có thể trở thành nạn nhân của những cáo buộc sai trái này, dẫn đến khủng hoảng pháp lý và uy tín cho hệ thống. Trong bối cảnh này, một Precision cao không chỉ là mong muốn - nó là điều bắt buộc để duy trì sự tồn tại của sản phẩm.

Bây giờ, hãy chuyển sang Recall, hay độ phủ. Recall trả lời một câu hỏi khác: trong tất cả các tuyên bố FAKE thực sự tồn tại trong dữ liệu, hệ thống đã phát hiện được bao nhiêu? Đây là thước đo sự toàn diện của hệ thống. Một Recall cao nghĩa là hệ thống rất giỏi trong việc "bắt" tin giả, không để nhiều tin giả lọt qua lưới.

Recall quan trọng vì lý do khác biệt nhưng cũng quan trọng không kém. Nếu hệ thống có Recall thấp, nó đang bỏ lỡ nhiều tin giả thực sự. Trong khi những tin giả mà nó phát hiện được thì chính xác (Precision cao), nó để cho hàng loạt tin giả khác lan truyền không kiểm soát. Người dùng có thể vẫn tin tưởng hệ thống khi nó cảnh báo, nhưng họ sẽ thiếu sự bảo vệ đầy đủ vì rất nhiều tin giả không bao giờ được gắn cờ.

Ở đây xuất hiện một sự đánh đổi cổ điển trong machine learning: thường rất khó để có cả Precision và Recall cao cùng lúc. Nếu bạn muốn tăng Recall - bắt được nhiều tin giả hơn - bạn có thể phải hạ ngưỡng quyết định của mô hình, làm cho nó dễ dàng gán nhãn FAKE hơn. Nhưng điều này thường dẫn đến việc giảm Precision, vì bây giờ hệ thống đang "kết tội" nhiều trường hợp hơn, bao gồm cả những trường hợp lầm lẫn. Ngược lại, nếu bạn muốn Precision cực kỳ cao - chỉ cảnh báo khi hoàn toàn chắc chắn - bạn có thể phải nâng ngưỡng quyết định rất cao, dẫn đến việc bỏ lỡ nhiều tin giả và Recall thấp.

Đây là lúc F1-Score đóng vai trò như một trọng tài công bằng. F1-Score là trung bình điều hòa của Precision và Recall, một công thức toán học đặc biệt có tính chất quan trọng: nó chỉ cao khi cả hai chỉ số đều cao. Nếu một trong hai chỉ số rất thấp, F1-Score sẽ bị kéo xuống mạnh. Điều này khác với trung bình số học thông thường, nơi một giá trị cao có thể bù đắp cho một giá trị thấp.

Ví dụ, nếu Precision là chín mươi chín phần trăm nhưng Recall chỉ có một phần trăm, trung bình số học sẽ là năm mươi phần trăm - nghe có vẻ tạm chấp nhận. Nhưng F1-Score sẽ chỉ khoảng hai phần trăm, phản ánh chính xác sự thật rằng mô hình này gần như vô dụng vì nó bỏ sót chín mươi chín phần trăm tin giả. F1-Score ép buộc chúng ta phải cân bằng cả hai khía cạnh của hiệu suất.

Trong nhiều báo cáo và bản tóm tắt, F1-Score trở thành con số duy nhất được trích dẫn vì nó nắm bắt được sự phức tạp của hiệu suất trong một giá trị duy nhất, dễ so sánh giữa các phiên bản mô hình.

=== Stability Over Time - Đo Lường Khả Năng Chống Concept Drift

Tất cả các chỉ số trên đo lường hiệu suất của mô hình tại một thời điểm cụ thể. Nhưng trong thế giới thực, thời gian không đứng yên. Môi trường thông tin liên tục thay đổi: chủ đề mới nổi lên, chiến thuật gây hiểu lầm mới được phát triển, ngôn ngữ và lối diễn đạt thay đổi. Đây chính là hiện tượng concept drift mà chúng ta đã thảo luận ở các chương trước.

Để đo lường khả năng của hệ thống trong việc chống lại concept drift, chúng ta cần một chỉ số khác biệt: Stability Over Time, hay độ ổn định theo thời gian. Đây không phải là một phép tính đơn lẻ mà là một phân tích theo dõi sự thay đổi của hiệu suất qua nhiều chu kỳ.

Phương pháp hoạt động như sau: chúng ta tạo ra một bộ dữ liệu kiểm thử "vàng", được gọi là golden test set. Đây là một tập hợp các tuyên bố đã được gán nhãn cẩn thận và được giữ cố định qua nhiều tháng, thậm chí nhiều năm. Bộ dữ liệu này không bao giờ được sử dụng trong quá trình huấn luyện - nó chỉ tồn tại để đánh giá.

Sau mỗi chu kỳ huấn luyện lại hàng tuần, phiên bản mô hình mới nhất được đánh giá trên golden test set này. Chúng ta ghi lại F1-Score và các chỉ số khác. Sau vài tháng, chúng ta có một chuỗi các điểm số: F1 của model v1 trên golden set, F1 của model v2 trên cùng golden set đó, F1 của model v3, và cứ thế tiếp tục.

Bây giờ chúng ta vẽ một biểu đồ đường với trục hoành là thời gian (tuần một, tuần hai, ... tuần N) và trục tung là F1-Score. Đây là nơi mà câu chuyện thực sự được kể. Nếu hệ thống không có cơ chế học liên tục, bạn sẽ thấy một đường đi xuống. Khi thời gian trôi qua và thế giới thay đổi, mô hình trở nên ngày càng lỗi thời so với thực tế mới. Golden test set, mặc dù cố định, phản ánh một thực tế cụ thể, và khi mô hình ngày càng xa rời thực tế đó, hiệu suất giảm dần.

Ngược lại, với hệ thống học liên tục của chúng ta, kỳ vọng là thấy một đường đi ngang hoặc thậm chí tăng nhẹ. Đường đi ngang nghĩa là mô hình duy trì được hiệu suất của nó theo thời gian - nó không bị suy giảm bởi concept drift vì nó liên tục học và thích ứng. Đường tăng nhẹ sẽ còn ấn tượng hơn, chỉ ra rằng không chỉ mô hình thích ứng với sự thay đổi, nó còn trở nên tốt hơn khi tích lũy thêm kinh nghiệm và dữ liệu.

Đây là bằng chứng trực quan mạnh mẽ nhất về giá trị của pipeline học liên tục. Một biểu đồ đơn giản có thể kể một câu chuyện phức tạp về sự tiến hóa của hệ thống qua thời gian.

== Phân Tích Concept Drift - Chứng Minh Giá Trị Của Việc Học

Các chỉ số tổng quát cho chúng ta cái nhìn bao quát, nhưng để thực sự hiểu sâu về giá trị của việc huấn luyện lại định kỳ, chúng ta cần đi sâu vào các phân tích cụ thể hơn. Phần này trình bày hai loại thí nghiệm được thiết kế đặc biệt để chứng minh rằng pipeline học liên tục không chỉ là một tính năng hay ho mà là một thành phần thiết yếu của hệ thống.

=== So Sánh Trước và Sau Khi Huấn Luyện Lại - Bằng Chứng Tức Thì

Thí nghiệm đầu tiên có thiết kế thanh lịch trong sự đơn giản của nó, và chính sự đơn giản đó làm cho kết quả của nó trở nên thuyết phục.

Vào cuối mỗi tuần, chúng ta có một tập hợp các báo cáo mới được chấp thuận từ người dùng trong tuần đó. Thay vì ngay lập tức chia nó thành tập huấn luyện và tập đánh giá, chúng ta tạm thời sử dụng toàn bộ tập này như một bộ kiểm thử đặc biệt. Đây là dữ liệu phản ánh chính xác những gì đang xảy ra trong tuần vừa qua - các chủ đề nổi bật, các loại tin giả đang lưu hành, và các mẫu ngôn ngữ đang được sử dụng.

Bước đầu tiên của thí nghiệm: chúng ta lấy mô hình của tuần trước, ví dụ v8 nếu chúng ta đang ở tuần thứ chín, và đánh giá nó trên bộ dữ liệu mới này. Mô hình v8 đã được huấn luyện trên dữ liệu đến hết tuần thứ tám, vì vậy nó chưa bao giờ "nhìn thấy" dữ liệu của tuần thứ chín. Chúng ta ghi lại F1-Score mà nó đạt được - đây là hiệu suất của mô hình "cũ" trên dữ liệu "mới".

Bước thứ hai: chúng ta chạy pipeline huấn luyện lại, sử dụng dữ liệu của tuần thứ chín (cùng với tất cả dữ liệu lịch sử) để tạo ra mô hình v9. Sau khi huấn luyện hoàn tất, chúng ta cũng đánh giá v9 trên cùng bộ dữ liệu tuần thứ chín đó. Đây là hiệu suất của mô hình "mới" trên dữ liệu mà nó vừa học từ đó.

Bây giờ chúng ta vẽ một biểu đồ cột đơn giản với hai cột: cột đầu tiên là F1-Score của v8 (trước khi retrain), cột thứ hai là F1-Score của v9 (sau khi retrain). Kỳ vọng của chúng ta, dựa trên giả thuyết về giá trị của học liên tục, là cột thứ hai sẽ cao hơn đáng kể so với cột đầu tiên.

Tại sao điều này quan trọng? Bởi vì nó chứng minh lợi ích tức thì và cụ thể của việc học từ dữ liệu mới. Nếu mô hình v9 thực sự tốt hơn v8 một cách đáng kể trên dữ liệu của tuần thứ chín, điều đó có nghĩa là nó đã nhanh chóng thích ứng với các đặc điểm của tuần đó - có thể là một chủ đề chính trị mới nổi lên, một chiến dịch tin giả về sức khỏe, hay một sự kiện quốc tế đang được bàn luận sôi nổi.

Biểu đồ này kể một câu chuyện rất trực quan: "Nhìn đây, trước khi học, mô hình chỉ đạt sáu mươi phần trăm F1-Score trên dữ liệu mới. Sau khi học từ dữ liệu đó, nó đạt tám mươi phần trăm. Sự cải thiện hai mươi điểm phần trăm này chính là giá trị của việc học liên tục." Đây là bằng chứng khó có thể chối cãi.

Lặp lại thí nghiệm này hàng tuần, chúng ta tích lũy được một chuỗi các điểm dữ liệu. Có thể không phải tuần nào sự cải thiện cũng lớn - có những tuần mà dữ liệu mới không khác biệt nhiều so với dữ liệu cũ, nên sự cải thiện có thể khiêm tốn. Nhưng trung bình theo thời gian, nếu chúng ta liên tục thấy cột "Sau khi Retrain" cao hơn cột "Trước khi Retrain", đó là xác nhận mạnh mẽ rằng pipeline đang hoạt động như thiết kế.

=== Nghiên Cứu Tình Huống - Kể Chuyện Qua Dữ Liệu

Trong khi các con số và biểu đồ mang lại độ chính xác và khả năng định lượng, đôi khi một câu chuyện cụ thể, chi tiết có thể tạo ấn tượng sâu sắc hơn. Đây là mục đích của nghiên cứu tình huống (case study) - một phân tích định tính theo dõi toàn bộ vòng đời của hệ thống khi đối mặt với một thách thức mới.

Hãy tưởng tượng một câu chuyện giả định nhưng hoàn toàn có thể xảy ra trong thực tế:

**Ngày 1 - Xuất hiện mối đe dọa mới:** Một chiến dịch thông tin sai lệch về một chủ đề mới, giả sử là về một loại vaccine mới, bắt đầu lan truyền trên mạng xã hội Việt Nam. Các tuyên bố giả mạo sử dụng một khung ngôn ngữ và lập luận mà mô hình hiện tại, giả sử là v8, chưa từng gặp trong quá trình huấn luyện. Kết quả là, khi người dùng kiểm tra các tuyên bố này thông qua extension hoặc website, mô hình hoặc phân loại sai chúng là REAL, hoặc không đủ tự tin và gán nhãn UNDEFINED.

**Ngày 2-5 - Phản ứng của cộng đồng:** Người dùng tinh ý, đặc biệt là những người có kiến thức về y học hoặc đã kiểm chứng thông tin từ các nguồn uy tín, nhận ra rằng hệ thống đang sai. Họ bắt đầu sử dụng tính năng báo cáo lỗi trong extension và dashboard. Trong vài ngày, có thể một trăm hoặc hai trăm báo cáo tích lũy, tất cả đều chỉ ra rằng các tuyên bố cụ thể về vaccine này là tin giả nhưng hệ thống lại không nhận diện được.

Trong khi đó, hệ thống Phản hồi & Độ uy tín đang hoạt động không ngừng nghỉ. Các báo cáo này được ghi nhận, lưu vào cơ sở dữ liệu, và đưa vào hàng đợi kiểm duyệt. Các chuyên gia - có thể là những người có điểm uy tín cao trong lĩnh vực y tế hoặc kiểm chứng sự thật - bắt đầu xem xét các báo cáo này. Họ xác minh từ các nguồn uy tín rằng các tuyên bố về vaccine thực sự là sai lệch, và họ đánh dấu các báo cáo là "Approved", kèm theo nhãn chính xác FAKE.

**Ngày 6 - Chu kỳ học bắt đầu:** Cuối tuần đến, thời điểm mà DAG `dags/weekly_retrain_dag.py` được lên lịch chạy. Airflow kích hoạt pipeline, và quá trình huấn luyện lại bắt đầu. Pipeline thu thập tất cả các báo cáo đã được chấp thuận trong tuần, bao gồm hàng trăm báo cáo về chiến dịch tin giả vaccine. Thông qua kỹ thuật oversampling có trọng số, các báo cáo từ chuyên gia y tế với điểm uy tín cao được chọn nhiều lần trong các batch huấn luyện.

Mô hình PhoBERT bắt đầu thấy các mẫu mới: các cụm từ đặc trưng, cấu trúc lập luận, và ngữ cảnh liên quan đến chiến dịch tin giả này. Nó điều chỉnh các trọng số trong mạng neural của mình để nhận diện những pattern này. Sau nhiều giờ tính toán trên GPU, một phiên bản mô hình mới, v9, được tạo ra và lưu vào `checkpoints/model_9`.

**Ngày 7 - Triển khai phiên bản mới:** Sáng sớm, trước khi lưu lượng người dùng đỉnh điểm bắt đầu, đội ngũ vận hành cập nhật file cấu hình để trỏ hệ thống đến model_9 và khởi động lại các máy chủ ứng dụng. Trong vòng vài phút, tất cả các instance của backend đang chạy model_9.

**Ngày 8 và sau đó - Khả năng mới được kích hoạt:** Khi các tuyên bố tin giả tương tự về vaccine tiếp tục lan truyền (vì chiến dịch thông tin sai lệch thường kéo dài nhiều ngày hoặc tuần), người dùng kiểm tra chúng qua hệ thống. Lần này, mô hình v9 ngay lập tức nhận diện được các pattern mà nó đã học. Với độ tự tin cao, nó gán nhãn FAKE cho các tuyên bố này. Người dùng nhận được cảnh báo rõ ràng rằng thông tin họ đang đọc là không đáng tin cậy.

Từ góc độ người dùng cá nhân, trải nghiệm chuyển từ "hệ thống không giúp được gì" (ngày 1-6) sang "hệ thống bảo vệ tôi khỏi thông tin sai lệch" (ngày 8 trở đi). Từ góc độ xã hội rộng lớn hơn, hệ thống đã chuyển từ một phần của vấn đề (vô tình để tin giả lan truyền) sang một phần của giải pháp (ngăn chặn sự lan truyền).

=== Giá Trị Của Câu Chuyện

Nghiên cứu tình huống này, mặc dù là một kịch bản giả định, minh họa một số điểm quan trọng mà các chỉ số định lượng không thể nắm bắt đầy đủ:

Thứ nhất, nó cho thấy **chu kỳ phản hồi hoàn chỉnh** của hệ thống. Từ lúc thất bại ban đầu, qua giai đoạn thu thập phản hồi, kiểm duyệt, học, và cuối cùng là cải thiện - mỗi giai đoạn được kết nối chặt chẽ với giai đoạn tiếp theo.

Thứ hai, nó minh họa **vai trò của cộng đồng** trong quá trình học. Hệ thống không tự mình khám phá ra rằng nó đang sai. Nó cần sự can thiệp của con người - những người dùng quan tâm đủ để báo cáo lỗi và những chuyên gia có kiến thức đủ để xác minh sự thật.

Thứ ba, nó làm rõ **tốc độ phản ứng** của hệ thống. Từ khi vấn đề xuất hiện đến khi được giải quyết là khoảng một tuần - không phải tức thì, nhưng cũng không chậm đến mức vô ích. Đây là một sự cân bằng thiết thực giữa tốc độ và sự ổn định.

Thứ tư, và có lẽ quan trọng nhất, nó kể một **câu chuyện về sự tiến hóa**. Hệ thống không được thiết kế để hoàn hảo ngay từ đầu. Thay vào đó, nó được thiết kế để học hỏi từ thất bại và trở nên tốt hơn theo thời gian. Đây là một triết lý khác biệt sâu sắc so với các hệ thống truyền thống mong đợi được hoàn thiện trước khi triển khai.
