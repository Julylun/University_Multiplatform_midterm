const mongoose = require('mongoose');

/**
 * Kết nối MongoDB với cơ chế kiểm tra quyền truy cập thực tế (Permission Verified):
 * 1. Thử process.env.MONGODB_URI nếu được cung cấp
 * 2. Thử cổng 27018 (QLHocPhan)
 * 3. Thử cổng 27017 (QLHocPhan)
 * Thực hiện truy vấn kiểm tra quyền thực tế (findOne) trước khi xác nhận kết nối thành công.
 */
const connectDB = async () => {
  const candidates = [
    process.env.MONGODB_URI,
    'mongodb://127.0.0.1:27018/QLHocPhan',
    'mongodb://127.0.0.1:27017/QLHocPhan',
  ].filter(Boolean);

  const uniqueUris = Array.from(new Set(candidates));

  for (const uri of uniqueUris) {
    try {
      const conn = await mongoose.connect(uri, {
        serverSelectionTimeoutMS: 2000,
      });

      // Kiểm tra thực tế quyền đọc/ghi trên collection GiangVien
      await conn.connection.db.collection('GiangVien').findOne({});

      console.log(`[MongoDB Connected & Verified]: ${conn.connection.host}:${conn.connection.port} / Database: ${conn.connection.name}`);
      return conn;
    } catch (err) {
      await mongoose.disconnect().catch(() => {});
      console.warn(`[MongoDB]: Thử kết nối ${uri} không khả dụng hoặc chưa cấp quyền (${err.message}), đang thử cổng tiếp theo...`);
    }
  }

  console.error('[MongoDB Fatal Error]: Không thể kết nối hoặc xác thực với cơ sở dữ liệu!');
  process.exit(1);
};

module.exports = connectDB;
