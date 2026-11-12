require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');
const connectDB = require('./config/db');

const authRoutes = require('./routes/authRoutes');
const giangVienRoutes = require('./routes/giangVienRoutes');
const uploadRoutes = require('./routes/uploadRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Bắt các ngoại lệ không mong muốn ở cấp process để đảm bảo máy chủ không bao giờ bị sập
process.on('uncaughtException', (err) => {
  console.error('[Uncaught Exception]:', err.message);
});

process.on('unhandledRejection', (reason, promise) => {
  console.error('[Unhandled Rejection]:', reason);
});

// Kết nối MongoDB (Database: QLHocPhan)
connectDB();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Phục vụ tệp tĩnh trong thư mục uploads
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/giangvien', giangVienRoutes);
app.use('/api/upload', uploadRoutes);

// Root route
app.get('/', (req, res) => {
  res.json({
    project: 'HoangXuanLuan23IT150-DaNenTang2026',
    database: 'QLHocPhan',
    collection: 'GiangVien',
    allowedFields: ['IDGV', 'Fullname', 'Image', 'SumClass'],
    status: 'Server Node.js backend đang hoạt động ổn định',
    endpoints: {
      auth: 'POST /api/auth/login',
      getGiangVien: 'GET /api/giangvien',
      getOneGiangVien: 'GET /api/giangvien/:idgv',
      createGiangVien: 'POST /api/giangvien',
      updateGiangVien: 'PUT /api/giangvien/:idgv',
      deleteGiangVien: 'DELETE /api/giangvien/:idgv',
      statsSummary: 'GET /api/giangvien/stats/summary',
      exportJson: 'GET /api/giangvien/export/json',
      uploadImage: 'POST /api/upload',
    },
  });
});

// Middleware xử lý lỗi tập trung & xử lý lỗi JSON cú pháp hỏng
app.use((err, req, res, next) => {
  if (res.headersSent) {
    return next(err);
  }

  // Bắt lỗi cú pháp JSON từ body-parser (trả về 400 Bad Request)
  if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
    return res.status(400).json({
      success: false,
      message: 'Cú pháp JSON trong yêu cầu không hợp lệ (Malformed JSON)!',
    });
  }

  const statusCode = err.statusCode || err.status || 500;
  return res.status(statusCode).json({
    success: false,
    message: err.message || 'Lỗi máy chủ nội bộ!',
  });
});

const server = app.listen(PORT, () => {
  console.log(`=======================================================`);
  console.log(`  HỆ THỐNG QUẢN LÝ GIẢNG VIÊN - PHÂN HỆ ADMIN`);
  console.log(`  Dự án: HoangXuanLuan23IT150-DaNenTang2026`);
  console.log(`  Backend đang chạy tại: http://localhost:${PORT}`);
  console.log(`  Database: QLHocPhan | Collection: GiangVien`);
  console.log(`=======================================================`);
});

module.exports = { app, server };
