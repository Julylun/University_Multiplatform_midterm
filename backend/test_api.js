const http = require('http');

const BASE_URL = 'http://localhost:5000';

function rawRequest(method, path, rawBody = null, headers = {}) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: { ...headers },
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => (data += chunk));
      res.on('end', () => {
        let json;
        try {
          json = JSON.parse(data);
        } catch (e) {
          json = data;
        }
        resolve({ status: res.statusCode, data: json });
      });
    });

    req.on('error', reject);

    if (rawBody) {
      req.write(rawBody);
    }
    req.end();
  });
}

function request(method, path, body = null, headers = {}) {
  const reqHeaders = {
    'Content-Type': 'application/json',
    ...headers,
  };
  return rawRequest(method, path, body ? JSON.stringify(body) : null, reqHeaders);
}

function uploadMultipart(fieldName, fileName, fileBuffer, mimeType) {
  const boundary = '----TestBoundary' + Date.now();
  const crlf = '\r\n';
  const header = [
    '--' + boundary,
    `Content-Disposition: form-data; name="${fieldName}"; filename="${fileName}"`,
    `Content-Type: ${mimeType}`,
    '',
    '',
  ].join(crlf);
  const footer = crlf + '--' + boundary + '--' + crlf;
  const payload = Buffer.concat([
    Buffer.from(header, 'utf8'),
    fileBuffer,
    Buffer.from(footer, 'utf8'),
  ]);

  return rawRequest('POST', '/api/upload', payload, {
    'Content-Type': `multipart/form-data; boundary=${boundary}`,
    'Content-Length': payload.length,
  });
}

async function runTests() {
  console.log('>>> BẮT ĐẦU KIỂM THỬ TOÀN DIỆN BACKEND API (HAPPY PATH & EDGE CASES) <<<');
  let passed = 0;
  let failed = 0;

  function assert(condition, message) {
    if (condition) {
      console.log(` [PASS] ${message}`);
      passed++;
    } else {
      console.error(` [FAIL] ${message}`);
      failed++;
    }
  }

  try {
    // 1. Root health check
    const rootRes = await request('GET', '/');
    assert(rootRes.status === 200, 'Root endpoint trả về status 200');
    assert(rootRes.data.project === 'HoangXuanLuan23IT150-DaNenTang2026', 'Project name chính xác');
    assert(rootRes.data.database === 'QLHocPhan', 'Database là QLHocPhan');
    assert(rootRes.data.collection === 'GiangVien', 'Collection là GiangVien');

    // 2. Auth Login fail with wrong pass
    const loginFail = await request('POST', '/api/auth/login', {
      username: 'admin',
      password: 'wrongpassword',
    });
    assert(loginFail.status === 401, 'Đăng nhập sai mật khẩu bị từ chối 401');

    // 3. Auth Login success (admin)
    const loginSuccess = await request('POST', '/api/auth/login', {
      username: 'admin',
      password: 'admin123',
    });
    assert(loginSuccess.status === 200, 'Đăng nhập admin thành công 200');
    assert(!!loginSuccess.data.token, 'Đăng nhập trả về JWT token hợp lệ');

    // 4. Auth Login success (student credentials: hoangxuanluan / 23IT150)
    const studentLogin = await request('POST', '/api/auth/login', {
      username: 'hoangxuanluan',
      password: '23IT150',
    });
    assert(studentLogin.status === 200, 'Đăng nhập bằng tài khoản sinh viên 23IT150 thành công 200');
    assert(studentLogin.data.user.role === 'admin', 'Tài khoản sinh viên được cấp quyền admin');

    // 5. Auth Me verification
    const authMe = await request('GET', '/api/auth/me', null, {
      Authorization: `Bearer ${loginSuccess.data.token}`,
    });
    assert(authMe.status === 200 && authMe.data.success === true, 'Xác thực token JWT qua /api/auth/me thành công');

    // 6. Multipart Image Upload (Valid Image)
    const fakePng = Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]);
    const uploadRes = await uploadMultipart('image', 'avatar_test.png', fakePng, 'image/png');
    assert(uploadRes.status === 200, 'Upload hình ảnh đại diện hợp lệ thành công 200');
    assert(typeof uploadRes.data.path === 'string' && uploadRes.data.path.startsWith('/uploads/'), 'Trả về relative path cho ảnh');
    assert(typeof uploadRes.data.url === 'string', 'Trả về full URL cho ảnh');

    // 7. Verify uploaded image is statically accessible
    const checkImgRes = await rawRequest('GET', uploadRes.data.path);
    assert(checkImgRes.status === 200, 'Tệp ảnh vừa upload truy cập tĩnh thành công 200');

    // 8. Negative test: Upload file không phải hình ảnh (Bị từ chối 400 Bad Request)
    const badFile = Buffer.from('console.log("hacker")', 'utf8');
    const badUploadRes = await uploadMultipart('image', 'script.js', badFile, 'application/javascript');
    assert(badUploadRes.status === 400, 'Từ chối tệp không phải hình ảnh với status 400 Bad Request');

    // 9. Negative test: Upload không có file đính kèm
    const emptyUpload = await request('POST', '/api/upload', {});
    assert(emptyUpload.status === 400, 'Upload không đính kèm file trả về 400 Bad Request');

    // 10. Get all lecturers
    const listRes = await request('GET', '/api/giangvien');
    assert(listRes.status === 200, 'Lấy danh sách giảng viên thành công 200');
    assert(Array.isArray(listRes.data.data), 'Danh sách trả về dạng mảng');
    assert(listRes.data.data.length >= 5, 'Dữ liệu ban đầu có >= 5 giảng viên');

    // 11. Kiểm tra tính nghiêm ngặt: document chỉ có đúng 4 trường IDGV, Fullname, Image, SumClass
    const sampleDoc = listRes.data.data[0];
    const keys = Object.keys(sampleDoc).sort();
    const expectedKeys = ['Fullname', 'IDGV', 'Image', 'SumClass'].sort();
    assert(
      JSON.stringify(keys) === JSON.stringify(expectedKeys),
      `Document CHỈ CÓ ĐÚNG 4 TRƯỜNG: ${keys.join(', ')}`
    );

    // 12. Thêm mới giảng viên GV999
    const testGV = {
      IDGV: 'GV999',
      Fullname: 'GS. Thử Nghiệm Tự Động',
      Image: uploadRes.data.path,
      SumClass: 7,
    };
    const createRes = await request('POST', '/api/giangvien', testGV);
    assert(createRes.status === 201, 'Tạo mới giảng viên GV999 thành công 201');

    // 13. Thêm trùng IDGV phải bị từ chối 409 Conflict
    const duplicateRes = await request('POST', '/api/giangvien', testGV);
    assert(duplicateRes.status === 409, 'Từ chối thêm trùng mã IDGV với status 409 Conflict');

    // 14. Negative test: SumClass âm (SumClass < 0) phải bị từ chối 400
    const negativeClassRes = await request('POST', '/api/giangvien', {
      IDGV: 'GV_TEST_NEG',
      Fullname: 'GV Kiểm tra số lớp âm',
      Image: 'https://example.com/avatar.jpg',
      SumClass: -5,
    });
    assert(negativeClassRes.status === 400, 'Từ chối SumClass âm với status 400 Bad Request');

    // 15. Negative test: Thiếu trường bắt buộc (Thiếu IDGV)
    const missingFieldRes = await request('POST', '/api/giangvien', {
      Fullname: 'Thiếu IDGV',
      Image: 'https://example.com/avatar.jpg',
      SumClass: 2,
    });
    assert(missingFieldRes.status === 400, 'Từ chối khi thiếu IDGV với status 400 Bad Request');

    // 16. Negative test: Cú pháp JSON hỏng (Malformed JSON) trả về 400 mà không làm sập server
    const malformedJsonRes = await rawRequest(
      'POST',
      '/api/giangvien',
      '{"IDGV":"GVTEST_BROKEN","Fullname":"Unterminated',
      { 'Content-Type': 'application/json' }
    );
    assert(malformedJsonRes.status === 400, 'Xử lý JSON cú pháp hỏng an toàn với status 400');

    // 17. Edge case: Tìm kiếm với ký tự đặc biệt RegExp (chống văng lỗi máy chủ 500)
    const safeRegexRes = await request('GET', '/api/giangvien?q=([*+?^$');
    assert(safeRegexRes.status === 200, 'Tìm kiếm an toàn với chuỗi RegExp đặc biệt không crash');

    // 18. Trường lạ ngoài 4 trường quy định được lọc bỏ
    const extraFieldGV = {
      IDGV: 'GV888',
      Fullname: 'TS. Kiểm Tra Trường Lạ',
      Image: 'https://example.com/avatar.jpg',
      SumClass: 3,
      extraFieldEmail: 'hacker@school.edu',
      salary: 999999999,
    };
    const createExtra = await request('POST', '/api/giangvien', extraFieldGV);
    assert(createExtra.status === 201, 'Tạo GV888 thành công');
    const get888 = await request('GET', '/api/giangvien/GV888');
    const keys888 = Object.keys(get888.data.data).sort();
    assert(
      JSON.stringify(keys888) === JSON.stringify(expectedKeys),
      `Trường lạ bị loại bỏ hoàn toàn, chỉ giữ lại đúng 4 trường: ${keys888.join(', ')}`
    );

    // 19. Cập nhật giảng viên GV999
    const updateRes = await request('PUT', '/api/giangvien/GV999', {
      Fullname: 'GS. Thử Nghiệm (Đã Sửa)',
      SumClass: 10,
    });
    assert(updateRes.status === 200, 'Cập nhật GV999 thành công 200');
    assert(updateRes.data.data.Fullname === 'GS. Thử Nghiệm (Đã Sửa)', 'Tên đã cập nhật');
    assert(updateRes.data.data.SumClass === 10, 'Số lớp đã cập nhật thành 10');

    // 20. Negative test: Cập nhật GV999 với số lớp âm bị từ chối 400
    const updateNegRes = await request('PUT', '/api/giangvien/GV999', {
      SumClass: -3,
    });
    assert(updateNegRes.status === 400, 'Từ chối cập nhật số lớp âm với status 400 Bad Request');

    // 21. Negative test: Cập nhật GV999 với tên rỗng bị từ chối 400
    const updateEmptyNameRes = await request('PUT', '/api/giangvien/GV999', {
      Fullname: '',
    });
    assert(updateEmptyNameRes.status === 400, 'Từ chối cập nhật Họ và tên rỗng với status 400');

    // 22. Thống kê nâng cao
    const statsRes = await request('GET', '/api/giangvien/stats/summary');
    assert(statsRes.status === 200, 'API thống kê nâng cao hoạt động 200');
    assert(typeof statsRes.data.stats.totalLecturers === 'number', 'Có tổng số giảng viên');
    assert(typeof statsRes.data.stats.totalClasses === 'number', 'Có tổng số lớp');
    assert(typeof statsRes.data.stats.avgClasses === 'number', 'Có số lớp trung bình');
    assert(Array.isArray(statsRes.data.stats.topLecturers), 'Có danh sách topLecturers dạng mảng');
    assert(statsRes.data.stats.topLecturers.length <= 3, 'TopLecturers giới hạn tối đa 3 giảng viên');
    if (statsRes.data.stats.topLecturers.length > 0) {
      const top1Keys = Object.keys(statsRes.data.stats.topLecturers[0]).sort();
      assert(
        JSON.stringify(top1Keys) === JSON.stringify(expectedKeys),
        `topLecturers chỉ gồm đúng 4 trường: ${top1Keys.join(', ')}`
      );
    }

    // 23. Xuất dữ liệu JSON (Export)
    const exportRes = await request('GET', '/api/giangvien/export/json');
    assert(exportRes.status === 200 && Array.isArray(exportRes.data), 'API xuất dữ liệu JSON hoạt động chính xác 200');
    const firstExport = exportRes.data[0];
    const exportKeys = Object.keys(firstExport).sort();
    assert(
      JSON.stringify(exportKeys) === JSON.stringify(expectedKeys),
      `Dữ liệu xuất ra strictly 4 trường: ${exportKeys.join(', ')}`
    );

    // 24. Xóa giảng viên đã thêm thử nghiệm
    const del999 = await request('DELETE', '/api/giangvien/GV999');
    assert(del999.status === 200, 'Xóa GV999 thành công');
    const del888 = await request('DELETE', '/api/giangvien/GV888');
    assert(del888.status === 200, 'Xóa GV888 thành công');

    // 25. Kiểm tra lại không còn GV999
    const checkDeleted = await request('GET', '/api/giangvien/GV999');
    assert(checkDeleted.status === 404, 'GV999 không còn tồn tại 404');

    console.log(`\n========================================`);
    console.log(` KẾT QUẢ KIỂM THỬ BACKEND: ${passed} PASS, ${failed} FAIL`);
    console.log(`========================================\n`);

    if (failed > 0) {
      process.exit(1);
    }
  } catch (err) {
    console.error('Lỗi khi chạy bộ kiểm thử:', err);
    process.exit(1);
  }
}

runTests();
