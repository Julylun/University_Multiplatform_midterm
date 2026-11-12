# BÁO CÁO NỘP BÀI DỰ ÁN GIỮA KỲ: LẬP TRÌNH ĐA NỀN TẢNG
## TÊN DỰ ÁN: HoangXuanLuan23IT150-DaNenTang2026
- **Sinh viên thực hiện:** Hoàng Xuân Luận
- **Mã sinh viên:** 23IT150
- **Công nghệ sử dụng:** Flutter (Frontend Web & Android), Node.js / Express (Backend API), MongoDB (Cơ sở dữ liệu NoSQL)
- **Cơ sở dữ liệu:** Học phần (`QLHocPhan`)
- **Collection:** Giảng viên (`GiangVien`)
- **Quy chuẩn ràng buộc:** CHỈ CHẤP NHẬN 4 TRƯỜNG: `IDGV`, `Fullname`, `Image`, `SumClass` (Tuyệt đối không tự bổ sung thêm trường)

---

## 1. CẤU TRÚC THƯ MỤC DỰ ÁN

```
HoangXuanLuan23IT150-DaNenTang2026/
├── backend/                                   # Máy chủ Node.js & Express RESTful API
│   ├── src/
│   │   ├── config/db.js                       # Cấu hình kết nối cơ sở dữ liệu MongoDB
│   │   ├── models/GiangVien.js                # Model Mongoose nghiêm ngặt đúng 4 trường
│   │   ├── routes/
│   │   │   ├── authRoutes.js                  # Tuyến xác thực đăng nhập phân hệ Admin
│   │   │   ├── giangVienRoutes.js             # Tuyến CRUD và thống kê nâng cao
│   │   │   └── uploadRoutes.js                # Tuyến tải lên hình ảnh từ Web/Android
│   │   └── server.js                          # File khởi chạy máy chủ Express
│   ├── uploads/                               # Thư mục lưu trữ hình ảnh tải lên
│   ├── package.json                           # Cấu hình thư viện npm
│   ├── test_api.js                            # Bộ kiểm thử tự động Backend (29 assertions PASS)
│   └── seed.js                                # Script nạp dữ liệu mẫu ban đầu
├── frontend/                                  # Ứng dụng Flutter Đa nền tảng (Web & Android)
│   ├── lib/
│   │   ├── models/giang_vien.dart             # Model GiangVien strictly 4 trường
│   │   ├── services/api_service.dart          # Dịch vụ gọi API mạng đa nền tảng
│   │   ├── widgets/safe_avatar.dart           # Widget hiển thị ảnh an toàn có fallback
│   │   ├── screens/
│   │   │   ├── login_screen.dart              # Màn hình đăng nhập phân hệ Admin
│   │   │   ├── home_screen.dart               # Màn hình chính (Responsive: Bảng trên Web, Thẻ trên Mobile)
│   │   │   ├── add_edit_screen.dart           # Màn hình Thêm / Sửa giảng viên & Tải ảnh
│   │   │   ├── detail_screen.dart             # Màn hình Xem chi tiết giảng viên
│   │   │   └── stats_screen.dart              # Màn hình Thống kê nâng cao & Xuất dữ liệu
│   │   └── main.dart                          # Điểm khởi chạy ứng dụng Flutter
│   ├── test/widget_test.dart                  # Bộ kiểm thử tự động Frontend (6 assertions PASS)
│   ├── android/app/src/main/AndroidManifest.xml# Cấu hình quyền Internet, Camera, CleartextTraffic
│   └── pubspec.yaml                           # Cấu hình thư viện Flutter (http, image_picker)
└── submit_docs/                               # THƯ MỤC NỘP BÀI THEO YÊU CẦU ĐỀ BÀI
    ├── data.json                              # Dữ liệu xuất từ CSDL (chuẩn 4 trường)
    ├── schemas.json                           # Schema định nghĩa CSDL
    ├── QLHocPhan_GiangVien_data.json          # File dữ liệu QLHocPhan.GiangVien
    ├── QLHocPhan_init_and_schema.js           # Kịch bản mongosh tạo DB và validation rules
    ├── INSTALL_LIBRARIES.md                   # Hướng dẫn chi tiết các lệnh cài đặt thư viện
    ├── install_libraries.txt                  # Danh sách lệnh cài đặt thư viện dạng text
    ├── libraries.txt                          # Lệnh cài đặt ngắn gọn
    ├── install_dependencies.bat               # File batch tự động cài đặt thư viện trên Windows
    ├── install_dependencies.sh                # File script tự động cài đặt trên Linux/macOS
    └── README.md                              # Báo cáo tổng quan dự án
```

---

## 2. ĐÁP ỨNG ĐẦY ĐỦ CÁC YÊU CẦU ĐỀ BÀI

### Yêu cầu 1: Sử dụng MongoDB thực hiện thêm, hiển thị các trường: IDGV, Fullname, Image, SumClass (Chạy trên Web)
- Đã thiết lập CSDL `QLHocPhan`, collection `GiangVien` với đúng 4 trường:
  - `IDGV`: Mã Giảng viên (String, Duy nhất, Bắt buộc).
  - `Fullname`: Họ và tên giảng viên (String, Bắt buộc).
  - `Image`: Hình ảnh chân dung / URL đại diện (String, Bắt buộc).
  - `SumClass`: Tổng số lớp học phần phụ trách (Integer >= 0, Bắt buộc).
- Trên nền tảng **Flutter Web**:
  - Giao diện dạng Bảng dữ liệu (Data Table) chuẩn Material 3 sang trọng.
  - Hiển thị trực quan avatar thu nhỏ, mã giảng viên, họ tên và số lớp.
  - Thêm mới giảng viên nhanh chóng với live preview ảnh.

### Yêu cầu 2: Thực hiện đăng nhập, xóa, sửa, các chức năng nâng cao khác
- **Đăng nhập phân hệ Admin**:
  - Tài khoản Admin mặc định: `admin` / `admin123` (hoặc tài khoản sinh viên `hoangxuanluan` / `23IT150`).
  - Nút "Điền nhanh tài khoản Admin mẫu" giúp đăng nhập 1 chạm khi chấm bài.
  - Cấp phát JWT token bảo mật phiên làm việc.
- **Sửa thông tin**:
  - Form chỉnh sửa tự động điền dữ liệu hiện tại, cho phép cập nhật Họ tên, Hình ảnh, Số lớp và Mã giảng viên (có kiểm tra trùng lặp).
- **Xóa giảng viên**:
  - Hộp thoại cảnh báo xác nhận trước khi xóa, bảo vệ người dùng thao tác nhầm.
- **Các chức năng nâng cao khác**:
  - **Tìm kiếm thời gian thực an toàn (Search)**: Tìm theo Mã GV hoặc Họ tên không phân biệt hoa thường, có cơ chế thoát Regex chống crash khi nhập ký tự đặc biệt.
  - **Sắp xếp linh hoạt (Sort)**: Sắp xếp theo Mã GV (A-Z), Tên (A-Z), Số lớp nhiều nhất, Số lớp ít nhất.
  - **Thống kê nâng cao (Advanced Analytics)**: Bảng điều khiển phân tích tổng số giảng viên, tổng số lớp, số lớp trung bình/GV, phân bổ tải giảng dạy (< 3 lớp, 3-6 lớp, > 6 lớp) và vinh danh Top giảng viên dạy nhiều lớp nhất.
  - **Xuất dữ liệu CSDL trực tiếp (Export JSON)**: Xem và sao chép toàn bộ dữ liệu CSDL chuẩn 4 trường chỉ với 1 click.
  - **Tự động chuyển đổi Host (Smart IP Host)**: Tự nhận diện chạy trên Web (`localhost:5000`) hay máy ảo Android (`10.0.2.2:5000`) và hỗ trợ nút cài đặt IP máy tính khi chạy trên điện thoại thật qua Wi-Fi.

### Yêu cầu 3: Nhập được hình ảnh và hiển thị thông tin người dùng (Trên nền tảng di động - Android)
- Tích hợp thư viện `image_picker` đa nền tảng:
  - Cho phép chụp ảnh trực tiếp từ Camera điện thoại.
  - Cho phép chọn ảnh từ Thư viện ảnh (Gallery / Photos).
  - Tự động tải lên API `/api/upload` của Node.js, lưu trữ tại thư mục `backend/uploads/`.
  - Hỗ trợ nhập URL ảnh trực tiếp từ Internet (Unsplash, trường học,...).
- Trên nền tảng **Android**:
  - Giao diện tự động co giãn Responsive thành dạng Thẻ danh sách (Card List) tối ưu cho ngón tay chạm lướt.
  - Xem chi tiết ảnh đại diện to rõ, xem thông tin số lớp phụ trách.
  - `AndroidManifest.xml` đã cấu hình đầy đủ quyền `INTERNET`, `CAMERA`, `READ_MEDIA_IMAGES` và `android:usesCleartextTraffic="true"`.

### Yêu cầu 4: Xuất ra file cơ sở dữ liệu (data & scheme) trong `/submit_docs`
- Đã xuất file:
  1. `submit_docs/data.json` & `QLHocPhan_GiangVien_data.json`: Chứa mảng dữ liệu mẫu chỉ gồm đúng 4 trường: `IDGV, Fullname, Image, SumClass`.
  2. `submit_docs/schemas.json` & `schema.json`: JSON Schema chuẩn xác định thuộc tính và kiểu dữ liệu của collection `GiangVien`.
  3. `submit_docs/QLHocPhan_init_and_schema.js`: Script cấu hình Schema Validator nghiêm ngặt (chặn tuyệt đối việc chèn thêm trường lạ) và chèn dữ liệu mẫu.

### Yêu cầu 5: Xuất ra file chứa lệnh cài thư viện trong `/submit_docs`
- Đã xuất file:
  1. `submit_docs/INSTALL_LIBRARIES.md`: Tài liệu hướng dẫn chi tiết từng lệnh cài đặt `npm install` và `flutter pub add`.
  2. `submit_docs/install_libraries.txt`: Danh sách lệnh cài đặt thư viện dạng file văn bản.
  3. `submit_docs/libraries.txt`: File lệnh ngắn gọn.
  4. `submit_docs/install_dependencies.bat`: Script 1-click cài đặt toàn bộ thư viện trên Windows.
  5. `submit_docs/install_dependencies.sh`: Script 1-click cài đặt trên Linux/macOS.

---

## 3. HƯỚNG DẪN KHỞI CHẠY HỆ THỐNG

### Bước 1: Cài đặt thư viện (Chỉ thực hiện lần đầu)
Chạy file script tự động:
```cmd
submit_docs\install_dependencies.bat
```

### Bước 2: Khởi chạy Máy chủ Backend
```bash
cd backend
npm start
```
*Backend sẽ lắng nghe tại: `http://localhost:5000`*

### Bước 3: Khởi chạy Frontend
- **Chạy trên Web (Google Chrome):**
  ```bash
  cd frontend
  flutter run -d chrome
  ```
- **Chạy trên Android (Máy ảo hoặc thiết bị thật):**
  ```bash
  cd frontend
  flutter run
  ```

---

## 4. KẾT QUẢ KIỂM THỬ TỰ ĐỘNG (AUTOMATED TESTS)

- **Backend API Test (`npm test`):** **29/29 bài kiểm tra ĐẠT (PASS)**.
- **Frontend Flutter Test (`flutter test`):** **6/6 bài kiểm tra ĐẠT (PASS)**.
- **Biên dịch Flutter Web (`flutter build web`):** **THÀNH CÔNG (Exit code 0)**.
