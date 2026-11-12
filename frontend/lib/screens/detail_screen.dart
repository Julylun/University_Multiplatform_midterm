import 'package:flutter/material.dart';
import '../models/giang_vien.dart';
import '../services/api_service.dart';
import '../widgets/safe_avatar.dart';
import 'add_edit_screen.dart';

class DetailScreen extends StatelessWidget {
  final GiangVien lecturer;
  final VoidCallback onDataChanged;

  const DetailScreen({
    super.key,
    required this.lecturer,
    required this.onDataChanged,
  });

  Future<void> _handleDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa giảng viên'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa Giảng viên "${lecturer.fullname}" (Mã: ${lecturer.idgv}) khỏi cơ sở dữ liệu QLHocPhan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await ApiService.deleteGiangVien(lecturer.idgv);
    if (!context.mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Đã xóa giảng viên thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      onDataChanged();
      Navigator.pop(context); // Quay về danh sách
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Xóa thất bại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết Giảng Viên: ${lecturer.idgv}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Sửa thông tin',
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditScreen(lecturer: lecturer),
                ),
              );
              if (updated == true) {
                onDataChanged();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Xóa giảng viên',
            onPressed: () => _handleDelete(context),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Avatar
                    SafeAvatar(
                      imageUrl: lecturer.image,
                      fallbackName: lecturer.fullname,
                      radius: 64,
                    ),
                    const SizedBox(height: 16),

                    // Fullname
                    Text(
                      lecturer.fullname,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),

                    // IDGV Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Mã GV: ${lecturer.idgv}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(),

                    // Information List
                    ListTile(
                      leading: const Icon(Icons.class_, color: Colors.indigo),
                      title: const Text('Tổng số lớp phụ trách (SumClass)'),
                      subtitle: Text('${lecturer.sumClass} lớp học phần'),
                      trailing: Chip(
                        label: Text(
                          '${lecturer.sumClass} lớp',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: lecturer.sumClass > 5
                            ? Colors.red.shade100
                            : Colors.green.shade100,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.image, color: Colors.teal),
                      title: const Text('Đường dẫn hình ảnh (Image)'),
                      subtitle: Text(
                        lecturer.image,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.edit),
                            label: const Text('Sửa'),
                            onPressed: () async {
                              final updated = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddEditScreen(lecturer: lecturer),
                                ),
                              );
                              if (updated == true) {
                                onDataChanged();
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                            ),
                            icon: const Icon(Icons.delete),
                            label: const Text('Xóa'),
                            onPressed: () => _handleDelete(context),
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
    );
  }
}
