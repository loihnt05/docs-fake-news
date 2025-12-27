#set par(justify: true)

  ---

  Chương 10: Các Hạn chế và Rủi ro (Limitations & Risks)

  Mặc dù hệ thống được thiết kế với nhiều lớp phòng thủ và cơ chế học tập thông minh, không có một hệ thống phức tạp nào là hoàn hảo. Việc nhận diện và thừa nhận các hạn chế và rủi ro tiềm tàng là tối quan trọng để định hướng các cải tiến
  trong tương lai và sử dụng hệ thống một cách có trách nhiệm.

  10.1. Nhiễu nhãn (Label Noise)

  Nhiễu nhãn là một trong những thách thức cố hữu và khó loại bỏ nhất trong bất kỳ hệ thống học máy nào dựa trên dữ liệu do con người gán nhãn.

   * Vấn đề: Mặc dù đã có hệ thống kiểm duyệt (6.3) và trọng số uy tín (6.2) để giảm thiểu, nhiễu vẫn có thể xâm nhập vào bộ dữ liệu huấn luyện. Các nguồn nhiễu bao gồm:
       * Lỗi từ người dùng thường: Người dùng có thể báo cáo sai do hiểu lầm hoặc thiếu thông tin, và dù có trọng số thấp, một lượng lớn các báo cáo sai có chủ đích vẫn có thể ảnh hưởng tiêu cực đến mô hình.
       * Lỗi từ chuyên gia: Các quản trị viên cũng là con người và có thể mắc lỗi, đặc biệt với các luận điểm phức tạp, đa nghĩa hoặc khi họ phải xử lý một khối lượng lớn báo cáo.
       * Sự thật thay đổi: Một thông tin được dán nhãn là REAL vào hôm nay có thể bị chính nguồn tin đó đính chính vào ngày mai. Nhãn đó, vốn đúng tại thời điểm nó được tạo ra, giờ đã trở thành nhiễu.

   * Tác động: Nhiễu trong dữ liệu huấn luyện có thể làm cho mô hình học các quy luật sai lệch, dẫn đến suy giảm hiệu suất và làm chậm quá trình hội tụ đến một trạng thái tối ưu. Dù hệ thống của chúng tôi được thiết kế để giảm thiểu rủi ro
     này, không thể loại bỏ nó hoàn toàn.

  10.2. Thiên kiến của Quản trị viên (Admin Bias)

  Đây là một rủi ro mang tính hệ thống và nguy hiểm hơn cả nhiễu nhãn đơn thuần.

   * Vấn đề: "Sự thật vàng" (ground truth) của hệ thống được quyết định bởi một nhóm nhỏ các quản trị viên/chuyên gia. Nhóm này, dù có thiện chí, cũng có thể vô thức chia sẻ chung một hệ thống niềm tin, quan điểm chính trị, hay nền tảng
     văn hóa. Điều này có thể dẫn đến một sự thiên vị có hệ thống trong quá trình kiểm duyệt. Họ có thể có xu hướng chấp thuận các báo cáo phù hợp với thế giới quan của mình và bác bỏ các báo cáo đi ngược lại nó.

   * Tác động: Theo thời gian, mô hình sẽ không chỉ học cách phân biệt tin thật/giả. Nó sẽ học cách phân biệt thông tin "hợp với quan điểm của quản trị viên" và thông tin "không hợp". Nếu không được kiểm soát, hệ thống có nguy cơ trở thành
     một "buồng vang" (echo chamber), củng cố một góc nhìn duy nhất thay vì là một công cụ kiểm chứng khách quan. Đây là rủi ro nghiêm trọng nhất, có thể làm xói mòn toàn bộ mục tiêu và tính chính danh của dự án. Giải pháp cho vấn đề này
     không chỉ nằm ở kỹ thuật, mà còn nằm ở quy trình quản trị: đảm bảo đội ngũ chuyên gia đa dạng về quan điểm và tuân thủ một bộ quy tắc đạo đức kiểm chứng thông tin nghiêm ngặt.

  10.3. Độ trễ trong việc học (Delayed Learning)

  Độ trễ này là một sự đánh đổi có chủ đích trong thiết kế của hệ thống để đổi lấy sự ổn định và hiệu quả tính toán.

   * Vấn đề: Quyết định sử dụng mô hình huấn luyện lại theo lô định kỳ (dags/weekly_retrain_dag.py) thay vì học real-time (7.1) tạo ra một độ trễ cố hữu. Trí thông minh của mô hình chỉ được cập nhật sau mỗi chu kỳ (ví dụ: một tuần).

   * Tác động: Điều này tạo ra một "cửa sổ tổn thương" (window of vulnerability). Khi một chiến dịch tin giả hoàn toàn mới xuất hiện vào thứ Hai, mô hình sẽ không "học" được về nó cho đến tận chu kỳ huấn luyện của cuối tuần. Trong suốt cả
     tuần đó, hệ thống sẽ phải dựa vào kiến thức cũ và khả năng đối sánh bằng chứng. Nếu dạng tin giả đủ mới lạ, mô hình sẽ gần như "mù" trước nó. Mặc dù cơ sở tri thức được cập nhật hàng ngày (dags/daily_crawl_dag.py) có thể giúp tìm thấy
     các bài báo phản bác trực tiếp, nhưng khả năng tự suy luận và nhận dạng mẫu của mô hình bị trễ lại. Đây là một sự đánh đổi quan trọng giữa khả năng phản ứng tức thời và sự ổn định lâu dài của hệ thống.
