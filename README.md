# HoangXuanLuan23IT150-DaNenTang2026

Dự án Xây dựng ứng dụng nhập, hiển thị, sửa, xóa người dùng trong cơ sở dữ liệu Học phần (`QLHocPhan`) chứa collection giảng viên (`GiangVien`) ở phân hệ admin.

## Công nghệ
- **Frontend**: Flutter (Web & Android)
- **Backend**: Node.js & Express RESTful API
- **Database**: MongoDB (Collection `GiangVien` tuân thủ strictly 4 trường: `IDGV, Fullname, Image, SumClass`)

## Cấu trúc thư mục
- `/backend`: Máy chủ Node.js Express RESTful API
- `/frontend`: Ứng dụng Flutter đa nền tảng (Web & Android)
- `/submit_docs`: Thư mục nộp bài chứa:
  - `QLHocPhan_GiangVien_data.json`
  - `QLHocPhan_GiangVien_schema.json`
  - `QLHocPhan_init_and_schema.js`
  - `INSTALL_LIBRARIES.md`
  - `install_dependencies.bat`
  - `install_dependencies.sh`
  - `README.md`

Xem chi tiết hướng dẫn cài đặt và vận hành tại [`submit_docs/README.md`](submit_docs/README.md) và [`submit_docs/INSTALL_LIBRARIES.md`](submit_docs/INSTALL_LIBRARIES.md).
