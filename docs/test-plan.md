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

### 3.1. Lần chạy 1 — 2026-11-02 05:47–06:49 (bằng chứng gốc: [`e2e_test/evidence-attempt1/`](../e2e_test/evidence-attempt1))

**6/39 lượt PASS (15 %).** Kết quả được giữ nguyên, không sửa.

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

Các lỗi của bộ test đã sửa ở commit `9652bb4` (làm mới token khi 401, kiểm URL Storage, chờ giữa các task) và `72a8a0a` (mục tiêu TC-01 rõ ràng hơn).

### 3.2. Lần chạy trên bản cuối (UI theo Figma + bản sửa GR-01/03/04) — **chưa hoàn thành**

Hai lần thử sau đó (08:00 và 15:23) bị dừng vì **hết quota miễn phí của Gemini API** mà ARTEMIS dùng: `gemini-3.5-flash-lite` và `gemini-3.1-flash-lite` mỗi model 500 lượt/ngày, cả hai trả `429 GenerateRequestsPerDayPerProject` với thời gian chờ ~23 giờ. Một lần chạy đủ 13×3 cần khoảng 450–600 lượt gọi. Kết quả của các lần bị dừng vì quota không được tính là PASS hay FAIL của app và đã bị xoá; lần chạy cuối sẽ được ghi vào đây khi quota cho phép.

### 3.3. Lỗi thật của app tìm thấy qua kiểm thử

- **Mất mạng hiện sai thông báo (TC-05 run 1):** khi chưa có cache Firestore và không có mạng, Browse hiện *"No teams match your search — Every team is full right now"* thay vì *"Can't connect right now"*. Nguyên nhân: truy vấn Firestore offline trả danh sách rỗng từ cache thay vì báo lỗi. Chưa sửa.
- **Undo khó dùng (TC-12):** thanh *Undo* tự ẩn sau 4 s, quá ngắn với người dùng chậm hoặc dùng trình đọc màn hình (WCAG 2.2.1). Chưa sửa.

## 4. Phiên kiểm thử khám phá (15–30 phút)

**Chưa thực hiện.** Sẽ làm thủ công trên máy ảo và ghi lại hành vi, ảnh chụp và lỗi tìm được.
