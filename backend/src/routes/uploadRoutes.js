const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Đảm bảo thư mục uploads tồn tại
const uploadDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

// Cấu hình lưu trữ tệp tin
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadDir);
  },
  filename: function (req, file, cb) {
    const ext = path.extname(file.originalname);
    const uniqueName = `gv_${Date.now()}_${Math.round(Math.random() * 1e9)}${ext}`;
    cb(null, uniqueName);
  },
});

const fileFilter = (req, file, cb) => {
  const allowedTypes = /jpeg|jpg|png|gif|webp|svg/;
  const ext = allowedTypes.test(path.extname(file.originalname).toLowerCase());
  const mime = allowedTypes.test(file.mimetype);

  if (ext && mime) {
    return cb(null, true);
  }
  const error = new Error('Chỉ chấp nhận tệp hình ảnh (.jpg, .jpeg, .png, .gif, .webp, .svg)!');
  error.statusCode = 400;
  cb(error);
};

const upload = multer({
  storage,
  limits: { fileSize: 10 * 1024 * 1024 }, // Tối đa 10MB
  fileFilter,
});

// Endpoint upload 1 ảnh (xử lý lỗi nội bộ để luôn trả về 400 thay vì 500 khi tệp không hợp lệ)
router.post('/', (req, res) => {
  upload.single('image')(req, res, (err) => {
    if (err) {
      if (err instanceof multer.MulterError) {
        return res.status(400).json({
          success: false,
          message: `Lỗi tải tệp: ${err.message}`,
        });
      }
      return res.status(400).json({
        success: false,
        message: err.message || 'Lỗi tải ảnh lên máy chủ!',
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Chưa có tệp hình ảnh nào được tải lên!',
      });
    }

    // URL ảnh trả về
    const protocol = req.protocol;
    const host = req.get('host');
    const imageUrl = `${protocol}://${host}/uploads/${req.file.filename}`;

    return res.status(200).json({
      success: true,
      message: 'Tải ảnh lên thành công!',
      filename: req.file.filename,
      url: imageUrl,
      path: `/uploads/${req.file.filename}`,
    });
  });
});

module.exports = router;
