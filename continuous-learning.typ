#set par(justify: true)

= Pipeline Học Liên tục - Trái Tim Trí Tuệ Nhân Tạo Tự Tiến Hóa

Hãy tưởng tượng bạn đang xây dựng một hệ thống phát hiện tin giả không chỉ hoạt động tốt hôm nay, mà còn ngày càng thông minh hơn theo thời gian. Đây chính là bản chất của Pipeline Học Liên tục - một cơ chế cho phép hệ thống tự học hỏi từ kinh nghiệm và thích ứng với môi trường thông tin luôn thay đổi. Chương này là trái tim của toàn bộ kiến trúc, nơi mà khoa học dữ liệu gặp gỡ kỹ thuật vận hành để tạo nên một hệ thống thực sự "sống".
#align(center)[
  #image("images/online-learning.png", width: 400pt)
]
== Thời Điểm Học - Nghệ Thuật Cân Bằng Giữa Tốc Độ và Ổn Định

Khi thiết kế một hệ thống học máy trong môi trường sản xuất thực tế, câu hỏi đầu tiên và quan trọng nhất là: mô hình nên học khi nào? Quyết định này không đơn thuần là một lựa chọn kỹ thuật, mà là sự cân bằng tinh tế giữa nhiều yếu tố đối lập nhau.

=== Tại Sao Không Học Real-time?

Nhiều người khi mới tiếp cận machine learning thường nghĩ rằng học trong thời gian thực (real-time learning) là giải pháp lý tưởng. Nghe có vẻ hấp dẫn: mỗi khi có phản hồi từ người dùng, mô hình ngay lập tức cập nhật và trở nên thông minh hơn. Tuy nhiên, trong thực tế, cách tiếp cận này ẩn chứa những rủi ro nghiêm trọng mà có thể phá hủy cả hệ thống.

Vấn đề đầu tiên là sự thiếu ổn định về mặt hành vi của mô hình. Hãy tưởng tượng bạn có một chiếc la bàn dẫn đường, nhưng mỗi lần gió thổi là kim la bàn lại xoay loạn xạ. Đó chính là điều xảy ra với mô hình học real-time. Một vài phản hồi đơn lẻ, có thể đúng hoặc sai, có thể khiến mô hình thay đổi hành vi một cách đột ngột. Người dùng A kiểm tra một tin tức vào lúc 9 giờ sáng và nhận kết quả REAL, nhưng chỉ vài phút sau, do mô hình vừa học từ một phản hồi sai lệch, người dùng B kiểm tra cùng tin đó lại nhận kết quả FAKE. Sự không nhất quán này không chỉ làm mất lòng tin của người dùng mà còn tạo ra hỗn loạn trong trải nghiệm sử dụng.

Vấn đề thứ hai liên quan đến chi phí tính toán, một khía cạnh mà nhiều kỹ sư thường đánh giá thấp. Việc huấn luyện lại một mô hình ngôn ngữ lớn như PhoBERT không phải là một phép tính đơn giản. Đây là một quá trình đòi hỏi hàng trăm GPU hours, tiêu tốn lượng điện năng khổng lồ và yêu cầu băng thông mạng lớn để di chuyển dữ liệu. Nếu bạn thực hiện việc này sau mỗi phản hồi, giả sử hệ thống nhận được một nghìn phản hồi mỗi ngày, bạn sẽ phải chạy một nghìn lần quá trình huấn luyện. Chi phí này không chỉ không thực tế về mặt kinh tế mà còn không bền vững về môi trường.

Vấn đề thứ ba là trạng thái không nhất quán trong kiến trúc phân tán. Trong một hệ thống thực tế, bạn thường có nhiều máy chủ phục vụ người dùng cùng lúc để đảm bảo khả năng mở rộng và độ tin cậy. Nếu mỗi máy chủ tự cập nhật mô hình theo thời gian thực của riêng nó, các máy chủ này sẽ nhanh chóng rời rạc về mặt phiên bản mô hình. Người dùng kết nối đến máy chủ A có thể thấy kết quả hoàn toàn khác với người dùng kết nối đến máy chủ B cho cùng một truy vấn. Đây là một cơn ác mộng về mặt vận hành và gỡ lỗi.

=== Giải Pháp: Batch Retraining - Học Theo Nhịp Điệu Được Kiểm Soát

Thay vì học liên tục như một dòng chảy không ngừng nghỉ, hệ thống của chúng ta áp dụng phương pháp Batch Retraining - học theo từng đợt được lên lịch cẩn thận. Đây là sự kết hợp hoàn hảo giữa khả năng thích ứng và sự ổn định.

Cụ thể, hệ thống sử dụng Apache Airflow, một công cụ điều phối workflow mạnh mẽ, để quản lý toàn bộ chu kỳ học. Trong file `dags/weekly_retrain_dag.py`, chúng ta định nghĩa một Directed Acyclic Graph (DAG) mô tả chính xác các bước của quá trình huấn luyện lại và khi nào chúng nên được thực thi. Hàng tuần, vào một thời điểm cố định (thường là cuối tuần khi lưu lượng người dùng thấp), Airflow tự động kích hoạt pipeline này như một chiếc đồng hồ báo thức đáng tin cậy.

Phương pháp này mang lại ba lợi ích quan trọng. Thứ nhất là sự ổn định có kiểm soát. Trong suốt cả tuần, mô hình hoạt động với hành vi nhất quán, tạo trải nghiệm đồng đều cho tất cả người dùng. Mô hình chỉ được cập nhật khi đã tích lũy đủ một khối lượng lớn phản hồi đã được kiểm duyệt kỹ lưỡng. Thay vì phản ứng với từng tiếng ồn ngẫu nhiên, mô hình học từ tín hiệu rõ ràng được lọc qua thời gian.

Thứ hai là hiệu quả về tài nguyên. Thay vì chạy một nghìn lần huấn luyện nhỏ lẻ, hệ thống chạy một lần huấn luyện lớn với toàn bộ dữ liệu tích lũy. Điều này không chỉ tiết kiệm chi phí tính toán mà còn cho phép mô hình học được những mẫu phức tạp hơn từ tập dữ liệu lớn hơn. Có một hiệu ứng tương tự như việc bạn học một ngôn ngữ mới: thay vì học một từ rồi quên, học một từ khác rồi quên, bạn học cả một bài văn đầy đủ để hiểu được ngữ cảnh và cấu trúc.

Thứ ba là tính nhất quán trong triển khai. Sau khi quá trình huấn luyện hoàn thành, tất cả các máy chủ sản xuất được cập nhật đồng thời lên cùng một phiên bản mô hình mới. Không có sự phân mảnh, không có các phiên bản "lẻ loi". Mọi người dùng, bất kể họ kết nối đến máy chủ nào, đều trải nghiệm cùng một mức độ trí tuệ của hệ thống.

#align(center)[
  #image("images/model-retrain.jpg", width: 400pt)
]

== Lựa Chọn Dữ Liệu Huấn Luyện - Nghệ Thuật Lọc Chân Lý

Có một nguyên tắc cơ bản trong machine learning mà mọi kỹ sư đều biết: "Garbage in, garbage out" - rác vào, rác ra. Chất lượng của mô hình mới phụ thuộc tuyệt đối vào chất lượng của dữ liệu được sử dụng để huấn luyện nó. Đây là lý do tại sao bước lựa chọn dữ liệu trong `retrain_pipeline.py` được thực hiện với sự cẩn trọng đến từng chi tiết nhỏ.

=== Tường Lửa Đầu Tiên: Chỉ Dùng Báo Cáo Đã Được Duyệt
Nguồn dữ liệu chính cho việc học liên tục đến từ các báo cáo của người dùng - những phản hồi họ gửi khi họ tin rằng hệ thống đã đưa ra phán đoán sai. Tuy nhiên, không phải mọi báo cáo đều đáng tin cậy. Một người dùng có thể nhầm lẫn, có thể có động cơ xấu, hoặc đơn giản là không hiểu đủ về ngữ cảnh để đánh giá chính xác.

Đây là nơi hệ thống kiểm duyệt từ Chương 6.3 phát huy vai trò then chốt. Mỗi báo cáo của người dùng phải trải qua một quy trình xem xét nghiêm ngặt bởi các chuyên gia - những người có kiến thức chuyên môn và được hệ thống tin tưởng thông qua điểm uy tín cao. Chỉ khi một báo cáo được đánh dấu rõ ràng là "Approved" - nghĩa là chuyên gia xác nhận rằng phản hồi này là chính xác và có giá trị - nó mới được đưa vào bộ dữ liệu huấn luyện.

Tưởng tượng bộ dữ liệu huấn luyện như một thư viện khoa học. Bạn không muốn đưa những cuốn sách giả mạo, những nghiên cứu không được kiểm chứng vào đó. Mỗi mẫu dữ liệu trong bộ huấn luyện là một "chân lý" mà bạn đang dạy cho mô hình. Nếu "chân lý" đó sai, mô hình sẽ học sai và lan truyền sự sai lệch đó đến hàng triệu người dùng khác.

=== Tường Lửa Thứ Hai: Loại Trừ Các Nhãn Không Xác Định

Nhưng chỉ có báo cáo được duyệt thôi chưa đủ. Hệ thống còn áp dụng một lớp lọc thứ hai dựa trên bản chất của nhãn được sửa chữa.

Nhớ lại rằng hệ thống có ba loại nhãn: REAL (thật), FAKE (giả), và UNDEFINED (không xác định). Nhãn UNDEFINED xuất hiện khi mô hình không đủ tự tin để đưa ra phán quyết, có thể vì thông tin không đầy đủ, ngữ cảnh phức tạp, hoặc yêu cầu kiến thức chuyên môn sâu.

Mục tiêu của việc học liên tục là giúp mô hình giải quyết được những trường hợp khó mà trước đây nó không chắc chắn. Do đó, bộ dữ liệu huấn luyện tập trung đặc biệt vào các cặp (claim, corrected_label) trong đó corrected_label là REAL hoặc FAKE rõ ràng do con người cung cấp. Đây thường là những trường hợp mà ban đầu mô hình đã gắn nhãn UNDEFINED, nhưng giờ đây có câu trả lời chính xác từ chuyên gia.

Tại sao không sử dụng những mẫu mà ngay cả con người cũng chưa xác định được? Lý do rất đơn giản: bạn không thể dạy những gì bạn chưa biết. Nếu một tuyên bố quá mơ hồ hoặc phức tạp đến mức ngay cả chuyên gia cũng không thể đưa ra phán quyết dứt khoát, việc ép buộc mô hình học nó chỉ tạo ra nhiễu và làm giảm chất lượng. Thay vào đó, những trường hợp này được giữ lại để con người xử lý trực tiếp, trong khi mô hình tập trung học những bài học rõ ràng và có giá trị.

== Huấn Luyện Có Trọng Số - Trí Tuệ Đám Đông Có Kiểm Soát

Sau khi đã có một bộ dữ liệu "sạch" gồm những mẫu đã được kiểm duyệt và có nhãn rõ ràng, bước tiếp theo là sử dụng nó một cách thông minh nhất. Đây là nơi mà khái niệm về độ uy tín từ Chương 6 được tích hợp sâu vào quá trình học.

=== Oversampling Theo Độ Uy Tín - Không Phải Tất Cả Ý Kiến Đều Bình Đẳng
Trong một xã hội dân chủ lý tưởng, mọi tiếng nói đều được lắng nghe bình đẳng. Nhưng khi nói đến việc đào tạo một hệ thống AI để phát hiện thông tin sai lệch, chúng ta cần nhận ra rằng không phải mọi ý kiến đều có giá trị như nhau. Một chuyên gia báo chí với 20 năm kinh nghiệm xác minh sự thật có kiến thức và khả năng phán đoán vượt trội so với một người dùng ngẫu nhiên trên internet.

Hệ thống của chúng ta thể hiện sự thật này thông qua kỹ thuật oversampling có trọng số dựa trên điểm uy tín. Hãy hiểu nó theo cách này: khi tạo các lô dữ liệu (data batches) để đưa vào mô hình trong quá trình huấn luyện, mỗi mẫu dữ liệu không có xác suất được chọn như nhau. Thay vào đó, xác suất này tỷ lệ thuận với điểm uy tín của người dùng đóng góp mẫu đó.

Cụ thể, giả sử bạn có một phản hồi từ một chuyên gia có điểm uy tín là 1000 và một phản hồi từ người dùng thường có điểm uy tín là 10. Trong quá trình lấy mẫu ngẫu nhiên để tạo batch, phản hồi từ chuyên gia sẽ có xác suất được chọn cao gấp 100 lần. Điều này có nghĩa là trong suốt quá trình huấn luyện, mô hình sẽ "gặp" phản hồi từ chuyên gia nhiều lần hơn hẳn, buộc nó phải "chú ý" và "ghi nhớ" kỹ hơn những gì chuyên gia dạy.

Đây giống như việc một học sinh học một bài quan trọng. Nếu giáo viên nhắc lại một khái niệm quan trọng mười lần trong suốt khóa học, học sinh sẽ nhớ nó tốt hơn nhiều so với một khái niệm chỉ được đề cập một lần thoáng qua. Oversampling hoạt động theo nguyên lý tương tự: mô hình "nghe" lời khuyên từ các chuyên gia nhiều lần hơn, khiến nó ảnh hưởng mạnh hơn đến trọng số cuối cùng của mạng neural.

=== Không Lọc Cứng - Sức Mạnh Của Lọc Mềm

Một quyết định thiết kế quan trọng khác là hệ thống không áp dụng một ngưỡng cứng như "chỉ học từ người dùng có điểm uy tín trên 50". Cách tiếp cận hard filter như vậy tuy đơn giản nhưng lại quá thô và bỏ lỡ nhiều thông tin có giá trị.

Thay vào đó, hệ thống sử dụng toàn bộ phổ điểm uy tín như một cơ chế "lọc mềm" thông qua việc lấy mẫu có trọng số. Một người dùng có điểm thấp, giả sử 5, vẫn có thể đóng góp vào quá trình học, dù xác suất phản hồi của họ được chọn vào batch huấn luyện là rất nhỏ. Nếu họ đóng góp một phản hồi thực sự đúng, nó vẫn có thể xuất hiện trong quá trình huấn luyện, dù hiếm hoi.

Cách tiếp cận này tận dụng được "trí tuệ đám đông" - ý tưởng rằng một nhóm lớn người, ngay cả khi mỗi cá nhân không phải chuyên gia, vẫn có thể đưa ra quyết định tập thể đúng đắn. Tuy nhiên, nó làm điều đó một cách an toàn bằng cách đảm bảo rằng tiếng nói của các chuyên gia luôn chi phối. Nếu một nghìn người dùng thường nói A và một chuyên gia nói B, mô hình sẽ nghiêng mạnh về B nhờ vào trọng số cao hơn của chuyên gia.

Đây là sự khác biệt giữa một hệ thống dân túy (nơi đa số luôn thắng bất kể chất lượng) và một hệ thống meritocratic có kiểm soát (nơi tiếng nói được cân đo dựa trên năng lực được chứng minh). Hệ thống của chúng ta nằm ở loại thứ hai, cân bằng giữa sự tham gia rộng rãi và chất lượng được bảo đảm.

== Quản Lý Phiên Bản Mô Hình - Nghệ Thuật An Toàn Trong Tiến Hóa

Việc cho phép một mô hình AI tự học và tiến hóa là một điều tuyệt vời, nhưng nó cũng tiềm ẩn rủi ro. Điều gì sẽ xảy ra nếu một phiên bản mới, dù được huấn luyện tốt trên dữ liệu lịch sử, lại hoạt động kém hơn trong thực tế? Đây là lý do tại sao quản lý phiên bản mô hình là một phần tối quan trọng của MLOps (Machine Learning Operations).

=== Hệ Thống Đánh Số Phiên Bản - Dấu Vết Tiến Hóa

Sau mỗi chu kỳ huấn luyện thành công, pipeline không ghi đè lên mô hình cũ như nhiều hệ thống nghiệp dư thường làm. Thay vào đó, nó lưu phiên bản mô hình mới vào một thư mục riêng biệt với số phiên bản được tăng dần: `checkpoints/model_1`, `checkpoints/model_2`, `checkpoints/model_3`, và cứ thế tiếp tục.

Mỗi thư mục này là một "ảnh chụp nhanh" hoàn chỉnh của mô hình tại một thời điểm cụ thể. Nó không chỉ chứa các trọng số của mạng neural mà còn chứa tất cả các file cấu hình, tokenizer, và metadata cần thiết để tái tạo chính xác hành vi của mô hình đó. Bạn có thể nghĩ về nó như một chuỗi các bản lưu trong một trò chơi video - mỗi bản lưu đại diện cho trạng thái đầy đủ của trò chơi tại một thời điểm.

Sau khi lưu phiên bản mới, một file cấu hình trung tâm (thường là `config/model_version.json` hoặc một biến môi trường) được cập nhật để trỏ ứng dụng backend trong `backend/main.py` đến phiên bản mới nhất này. Khi các máy chủ sản xuất khởi động lại, chúng đọc file cấu hình này và load mô hình từ thư mục tương ứng.

=== Chiến Lược Rollback - Mạng Lưới An Toàn

Nhưng giá trị thực sự của hệ thống versioning không nằm ở việc lưu trữ lịch sử, mà nằm ở khả năng quay lui (rollback) an toàn khi cần thiết.

Hãy tưởng tượng kịch bản này: Vào một ngày Chủ nhật, pipeline huấn luyện tự động chạy và tạo ra model_9, một phiên bản mới được huấn luyện trên dữ liệu của tuần trước. Các chỉ số đánh giá trên tập validation trông rất tốt - độ chính xác tăng, F1-score cải thiện. Hệ thống tự động triển khai model_9 lên môi trường sản xuất.

Nhưng vào sáng thứ Hai, khi lưu lượng người dùng thực tế đổ về, đội ngũ vận hành bắt đầu nhận được báo cáo rằng hệ thống đang có hành vi kỳ lạ. Có thể model_9 quá nhạy cảm với một loại ngôn ngữ cụ thể, hoặc nó đã học được một pattern sai lệch từ dữ liệu huấn luyện mà không được phát hiện trong giai đoạn kiểm tra. Trong machine learning, những vấn đề như vậy không hiếm - chúng thường chỉ lộ rõ khi mô hình gặp phải sự đa dạng đầy đủ của dữ liệu thực tế.

Nhờ vào hệ thống quản lý phiên bản, việc xử lý tình huống này trở nên đơn giản đến đáng ngạc nhiên. Đội ngũ vận hành chỉ cần thực hiện hai bước: đầu tiên, chỉnh sửa file cấu hình để trỏ về `checkpoints/model_8` (phiên bản ổn định trước đó); thứ hai, khởi động lại các máy chủ ứng dụng. Trong vòng vài phút, toàn bộ hệ thống quay về trạng thái hoạt động tốt trước đó.

Trong khi đó, đội ngũ kỹ thuật có thể dành thời gian để phân tích kỹ lưỡng xem điều gì đã xảy ra với model_9. Họ có thể chạy các phân tích offline, kiểm tra lại dữ liệu huấn luyện, điều chỉnh các siêu tham số, hoặc cải thiện quy trình đánh giá. Tất cả những điều này được thực hiện mà không có áp lực thời gian, vì sản phẩm đang chạy ổn định trên một phiên bản đã được kiểm chứng.

=== Triết Lý Vận Hành Chuyên Nghiệp

Chiến lược này phản ánh một tư duy vận hành chuyên nghiệp và trưởng thành. Nó thừa nhận rằng trong hệ thống phức tạp, vấn đề là điều không thể tránh khỏi. Điều quan trọng không phải là làm thế nào để không bao giờ có vấn đề, mà là làm thế nào để phát hiện và khôi phục nhanh chóng khi vấn đề xảy ra.

Trong lĩnh vực kỹ thuật phần mềm, điều này được gọi là "mean time to recovery" (MTTR) - thời gian trung bình để khôi phục. Một hệ thống tốt không phải là hệ thống không bao giờ gặp lỗi, mà là hệ thống có MTTR thấp. Với cơ chế rollback được thiết kế tốt, MTTR của hệ thống này chỉ tính bằng phút, so với hàng giờ hoặc thậm chí hàng ngày trong các hệ thống kém hơn.

Hơn nữa, chiến lược này tạo ra một môi trường an toàn cho đổi mới. Biết rằng họ luôn có thể quay lui, đội ngũ kỹ thuật được khuyến khích thử nghiệm các cải tiến táo bạo, thử các kiến trúc mô hình mới, hoặc thử nghiệm với các phương pháp huấn luyện tiên tiến. Không có nỗi sợ "phá hỏng production" - một nỗi sợ thường kìm hãm sự đổi mới trong nhiều tổ chức.

---

Pipeline Học Liên tục này là minh chứng cho việc kết hợp hài hòa giữa nhiều nguyên tắc: sự ổn định và khả năng thích ứng, tự động hóa và kiểm soát, dân chủ và chuyên môn, đổi mới và an toàn. Nó biến một hệ thống AI tĩnh thành một sinh vật học hỏi sống động, nhưng làm điều đó với sự kiểm soát và trách nhiệm cần thiết cho một ứng dụng quan trọng đối với xã hội.