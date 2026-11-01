# AI Code Review — Báo cáo rà soát mã nguồn tự động (PRM393 Lab 3)

| Thuộc tính | Chi tiết |
|---|---|
| **Công cụ (Tool)** | **Gemini Code Assist for GitHub** (Google Cloud Code Assist — Hỗ trợ miễn phí cho Private Repositories) |
| **Mục tiêu rà soát (Target)** | Pull Request tích hợp dịch vụ đám mây Firebase Lab 3 (`feat/lab3-firebase-fixes` → `main`) |
| **Phạm vi (Scope)** | `lib/firebase/`, `firebase/firestore.rules`, `firebase/remote-config-defaults.json` |
| **Phương pháp (Method)** | Phân tích tự động đa chiều (Correctness, Security, Concurrency, Reliability, Efficiency). Kiểm tra chéo với quy chuẩn kiến trúc MVVM và quy tắc nghiệp vụ Lab 2. |
| **Quy trình thẩm định người (Human-in-the-loop)** | Mỗi phát hiện từ Gemini Code Assist được đối chiếu với yêu cầu đề bài Lab 3 và quy tắc nghiệp vụ Lab 2 trước khi đưa ra quyết định: **Chấp nhận sửa (Fix)**, **Bác bỏ (Won't fix)** hoặc **Trì hoãn (Defer)**. |

---

## 1. Bảng tổng hợp các phát hiện (Findings Summary)

Gemini Code Assist đã rà soát và phát hiện **6 vấn đề** thuộc **4 nhóm phân loại** (`security`, `correctness`, `reliability`, `efficiency`):
- **5 phát hiện được Chấp nhận và Sửa chữa (Fix)** với thay đổi cụ thể trên mã nguồn.
- **1 phát hiện được Bác bỏ (Won't fix)** do xung đột với quy tắc nghiệp vụ bầu cử của Lab 2.

---

## 2. Danh sách chi tiết các phát hiện và quyết định kỹ thuật

| ID | Nhóm (Kind) | Vị trí (File & Line) | Phát hiện của Gemini Code Assist | Quyết định | Lý do kỹ thuật & Giải pháp | Minh chứng xử lý (Fix / Trace) |
|---|---|---|---|---|---|---|
| **GCA-01** | `security` | `firebase/firestore.rules:30` | Quy tắc cập nhật `teams` ban đầu cho phép mọi tài khoản trong `allowedEmails` sửa đổi toàn bộ document, dẫn đến nguy cơ giả mạo thành viên, sửa phiếu bầu và tự ý khóa nhóm của người khác. | **Fix (Chấp nhận)** | Giao dịch phía client không thay thế được phân quyền tại database server. Đã xây dựng hàm kiểm tra phân quyền chi tiết: sinh viên chỉ được tự gia nhập/rời nhóm và bỏ phiếu cho chính mình; chỉ nhóm trưởng mới có quyền mời từ Waiting Pool và khóa nhóm (`locked = true`). | `firebase/firestore.rules` (hàm `isValidTeamUpdate` và các hàm con kiểm tra trước/sau cập nhật) |
| **GCA-02** | `correctness` | `lib/firebase/firestore_team_repository.dart:234-280` | Trong phương thức `inviteFromPool()`, tài liệu sinh viên trong Waiting Pool được truy vấn ngoài giao dịch nhưng không được khóa đọc lại trong giao dịch (`tx.get()`). Nếu hai nhóm cùng gọi mời sinh viên tại cùng thời điểm sẽ xảy ra xung đột gán trùng 1 sinh viên vào 2 nhóm. | **Fix (Chấp nhận)** | Áp dụng nguyên tắc Optimistic Locking của Cloud Firestore: đưa `tx.get(candidateDoc.reference)` vào trong giao dịch và kiểm tra trạng thái `assigned != true`. Nếu đã bị nhóm khác ghép, giao dịch hủy hoặc chuyển ứng viên an toàn. | `lib/firebase/firestore_team_repository.dart` (`inviteFromPool`) |
| **GCA-03** | `reliability` | `lib/firebase/firebase_pool_repository.dart:55-64` | `currentWindow()` tự động dùng giờ máy (`DateTime.now() + 90 ngày`) khi tài liệu Firestore thiếu `opensAt` hoặc `closesAt`. Điều này che giấu cấu hình thiếu trên đám mây và vi phạm yêu cầu kiểm chứng dữ liệu thật của Lab 3. | **Fix (Chấp nhận)** | Khi Firestore thiếu `opensAt` hoặc `closesAt` (hoặc sai kiểu dữ liệu Timestamp), ứng dụng ném ngoại lệ rõ ràng `AppFailure('Registration dates are not configured', code: 'invalid-configuration')` để giao diện hiển thị thông báo lỗi và nút Retry chuẩn xác. | `lib/firebase/firebase_pool_repository.dart` (`currentWindow`) |
| **GCA-04** | `correctness` | `lib/firebase/firestore_team_repository.dart:193` | Khi một thành viên mới từ Waiting Pool tham gia (nhóm tăng từ 3 lên 4 người), Gemini Code Assist đề xuất tự động hủy vai trò nhóm trưởng vì 2/3 phiếu ban đầu không còn đạt quá bán ở nhóm 4 người (2/4 = 50%). | **Won't fix (Bác bỏ)** | Theo đặc tả Flow 2 & Flow 3 của Lab 2: nhóm trưởng được bầu dựa trên đa số phiếu tại thời điểm bỏ phiếu. Tự động truất quyền nhóm trưởng khi thêm thành viên từ Pool sẽ phá vỡ Flow 3 (nhóm vừa đủ điều kiện khóa thì lại mất trưởng nhóm để bấm khóa). Thành viên có quyền đổi phiếu tự nguyện, nhưng app không tự động truất quyền. | Giữ nguyên quy tắc nghiệp vụ theo Lab 2, ghi nhận phân tích kỹ thuật |
| **GCA-05** | `reliability` | `lib/firebase/firebase_remote_config_service.dart:21-25` | Phương thức khởi tạo `initialize()` gọi `refresh()` có thể gây crash hoặc gián đoạn luồng khởi động app nếu thiết bị mất kết nối mạng hoặc server Remote Config phản hồi timeout. | **Fix (Chấp nhận)** | Bọc lệnh `await refresh()` trong khối `try-catch`. Khi ngoại lệ xảy ra, ứng dụng tiếp tục khởi động bình thường với các giá trị mặc định nội bộ an toàn định nghĩa trong `ConfigKeys.defaults`. | `lib/firebase/firebase_remote_config_service.dart` (`initialize`) |
| **GCA-06** | `efficiency` | `lib/firebase/firebase_analytics_service.dart:12-60` | Các sự kiện Analytics chỉ gửi lên Google Analytics SDK mà không ghi nhật ký Logcat trong môi trường Debug, gây khó khăn cho việc kiểm thử tự động (ARTEMIS) và kiểm tra nhật ký runtime qua ADB. | **Fix (Chấp nhận)** | Bổ sung `debugPrint('analytics_event $name ...')` tại lớp dịch vụ `FirebaseAnalyticsService`. Đảm bảo các công cụ kiểm thử tự động đọc được sự kiện trong Logcat mà vẫn tuyệt đối không rò rỉ dữ liệu nhạy cảm (PII). | `lib/firebase/firebase_analytics_service.dart` |

---

## 3. Đánh giá hiệu quả của AI Review và vai trò của Lập trình viên

- **Điểm mạnh của Gemini Code Assist:** Phát hiện nhanh các lỗ hổng bảo mật nghiêm trọng trong Firestore Security Rules (GCA-01) và điều kiện tranh chấp đồng thời (Race condition) trong Firestore Transaction (GCA-02) mà kiểm thử thông thường dễ bỏ sót.
- **Vai trò thẩm định của Lập trình viên (Human judgment):** 
  - Tại **GCA-04**, lập trình viên đã kịp thời ngăn chặn việc thay đổi logic nghiệp vụ làm hỏng quy trình làm việc (Flow 3) của ứng dụng.
  - Tại **GCA-03**, lập trình viên đưa ra quyết định chuẩn hóa dữ liệu thay vì sử dụng cơ chế fallback ngầm làm sai lệch dữ liệu kiểm thử.
- **Kết luận:** Mã nguồn sau khi sửa đạt tiêu chuẩn `flutter analyze` không lỗi (0 warnings, 0 errors) và sẵn sàng tích hợp hoàn chỉnh.
