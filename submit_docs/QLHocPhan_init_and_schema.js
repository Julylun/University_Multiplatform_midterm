/**
 * =========================================================================================
 * DỰ ÁN: HoangXuanLuan23IT150-DaNenTang2026
 * DATABASE: QLHocPhan
 * COLLECTION: GiangVien
 * YÊU CẦU: Chỉ chấp nhận đúng 4 trường: IDGV, Fullname, Image, SumClass
 * =========================================================================================
 * Hướng dẫn chạy trong mongosh:
 *   mongosh "mongodb://localhost:27018" QLHocPhan_init_and_schema.js
 * =========================================================================================
 */

// Chuyển sang cơ sở dữ liệu QLHocPhan
db = db.getSiblingDB('QLHocPhan');

// Xóa collection nếu đã tồn tại để thiết lập lại schema validator
db.GiangVien.drop();

// Tạo collection GiangVien với bộ quy tắc kiểm tra (Schema Validator) nghiêm ngặt
db.createCollection('GiangVien', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['IDGV', 'Fullname', 'Image', 'SumClass'],
      additionalProperties: false, // TUYỆT ĐỐI KHÔNG CHO PHÉP THÊM BẤT KỲ TRƯỜNG NÀO KHÁC NGOÀI _id và 4 trường quy định
      properties: {
        _id: {
          bsonType: 'objectId',
          description: 'Mã định danh nội bộ MongoDB (tự sinh)'
        },
        IDGV: {
          bsonType: 'string',
          description: 'Mã Giảng viên - Bắt buộc là chuỗi ký tự'
        },
        Fullname: {
          bsonType: 'string',
          description: 'Họ và tên - Bắt buộc là chuỗi ký tự'
        },
        Image: {
          bsonType: 'string',
          description: 'Đường dẫn/URL hình ảnh - Bắt buộc là chuỗi ký tự'
        },
        SumClass: {
          bsonType: ['int', 'number', 'long'],
          minimum: 0,
          description: 'Tổng số lớp - Bắt buộc là số nguyên >= 0'
        }
      }
    }
  },
  validationAction: 'error',
  validationLevel: 'strict'
});

// Tạo chỉ mục duy nhất (unique index) cho trường IDGV
db.GiangVien.createIndex({ IDGV: 1 }, { unique: true });

// Chèn dữ liệu mẫu ban đầu (ĐÚNG 4 TRƯỜNG)
db.GiangVien.insertMany([
  {
    IDGV: "GV001",
    Fullname: "TS. Hoàng Xuân Luận",
    Image: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80",
    SumClass: 6
  },
  {
    IDGV: "GV002",
    Fullname: "ThS. Trần Thị Mai",
    Image: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=400&q=80",
    SumClass: 4
  },
  {
    IDGV: "GV003",
    Fullname: "PGS.TS. Lê Văn Minh",
    Image: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=400&q=80",
    SumClass: 8
  },
  {
    IDGV: "GV004",
    Fullname: "ThS. Phạm Quỳnh Nga",
    Image: "https://images.unsplash.com/photo-1580894732454-defa4fb50170?auto=format&fit=crop&w=400&q=80",
    SumClass: 3
  },
  {
    IDGV: "GV005",
    Fullname: "TS. Đỗ Quốc Tuấn",
    Image: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=400&q=80",
    SumClass: 5
  }
]);

print(">>> [THÀNH CÔNG] Đã khởi tạo cơ sở dữ liệu QLHocPhan và collection GiangVien!");
print(">>> Danh sách bản ghi hiện có trong QLHocPhan.GiangVien:");
printjson(db.GiangVien.find({}, { _id: 0 }).toArray());
