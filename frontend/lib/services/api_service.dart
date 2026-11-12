import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/giang_vien.dart';

class ApiService {
  // Tự động nhận diện Base URL cho Web và Android
  static String _defaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:5000';
    } else {
      // Đối với Android Emulator, máy chủ tính chủ ánh xạ qua 10.0.2.2
      return 'http://10.0.2.2:5000';
    }
  }

  static String _baseUrl = _defaultBaseUrl();
  static String? _authToken;

  static String get baseUrl => _baseUrl;
  static String? get authToken => _authToken;

  static void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static Map<String, String> _headers() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  /// Chuẩn hóa URL hình ảnh để hiển thị an toàn trên cả Web và Android Emulator/Thực
  static String normalizeImageUrl(String url) {
    if (url.isEmpty) return '';

    final cleaned = url.trim();

    // Nếu là ảnh lưu trong thư mục /uploads/ của backend (dù lưu dạng tương đối hay tuyệt đối từ bất kỳ máy chủ nào)
    final uploadsIndex = cleaned.indexOf('/uploads/');
    if (uploadsIndex != -1) {
      final relativePath = cleaned.substring(uploadsIndex);
      return '$_baseUrl$relativePath';
    }

    // Nếu chạy trên Android và URL chứa localhost:5000, thay bằng IP máy chủ hiện tại
    if (!kIsWeb && cleaned.contains('localhost:5000')) {
      final host = _baseUrl.replaceAll('http://', '').replaceAll('https://', '');
      return cleaned.replaceAll('localhost:5000', host);
    }

    return cleaned;
  }

  /// 1. Đăng nhập Admin
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/api/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.trim(),
          'password': password.trim(),
        }),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200 && data['success'] == true) {
        _authToken = data['token'];
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Đăng nhập thất bại!'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối máy chủ: $e'};
    }
  }

  /// 2. Lấy danh sách giảng viên (Hỗ trợ tìm kiếm, sắp xếp)
  static Future<List<GiangVien>> getGiangViens({
    String? search,
    String? sortBy,
    String? order,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (search != null && search.trim().isNotEmpty) {
        queryParams['q'] = search.trim();
      }
      if (sortBy != null && sortBy.trim().isNotEmpty) {
        queryParams['sortBy'] = sortBy.trim();
      }
      if (order != null && order.trim().isNotEmpty) {
        queryParams['order'] = order.trim();
      }

      final uri = Uri.parse('$_baseUrl/api/giangvien').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers());

      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> items = body['data'] ?? [];
        return items.map((json) => GiangVien.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tải danh sách giảng viên (Mã lỗi: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 3. Lấy chi tiết giảng viên theo IDGV
  static Future<GiangVien?> getGiangVienById(String idgv) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/giangvien/$idgv');
      final response = await http.get(uri, headers: _headers());
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return GiangVien.fromJson(body['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 4. Thêm mới giảng viên (ĐÚNG 4 TRƯỜNG IDGV, Fullname, Image, SumClass)
  static Future<Map<String, dynamic>> createGiangVien(GiangVien gv) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/giangvien');
      final response = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode(gv.toJson()),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 201) {
        return {'success': true, 'data': GiangVien.fromJson(data['data'])};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Thêm giảng viên thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  /// 5. Sửa giảng viên theo IDGV
  static Future<Map<String, dynamic>> updateGiangVien(String originalIdgv, GiangVien gv) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/giangvien/$originalIdgv');
      final response = await http.put(
        uri,
        headers: _headers(),
        body: jsonEncode(gv.toJson()),
      );

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        return {'success': true, 'data': GiangVien.fromJson(data['data'])};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Cập nhật giảng viên thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  /// 6. Xóa giảng viên theo IDGV
  static Future<Map<String, dynamic>> deleteGiangVien(String idgv) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/giangvien/$idgv');
      final response = await http.delete(uri, headers: _headers());

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Xóa giảng viên thất bại'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  /// 7. Tải hình ảnh lên máy chủ (Hỗ trợ cả Web & Android)
  static Future<String?> uploadImage(Uint8List bytes, String filename) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/upload');
      final request = http.MultipartRequest('POST', uri);

      // Xác định mime type
      String mimeType = 'jpeg';
      final lower = filename.toLowerCase();
      if (lower.endsWith('.png')) mimeType = 'png';
      if (lower.endsWith('.webp')) mimeType = 'webp';
      if (lower.endsWith('.gif')) mimeType = 'gif';

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: filename,
          contentType: MediaType('image', mimeType),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Ưu tiên trả về đường dẫn tương đối /uploads/... để độc lập host giữa Web và Android
        return data['path'] ?? data['url'];
      }
      return null;
    } catch (e) {
      debugPrint('Lỗi tải ảnh lên: $e');
      return null;
    }
  }

  /// 8. Lấy thống kê nâng cao
  static Future<Map<String, dynamic>?> getStats() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/giangvien/stats/summary');
      final response = await http.get(uri, headers: _headers());
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['stats'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 9. Xuất dữ liệu JSON
  static Future<String> exportJson() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/giangvien/export/json');
      final response = await http.get(uri, headers: _headers());
      if (response.statusCode == 200) {
        return utf8.decode(response.bodyBytes);
      }
      throw Exception('Không thể tải tệp xuất dữ liệu');
    } catch (e) {
      rethrow;
    }
  }
}
