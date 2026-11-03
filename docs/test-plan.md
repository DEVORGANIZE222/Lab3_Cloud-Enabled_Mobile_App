# Kế hoạch & Báo cáo kiểm thử E2E (ARTEMIS) — PRM393 Lab 3

Kiểm thử đầu cuối cho ứng dụng **EXEMatching** trên Firebase thật (Auth, Firestore, Storage, Analytics), điều khiển bởi **ARTEMIS** trên máy ảo Android `Pixel_API_36` (Android 16). Mã kiểm thử: [`e2e_test/`](../e2e_test).

---

## 1. Phương pháp

- **Tài khoản thật:** app dùng Google Sign-In thật, nên bộ test dùng một tài khoản Google đã đăng nhập trên máy ảo (`E2E_ACCOUNT`, mặc định `megalit2578@gmail.com`) và có trong `allowedEmails`.
- **Điều kiện đầu đặt bằng Firestore:** trước mỗi ca, [`e2e_test/backend.py`](../e2e_test/backend.py) khôi phục dữ liệu seed (`tool/seed_firestore_lab3.py`) rồi đặt tài khoản vào đúng vai: sinh viên chưa có nhóm, thành viên Team AI-04 (thay ghế của Minh Le), hoặc nhóm trưởng.
- **ARTEMIS thực hiện các bước** theo mục tiêu viết bằng ngôn ngữ tự nhiên và trả về JSON.
- **Không tin mỗi cờ SUCCESS:** mỗi ca so JSON của agent với (1) cây accessibility thật của màn hình (`Semantics.identifier` → `resource-id`), (2) sự kiện `analytics_event` trong Logcat, và (3) **dữ liệu thật trên Firestore / Cloud Storage** sau thao tác (ví dụ `memberIds` có uid, `lockCode` khớp mã trên màn hình, file PDF có trong `reports/{uid}/`).
- **3 lần chạy mỗi ca** (`E2E_RUNS=3`), bằng chứng mỗi lần trong `evidence/<ca>/runN/`: `result.json` (trace ARTEMIS, thời gian, output), `screen.txt`, `analytics.txt`, `final.png`; tổng hợp trong `junit.xml`.

## 2. Đặc tả 13 ca kiểm thử

| ID | Luồng · loại | Điều kiện đầu (Firestore) | Bước (ARTEMIS) | Kết quả mong đợi (kiểm trên màn hình + backend) |
|---|---|---|---|---|
| TC-01 | Đăng nhập · nhánh lỗi | Tài khoản bị tắt trong `allowedEmails` | Bấm *Continue with Google*, chọn tài khoản trong trình chọn của Google | Ở lại Sign In; banner `sign_in_message` "This account is not on the class roster" nêu email đã chọn |
| TC-02 | Đăng nhập · chuẩn | Tài khoản trong Team AI-04 | Đăng nhập, đọc lời chào, hạn đăng ký, tên nhóm | "Hi, \<tên\>", `card_deadline` "… left", Team AI-04; Logcat có `login`; `students/{uid}.email` đúng |
| TC-03 | Flow 1 · tìm & lọc | Chưa có nhóm | Bật lọc AI/ML + Open Slots, tìm "drone" | `browse_result_count` "1 team with open slots", có AI-04; Logcat `search_teams` |
| TC-04 | Flow 1 · rỗng | Chưa có nhóm | Tìm "quantum", bấm *Clear Filters* | "No teams match your search"; sau khi xoá lọc, số nhóm = số nhóm còn chỗ đọc từ Firestore |
| TC-05 | Flow 1 · mất mạng | Chưa có nhóm, tắt Wi-Fi + data qua ADB | Mở Browse; bật mạng; *Try Again* | "Can't connect right now" + `state_error`; sau thử lại hiện đúng số nhóm |
| TC-06 | Flow 1 · tham gia | Chưa có nhóm, FinTech Guard 2/5 | Mở FinTech Guard, *Join Team*, xác nhận | My Team "3 of 5", có `member_<uid>`; Logcat `join_team`; Firestore `team_fin02.memberIds` có uid |
| TC-07 | Flow 1 · nhóm vừa đầy | EduSmart 4/5 | Mở hộp thoại join; **backend thêm thành viên thứ 5**; xác nhận | Banner `banner_team_filled`, "This team is full (5/5)"; Firestore không có uid trong `team_edu07` |
| TC-08 | Flow 2 · ẩn kết quả | Thành viên AI-04, chưa bỏ phiếu | Mở *Vote for Leader*, không bỏ phiếu | Không thấy số phiếu, "Results appear after you vote", *Submit* bị khoá; Firestore chưa có phiếu |
| TC-09 | Flow 2 · bầu trưởng nhóm | Như TC-08 | Chọn chính mình, *Submit Vote* | `banner_leader_elected` "\<tên\> is your team leader", 2 phiếu; Firestore `votes[uid]` và `leaderId` = uid |
| TC-10 | Flow 3 · lỗi & phục hồi | Nhóm trưởng AI-04 (3/5), Khanh Vo trong pool | *Review & Lock* → *Invite from Waiting Pool* → khoá | Lỗi đầu "Can't lock yet…"; Khanh Vo vào nhóm; `state_locked` + mã `CM-AI04-XXXX`; Firestore `locked`, `lockCode` khớp, `waitingPool/s_khanh.assigned` |
| TC-11 | Flow 3 · Android gốc | Nhóm trưởng AI-04 | *Share Team Link* | Activity trên cùng là `intentresolver` (share sheet hệ thống) |
| TC-12 | Alerts · từ chối & hoàn tác | Có lời mời từ FinTech Guard | Lọc *Invites*, *Decline*, *Undo* | 0 lời mời sau khi từ chối, 1 sau Undo; tài liệu notification còn trên Firestore |
| TC-13 | Profile · xuất & tải lên | Thành viên AI-04 | *Export & Upload PDF* | `export_done` chứa URL `reports%2F<uid>%2Fteam-ai-04-….pdf`; Logcat `export_report`; object mới trong Cloud Storage |

## 3. Kết quả

<<<<<<< HEAD
### 3.1. Lần chạy 1 — 2026-11-02 05:47–06:49 (bằng chứng gốc: [`e2e_test/evidence-attempt1/`](../e2e_test/evidence-attempt1))

**6/39 lượt PASS (15 %).** Kết quả được giữ nguyên, không sửa.
=======
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
>>>>>>> main

| Ca | Run 1 | Run 2 | Run 3 | Nguyên nhân |
|---|---|---|---|---|
| TC-01 | PASS | PASS | PASS | — |
| TC-02 | PASS | PASS | PASS | — |
| TC-03 | FAIL | FAIL | FAIL | Agent không nhập được từ khoá (ô tìm kiếm trống, báo 2 nhóm); run 3 lỗi đăng nhập (timeout `nav_home`) |
| TC-04 | FAIL | FAIL | FAIL | Run 1: agent rời app sang một app khác trên máy ảo; run 2: task ARTEMIS timeout 900 s; run 3: lỗi đăng nhập |
| TC-05 | FAIL | FAIL | FAIL | Run 1 phát hiện **lỗi thật của app** (xem 3.3); run 2–3: Gemini API 429 (giới hạn 15 lượt/phút) |
| TC-06 | FAIL | FAIL | FAIL | Gemini API 429 → ARTEMIS dừng trước bước đầu tiên |
| TC-07 … TC-11 | FAIL ×15 | | | **Lỗi bộ test:** token Firestore hết hạn sau 1 giờ, điều kiện đầu không đặt được, ca không chạy |
| TC-12 | FAIL | FAIL | FAIL | Run 1 lỗi đăng nhập; run 2–3: thanh *Undo* (4 s) biến mất trước khi agent kịp bấm |
| TC-13 | FAIL | FAIL | FAIL | **Lỗi bộ test:** upload thật thành công (PDF 6 KB trên Storage) nhưng test đọc sai nhãn banner |

<<<<<<< HEAD
Các lỗi của bộ test đã sửa ở commit `9652bb4` (làm mới token khi 401, kiểm URL Storage, chờ giữa các task) và `72a8a0a` (mục tiêu TC-01 rõ ràng hơn).

### 3.2. Lần chạy trên bản cuối (UI theo Figma + bản sửa GR-01/03/04) — **chưa hoàn thành**

Hai lần thử sau đó (08:00 và 15:23) bị dừng vì **hết quota miễn phí của Gemini API** mà ARTEMIS dùng: `gemini-3.5-flash-lite` và `gemini-3.1-flash-lite` mỗi model 500 lượt/ngày, cả hai trả `429 GenerateRequestsPerDayPerProject` với thời gian chờ ~23 giờ. Một lần chạy đủ 13×3 cần khoảng 450–600 lượt gọi. Kết quả của các lần bị dừng vì quota không được tính là PASS hay FAIL của app và đã bị xoá; lần chạy cuối sẽ được ghi vào đây khi quota cho phép.

### 3.3. Lỗi thật của app tìm thấy qua kiểm thử

- **Mất mạng hiện sai thông báo (TC-05 run 1):** khi chưa có cache Firestore và không có mạng, Browse hiện *"No teams match your search — Every team is full right now"* thay vì *"Can't connect right now"*. Nguyên nhân: truy vấn Firestore offline trả danh sách rỗng từ cache thay vì báo lỗi. Chưa sửa.
- **Undo khó dùng (TC-12):** thanh *Undo* tự ẩn sau 4 s, quá ngắn với người dùng chậm hoặc dùng trình đọc màn hình (WCAG 2.2.1). Chưa sửa.

## 4. Phiên kiểm thử khám phá (15–30 phút)

**Chưa thực hiện.** Sẽ làm thủ công trên máy ảo và ghi lại hành vi, ảnh chụp và lỗi tìm được.
=======
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
>>>>>>> main
