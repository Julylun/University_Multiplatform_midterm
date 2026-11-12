require('dotenv').config();
const mongoose = require('mongoose');
const GiangVien = require('./src/models/GiangVien');

const sampleData = [
  {
    IDGV: 'GV001',
    Fullname: 'TS. Hoàng Xuân Luận',
    Image: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    SumClass: 6,
  },
  {
    IDGV: 'GV002',
    Fullname: 'ThS. Trần Thị Mai',
    Image: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80',
    SumClass: 4,
  },
  {
    IDGV: 'GV003',
    Fullname: 'PGS.TS. Lê Văn Minh',
    Image: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80',
    SumClass: 8,
  },
  {
    IDGV: 'GV004',
    Fullname: 'ThS. Phạm Quỳnh Nga',
    Image: 'https://images.unsplash.com/photo-1580894732454-defa4fb50170?auto=format&fit=crop&w=400&q=80',
    SumClass: 3,
  },
  {
    IDGV: 'GV005',
    Fullname: 'TS. Đỗ Quốc Tuấn',
    Image: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80',
    SumClass: 5,
  },
];

async function seed() {
  try {
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/QLHocPhan');
    console.log('[Seed] Đã kết nối cơ sở dữ liệu QLHocPhan');

    // Xóa dữ liệu cũ nếu có
    await GiangVien.deleteMany({});
    console.log('[Seed] Đã xóa sạch dữ liệu cũ trong collection GiangVien');

    // Thêm dữ liệu mẫu (chỉ gồm IDGV, Fullname, Image, SumClass)
    const inserted = await GiangVien.insertMany(sampleData);
    console.log(`[Seed] Đã thêm thành công ${inserted.length} giảng viên mẫu vào collection GiangVien!`);

    const result = await GiangVien.find().select('-_id IDGV Fullname Image SumClass');
    console.log('[Seed] Dữ liệu hiện có:');
    console.log(JSON.stringify(result, null, 2));

    await mongoose.disconnect();
    console.log('[Seed] Hoàn tất nạp dữ liệu mẫu!');
  } catch (error) {
    console.error('[Seed Error]:', error);
    process.exit(1);
  }
}

seed();
