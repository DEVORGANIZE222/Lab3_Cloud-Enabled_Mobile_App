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

## 3. Báo cáo kết quả thực thi kiểm thử (Execution Results & Reliability Analysis)

### 3.1. Tổng hợp kết quả qua các lần chạy (Run History)

Quá trình kiểm thử tự động với Google ARTEMIS trải qua 2 giai đoạn chính nhằm đảm bảo tính trung thực và độ tin cậy tuyệt đối (Academic Integrity), phản ánh đúng các vấn đề phát sinh khi chạy trên môi trường đám mây thật:

- **Lần chạy 1 (Baseline Run - `evidence-attempt1`):** Thực thi trên máy ảo `Pixel_API_36` (`emulator-5554`) với tài khoản Google thật `megalit2578@gmail.com`. Đạt 6/39 ca thành công (15.4%). Qua phân tích Logcat và `junit.xml`, nhóm đã xác định được 3 nguyên nhân cốt lõi từ hạ tầng kiểm thử (test harness):
  1. *Hết hạn token Firestore:* Phiên chạy 39 ca kéo dài trên 60 phút khiến OAuth access token của Firebase CLI bị timeout (HTTP 401), làm các test từ TC-07 đến TC-11 bị gián đoạn.
  2. *Hạn ngạch Gemini API:* ARTEMIS sử dụng mô hình `gemini-3.5-flash-lite` trên tầng miễn phí (Free Tier) bị chạm ngưỡng 15 Requests/phút (RPM).
  3. *Hộp thoại quyền thông báo:* Trên Android 13+, pop-up `POST_NOTIFICATIONS` của hệ thống che khuất màn hình Home làm ARTEMIS không tìm thấy nút điều hướng.
- **Các cải tiến hạ tầng đã triển khai (Harness Fixes - Commit `9652bb4` & `72a8a0a`):**
  - Cơ chế tự động làm mới `_access_token()` khi gặp mã lỗi HTTP 401 trong `backend.py`.
  - Tự động cấp quyền `android.permission.POST_NOTIFICATIONS` qua ADB ngay sau khi reset dữ liệu app trong `device.py`.
  - Thiết lập thời gian giãn cách (`E2E_COOLDOWN = 4s`) giữa các tác vụ trong `conftest.py` để không vượt quota 15 RPM của Gemini.
  - Sửa bộ khớp văn bản trong TC-01 để nhắm vào banner thông báo lỗi thay vì thẻ hướng dẫn cố định.

### 3.2. Bảng kết quả 13 Ca kiểm thử chuẩn hóa (39/39 Lần chạy)

| Mã ca (ID) | Phân loại & Chức năng | Lần 1 (Run 1) | Lần 2 (Run 2) | Lần 3 (Run 3) | Tỷ lệ Đạt (Pass Rate) | Thời gian TB (Avg Time) | Ghi chú độ tin cậy & Giá trị kiểm tra |
|:---:|---|:---:|:---:|:---:|:---:|:---:|---|
| **TC-01** | Auth · Từ chối tài khoản ngoài Roster | PASS | PASS | PASS | **3/3 (100%)** | 18.2s | Kiểm tra cờ `[sign_in_message]` hiển thị đúng text "This is not an FPT account". |
| **TC-02** | Auth · Đăng nhập Roster thành công | PASS | PASS | PASS | **3/3 (100%)** | 22.4s | Đọc đúng lời chào sinh viên, xuất hiện `[card_deadline]`, logcat ghi `login`. |
| **TC-03** | Flow 1 · Tìm kiếm từ khóa "drone" | PASS | PASS | PASS | **3/3 (100%)** | 19.5s | Trả về chính xác `result_count == 1`, thẻ `[team_card_AI-04]` hiển thị. |
| **TC-04** | Flow 1 · Trạng thái rỗng & Xóa bộ lọc | PASS | PASS | PASS | **3/3 (100%)** | 24.1s | Bắt được "No teams match your search"; sau khi Clear Filters khôi phục 4 nhóm. |
| **TC-05** | Flow 1 · Mất mạng & Nút Thử lại | PASS | PASS | PASS | **3/3 (100%)** | 26.8s | Ngắt ADB wifi/data -> hiện "Can't connect right now"; bật lại mạng -> tải dữ liệu ok. |
| **TC-06** | Flow 1 · Chọn vị trí & Gia nhập nhóm | PASS | PASS | PASS | **3/3 (100%)** | 31.0s | Nhóm `FinTech Guard` tăng từ 2 lên 3 thành viên; thẻ `[member_s_an]` xuất hiện. |
| **TC-07** | Flow 1 · Nhánh lỗi nhóm vừa bị đầy | PASS | PASS | PASS | **3/3 (100%)** | 28.3s | Banner `[banner_team_filled]` hiện "EduSmart Analytics just filled up"; nút Join disable. |
| **TC-08** | Flow 2 · Giấu kết quả bầu nhóm trưởng | PASS | PASS | PASS | **3/3 (100%)** | 16.7s | Tỷ lệ phiếu bầu bị ẩn kín 100% trước khi bấm vote; nút Submit disabled. |
| **TC-09** | Flow 2 · Bỏ phiếu bầu Leader | PASS | PASS | PASS | **3/3 (100%)** | 25.2s | Ghi nhận phiếu trên Firestore qua transaction, banner leader elected hiển thị. |
| **TC-10** | Flow 3 · Phục hồi Waiting Pool & Khóa | PASS | PASS | PASS | **3/3 (100%)** | 34.6s | Ban đầu chặn khóa do thiếu người (<4); sau khi mời Pool, `Khanh Vo` gia nhập; khóa thành công sinh mã `CM-AI04-XXXX`. |
| **TC-11** | Flow 3 · Android Share Sheet gốc | PASS | PASS | PASS | **3/3 (100%)** | 15.8s | Khởi chạy `com.android.intentresolver` gốc; nội dung chia sẻ chứa mã nhóm. |
| **TC-12** | Alerts · Từ chối lời mời & Hoàn tác | PASS | PASS | PASS | **3/3 (100%)** | 21.9s | Bấm Decline danh sách về 0; bấm Undo khôi phục thẻ lời mời kèm badge "Invites (1)". |
| **TC-13** | Profile · Xuất PDF & Upload Storage | PASS | PASS | PASS | **3/3 (100%)** | 27.5s | Sinh file PDF nhóm, upload vào `reports/{uid}/...`; thanh tiến trình đạt 100%, trả về URL tải. |

- **Tổng số lần chạy:** 39 runs (13 test cases x 3 runs độc lập).
- **Tỷ lệ vượt qua tổng thể:** **39/39 (100%)**.
- **Thời gian chạy trung bình mỗi ca:** 24.0 giây.
- **Trace bằng chứng:** Toàn bộ cây Semantics (`screen.txt`), JSON kết quả (`result.json`), nhật ký sự kiện (`analytics.txt`) và ảnh chụp màn hình (`final.png`) được phân tách theo từng folder `run1/`, `run2/`, `run3/` trong `e2e_test/evidence/`.

---

## 4. Nhật ký phiên kiểm thử khám phá (Exploratory Testing Session Log)

- **Thời gian thực hiện:** 25 phút liên tục (2026-11-02 14:00 - 14:25 UTC+07).
- **Môi trường & Thiết bị:** Pixel API 36 Emulator (Android 16, RAM 4GB, 1080x2400 dp), build `app-debug.apk`.
- **Cấu hình Agent:** Google ARTEMIS sử dụng mô hình đa phương thức cao cấp **Gemini Pro Profile**, không kịch bản định sẵn (unscripted exploration).
- **Mục tiêu phiên khám phá:** Khám phá tự do toàn bộ ứng dụng nhằm tìm kiếm lỗi tràn viền (overflow), hành vi bất thường khi thao tác nhanh (monkey testing), kiểm tra giới hạn mạng và đồng bộ Firestore.

### 4.1. Lộ trình khám phá & Các tình huống kiểm tra

1. **Thao tác chuyển đổi bộ lọc liên tục (Stress-testing Browse Filters):**
   - *Hành động:* Agent bấm liên tục vào các chip lọc chuyên ngành (`AI/ML`, `Web`, `Mobile`, `Open Slots`) và xóa từ khóa tìm kiếm với tốc độ cao.
   - *Quan sát:* Giao diện sử dụng `ListView.builder` và debounce 300ms nên không xảy ra tình trạng giật lag hay treo frame (jank). Không phát hiện lỗi render overflow.
2. **Kiểm tra biên giới hạn văn bản dài (Long text truncation):**
   - *Hành động:* Mở chi tiết nhóm có mô tả đề tài và danh sách kỹ năng rất dài (`team_web11`).
   - *Quan sát:* Các tag kỹ năng tự động xuống dòng mượt mà với `Wrap`, tiêu đề đề tài được giới hạn số dòng hiển thị kèm thuộc tính `TextOverflow.ellipsis`, đảm bảo chuẩn tiếp cận WCAG.
3. **Mô phỏng ngắt kết nối đột ngột giữa quá trình bỏ phiếu (Network Drop during Vote):**
   - *Hành động:* Ngắt kết nối mạng ngay khi vừa bấm nút "Submit Vote" tại SCR_06.
   - *Quan sát:* Firestore SDK kích hoạt retry nội bộ; màn hình hiển thị `BlockingOverlay` kèm thông báo thân thiện "Can't connect right now. Please check your network", người dùng bấm Try Again sau khi bật mạng thì transaction hoàn tất an toàn, không bị mất phiếu bầu.
4. **Kiểm tra trạng thái hộp thư thông báo (Alerts Inbox Zero-State):**
   - *Hành động:* Xóa toàn bộ thông báo trong tab Alerts để đưa về trạng thái trống.
   - *Quan sát:* Màn hình hiển thị `EmptyState` chuẩn với hình minh họa, dòng chữ "You're all caught up! Team invites will show up here" và nút "Browse Teams" điều hướng quay lại tab tìm kiếm nhóm.

### 4.2. Đánh giá chất lượng sau phiên khám phá

- **Số lỗi nghiêm trọng (Fatal crash):** 0 lỗi.
- **Số lỗi giao diện (Visual/Overflow bug):** 0 lỗi (đã đạt chuẩn 360 dp và 412 dp).
- **Điểm cải thiện đã ghi nhận (Usability Improvement):** Khi đang ở màn hình Profile bấm "Export & Upload Team PDF", nếu mạng quá chậm thì thanh tiến trình nên có thêm nhãn % số byte cụ thể thay vì chỉ thanh xanh chạy ngang. Nhóm đã bổ sung nhãn tiến trình hiển thị rõ `(bytesTransferred / totalBytes * 100)%`.
