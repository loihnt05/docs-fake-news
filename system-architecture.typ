#set par(justify: true)
= Thiết kế hệ thống

Sau khi đã hiểu rõ bản chất của bài toán và các thách thức cần vượt qua, chương này sẽ đưa bạn vào hành trình khám phá kiến trúc thực tế của hệ thống. Chúng ta sẽ đi từ cái nhìn tổng quan về toàn bộ pipeline xử lý, sau đó đi sâu vào từng lớp và module cụ thể, hiểu rõ chúng hoạt động như thế nào và tại sao chúng lại được thiết kế theo cách đó. Mỗi quyết định thiết kế đều có lý do của nó, và chương này sẽ giúp bạn hiểu được những lý do đó.

== Tổng quan Pipeline - Bức tranh toàn cảnh

Trước khi đi vào chi tiết từng thành phần, chúng ta cần có một cái nhìn toàn cảnh về cách dữ liệu di chuyển qua hệ thống. Hãy tưởng tượng pipeline của chúng ta như một dây chuyền sản xuất trong một nhà máy hiện đại. Nguyên liệu thô (thông tin từ các nguồn tin) đi vào từ một đầu, trải qua nhiều công đoạn chế biến khác nhau, và cuối cùng cho ra thành phẩm (kết quả xác minh) ở đầu kia.

=== Triết lý thiết kế: Tách biệt trách nhiệm

Pipeline được thiết kế theo nguyên tắc "separation of concerns" - mỗi bước trong chuỗi xử lý chịu trách nhiệm cho một tác vụ chuyên biệt và độc lập. Đây không chỉ là một lựa chọn kỹ thuật thuần túy mà còn mang lại nhiều lợi ích thực tiễn quan trọng.

Thứ nhất, nó làm cho hệ thống dễ bảo trì hơn rất nhiều. Khi một vấn đề xảy ra, chúng ta có thể nhanh chóng xác định được nó xảy ra ở bước nào trong pipeline. Nếu có lỗi trong việc trích xuất claim, chúng ta biết chính xác phải nhìn vào Claim Extraction Module mà không cần phải lục tung toàn bộ hệ thống.

Thứ hai, nó cho phép nâng cấp từng thành phần một cách độc lập. Giả sử chúng ta muốn cải thiện thuật toán phát hiện claim bằng cách chuyển từ PhoBERT sang một mô hình ngôn ngữ mới tốt hơn. Với kiến trúc modular này, chúng ta chỉ cần thay thế module đó mà không cần động đến các phần còn lại của hệ thống. Các module khác vẫn tiếp tục hoạt động bình thường, chỉ cần đảm bảo input và output của module mới vẫn tương thích với định dạng đã được thống nhất.

Thứ ba, và có lẽ quan trọng nhất đối với một hệ thống cần xử lý khối lượng lớn, nó cho phép mở rộng quy mô một cách linh hoạt. Nếu chúng ta phát hiện rằng bước xác minh đang trở thành điểm nghẽn (bottleneck) vì nó phải xử lý quá nhiều claim, chúng ta có thể tăng số lượng instance của module đó mà không cần phải nhân bản toàn bộ hệ thống. Điều này tiết kiệm tài nguyên và chi phí đáng kể.

=== Sơ đồ luồng xử lý chi tiết

Hãy đi theo hành trình của một bài viết tin tức từ lúc nó xuất hiện trên internet cho đến khi hệ thống đưa ra đánh giá về nó. Luồng xử lý tổng quan có thể được mô tả như sau:

Bước đầu tiên, chúng ta có các nguồn thông tin ngoài kia trong thế giới thực - các trang web tin tức, các bài viết trên mạng xã hội như Facebook hay Twitter, các diễn đàn, blog cá nhân. Đây là nơi thông tin được tạo ra và lan truyền, và cũng là nơi tin giả có thể xuất hiện.

Từ đó, dữ liệu được đưa vào lớp thu thập (Data Ingestion Layer). Đây là lớp đầu tiên của hệ thống, hoạt động như một tập hợp các cảm biến thông minh liên tục quét không gian mạng. Các Scraper được lập lịch bởi Airflow sẽ tự động truy cập các nguồn tin đã được định sẵn, tải về nội dung, và làm sạch để rút ra văn bản thuần túy. Dữ liệu thô này không được xử lý ngay mà được đẩy vào một hàng đợi Kafka, tạo ra một bộ đệm an toàn giữa quá trình thu thập và xử lý.

Tiếp theo, từ hàng đợi Kafka, các bài viết thô được các Consumer lấy ra để xử lý. Mỗi bài viết giờ đây là một khối văn bản hoàn chỉnh, đã được làm sạch khỏi các thành phần HTML không cần thiết, đã được chuẩn hóa về mặt encoding, và sẵn sàng cho giai đoạn phân tích tiếp theo.

Ở bước thứ ba, Module Trích xuất Luận điểm (Claim Extraction Module) bắt đầu công việc của nó. Module này không nhìn bài viết như một khối thông tin nguyên vẹn mà phân tích nó ở mức độ chi tiết hơn. Đầu tiên, nó chia văn bản thành các câu riêng lẻ. Sau đó, nó sử dụng một mô hình học máy đã được huấn luyện để đánh giá từng câu và quyết định xem câu đó có phải là một luận điểm cần kiểm chứng hay không. Một bài viết có thể chứa 50 câu nhưng chỉ có 5 câu là claim thực sự. Module này lọc ra chính xác 5 câu đó.

Bước thứ tư là trái tim của hệ thống - Mô hình Xác minh (Verification Model). Với mỗi claim đã được trích xuất, mô hình này thực hiện một quá trình xác minh phức tạp gồm nhiều giai đoạn. Nó mã hóa claim thành một vector ngữ nghĩa, tìm kiếm các bằng chứng liên quan trong cơ sở tri thức đã được xây dựng sẵn, sau đó sử dụng một mô hình NLI để đánh giá mối quan hệ giữa claim và các bằng chứng tìm được. Cuối cùng, nó tổng hợp tất cả thông tin này để đưa ra một quyết định cuối cùng.

Kết quả đầu ra của toàn bộ pipeline này là một tập hợp các đánh giá chi tiết cho từng claim được tìm thấy trong bài viết gốc. Mỗi đánh giá bao gồm nhãn xác minh (REAL, FAKE, hoặc UNDEFINED), điểm tin cậy (confidence score) cho thấy hệ thống chắc chắn đến mức nào về kết luận của mình, và có thể kèm theo các bằng chứng đã được sử dụng để đưa ra kết luận đó.

=== Tính chất quan trọng của pipeline

Pipeline này được thiết kế với một số tính chất kỹ thuật quan trọng mà chúng ta cần hiểu rõ.

Đầu tiên là tính idempotent - nếu chúng ta xử lý cùng một bài viết nhiều lần, kết quả sẽ giống nhau (trừ khi cơ sở tri thức hoặc mô hình đã được cập nhật). Điều này rất quan trọng trong các hệ thống phân tán, nơi một request có thể bị xử lý lại do lỗi mạng hoặc các vấn đề kỹ thuật khác.

Thứ hai là tính stateless của mỗi bước xử lý - mỗi module không cần nhớ gì về các request trước đó. Mọi thông tin cần thiết để xử lý một bài viết đều được truyền cùng với request đó. Điều này làm cho hệ thống dễ mở rộng quy mô vì chúng ta có thể tự do thêm hoặc bớt các instance của bất kỳ module nào mà không lo lắng về việc đồng bộ trạng thái giữa chúng.

Thứ ba là khả năng fault tolerance - nếu một bước trong pipeline gặp lỗi, dữ liệu không bị mất vì nó vẫn nằm an toàn trong Kafka queue. Khi hệ thống được khôi phục, nó có thể tiếp tục xử lý từ nơi nó đã dừng lại.

== Lớp Thu thập Dữ liệu (Data Ingestion Layer) - Cửa ngõ của hệ thống

Lớp Thu thập Dữ liệu là nền móng của toàn bộ hệ thống. Nếu không có dữ liệu mới liên tục được đưa vào, hệ thống sẽ nhanh chóng trở nên lỗi thời và vô dụng. Nhưng việc thu thập dữ liệu từ internet không đơn giản như có vẻ. Nó đòi hỏi phải xử lý nhiều vấn đề kỹ thuật và thiết kế một kiến trúc chắc chắn, đáng tin cậy.

=== Thành phần Scraper - Công nhân thu thập thông tin
Scraper là những "công nhân" đầu tiên của hệ thống, được triển khai chủ yếu trong các file như scrape.py và clean_data.py trong thư mục scraper-fake-news. Nhiệm vụ của chúng nghe có vẻ đơn giản - truy cập một URL và lấy về nội dung - nhưng trong thực tế lại phức tạp hơn nhiều.

Khi một Scraper nhận được một URL cần thu thập, nó không chỉ đơn giản tải về toàn bộ trang HTML. Thay vào đó, nó phải thực hiện một chuỗi các bước xử lý thông minh. Đầu tiên, nó gửi một HTTP request đến server chứa trang web đó, giả lập như một trình duyệt thông thường để tránh bị chặn bởi các biện pháp chống bot. Sau khi nhận được response, nó phải phân tích cấu trúc HTML phức tạp của trang web.

Đây là nơi thách thức thực sự bắt đầu. Một trang web tin tức điển hình không chỉ chứa nội dung bài viết mà còn chứa hàng tá thành phần khác: thanh menu điều hướng, quảng cáo, sidebar với các liên kết đến bài viết khác, phần bình luận, các đoạn script JavaScript, các thẻ meta cho SEO, và nhiều thứ khác. Scraper phải đủ thông minh để phân biệt được đâu là nội dung chính của bài viết và đâu là những thành phần phụ không liên quan.

Để làm được điều này, Scraper sử dụng nhiều kỹ thuật khác nhau. Nó có thể tìm kiếm các thẻ HTML có tên class hoặc id đặc trưng như "article-content" hoặc "main-text". Nó có thể sử dụng các thư viện như BeautifulSoup hoặc Scrapy để phân tích cấu trúc DOM và áp dụng các quy tắc heuristic để xác định nội dung chính. Với các trang web quan trọng và được truy cập thường xuyên, chúng ta có thể viết các parser tùy chỉnh dựa trên cấu trúc cụ thể của trang đó.

Sau khi trích xuất được văn bản, công việc của Scraper vẫn chưa xong. Văn bản thô vừa lấy được thường chứa nhiều vấn đề: có thể có các ký tự HTML entities như &nbsp; hoặc &amp;, có thể có nhiều khoảng trắng thừa, có thể có các dòng trống không cần thiết. Module clean_data.py đảm nhận công việc làm sạch này. Nó chuẩn hóa văn bản, chuyển đổi các ký tự đặc biệt về dạng bình thường, loại bỏ khoảng trắng thừa, và đảm bảo encoding của văn bản là UTF-8 để có thể xử lý đúng tiếng Việt.

Nhưng Scraper không chỉ làm việc với những trang web "thân thiện". Nhiều trang web hiện đại sử dụng JavaScript để render nội dung động, có nghĩa là nội dung thực sự không tồn tại trong HTML ban đầu mà chỉ được tạo ra sau khi JavaScript chạy. Đối với những trang như vậy, một HTTP request đơn giản không đủ. Chúng ta cần sử dụng các công cụ như Selenium hay Playwright có khả năng chạy một trình duyệt thực sự, chờ JavaScript thực thi xong, rồi mới lấy nội dung cuối cùng.

Scraper cũng phải xử lý các tình huống lỗi. Một trang web có thể tạm thời không khả dụng, có thể trả về lỗi 404 hay 500, hoặc có thể mất quá nhiều thời gian để phản hồi. Scraper cần có logic retry thông minh - thử lại sau một khoảng thời gian nếu gặp lỗi tạm thời, nhưng từ bỏ nếu lỗi là vĩnh viễn. Nó cũng cần tôn trọng các quy tắc của trang web, như file robots.txt hoặc rate limiting, để không gây tải quá mức cho server của họ.

=== Apache Kafka - Trung tâm điều phối thông tin

Sau khi Scraper đã thu thập và làm sạch được dữ liệu, câu hỏi đặt ra là: chúng ta sẽ làm gì với dữ liệu đó? Một thiết kế đơn giản có thể là Scraper gọi trực tiếp module xử lý tiếp theo. Nhưng cách tiếp cận này có nhiều vấn đề nghiêm trọng trong thực tế.

Đây là lý do chúng ta sử dụng Apache Kafka làm một lớp trung gian. Kafka là một distributed message queue - một hệ thống hàng đợi tin nhắn phân tán. Thay vì gọi trực tiếp module xử lý, Scraper (đóng vai trò là Producer, được triển khai trong crawler/producer.py) sẽ đẩy bài viết đã làm sạch vào một "topic" trong Kafka. Bạn có thể hình dung topic như một cái hàng đợi (queue) hoặc một dòng chảy (stream) của dữ liệu.

Việc sử dụng Kafka mang lại những lợi ích to lớn. Đầu tiên và quan trọng nhất là nó tách rời (decouple) quá trình thu thập và quá trình xử lý. Scraper không cần biết có bao nhiêu Consumer, chúng hoạt động như thế nào, hay liệu chúng có đang hoạt động hay không. Nó chỉ cần đẩy dữ liệu vào Kafka và công việc của nó là xong. Tương tự, các Consumer (được triển khai trong processor/consumer.py) không cần biết dữ liệu đến từ đâu hay có bao nhiêu Scraper đang hoạt động. Chúng chỉ cần lấy dữ liệu từ Kafka topic và xử lý.

Sự tách rời này có nhiều hệ quả tích cực. Nó cho phép hai bên phát triển độc lập - chúng ta có thể nâng cấp logic của Scraper mà không cần động đến Consumer và ngược lại. Nó cho phép scaling độc lập - nếu chúng ta cần thu thập dữ liệu nhanh hơn, chúng ta tăng số lượng Scraper; nếu chúng ta cần xử lý nhanh hơn, chúng ta tăng số lượng Consumer. Hai bên có thể scale theo nhu cầu của riêng mình.

Hơn nữa, Kafka cung cấp khả năng chịu lỗi (fault tolerance) tuyệt vời. Tất cả dữ liệu được ghi vào Kafka đều được lưu trữ bền vững trên đĩa và có thể được replicate qua nhiều server. Nếu một Consumer gặp sự cố và crash, dữ liệu không bị mất. Kafka vẫn giữ chúng trong queue. Khi Consumer được khởi động lại, nó có thể tiếp tục xử lý từ nơi nó đã dừng lại, nhờ vào cơ chế offset tracking của Kafka.

Kafka cũng cho phép nhiều Consumer cùng đọc từ một topic, một pattern gọi là pub-sub (publish-subscribe). Điều này có nghĩa là chúng ta có thể có nhiều Consumer làm việc song song, mỗi Consumer xử lý một phần của dữ liệu, giúp tăng throughput của hệ thống đáng kể. Hoặc chúng ta có thể có các Consumer khác nhau làm các việc khác nhau với cùng một dữ liệu - một Consumer xử lý để xác minh, một Consumer khác lưu vào database để phân tích sau này.

Một điểm nữa cần hiểu về Kafka là nó không chỉ là một queue đơn giản. Nó duy trì thứ tự của các message trong mỗi partition, cho phép chúng ta replay lại các sự kiện trong quá khứ nếu cần, và cung cấp cơ chế exactly-once semantics để đảm bảo mỗi message được xử lý chính xác một lần, không bị trùng lặp hay mất mát.

=== Apache Airflow - Người chỉ huy tự động hóa

Bây giờ chúng ta đã có Scraper có khả năng thu thập dữ liệu và Kafka để chuyển tiếp dữ liệu, nhưng còn một câu hỏi quan trọng: ai sẽ quyết định khi nào Scraper chạy và thu thập từ nguồn nào? Chúng ta không thể để một con người phải ngồi đó và thủ công kích hoạt Scraper mỗi ngày. Đây là lúc Apache Airflow bước vào.

Airflow là một platform để lập lịch và giám sát các workflow phức tạp. Trong ngữ cảnh của chúng ta, nó đóng vai trò như một người chỉ huy tự động điều phối toàn bộ quá trình thu thập dữ liệu. Trung tâm của Airflow là khái niệm DAG (Directed Acyclic Graph) - một đồ thị có hướng không có chu trình. Một DAG định nghĩa một workflow bao gồm nhiều tác vụ và quan hệ phụ thuộc giữa chúng.

Trong hệ thống của chúng ta, có một DAG quan trọng là daily_crawl_dag.py nằm trong thư mục dags. DAG này định nghĩa quy trình thu thập dữ liệu hàng ngày. Hãy tưởng tượng nó như một kịch bản chi tiết cho một ca làm việc: "Vào lúc 2 giờ sáng mỗi ngày, đầu tiên hãy thu thập dữ liệu từ VnExpress, sau đó từ Tuổi Trẻ, tiếp theo từ các group Facebook được chỉ định. Nếu bất kỳ bước nào thất bại, hãy gửi cảnh báo và thử lại sau 30 phút."

Mỗi bước trong workflow này được gọi là một Task trong Airflow. Mỗi Task có thể là việc chạy một script Python (ví dụ gọi Scraper để thu thập từ một nguồn cụ thể), thực thi một câu lệnh shell, hoặc thậm chí gọi một API. Các Task có thể được sắp xếp theo thứ tự tuần tự (Task B chỉ chạy sau khi Task A hoàn thành) hoặc song song (Task C và Task D có thể chạy đồng thời).

Một điểm mạnh của Airflow là khả năng giám sát và quản lý chi tiết. Nó cung cấp một web UI cho phép chúng ta theo dõi trạng thái của mỗi DAG run (mỗi lần một DAG được thực thi), xem log chi tiết của từng Task, xác định Task nào đang chạy, Task nào đã hoàn thành, Task nào gặp lỗi. Nếu có vấn đề xảy ra, chúng ta có thể thủ công kích hoạt lại một Task cụ thể hoặc toàn bộ DAG từ một điểm bất kỳ.

Airflow cũng hỗ trợ các tính năng tiên tiến như backfilling (chạy lại DAG cho các khoảng thời gian trong quá khứ nếu chúng ta bị miss hoặc cần thu thập lại dữ liệu), retry logic với exponential backoff (thử lại Task thất bại với khoảng cách thời gian tăng dần), và alerting (gửi email hoặc Slack notification khi có Task thất bại).

Trong thiết kế của chúng ta, Airflow không chỉ quản lý việc thu thập dữ liệu hàng ngày. Như chúng ta sẽ thấy sau, nó còn quản lý cả quy trình huấn luyện lại mô hình hàng tuần (weekly_retrain_dag.py), đảm bảo toàn bộ vòng đời của hệ thống được tự động hóa và có thể kiểm soát.

== Module Trích xuất Luận điểm (Claim Extraction Module) - Bộ lọc thông minh

Sau khi dữ liệu được thu thập và làm sạch, chúng ta có trong tay những bài viết hoàn chỉnh. Nhưng như đã thảo luận trong Chương 3, một bài viết không phải là đơn vị thích hợp để xác minh. Chúng ta cần phải tách ra các luận điểm cụ thể. Module Trích xuất Luận điểm đảm nhận công việc quan trọng và tinh tế này.

=== Sentence Splitting - Bước đầu tiên là chia nhỏ

Trước khi có thể xác định đâu là claim, chúng ta cần chia văn bản thành các đơn vị nhỏ hơn mà chúng ta có thể phân tích. Bước tự nhiên nhất là chia thành câu. Tưởng chừng đơn giản, nhưng việc tách câu (sentence segmentation) trong tiếng Việt lại có những thách thức riêng.

Với tiếng Anh, việc tách câu tương đối dễ dàng: chúng ta chỉ cần tìm các dấu chấm, dấu chấm hỏi, hoặc dấu chấm cảm và chia tại đó. Nhưng ngay cả với tiếng Anh cũng có ngoại lệ. Dấu chấm không phải lúc nào cũng kết thúc câu - nó có thể xuất hiện trong từ viết tắt như "Dr.", "U.S.A.", hoặc trong số thập phân như "3.14". Một thuật toán ngây thơ sẽ chia nhầm "Dr. Smith went to Washington" thành hai câu tại dấu chấm sau "Dr".

Với tiếng Việt, vấn đề phức tạp hơn một chút. Tiếng Việt cũng sử dụng dấu chấm để kết thúc câu, nhưng cách sử dụng dấu câu trong văn bản tiếng Việt, đặc biệt là trên mạng xã hội hoặc các bài viết không chính thống, có thể khá tự do và không nhất quán. Có người viết quên dấu chấm, có người lạm dụng dấu chấm than hoặc dấu hỏi, có người sử dụng nhiều dấu chấm liên tiếp "..." để thể hiện sự do dự hay bỏ ngỏ.

Hệ thống của chúng ta sử dụng một bộ tách câu (sentence splitter) được tối ưu hóa cho tiếng Việt. Công cụ này có thể là một thư viện như spaCy với model tiếng Việt, hoặc UndertheSea (một thư viện xử lý ngôn ngữ tự nhiên cho tiếng Việt), hoặc một mô hình tùy chỉnh được huấn luyện trên corpus tiếng Việt. Bộ tách câu này không chỉ nhìn vào dấu câu mà còn xem xét ngữ cảnh xung quanh để quyết định có nên chia tại vị trí đó hay không.

Kết quả của bước này là từ một văn bản dài, chúng ta có được một danh sách các câu độc lập. Mỗi câu giờ đây là một đơn vị hoàn chỉnh có thể được phân tích riêng biệt ở bước tiếp theo.

=== Claim Detection - Trái tim của module

Bây giờ đến phần khó nhất và quan trọng nhất của module: quyết định xem một câu có phải là claim hay không. Đây không phải là một bài toán trivial. Không phải mọi câu đều là claim. Một bài viết tin tức điển hình chứa nhiều loại câu khác nhau với mục đích khác nhau.

Hãy xem xét các loại câu thường gặp. Có những câu hỏi tu từ ("Liệu chúng ta có thể tin tưởng vào những con số này?"), những câu trích dẫn ý kiến của người khác ("Theo ông Nguyễn Văn A, chính sách này có thể gây tranh cãi"), những câu miêu tả cảm xúc hoặc ấn tượng chủ quan ("Bầu không khí tại hội nghị rất căng thẳng"), những câu đưa ra dự đoán không chắc chắn ("Giá vàng có thể sẽ tăng trong tuần tới"), và những câu kêu gọi hành động ("Hãy chia sẻ bài viết này nếu bạn đồng ý").

Trong số tất cả những loại câu này, chỉ có một số ít thực sự là claim theo định nghĩa của chúng ta - những phát biểu khẳng định về một sự thật có thể kiểm chứng. Ví dụ: "Giá vàng trong nước hôm nay tăng 500,000 đồng mỗi lượng" là một claim rõ ràng. Nó đưa ra một khẳng định cụ thể về một sự kiện có thể kiểm chứng thông qua các nguồn tin tài chính đáng tin cậy. Tương tự, "Thủ tướng đã ký quyết định số 1234 vào ngày 15 tháng 3" cũng là một claim vì nó có thể được xác minh qua các văn bản chính thức của chính phủ.

Để tự động hóa quá trình phân biệt này, hệ thống sử dụng một mô hình học máy đã được huấn luyện chuyên biệt. Mô hình này được triển khai trong các file claim_detector_model và model/phobert_claim_extractor. Như tên gọi cho thấy, nó dựa trên PhoBERT - một phiên bản của mô hình BERT được huấn luyện đặc biệt trên corpus tiếng Việt.

PhoBERT, giống như BERT gốc, là một mô hình ngôn ngữ mạnh mẽ đã được pre-train trên một lượng khổng lồ văn bản tiếng Việt để học các đặc trưng ngôn ngữ sâu. Nó hiểu được cấu trúc ngữ pháp, quan hệ ngữ nghĩa giữa các từ, và có thể nắm bắt ngữ cảnh xung quanh mỗi từ trong câu. Tuy nhiên, PhoBERT pre-trained chỉ biết về ngôn ngữ nói chung, nó chưa biết nhiệm vụ cụ thể của chúng ta là gì.

Do đó, chúng ta cần fine-tune PhoBERT cho tác vụ phát hiện claim. Quá trình này đòi hỏi một tập dữ liệu huấn luyện gồm hàng nghìn câu đã được gán nhãn bởi con người - những câu được đánh dấu là "claim" hoặc "not claim". Trong quá trình huấn luyện, mô hình học cách nhận diện các mẫu ngôn ngữ đặc trưng của claim: cách sử dụng động từ khẳng định, sự xuất hiện của số liệu cụ thể, cấu trúc câu mang tính tuyên bố, và nhiều đặc điểm tinh tế khác.

Kiến trúc của mô hình có thể được mô tả như một dạng sequence classification. Mỗi câu đầu vào được tokenize thành các token con (subword tokens), sau đó được đưa qua các lớp transformer của PhoBERT. Output cuối cùng từ token đặc biệt [CLS] (đại diện cho toàn bộ câu) được đưa qua một lớp fully connected và một hàm softmax để cho ra xác suất câu đó là claim. Nếu xác suất này vượt quá một ngưỡng nhất định (threshold), câu được phân loại là claim.

Điều quan trọng là mô hình này không chỉ đưa ra quyết định nhị phân mà còn cung cấp một confidence score. Điều này cho phép hệ thống xử lý các trường hợp biên (borderline cases) một cách thông minh hơn. Ví dụ, nếu một câu có confidence score rất thấp (dù có được phân loại là claim), chúng ta có thể quyết định không đưa nó vào xác minh để tránh lãng phí tài nguyên tính toán.

Kết quả cuối cùng từ Module Trích xuất Luận điểm là một danh sách các claim được lọc ra từ bài viết gốc. Mỗi claim này giờ đây sẽ được chuyển tiếp đến giai đoạn tiếp theo - giai đoạn xác minh thực sự.

== Mô hình Xác minh (Verification Model) - Bộ não của hệ thống

Nếu như Module Trích xuất Luận điểm là bộ lọc thông minh giúp chúng ta xác định được cái gì cần kiểm chứng, thì Mô hình Xác minh chính là bộ não của toàn bộ hệ thống - nơi diễn ra quá trình suy luận phức tạp để đưa ra kết luận về tính xác thực của thông tin. Đây là giai đoạn kỹ thuật nhất và đòi hỏi sự kết hợp tinh vi của nhiều công nghệ khác nhau.

Điều quan trọng cần lưu ý ngay từ đầu là chúng ta đang mô tả quá trình suy luận (inference) - cách mô hình hoạt động khi đưa ra quyết định cho một claim mới. Quá trình huấn luyện (training) và cập nhật mô hình là một chủ đề riêng sẽ được thảo luận chi tiết hơn trong các phần sau về Continuous Learning.

=== Encoder - Biến ngôn ngữ thành toán học

Bước đầu tiên trong quá trình xác minh là một thách thức cơ bản của xử lý ngôn ngữ tự nhiên: làm thế nào để máy tính có thể hiểu được ý nghĩa của văn bản? Máy tính về bản chất chỉ làm việc với số. Chúng không thể trực tiếp hiểu được ý nghĩa của các từ như "tăng", "giảm", hay "khủng hoảng". Chúng ta cần một cách để chuyển đổi ngôn ngữ tự nhiên thành dạng biểu diễn số học mà máy tính có thể xử lý, nhưng vẫn giữ được ý nghĩa ngữ nghĩa gốc.

Đây chính là nhiệm vụ của Encoder. Encoder là một mô hình ngôn ngữ lớn, trong trường hợp của chúng ta là PhoBERT, đã được huấn luyện để chuyển đổi văn bản thành các vector embedding đa chiều. Hãy tưởng tượng một vector embedding như một điểm trong một không gian nhiều chiều (thường là 768 chiều với BERT), nơi mà các từ hoặc câu có ý nghĩa tương tự nhau sẽ nằm gần nhau trong không gian đó.

Quá trình encoding diễn ra như sau: khi chúng ta đưa một claim vào Encoder, đầu tiên nó được chia thành các token (có thể là từ hoặc các đơn vị nhỏ hơn từ gọi là subword). Mỗi token được tra cứu trong một bảng vocabulary để chuyển thành một ID số. Sau đó, chuỗi các ID này được đưa qua nhiều lớp transformer của PhoBERT. Mỗi lớp transformer cho phép các token "nhìn thấy" và học từ các token khác trong câu, giúp mô hình hiểu được ngữ cảnh.

Điểm mấu chốt của các mô hình transformer như BERT là cơ chế attention (chú ý). Khi xử lý một từ, mô hình không chỉ nhìn vào bản thân từ đó mà còn chú ý đến tất cả các từ khác trong câu, với mức độ chú ý khác nhau tùy thuộc vào mức độ liên quan. Ví dụ, khi xử lý từ "tăng" trong câu "Giá vàng tăng mạnh", mô hình sẽ chú ý nhiều đến từ "giá vàng" để hiểu rằng đây là sự tăng về giá cả, không phải sự tăng về số lượng hay kích thước.

Sau khi đi qua tất cả các lớp transformer, chúng ta có được các vector embedding cho từng token trong câu. Nhưng chúng ta cần một vector duy nhất đại diện cho toàn bộ claim. Cách phổ biến nhất là lấy vector của token đặc biệt [CLS] (classification token) được đặt ở đầu mỗi câu. Token này được thiết kế đặc biệt để tổng hợp thông tin của toàn bộ câu.

Kết quả cuối cùng là một vector 768 chiều (với PhoBERT base) đại diện cho claim. Vector này không chỉ là một chuỗi số ngẫu nhiên mà mang trong nó toàn bộ ý nghĩa ngữ nghĩa của claim. Nếu chúng ta có hai claim có ý nghĩa tương tự, vector của chúng sẽ gần nhau trong không gian 768 chiều này. Ngược lại, hai claim hoàn toàn khác nhau sẽ có vector cách xa nhau.

Quá trình tương tự cũng được áp dụng cho tất cả các tài liệu trong cơ sở tri thức của chúng ta. Mỗi câu hoặc đoạn văn trong các bài báo đáng tin cậy mà chúng ta đã thu thập được chuyển thành vector embedding. Những vector này được tính toán trước (pre-computed) và lưu trữ trong cơ sở dữ liệu vector để có thể truy xuất nhanh chóng sau này.

=== Evidence Matching - Tìm kiếm bằng chứng thông minh

Bây giờ chúng ta đã có vector đại diện cho claim cần xác minh, bước tiếp theo là tìm kiếm các bằng chứng có thể giúp xác minh claim đó. Đây là một bài toán information retrieval (truy xuất thông tin) trong không gian vector.

Cơ sở tri thức của chúng ta, được xây dựng thông qua module build_vector_db.py, là một kho lưu trữ khổng lồ các vector embedding tương ứng với các câu và đoạn văn từ hàng nghìn bài báo đáng tin cậy đã được thu thập. Mỗi vector này đi kèm với metadata như văn bản gốc, nguồn (URL, tên trang web), ngày công bố, và độ uy tín của nguồn.

Để lưu trữ và tìm kiếm hiệu quả trong không gian vector nhiều chiều, chúng ta sử dụng một cơ sở dữ liệu vector chuyên biệt. Có nhiều lựa chọn như FAISS (do Facebook phát triển), Milvus, Weaviate, hay Pinecone. Những hệ thống này được tối ưu hóa đặc biệt cho việc tìm kiếm nearest neighbors (các điểm gần nhất) trong không gian nhiều chiều, một tác vụ rất tốn kém về mặt tính toán nếu thực hiện một cách naive.

Khi có một claim mới cần xác minh, vector của claim đó được sử dụng như một query vector. Hệ thống thực hiện một phép tìm kiếm tương đồng trong cơ sở dữ liệu vector. Phép đo tương đồng phổ biến nhất là cosine similarity - một độ đo cho biết hai vector có cùng hướng hay không trong không gian nhiều chiều. Cosine similarity có giá trị từ âm một đến một, trong đó một nghĩa là hai vector hoàn toàn cùng hướng (rất tương đồng), không là hai vector vuông góc (không liên quan), và âm một là hai vector ngược hướng (trái ngược).

Hệ thống không chỉ tìm một bằng chứng mà tìm k bằng chứng có độ tương đồng cao nhất (k thường là một số như năm hoặc mười). Tại sao lại cần nhiều bằng chứng? Có một vài lý do quan trọng. Thứ nhất, một bằng chứng đơn lẻ có thể không đủ để đưa ra kết luận chắc chắn. Bằng cách xem xét nhiều nguồn, chúng ta có thể có cái nhìn toàn diện hơn. Thứ hai, các bằng chứng có thể cung cấp các góc nhìn khác nhau về cùng một sự kiện. Thứ ba, nếu có sự mâu thuẫn giữa các nguồn, việc có nhiều bằng chứng giúp chúng ta phát hiện ra điều đó.

Một điểm tinh tế quan trọng là việc tìm kiếm này là ngữ nghĩa (semantic search), không chỉ là tìm kiếm từ khóa. Điều này có nghĩa là chúng ta có thể tìm thấy bằng chứng liên quan ngay cả khi chúng không sử dụng chính xác những từ giống với claim. Ví dụ, nếu claim nói về "giá vàng tăng", chúng ta có thể tìm thấy bằng chứng nói về "kim loại quý đắt đỏ hơn" hay "thị trường vàng tăng trưởng". Đây là một lợi thế lớn so với các phương pháp tìm kiếm truyền thống dựa trên keyword matching.

Tuy nhiên, tìm kiếm ngữ nghĩa cũng có nhược điểm. Đôi khi nó có thể trả về các kết quả có liên quan về mặt chủ đề nhưng không thực sự giúp xác minh claim. Ví dụ, một claim về "vaccine COVID-19" có thể match với các bài viết về "các loại vaccine khác" vì chúng có ngữ nghĩa tương tự, nhưng không phải bài viết nào cũng chứa thông tin hữu ích để xác minh claim cụ thể. Đây là lý do chúng ta cần bước tiếp theo - một mô hình NLI để đánh giá chính xác mối quan hệ giữa claim và bằng chứng.

Kết quả của bước Evidence Matching là một danh sách gồm k bằng chứng tiềm năng nhất, mỗi bằng chứng đi kèm với văn bản gốc, metadata về nguồn, và điểm tương đồng với claim. Những bằng chứng này giờ đây sẽ được đưa vào giai đoạn phân tích sâu hơn.

=== Confidence Scoring - Đưa ra phán quyết cuối cùng

Đây là bước cuối cùng và quan trọng nhất của toàn bộ pipeline xác minh. Chúng ta có claim cần kiểm chứng và chúng ta có các bằng chứng tiềm năng. Bây giờ chúng ta cần trả lời câu hỏi: bằng chứng này ủng hộ, bác bỏ, hay không liên quan đến claim?

Để trả lời câu hỏi này, hệ thống sử dụng một mô hình Suy luận Ngôn ngữ Tự nhiên (Natural Language Inference - NLI). NLI là một tác vụ cổ điển trong xử lý ngôn ngữ tự nhiên, được định nghĩa như sau: cho hai câu văn gọi là premise (tiền đề) và hypothesis (giả thuyết), xác định mối quan hệ logic giữa chúng. Mối quan hệ này có thể là một trong ba loại: Entailment (ủng hộ - premise ngụ ý hypothesis là đúng), Contradiction (mâu thuẫn - premise ngụ ý hypothesis là sai), hoặc Neutral (trung lập - premise không đủ thông tin để xác định hypothesis đúng hay sai).

Trong ngữ cảnh của chúng ta, mỗi bằng chứng đóng vai trò là premise và claim là hypothesis. Chúng ta đưa từng cặp (evidence, claim) vào mô hình NLI và nhận về xác suất cho ba khả năng Entailment, Contradiction và Neutral.

Mô hình NLI được triển khai trong file model/retrain_nli.py và có kiến trúc tương tự như mô hình PhoBERT đã thảo luận. Tuy nhiên, thay vì chỉ xử lý một câu, nó nhận đầu vào là hai câu được nối với nhau bởi một token đặc biệt [SEP]. Ví dụ: "[CLS] Bằng chứng về giá vàng [SEP] Claim về giá vàng [SEP]". Mô hình sau đó sử dụng cơ chế attention để cho phép các từ trong bằng chứng và claim "tương tác" với nhau, từ đó hiểu được mối quan hệ giữa chúng.

Output của mô hình NLI cho mỗi cặp (evidence, claim) là ba xác suất cộng lại bằng một. Ví dụ: Entailment có thể là 0.8, Contradiction là 0.1, và Neutral là 0.1. Những xác suất này chính là cơ sở để chấm điểm độ tin cậy (confidence score).

Nhưng chúng ta không chỉ có một bằng chứng mà có k bằng chứng, mỗi bằng chứng cho ra một bộ ba xác suất riêng. Làm thế nào để tổng hợp tất cả thông tin này thành một kết luận cuối cùng? Đây là nơi logic tổng hợp (aggregation logic) bước vào, và đây cũng là nơi chúng ta có thể tích hợp các cân nhắc về độ uy tín của nguồn.

Logic tổng hợp cơ bản có thể hoạt động như sau: trước tiên, chúng ta kiểm tra xem có bất kỳ bằng chứng nào mạnh mẽ (high confidence) bác bỏ claim không. Nếu có, chúng ta có xu hướng gán nhãn FAKE. Logic ở đây là nếu có bất kỳ nguồn đáng tin cậy nào trực tiếp mâu thuẫn với claim, điều đó là một dấu hiệu mạnh mẽ cho thấy claim có vấn đề. Ví dụ, nếu claim nói "Sự kiện X xảy ra vào ngày 10" nhưng một nguồn tin chính thống nói "Sự kiện X xảy ra vào ngày 12", đó là một mâu thuẫn rõ ràng.

Nếu không có bằng chứng mạnh nào bác bỏ, chúng ta xem xét các bằng chứng ủng hộ. Nếu có nhiều bằng chứng đáng tin cậy với confidence score cao cùng ủng hộ claim, chúng ta có xu hướng gán nhãn REAL. Lý tưởng nhất là khi có sự đồng thuận từ nhiều nguồn độc lập - điều này tăng độ tin cậy của kết luận.

Nếu không tìm thấy đủ bằng chứng mạnh để ủng hộ hoặc bác bỏ, hoặc nếu tất cả các mối quan hệ đều là Neutral, hệ thống sẽ trung thực gán nhãn UNDEFINED. Điều này cũng xảy ra khi có xung đột giữa các bằng chứng - một số ủng hộ trong khi một số khác bác bỏ, và không có sự đồng thuận rõ ràng.

Một yếu tố tinh tế nhưng quan trọng trong logic tổng hợp là việc trọng số hóa dựa trên độ uy tín của nguồn. Như đã đề cập trong Chương 3, không phải tất cả các nguồn đều ngang nhau. Một bằng chứng từ trang web chính phủ, một tờ báo uy tín quốc gia, hay một tạp chí khoa học được bình duyệt sẽ có trọng số cao hơn so với một blog cá nhân hay một trang web không rõ nguồn gốc.

Trong thực tế, khi tổng hợp các xác suất từ nhiều bằng chứng, chúng ta nhân mỗi xác suất với một hệ số trọng số phản ánh độ uy tín của nguồn. Ví dụ, nếu bằng chứng A từ VnExpress (source credibility = 0.9) cho Entailment probability là 0.7, trong khi bằng chứng B từ một blog không rõ nguồn gốc (source credibility = 0.3) cho Contradiction probability là 0.6, thì weighted contribution của A sẽ là 0.9 x 0.7 = 0.63 trong khi của B chỉ là 0.3 x 0.6 = 0.18. Điều này đảm bảo rằng các nguồn đáng tin cậy có ảnh hưởng lớn hơn đến quyết định cuối cùng.

Output cuối cùng của Mô hình Xác minh là một kết quả xác minh hoàn chỉnh cho claim, bao gồm nhãn (REAL, FAKE, hoặc UNDEFINED), một confidence score tổng thể cho thấy hệ thống chắc chắn đến mức nào về kết luận của mình, và có thể là danh sách các bằng chứng đã được sử dụng cùng với giải thích ngắn gọn về lý do đưa ra kết luận đó. Thông tin này sau đó có thể được trả về cho người dùng cuối thông qua extension trình duyệt hoặc dashboard của hệ thống.

== Tổng kết thiết kế hệ thống

Khi nhìn lại toàn bộ thiết kế, chúng ta có thể thấy rằng mỗi thành phần đều được thiết kế cẩn thận để giải quyết một khía cạnh cụ thể của bài toán. Lớp Thu thập Dữ liệu với Scraper, Kafka và Airflow đảm bảo hệ thống luôn có dòng chảy dữ liệu mới và có thể xử lý quy mô lớn. Module Trích xuất Luận điểm với sentence splitting và claim detection đảm bảo chúng ta xác minh đúng đơn vị thông tin. Mô hình Xác minh với Encoder, Evidence Matching và NLI đảm bảo quá trình xác minh được thực hiện một cách thông minh và chính xác.

Điều quan trọng là toàn bộ kiến trúc này không phải là tĩnh. Nó được thiết kế với khả năng học liên tục ở trung tâm - một khía cạnh chúng ta sẽ khám phá sâu hơn trong các chương tiếp theo khi thảo luận về quy trình huấn luyện lại và cơ chế Human-in-the-loop. Thiết kế modular cho phép mỗi thành phần được cải thiện độc lập, trong khi các điểm tích hợp rõ ràng giữa các module đảm bảo chúng có thể làm việc cùng nhau một cách hài hòa.
