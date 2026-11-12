import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/giang_vien.dart';
import '../services/api_service.dart';
import '../widgets/safe_avatar.dart';

class AddEditScreen extends StatefulWidget {
  final GiangVien? lecturer; // Nếu null là Thêm mới, nếu khác null là Sửa

  const AddEditScreen({super.key, this.lecturer});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _idgvController;
  late TextEditingController _fullnameController;
  late TextEditingController _imageController;
  late TextEditingController _sumClassController;

  final ImagePicker _picker = ImagePicker();
  bool _isUploadingImage = false;
  bool _isSaving = false;

  bool get isEditMode => widget.lecturer != null;

  @override
  void initState() {
    super.initState();
    _idgvController = TextEditingController(text: widget.lecturer?.idgv ?? '');
    _fullnameController = TextEditingController(text: widget.lecturer?.fullname ?? '');
    _imageController = TextEditingController(text: widget.lecturer?.image ?? '');
    _sumClassController = TextEditingController(
      text: widget.lecturer?.sumClass != null ? widget.lecturer!.sumClass.toString() : '4',
    );
  }

  @override
  void dispose() {
    _idgvController.dispose();
    _fullnameController.dispose();
    _imageController.dispose();
    _sumClassController.dispose();
    super.dispose();
  }

  /// Chụp ảnh từ Camera hoặc chọn từ Thư viện ảnh (Hỗ trợ cả Web & Android)
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file == null) return;

      setState(() => _isUploadingImage = true);

      final Uint8List bytes = await file.readAsBytes();
      final String filename = file.name.isNotEmpty ? file.name : 'avatar.jpg';

      final uploadedUrl = await ApiService.uploadImage(bytes, filename);

      setState(() => _isUploadingImage = false);

      if (uploadedUrl != null) {
        setState(() {
          _imageController.text = uploadedUrl;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tải ảnh đại diện lên thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể tải ảnh lên máy chủ, vui lòng kiểm tra kết nối!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xử lý ảnh: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Chọn ảnh từ Thư viện (Gallery)'),
              subtitle: const Text('Tải ảnh đại diện từ bộ sưu tập của máy'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Chụp ảnh từ Máy ảnh (Camera)'),
              subtitle: const Text('Mở camera chụp trực tiếp trên thiết bị'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUploadImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome, color: Colors.amber),
              title: const Text('Sử dụng ảnh đại diện mẫu'),
              subtitle: const Text('Tự động điền URL ảnh giảng viên mẫu chất lượng cao'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _imageController.text =
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final idgv = _idgvController.text.trim();
    final fullname = _fullnameController.text.trim();
    final image = _imageController.text.trim();
    final sumClass = int.tryParse(_sumClassController.text.trim()) ?? 0;

    final gv = GiangVien(
      idgv: idgv,
      fullname: fullname,
      image: image,
      sumClass: sumClass,
    );

    setState(() => _isSaving = true);

    Map<String, dynamic> result;
    if (isEditMode) {
      result = await ApiService.updateGiangVien(widget.lecturer!.idgv, gv);
    } else {
      result = await ApiService.createGiangVien(gv);
    }

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode ? 'Cập nhật giảng viên thành công!' : 'Thêm mới giảng viên thành công!',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.pop(context, true); // Trả về true để màn hình danh sách tự tải lại
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Có lỗi xảy ra'),
          content: Text(result['message'] ?? 'Thao tác thất bại'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đồng ý'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Sửa Giảng Viên (${widget.lecturer!.idgv})' : 'Thêm Giảng Viên Mới',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Badge thông báo 4 trường
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Cơ sở dữ liệu QLHocPhan.GiangVien chuẩn xác 4 trường: IDGV, Fullname, Image, SumClass',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Image preview and pick buttons
                      Center(
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SafeAvatar(
                                  imageUrl: _imageController.text,
                                  fallbackName: _fullnameController.text,
                                  radius: 50,
                                ),
                                if (_isUploadingImage)
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                      color: Colors.black45,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              alignment: WrapAlignment.center,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _pickAndUploadImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt, size: 16, color: Colors.green),
                                  label: const Text('Máy ảnh (Camera)', style: TextStyle(fontSize: 12)),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () => _pickAndUploadImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library, size: 16, color: Colors.blue),
                                  label: const Text('Thư viện (Gallery)', style: TextStyle(fontSize: 12)),
                                ),
                                TextButton.icon(
                                  onPressed: _showImageSourceModal,
                                  icon: const Icon(Icons.more_vert, size: 16),
                                  label: const Text('Tùy chọn khác', style: TextStyle(fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 1. IDGV Field
                      TextFormField(
                        controller: _idgvController,
                        decoration: const InputDecoration(
                          labelText: 'Mã Giảng Viên (IDGV) *',
                          hintText: 'Ví dụ: GV001',
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Vui lòng nhập Mã Giảng viên (IDGV)!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 2. Fullname Field
                      TextFormField(
                        controller: _fullnameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ và Tên (Fullname) *',
                          hintText: 'Ví dụ: TS. Nguyễn Văn A',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => setState(() {}),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Vui lòng nhập Họ và tên (Fullname)!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 3. SumClass Field
                      TextFormField(
                        controller: _sumClassController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tổng Số Lớp Phụ Trách (SumClass) *',
                          hintText: 'Ví dụ: 4',
                          prefixIcon: Icon(Icons.class_),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Vui lòng nhập Tổng số lớp (SumClass)!';
                          }
                          final num = int.tryParse(val.trim());
                          if (num == null) {
                            return 'Tổng số lớp phải là một số nguyên!';
                          }
                          if (num < 0) {
                            return 'Tổng số lớp phải lớn hơn hoặc bằng 0!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 4. Image URL Field
                      TextFormField(
                        controller: _imageController,
                        decoration: InputDecoration(
                          labelText: 'Đường dẫn Hình Ảnh (Image) *',
                          hintText: 'https://... hoặc /uploads/...',
                          prefixIcon: const Icon(Icons.image),
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Cập nhật xem trước ảnh',
                            onPressed: () => setState(() {}),
                          ),
                        ),
                        onChanged: (val) => setState(() {}),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Vui lòng cung cấp đường dẫn ảnh (Image)!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit & Cancel Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSaving ? null : () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Hủy'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: FilledButton.icon(
                              onPressed: _isSaving ? null : _handleSubmit,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(isEditMode ? Icons.check : Icons.save),
                              label: Text(
                                _isSaving
                                    ? 'Đang lưu...'
                                    : (isEditMode ? 'LƯU THAY ĐỔI' : 'THÊM GIẢNG VIÊN'),
                              ),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
