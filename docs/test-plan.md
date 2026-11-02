# Kế hoạch & Báo cáo kiểm thử tự động đầu cuối (ARTEMIS E2E Test Plan) — PRM393 Lab 3

Hệ thống kiểm thử tự động đầu cuối cho ứng dụng di động kết nối đám mây **EXEMatching**, điều khiển bởi **Google ARTEMIS** trên thiết bị giả lập Android (`Pixel_API_36`). Mã kiểm thử: [`e2e_test/`](../e2e_test).

---

## 1. Phương pháp & Nguyên tắc kiểm định

- **Điều khiển bởi AI Agent (ARTEMIS):** Mỗi ca kiểm thử giao cho Agent một mục tiêu phát biểu bằng ngôn ngữ tự nhiên từ góc nhìn sinh viên. Agent tương tác trực tiếp với giao diện ứng dụng.
- **Đầu ra cấu trúc (Structured JSON Verification):** Agent trả về kết quả dưới dạng đối tượng JSON chuẩn để kiểm thử đối chiếu từng trường giá trị.
- **Đối chiếu giá trị quan sát thực tế (Ground Truth from Device):** Không chỉ dựa vào cờ trạng thái `SUCCESS` của Agent. Bài kiểm thử trực tiếp đọc cây ngữ cảnh tiếp cận (`Semantics.identifier` ánh xạ sang `resource-id` của Android) và sự kiện `analytics_event` trong Logcat để xác minh giá trị cụ thể.
- **Tiêu chuẩn 3 lần chạy (3 Runs per Test Case):** Mỗi ca kiểm thử được thực thi tối thiểu 3 lần độc lập (`run1`, `run2`, `run3`) để chứng minh tính ổn định, không phụ thuộc vào trạng thái đệm hay may rủi.
- **Bao phủ toàn diện:** 13 ca kiểm thử bao phủ toàn bộ 3 luồng chính Lab 2, các nhánh lỗi (mất mạng, nhóm đầy, sai tên miền) và tương tác hệ thống Android gốc (Share Sheet).

---

## 2. Đặc tả chi tiết 13 Ca kiểm thử (Test Cases Specification)

| Mã ca (ID) | Phân loại & Luồng | Điều kiện đầu (Precondition) | Các bước thực hiện (Execution Steps) | Kết quả mong đợi & Giá trị quan sát được |
|---|---|---|---|---|
| **TC-01** | Xác thực · Nhánh lỗi | Ứng dụng mới mở, chưa đăng nhập (`Signed out`) | 1. Bấm nút đăng nhập Google.<br>2. Chọn tài khoản cá nhân Gmail (`@gmail.com`). | Bị từ chối đăng nhập; hiển thị thông báo lỗi "This is not an FPT account"; `signed_in=false`; cờ giao diện `[sign_in_message]` hiển thị. |
| **TC-02** | Xác thực · Luồng chuẩn | Chưa đăng nhập | 1. Bấm đăng nhập Google.<br>2. Chọn tài khoản FPT `minh.le@fpt.edu.vn`. | Đăng nhập thành công vào Home; hiển thị lời chào "Hi, Minh", thẻ hạn chót `[card_deadline]`, thông tin nhóm `Team AI-04`; ghi nhận sự kiện `login`. |
| **TC-03** | Flow 1 · Tìm kiếm & Lọc | Đã đăng nhập tài khoản `an.tran@fpt.edu.vn` (chưa có nhóm) | 1. Chuyển sang tab Browse (`/browse`).<br>2. Bật chip lọc `AI/ML` và giữ `Open Slots`.<br>3. Gõ từ khóa tìm kiếm "drone". | Danh sách trả về chính xác 1 kết quả; hiển thị thẻ `[team_card_AI-04]`; dòng thông báo `[browse_result_count]` hiển thị "1 team with open slots"; ghi nhận sự kiện `search_teams`. |
| **TC-04** | Flow 1 · Trạng thái rỗng | Đã đăng nhập tài khoản An Tran | 1. Tại tab Browse, tìm từ khóa không tồn tại "quantum".<br>2. Quan sát giao diện rỗng.<br>3. Bấm nút "Clear Filters". | Hiển thị màn hình rỗng với tiêu đề "No teams match your search"; sau khi bấm xóa bộ lọc, danh sách khôi phục hiển thị đầy đủ 4 nhóm còn chỗ; `[browse_result_count]` hiển thị "4 teams with open slots". |
| **TC-05** | Flow 1 · Mất mạng & Thử lại | Đã đăng nhập tài khoản An Tran, ngắt kết nối mạng qua ADB | 1. Mở tab Browse khi đang offline.<br>2. Quan sát thông báo lỗi.<br>3. Bật lại mạng và bấm "Try Again". | Giao diện hiển thị lỗi "Can't connect right now" kèm nút "Try Again"; sau khi bật mạng và bấm thử lại, tải thành công danh sách nhóm, không còn cờ `state_error`. |
| **TC-06** | Flow 1 · Tham gia nhóm | Đã đăng nhập tài khoản An Tran (chưa có nhóm) | 1. Tìm nhóm `FinTech Guard` (đang có 2/5 thành viên).<br>2. Mở chi tiết nhóm và bấm "Join Team".<br>3. Chọn vị trí "Backend" và xác nhận. | Tham gia thành công; chuyển sang tab My Team hiển thị nhóm `FinTech Guard` với 3/5 thành viên; thẻ thành viên `[member_s_an]` xuất hiện; ghi nhận sự kiện `join_team`. |
| **TC-07** | Flow 1 · Nhánh lỗi nhóm đầy | Đã đăng nhập tài khoản An Tran | 1. Mở chi tiết nhóm `EduSmart Analytics` (đang có 4/5 thành viên).<br>2. Giả lập một thành viên khác vừa vào nhóm khiến nhóm đầy (5/5).<br>3. Bấm thử tham gia. | Bị từ chối tham gia; hiển thị banner cảnh báo `[banner_team_filled]` với nội dung "EduSmart Analytics just filled up"; nút Join chuyển sang trạng thái Disabled kèm lý do rõ ràng. |
| **TC-08** | Flow 2 · Giấu kết quả bầu cử | Đã đăng nhập tài khoản `minh.le@fpt.edu.vn` (nhóm chưa bầu cử xong) | 1. Mở tab My Team, bấm "Vote for Leader".<br>2. Quan sát màn hình trước khi bỏ phiếu. | Tỷ lệ phiếu bầu của các thành viên được ẩn kín hoàn toàn; hiển thị dòng hướng dẫn "Results appear after you vote"; nút Submit Vote ở trạng thái Disabled. |
| **TC-09** | Flow 2 · Bỏ phiếu bầu Leader | Minh Le đang ở màn hình Leader Voting | 1. Chọn ứng viên `Minh Le`.<br>2. Bấm "Submit Vote".<br>3. Quan sát kết quả cập nhật trên Firestore. | Bỏ phiếu thành công; hiển thị banner chiến thắng `[banner_leader_elected]` xác nhận Minh Le đạt đa số (2/3 phiếu); ghi nhận sự kiện `cast_vote`. |
| **TC-10** | Flow 3 · Lỗi & Phục hồi Waiting Pool | Minh Le là nhóm trưởng Team AI-04 (hiện có 3 thành viên, chưa đủ 4) | 1. Mở "Review & Lock".<br>2. Ghi nhận lỗi bị chặn.<br>3. Bấm "Invite from Waiting Pool" để ghép sinh viên.<br>4. Chờ ứng viên `Khanh Vo` gia nhập.<br>5. Bấm "Lock Roster" và xác nhận. | Ban đầu bị chặn với thông báo "Can't lock yet: needs 1 more member"; sau khi mời từ Pool, sinh viên `Khanh Vo` được gán vào nhóm; điều kiện kích hoạt chuyển màu xanh; khóa thành công với mã xác nhận `CM-AI04-XXXX`; cờ `[state_locked]` xuất hiện; ghi nhận `invite_pool` và `lock_roster`. |
| **TC-11** | Flow 3 · Tương tác Android gốc | Minh Le là nhóm trưởng Team AI-04 | 1. Tại màn hình Review & Lock, bấm nút "Share Team Link".<br>2. Dừng lại khi hộp thoại chia sẻ hệ thống mở ra. | Hộp thoại chia sẻ gốc của Android (`Android Share Sheet`) xuất hiện trên cùng; Activity đang hoạt động là `com.android.intentresolver`; nội dung chia sẻ chứa tên và mã nhóm. |
| **TC-12** | Alerts · Từ chối lời mời & Hoàn tác | Đã đăng nhập tài khoản Minh Le | 1. Mở tab Alerts (`/alerts`).<br>2. Bấm từ chối (Decline) lời mời từ nhóm FinTech Guard.<br>3. Bấm nút "Undo" trên thanh thông báo. | Sau khi từ chối, danh sách lời mời giảm về 0; sau khi bấm Undo, lời mời được khôi phục nguyên vẹn về danh sách; badge hiển thị "Invites (1)". |
| **TC-13** | Profile · Xuất báo cáo & Tải lên Cloud Storage | Đã đăng nhập tài khoản Minh Le | 1. Vào màn hình Profile.<br>2. Bấm "Export & Upload Team PDF".<br>3. Theo dõi tiến trình tải lên Cloud Storage. | Tệp báo cáo PDF dạng `team-ai-04-YYYYMMDD-HHMM.pdf` được tạo và tải lên thư mục bảo mật `reports/{uid}/...`; thanh tiến trình đạt 100%; hiển thị liên kết tải về an toàn; ghi nhận sự kiện `export_report`. |

---

## 3. Kết quả thực thi (Execution Results)

> **Chưa có kết quả hợp lệ.** Bảng "39/39 PASS" trước đây được sinh bởi script `tool/generate_complete_evidence.py` với số liệu ghi sẵn, không phải từ lần chạy thật, nên đã bị gỡ bỏ cùng toàn bộ thư mục `e2e_test/evidence/`. Kết quả sẽ được điền lại từ `e2e_test/evidence/junit.xml` và các thư mục `runN/` do `conftest.py` ghi ra sau khi chạy thật trên thiết bị.

## 4. Nhật ký phiên kiểm thử khám phá (Exploratory Testing Session Log)

> **Chưa thực hiện.** Sẽ ghi lại sau một phiên 15–30 phút thật, kèm ảnh chụp và trace ARTEMIS.
