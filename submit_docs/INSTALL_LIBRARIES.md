# HƯỚNG DẪN CÀI ĐẶT THƯ VIỆN & KHỞI CHẠY HỆ THỐNG
## Dự án: HoangXuanLuan23IT150-DaNenTang2026
**Môn học:** Lập trình Đa Nền Tảng  
**Sinh viên thực hiện:** Hoàng Xuân Luận - Mã SV: 23IT150  
**Cơ sở dữ liệu:** Học phần (`QLHocPhan`)  
**Collection:** Giảng viên (`GiangVien`)  
**Quy chuẩn trường:** CHỈ CHẤP NHẬN 4 TRƯỜNG: `IDGV`, `Fullname`, `Image`, `SumClass`  

---

## 1. LỆNH CÀI ĐẶT THƯ VIỆN BACKEND (NODE.JS & EXPRESS & MONGODB)

### Cách 1: Cài đặt toàn bộ thông qua file `package.json` (Khuyên dùng)
Mở terminal tại thư mục gốc dự án và chạy:
```bash
cd backend
npm install
```

### Cách 2: Cài đặt từng thư viện riêng lẻ bằng lệnh `npm install`
```bash
cd backend
npm install express mongoose cors multer dotenv jsonwebtoken bcryptjs
npm install --save-dev nodemon
```

### Danh sách các thư viện Backend được sử dụng:
1. `express`: Framework máy chủ RESTful API.
2. `mongoose`: Thư viện ODM kết nối MongoDB (cấu hình `versionKey: false` và strict validation 4 trường).
3. `cors`: Cho phép chia sẻ tài nguyên cross-origin giữa Flutter Web / Android và máy chủ Node.js.
4. `multer`: Xử lý tải ảnh đại diện giảng viên lên từ cả Web và thiết bị di động Android.
5. `dotenv`: Nạp biến môi trường từ file `.env` (Cổng PORT, MONGODB_URI, JWT_SECRET).
6. `jsonwebtoken`: Tạo mã phiên đăng nhập (JWT token) cho phân hệ quản trị viên Admin.
7. `bcryptjs`: Mã hóa và hỗ trợ xác thực đăng nhập bảo mật.
8. `nodemon` (devDependencies): Tự động khởi động lại server khi phát hiện thay đổi mã nguồn.

---

## 2. LỆNH CÀI ĐẶT THƯ VIỆN FRONTEND (FLUTTER)

### Cách 1: Cài đặt toàn bộ thông qua file `pubspec.yaml` (Khuyên dùng)
Mở terminal tại thư mục gốc dự án và chạy:
```bash
cd frontend
flutter pub get
```

### Cách 2: Cài đặt từng gói thư viện bằng lệnh `flutter pub add`
```bash
cd frontend
flutter pub add http
flutter pub add image_picker
flutter pub add intl
```

### Danh sách các thư viện Flutter được sử dụng:
1. `http`: Thư viện gửi các yêu cầu HTTP/REST (GET, POST, PUT, DELETE, Multipart Request upload ảnh) tới Backend.
2. `image_picker`: Hỗ trợ chọn ảnh từ thư viện máy hoặc chụp ảnh trực tiếp từ Camera trên Web và Android.
3. `intl`: Hỗ trợ định dạng số, chuỗi hiển thị giao diện đa ngôn ngữ và thẩm mỹ.

---

## 3. CÁC TẬP TIN CƠ SỞ DỮ LIỆU TRONG `/submit_docs`

Thư mục `/submit_docs` chứa đầy đủ dữ liệu và cấu trúc cơ sở dữ liệu:
1. `data.json` & `QLHocPhan_GiangVien_data.json`: File dữ liệu chứa các bản ghi giảng viên mẫu với đúng 4 trường: `IDGV, Fullname, Image, SumClass`.
2. `schemas.json` & `schema.json`: File định nghĩa cấu trúc JSON Schema chuẩn cho collection `GiangVien`.
3. `QLHocPhan_init_and_schema.js`: File kịch bản khởi tạo cơ sở dữ liệu `QLHocPhan`, tạo bảng `GiangVien` với Schema Validator nghiêm ngặt và tạo unique index cho `IDGV`.

---

## 4. HƯỚNG DẪN KHỞI CHẠY VÀ KIỂM THỬ HỆ THỐNG

### 4.1. Khởi chạy Backend
```bash
cd backend
npm start
```
- Máy chủ backend sẽ lắng nghe tại: `http://localhost:5000`
- Bộ API CRUD: `http://localhost:5000/api/giangvien`
- API Thống kê: `http://localhost:5000/api/giangvien/stats/summary`
- API Xuất dữ liệu: `http://localhost:5000/api/giangvien/export/json`

### 4.2. Chạy bộ kiểm thử tự động Backend (Automated Tests)
```bash
cd backend
npm test
```
*Bộ test kiểm tra 29 tiêu chuẩn: tính nghiêm ngặt 4 trường, đăng nhập phân hệ admin, CRUD, tìm kiếm chống lỗi RegExp, loại bỏ trường lạ, và các kịch bản kiểm thử phủ định.*

### 4.3. Khởi chạy Frontend trên nền tảng Web (Yêu cầu 1)
```bash
cd frontend
flutter run -d chrome
```

### 4.4. Khởi chạy Frontend trên nền tảng Di động Android (Yêu cầu 3)
```bash
cd frontend
flutter run
```
*(Lưu ý: Ứng dụng đã được tích hợp tự động chuyển đổi địa chỉ IP máy chủ: trên máy ảo Android tự dùng `http://10.0.2.2:5000`, trên Web dùng `http://localhost:5000`, và có nút cấu hình IP nhanh bằng biểu tượng Cài đặt ⚙️ trên giao diện).*
