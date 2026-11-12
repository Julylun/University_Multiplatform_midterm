const mongoose = require('mongoose');

/**
 * Model GiangVien (Collection: GiangVien in Database: QLHocPhan)
 * CHÚ Ý QUAN TRỌNG THEO YÊU CẦU ĐỀ BÀI:
 * Chỉ chấp nhận cơ sở dữ liệu gồm đúng 4 trường:
 * - IDGV: Mã Giảng viên (String)
 * - Fullname: Họ và tên (String)
 * - Image: Hình ảnh (String)
 * - SumClass: Tổng số lớp (Number)
 * KHÔNG tự bổ sung thêm bất kỳ trường nào khác (tắt versionKey __v, không timestamps).
 */
const GiangVienSchema = new mongoose.Schema(
  {
    IDGV: {
      type: String,
      required: [true, 'Vui lòng nhập Mã Giảng viên (IDGV)'],
      unique: true,
      trim: true,
    },
    Fullname: {
      type: String,
      required: [true, 'Vui lòng nhập Họ và tên (Fullname)'],
      trim: true,
    },
    Image: {
      type: String,
      required: [true, 'Vui lòng nhập đường dẫn/URL hình ảnh (Image)'],
      trim: true,
    },
    SumClass: {
      type: Number,
      required: [true, 'Vui lòng nhập Tổng số lớp (SumClass)'],
      min: [0, 'Tổng số lớp phải lớn hơn hoặc bằng 0'],
      validate: {
        validator: Number.isInteger,
        message: 'Tổng số lớp (SumClass) phải là số nguyên',
      },
    },
  },
  {
    collection: 'GiangVien',
    versionKey: false, // Không tạo trường __v
    timestamps: false, // Tuyệt đối không thêm createdAt / updatedAt
    toJSON: {
      transform: (doc, ret) => {
        delete ret._id; // Trả về strictly 4 trường theo đúng yêu cầu đề bài
        return ret;
      },
    },
    toObject: {
      transform: (doc, ret) => {
        delete ret._id;
        return ret;
      },
    },
  }
);

module.exports = mongoose.model('GiangVien', GiangVienSchema);
