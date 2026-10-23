# EXEMatching — Capstone Team Formation Mobile App
**PRM393 — Lab 3: Cloud-Enabled Mobile App (Firebase, Google ARTEMIS, AI Code Review)**

- **Topic:** Exe Team Formation and Roster Locking Application for FPT University Students.
- **Backend Infrastructure:** Firebase (Authentication, Cloud Firestore, Cloud Storage, FCM, Remote Config, Crashlytics, Analytics).
- **Target Platform:** Android Device / Emulator (Flutter 3.47.4 / Dart 3.13.3).


## 📂 Deliverables & Documentation Map

| Deliverable | File Path | Description |
|---|---|---|
| **Design Traceability Matrix** | [`docs/design-traceability.md`](file:///c:/Users/Administrator/Desktop/Lab3_Cloud-Enabled_Mobile_App/docs/design-traceability.md) | Ánh xạ 9 màn hình từ Lab 2, 3 flows, widgets và data sources. |
| **Architecture Documentation** | [`docs/architecture.md`](file:///c:/Users/Administrator/Desktop/Lab3_Cloud-Enabled_Mobile_App/docs/architecture.md) | Sơ đồ tầng MVVM (Mermaid), Sequence diagram và bảng ViewModels. |
| **Analytics Event Plan** | [`docs/analytics-plan.md`](file:///c:/Users/Administrator/Desktop/Lab3_Cloud-Enabled_Mobile_App/docs/analytics-plan.md) | Kế hoạch 7+ events đo lường sản phẩm (không chứa PII). |
| **Test Plan (ARTEMIS)** | [`docs/test-plan.md`](file:///c:/Users/Administrator/Desktop/Lab3_Cloud-Enabled_Mobile_App/docs/test-plan.md) | Kế hoạch 10+ E2E test cases và phiên kiểm thử thăm dò. |
| **AI Code Review Record** | [`docs/code-review.md`](file:///c:/Users/Administrator/Desktop/Lab3_Cloud-Enabled_Mobile_App/docs/code-review.md) | Ghi nhận 5+ findings và 3 commits sửa lỗi tương ứng. |
| **Storage Security Rules** | [`firebase/storage.rules`](file:///c:/Users/Administrator/Desktop/Lab3_Cloud-Enabled_Mobile_App/firebase/storage.rules) | Quy tắc bảo mật Cloud Storage phân quyền theo `request.auth.uid`. |
| **Remote Config Defaults** | [`firebase/remote-config-defaults.json`](file:///c:/Users/Administrator/Desktop/Lab3_Cloud-Enabled_Mobile_App/firebase/remote-config-defaults.json) | Giá trị in-app mặc định cho các tham số cấu hình từ xa. |
| **Demo Video Link** | *Updating...* | Video trình diễn 5–10 phút trên thiết bị Android thật và Console. |

---

## 🛠️ Pinned Versions & Environment

- **Flutter:** `3.47.4 (channel stable)`
- **Dart:** `3.13.3`
- **Firebase Core:** `5.1.0`
- **Cloud Firestore:** `7.1.0`
- **Firebase Auth:** `7.0.1`
- **Firebase Storage:** `14.0.1`
- **Firebase Messaging:** `17.0.1`
- **Firebase Remote Config:** `7.0.1`
- **Firebase Crashlytics:** `6.0.1`
- **Firebase Analytics:** `13.0.1`
- **Provider:** `6.1.5+1`
- **Google ARTEMIS:** `Commit pinned in e2e_test/`

---

## 🚀 Hướng Dẫn Cài Đặt & Khởi Chạy

```bash
# 1. Cài đặt dependencies
flutter pub get

# 2. Khởi chạy ứng dụng trên thiết bị Android / Emulator
flutter run
```