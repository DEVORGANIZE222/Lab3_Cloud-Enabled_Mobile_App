# 🚨 CẨM NANG VIBE CODING & QUY TẮC SỐNG CÒN — PRM393 LAB 3
> **DÀNH CHO ANH EM TRONG TEAM:** Nếu dùng AI (Copilot, Cursor, Gemini, Claude, ChatGPT...) hoặc code tay nhanh (vibe coding), **BẮT BUỘC ĐỌC FILE NÀY** trước khi đụng vào code để tránh bị giảng viên chấm **0 ĐIỂM** 

---

## ⛔ 8 CÁI BẪY BỊ 0 ĐIỂM HOẶC TRỪ SẠCH ĐIỂM (DEADLY TRAPS)

| # | Hành vi phạm lỗi (CẤM LÀM) | Hậu quả | Cách làm ĐÚNG |
|---|---|---|---|
| **1** | **Gọi Firebase/API trực tiếp trong Widget**<br>`FirebaseAuth.instance...`<br>`FirebaseFirestore.instance...`<br>`http.get(...)` | **0 điểm Kiến trúc** (Mất 0.75đ) | Mọi thao tác mạng/Firebase **phải qua Service**, View chỉ được gọi `ViewModel`. |
| **2** | **Hard-code dữ liệu hoặc dùng Mock Data khi nộp** | **0 điểm Dữ liệu** (Mất 0.75đ) | Dữ liệu phải đọc/ghi thật trên **Cloud Firestore**. |
| **3** | **Storage Rules để mở toang:**<br>`allow read, write: if true;` | **0 điểm Cloud Storage** (Mất 0.25đ) | Bắt buộc kiểm tra UID: `allow read, write: if request.auth != null && request.auth.uid == userId;` |
| **4** | **Quay vòng tròn vĩnh viễn (Spinner forever) hoặc màn hình trắng xóa khi lỗi mạng** | **0 điểm Error Handling** (Mất 0.75đ) | Mọi màn hình load data phải có đủ **4 trạng thái**: `Loading`, `Empty`, `Error` (phải có nút **Retry**), và `Data`. |
| **5** | **Hard-code mã màu, font chữ hoặc padding trong màn hình**<br>Ví dụ: `color: Colors.green`, `fontSize: 16` | **0 điểm Design System** (Mất 0.5đ) | Dùng Theme: `Theme.of(context).colorScheme.primary`, `AppSpacing.md`, `AppColors...`. |
| **6** | **Nút bấm bé hơn 48dp hoặc bị Lỗi tràn màn hình (Overflow stripes vàng đen)** | **Trừ điểm Accessibility** (Mất 0.25đ) | Chiều cao nút $\ge 48\text{dp}$, bọc màn hình bằng `SingleChildScrollView` tránh bàn phím đẩy gây overflow. |
| **7** | **Lệnh Test chỉ kiểm tra `status == "SUCCESS"`** mà không so sánh dữ liệu thực tế | **Trừ điểm ARTEMIS Test** (Mất 0.5đ) | Test phải bảo AI trả về số lượng/kết quả và assert giá trị cụ thể. |
| **8** | **Commit dồn 1 cục vào ngày nộp** (1–2 commit lớn) | **Vi phạm Academic Integrity** | Mỗi tính năng commit 1 lần, commit theo thứ tự 8 giai đoạn. |

---

## 🏛️ 1. QUY TẮC KIẾN TRÚC MVVM (BẮT BUỘC TUÂN THỦ)

Dependencies chỉ được đi theo **MỘT CHIỀU DUY NHẤT TỪ TRÊN XUỐNG**:
$$\text{View (Screen/Widget)} \xrightarrow{\text{Gửi sự kiện}} \text{ViewModel} \xrightarrow{\text{Gọi}} \text{Service} \xrightarrow{\text{Truy cập}} \text{Cloud Firestore / Firebase}$$

### ❌ SAI HOÀN TOÀN (Bị trừ điểm):
```dart
// TRONG WIDGET / SCREEN (lib/screens/group_detail_screen.dart)
ElevatedButton(
  onPressed: () async {
    // ❌ CẤM: Gọi SDK trực tiếp trong widget
    await FirebaseFirestore.instance.collection('teams').doc(id).update({...});
    // ❌ CẤM: Gọi FirebaseAuth trực tiếp
    final user = FirebaseAuth.instance.currentUser;
  },
  child: Text('Gia nhập nhóm'),
)
```

### ✅ ĐÚNG CHUẨN ĐỀ BÀI:
```dart
// TRONG WIDGET: Chỉ gọi ViewModel
ElevatedButton(
  onPressed: () => context.read<GroupViewModel>().joinTeam(teamId),
  child: Text('Gia nhập nhóm'),
)

// TRONG VIEWMODEL (lib/viewmodels/group_viewmodel.dart):
Future<void> joinTeam(String teamId) async {
  _state = const LoadingState('Đang gửi yêu cầu...');
  notifyListeners();
  try {
    await _groupService.requestToJoin(teamId, _authService.currentUserId);
    _state = const SuccessState(null);
  } catch (e) {
    _state = ErrorState('Không thể gia nhập nhóm: $e', onRetry: () => joinTeam(teamId));
  }
  notifyListeners();
}

// TRONG SERVICE (lib/services/group_service.dart): Nơi duy nhất được chạm vào Firestore
Future<void> requestToJoin(String teamId, String userId) async { ... }
```

---

## 🎨 2. QUY TẮC DESIGN SYSTEM & GIAO DIỆN

Lấy theo đúng bản thiết kế Lab 2:
- **Màu sắc:**
  - Màu chính (Growth Green): `Theme.of(context).colorScheme.primary` hoặc `AppColors.primary` (`#15803D`)
  - Màu nền được chọn: `AppColors.primaryContainer` (`#DCFCE7`)
  - Màu thẻ đã khóa / Slot đủ (Verification Teal): `AppColors.success` (`#0F766E`)
  - Màu cảnh báo / Đếm ngược: `AppColors.warning` (`#B26A00`)
  - Màu lỗi / Nút hủy xóa: `Theme.of(context).colorScheme.error` (`#BA1A1A`)
- **Spacing:** Dùng `AppSpacing.xs (4)`, `AppSpacing.sm (8)`, `AppSpacing.md (12)`, `AppSpacing.lg (16)`, `AppSpacing.xl (24)`.
- **Reusable Widgets:** Dùng widget trong `lib/widgets/`:
  - Trạng thái đang tải: `AppLoadingView(message: ...)`
  - Trạng thái danh sách trống: `AppEmptyView(title: ..., onAction: ...)`
  - Trạng thái lỗi: `AppErrorView(message: ..., onRetry: ...)`
- **Accessibility:**
  - Mọi nút bấm hoặc ô gõ phải có chiều cao tối thiểu **48dp**.
  - Font chữ nội dung tối thiểu **14sp**.
  - Luôn thêm `Semantics(label: "...", child: ...)` vào các nút quan trọng để phục vụ kiểm thử AI ARTEMIS.

---

## ☁️ 3. QUY TẮC FIREBASE CHO CẢ 6 DỊCH VỤ

1. **Authentication:**
   - Đăng nhập bằng Google (`GoogleSignIn`).
   - Xử lý khi user bấm nút Cancel quay lại (hiển thị thông báo, không văng app).
   - Đăng xuất phải dọn sạch session trên máy.
2. **Cloud Storage (Xuất file PDF):**
   - File sinh ra phải lưu đúng thư mục: `reports/{userId}/roster_{teamId}.pdf`.
   - Có thanh tiến trình (progress bar) khi tải lên.
   - Bắt buộc kiểm tra `storage.rules`.
3. **Cloud Messaging (FCM):**
   - Xin quyền notification trên Android 13+.
   - Có màn hình danh sách thông báo đã nhận (`SCR_09`).
   - Bấm vào thông báo phải chuyển đúng màn hình chi tiết nhóm.
4. **Analytics (Tối thiểu 7 events):**
   - Đặt tên theo chuẩn Firebase hoặc `snake_case`.
   - **CẤM:** Không được nhét Email hay Tên người dùng vào tham số event (Vi phạm PII).
5. **Crashlytics:**
   - Có 1 điểm bắt lỗi thực tế: `FirebaseCrashlytics.instance.recordError(...)`.
   - Có 1 nút test crash trong trang Profile.
   - Gắn `setCustomKey('team_id', ...)` và `setUserIdentifier(userId)`.
6. **Remote Config:**
   - 2 biến điều khiển giao diện: `max_team_members` và `enable_waiting_pool`.
   - Phải có file `firebase/remote-config-defaults.json`.

---

## 🤖 4. QUY TẮC KIỂM THỬ E2E (GOOGLE ARTEMIS)

- Mỗi test case phải chạy **ít nhất 3 lần** (để tính Pass rate $3/3$).
- Hướng dẫn test phải viết rõ ràng, yêu cầu AI trả về số liệu cụ thể để `assert`:
  ```python
  # ✅ ĐÚNG:
  result = await artemis.run("Search for 'AI'. Report the number of teams displayed.")
  assert result.status == "SUCCESS"
  assert int(result.data['count']) > 0

  # ❌ SAI:
  result = await artemis.run("Check that the app works")
  assert result.status == "SUCCESS" # Bị trừ điểm vì vague
  ```

---

## 🔍 5. QUY TẮC AI CODE REVIEW & COMMIT

- Công cụ: Dùng **GitHub Copilot / CodeRabbit / SonarQube**.
- Tìm ra ít nhất **5 vấn đề (findings)** và ghi vào `docs/code-review.md`.
- Sửa ít nhất **3 lỗi**, **mỗi lỗi tạo 1 commit riêng biệt**:
  - `git commit -m "fix(CR-01): move direct firestore call from widget to viewmodel"`
  - `git commit -m "fix(CR-02): handle null safety on member count in lock screen"`
  - `git commit -m "fix(CR-03): add retry button to network error state"`

---

## 📋 BẢNG TỰ KIỂM TRA (CHECKLIST TRƯỚC KHI PUSH CODE)

- [ ] Trong file này có dòng code nào gọi thẳng `Firebase...` hay `http` trong hàm `build()` không?
- [ ] Màn hình có xử lý nút Thử lại (Retry) khi tắt Wifi không?
- [ ] Có mã màu `#...` hoặc kích thước padding số lẻ nào bị hard-code không?
- [ ] Màn hình có bị sọc vàng đen khi mở bàn phím ảo không?
- [ ] Nút bấm có đủ to để ngón tay bấm dễ dàng ($\ge 48\text{dp}$) không?
