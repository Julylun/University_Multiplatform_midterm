const express = require('express');
const router = express.Router();
const jwt = require('jsonwebtoken');

// Đăng nhập phân hệ Admin
router.post('/login', (req, res) => {
  const { username, password } = req.body;

  const validUsername = process.env.ADMIN_USERNAME || 'admin';
  const validPassword = process.env.ADMIN_PASSWORD || 'admin123';

  if (!username || !password) {
    return res.status(400).json({
      success: false,
      message: 'Vui lòng cung cấp đầy đủ tên đăng nhập và mật khẩu!',
    });
  }

  // Kiểm tra tài khoản admin (hoặc tài khoản sinh viên HoangXuanLuan / 23IT150)
  const isMatch =
    (username === validUsername && password === validPassword) ||
    (username.toLowerCase() === 'hoangxuanluan' && password === '23IT150');

  if (!isMatch) {
    return res.status(401).json({
      success: false,
      message: 'Tên đăng nhập hoặc mật khẩu không chính xác!',
    });
  }

  const token = jwt.sign(
    { username, role: 'admin' },
    process.env.JWT_SECRET || 'HoangXuanLuan23IT150_SecretKey_2026',
    { expiresIn: '7d' }
  );

  return res.json({
    success: true,
    message: 'Đăng nhập phân hệ quản trị viên thành công!',
    token,
    user: {
      username,
      role: 'admin',
      displayName: username === 'hoangxuanluan' ? 'Hoàng Xuân Luận (23IT150)' : 'Quản trị viên (Admin)',
    },
  });
});

// Kiểm tra phiên đăng nhập
router.get('/me', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'Chưa đăng nhập!' });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'HoangXuanLuan23IT150_SecretKey_2026'
    );
    return res.json({ success: true, user: decoded });
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Token không hợp lệ hoặc đã hết hạn!' });
  }
});

module.exports = router;
