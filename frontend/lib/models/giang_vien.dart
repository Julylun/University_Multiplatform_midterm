/// Model GiangVien
/// CHÚ Ý QUAN TRỌNG:
/// Cơ sở dữ liệu QLHocPhan.GiangVien CHỈ CHẤP NHẬN 4 TRƯỜNG:
/// - IDGV: Mã Giảng viên
/// - Fullname: Họ và tên
/// - Image: Hình ảnh
/// - SumClass: Tổng số lớp
/// TUYỆT ĐỐI KHÔNG TỰ Ý BỔ SUNG TRƯỜNG KHÁC.
class GiangVien {
  final String idgv;
  final String fullname;
  final String image;
  final int sumClass;

  GiangVien({
    required this.idgv,
    required this.fullname,
    required this.image,
    required this.sumClass,
  });

  factory GiangVien.fromJson(Map<String, dynamic> json) {
    return GiangVien(
      idgv: json['IDGV']?.toString() ?? '',
      fullname: json['Fullname']?.toString() ?? '',
      image: json['Image']?.toString() ?? '',
      sumClass: (json['SumClass'] is num)
          ? (json['SumClass'] as num).toInt()
          : int.tryParse(json['SumClass']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IDGV': idgv,
      'Fullname': fullname,
      'Image': image,
      'SumClass': sumClass,
    };
  }

  GiangVien copyWith({
    String? idgv,
    String? fullname,
    String? image,
    int? sumClass,
  }) {
    return GiangVien(
      idgv: idgv ?? this.idgv,
      fullname: fullname ?? this.fullname,
      image: image ?? this.image,
      sumClass: sumClass ?? this.sumClass,
    );
  }
}
