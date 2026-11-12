const express = require('express');
const router = express.Router();
const GiangVien = require('../models/GiangVien');

/**
 * Thoát các ký tự đặc biệt trong biểu thức chính quy (Chống lỗi SyntaxError RegExp)
 */
function escapeRegex(text) {
  if (typeof text !== 'string') return '';
  return text.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&');
}

/**
 * Lọc strictly chỉ cho phép 4 trường theo yêu cầu đề bài:
 * IDGV, Fullname, Image, SumClass
 */
function sanitizeGiangVienData(body) {
  if (!body || typeof body !== 'object') {
    throw new Error('Dữ liệu yêu cầu không hợp lệ!');
  }

  const sanitized = {};

  if (body.IDGV !== undefined) {
    if (typeof body.IDGV !== 'string' && typeof body.IDGV !== 'number') {
      throw new Error('Mã Giảng viên (IDGV) phải là chuỗi ký tự!');
    }
    const val = String(body.IDGV).trim();
    if (!val) {
      throw new Error('Mã Giảng viên (IDGV) không được để trống!');
    }
    sanitized.IDGV = val;
  }

  if (body.Fullname !== undefined) {
    if (typeof body.Fullname !== 'string') {
      throw new Error('Họ và tên (Fullname) phải là chuỗi ký tự!');
    }
    const val = body.Fullname.trim();
    if (!val) {
      throw new Error('Họ và tên (Fullname) không được để trống!');
    }
    sanitized.Fullname = val;
  }

  if (body.Image !== undefined) {
    if (typeof body.Image !== 'string') {
      throw new Error('Hình ảnh (Image) phải là chuỗi đường dẫn/URL!');
    }
    const val = body.Image.trim();
    if (!val) {
      throw new Error('Đường dẫn hình ảnh (Image) không được để trống!');
    }
    sanitized.Image = val;
  }

  if (body.SumClass !== undefined) {
    const num = Number(body.SumClass);
    if (isNaN(num)) {
      throw new Error('Tổng số lớp (SumClass) phải là một số hợp lệ!');
    }
    if (num < 0) {
      throw new Error('Tổng số lớp (SumClass) phải lớn hơn hoặc bằng 0!');
    }
    sanitized.SumClass = Math.round(num);
  }

  return sanitized;
}

// 1. Thống kê nâng cao (Advanced Statistics)
router.get('/stats/summary', async (req, res) => {
  try {
    const totalGV = await GiangVien.countDocuments();
    if (totalGV === 0) {
      return res.json({
        success: true,
        stats: {
          totalLecturers: 0,
          totalClasses: 0,
          avgClasses: 0,
          maxClasses: 0,
          minClasses: 0,
          distribution: {
            under3: 0,
            from3to6: 0,
            over6: 0,
          },
          topLecturers: [],
        },
      });
    }

    const aggregation = await GiangVien.aggregate([
      {
        $group: {
          _id: null,
          totalClasses: { $sum: '$SumClass' },
          avgClasses: { $avg: '$SumClass' },
          maxClasses: { $max: '$SumClass' },
          minClasses: { $min: '$SumClass' },
        },
      },
    ]);

    const under3 = await GiangVien.countDocuments({ SumClass: { $lt: 3 } });
    const from3to6 = await GiangVien.countDocuments({ SumClass: { $gte: 3, $lte: 6 } });
    const over6 = await GiangVien.countDocuments({ SumClass: { $gt: 6 } });

    const topLecturers = await GiangVien.find()
      .sort({ SumClass: -1, IDGV: 1 })
      .limit(3)
      .select('-_id IDGV Fullname Image SumClass');

    const aggResult = aggregation[0] || {};

    return res.json({
      success: true,
      stats: {
        totalLecturers: totalGV,
        totalClasses: aggResult.totalClasses || 0,
        avgClasses: Number((aggResult.avgClasses || 0).toFixed(2)),
        maxClasses: aggResult.maxClasses || 0,
        minClasses: aggResult.minClasses || 0,
        distribution: {
          under3,
          from3to6,
          over6,
        },
        topLecturers,
      },
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// 2. Xuất dữ liệu JSON (Export data)
router.get('/export/json', async (req, res) => {
  try {
    const data = await GiangVien.find().select('-_id IDGV Fullname Image SumClass');
    res.setHeader('Content-Type', 'application/json');
    res.setHeader('Content-Disposition', 'attachment; filename=QLHocPhan_GiangVien_data.json');
    return res.json(data);
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// 3. Lấy danh sách giảng viên (Hỗ trợ tìm kiếm an toàn chống lỗi RegExp, lọc, sắp xếp, phân trang)
router.get('/', async (req, res) => {
  try {
    const { search, q, sortBy, order, minClasses, maxClasses, page, limit } = req.query;

    const query = {};

    // Tìm kiếm an toàn theo IDGV hoặc Fullname
    const keyword = search || q;
    if (keyword && String(keyword).trim() !== '') {
      const safePattern = escapeRegex(String(keyword).trim());
      const regex = new RegExp(safePattern, 'i');
      query.$or = [{ IDGV: regex }, { Fullname: regex }];
    }

    // Lọc theo khoảng số lớp
    if (minClasses !== undefined || maxClasses !== undefined) {
      query.SumClass = {};
      if (minClasses !== undefined) {
        const min = Number(minClasses);
        if (!isNaN(min)) query.SumClass.$gte = min;
      }
      if (maxClasses !== undefined) {
        const max = Number(maxClasses);
        if (!isNaN(max)) query.SumClass.$lte = max;
      }
    }

    // Sắp xếp
    let sortOptions = { IDGV: 1 };
    if (sortBy) {
      const validSortFields = ['IDGV', 'Fullname', 'SumClass'];
      if (validSortFields.includes(sortBy)) {
        const sortDirection = order === 'desc' || order === '-1' ? -1 : 1;
        sortOptions = { [sortBy]: sortDirection };
      }
    }

    // Thực hiện truy vấn với projection loại bỏ _id để strictly 4 trường
    let dbQuery = GiangVien.find(query).select('-_id IDGV Fullname Image SumClass').sort(sortOptions);

    if (page && limit) {
      const pageNum = Math.max(1, parseInt(page, 10) || 1);
      const limitNum = Math.max(1, parseInt(limit, 10) || 10);
      const skip = (pageNum - 1) * limitNum;
      const total = await GiangVien.countDocuments(query);
      const items = await dbQuery.skip(skip).limit(limitNum);

      return res.json({
        success: true,
        data: items,
        pagination: {
          total,
          page: pageNum,
          limit: limitNum,
          totalPages: Math.ceil(total / limitNum),
        },
      });
    }

    const items = await dbQuery;
    return res.json({
      success: true,
      total: items.length,
      data: items,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// 4. Lấy chi tiết 1 giảng viên theo IDGV
router.get('/:idgv', async (req, res) => {
  try {
    const { idgv } = req.params;
    const gv = await GiangVien.findOne({ IDGV: idgv }).select('-_id IDGV Fullname Image SumClass');

    if (!gv) {
      return res.status(404).json({
        success: false,
        message: `Không tìm thấy Giảng viên với Mã: ${idgv}`,
      });
    }

    return res.json({
      success: true,
      data: gv,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

// 5. Thêm mới giảng viên
router.post('/', async (req, res) => {
  try {
    let data;
    try {
      data = sanitizeGiangVienData(req.body);
    } catch (validationErr) {
      return res.status(400).json({ success: false, message: validationErr.message });
    }

    // Kiểm tra đầy đủ 4 trường bắt buộc
    if (!data.IDGV) {
      return res.status(400).json({ success: false, message: 'Thiếu trường IDGV (Mã Giảng viên)!' });
    }
    if (!data.Fullname) {
      return res.status(400).json({ success: false, message: 'Thiếu trường Fullname (Họ và tên)!' });
    }
    if (!data.Image) {
      return res.status(400).json({ success: false, message: 'Thiếu trường Image (Hình ảnh)!' });
    }
    if (data.SumClass === undefined || data.SumClass < 0) {
      return res.status(400).json({ success: false, message: 'Trường SumClass (Tổng số lớp) phải là số nguyên >= 0!' });
    }

    // Kiểm tra trùng mã IDGV
    const exists = await GiangVien.findOne({ IDGV: data.IDGV });
    if (exists) {
      return res.status(409).json({
        success: false,
        message: `Mã Giảng viên "${data.IDGV}" đã tồn tại trong hệ thống!`,
      });
    }

    const newGV = new GiangVien(data);
    await newGV.save();

    return res.status(201).json({
      success: true,
      message: 'Thêm giảng viên thành công!',
      data: newGV,
    });
  } catch (error) {
    return res.status(400).json({ success: false, message: error.message });
  }
});

// 6. Sửa thông tin giảng viên theo IDGV
router.put('/:idgv', async (req, res) => {
  try {
    const { idgv } = req.params;

    let updateData;
    try {
      updateData = sanitizeGiangVienData(req.body);
    } catch (validationErr) {
      return res.status(400).json({ success: false, message: validationErr.message });
    }

    const existing = await GiangVien.findOne({ IDGV: idgv });
    if (!existing) {
      return res.status(404).json({
        success: false,
        message: `Không tìm thấy Giảng viên với Mã: ${idgv} để cập nhật!`,
      });
    }

    // Nếu thay đổi IDGV, kiểm tra có bị trùng với GV khác không
    if (updateData.IDGV && updateData.IDGV !== idgv) {
      const duplicate = await GiangVien.findOne({ IDGV: updateData.IDGV });
      if (duplicate) {
        return res.status(409).json({
          success: false,
          message: `Mã Giảng viên mới "${updateData.IDGV}" đã được sử dụng!`,
        });
      }
    }

    if (updateData.IDGV !== undefined) existing.IDGV = updateData.IDGV;
    if (updateData.Fullname !== undefined) existing.Fullname = updateData.Fullname;
    if (updateData.Image !== undefined) existing.Image = updateData.Image;
    if (updateData.SumClass !== undefined) existing.SumClass = updateData.SumClass;

    await existing.save();

    return res.json({
      success: true,
      message: 'Cập nhật thông tin giảng viên thành công!',
      data: existing,
    });
  } catch (error) {
    return res.status(400).json({ success: false, message: error.message });
  }
});

// 7. Xóa giảng viên theo IDGV
router.delete('/:idgv', async (req, res) => {
  try {
    const { idgv } = req.params;
    const deleted = await GiangVien.findOneAndDelete({ IDGV: idgv });

    if (!deleted) {
      return res.status(404).json({
        success: false,
        message: `Không tìm thấy Giảng viên với Mã: ${idgv} để xóa!`,
      });
    }

    return res.json({
      success: true,
      message: `Đã xóa giảng viên ${deleted.Fullname} (Mã: ${idgv}) thành công!`,
      data: deleted,
    });
  } catch (error) {
    return res.status(500).json({ success: false, message: error.message });
  }
});

module.exports = router;
