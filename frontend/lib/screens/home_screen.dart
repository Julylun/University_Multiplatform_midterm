import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/giang_vien.dart';
import '../services/api_service.dart';
import '../widgets/safe_avatar.dart';
import 'add_edit_screen.dart';
import 'detail_screen.dart';
import 'login_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<GiangVien> _lecturers = [];
  bool _isLoading = true;
  String? _error;

  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'IDGV';
  String _order = 'asc';

  @override
  void initState() {
    super.initState();
    _loadLecturers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLecturers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await ApiService.getGiangViens(
        search: _searchController.text.trim(),
        sortBy: _sortBy,
        order: _order,
      );
      setState(() {
        _lecturers = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete(GiangVien gv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Xác nhận xóa'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa Giảng viên "${gv.fullname}" (Mã: ${gv.idgv})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await ApiService.deleteGiangVien(gv.idgv);
    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Xóa thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      _loadLecturers();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res['message'] ?? 'Xóa thất bại!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportJsonDialog() async {
    try {
      final jsonStr = await ApiService.exportJson();
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xuất dữ liệu QLHocPhan.GiangVien'),
          content: SizedBox(
            width: double.maxFinite,
            height: 350,
            child: SingleChildScrollView(
              child: SelectableText(
                jsonStr,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('Sao chép vào Clipboard'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép dữ liệu JSON!')),
                );
              },
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi xuất dữ liệu: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _handleLogout() {
    ApiService.setAuthToken(null);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWide = MediaQuery.of(context).size.width > 768;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QLHocPhan - Quản Lý Giảng Viên',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              'HoangXuanLuan23IT150-DaNenTang2026 | Phân hệ Admin',
              style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'Thống kê nâng cao',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Xuất dữ liệu JSON',
            onPressed: _exportJsonDialog,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: _loadLecturers,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: _handleLogout,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final res = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const AddEditScreen()),
          );
          if (res == true) _loadLecturers();
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Thêm Giảng Viên'),
      ),
      body: Column(
        children: [
          // Filter & Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Search box
                SizedBox(
                  width: isWide ? 340 : double.infinity,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm theo Mã GV hoặc Họ tên...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _loadLecturers();
                              },
                            )
                          : null,
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: (_) => _loadLecturers(),
                  ),
                ),

                // Sort dropdown
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Sắp xếp: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    DropdownButton<String>(
                      value: '$_sortBy:$_order',
                      isDense: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'IDGV:asc',
                          child: Text('Mã GV (A - Z)'),
                        ),
                        DropdownMenuItem(
                          value: 'Fullname:asc',
                          child: Text('Họ tên (A - Z)'),
                        ),
                        DropdownMenuItem(
                          value: 'SumClass:desc',
                          child: Text('Số lớp (Nhiều nhất)'),
                        ),
                        DropdownMenuItem(
                          value: 'SumClass:asc',
                          child: Text('Số lớp (Ít nhất)'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val == null) return;
                        final parts = val.split(':');
                        setState(() {
                          _sortBy = parts[0];
                          _order = parts[1];
                        });
                        _loadLecturers();
                      },
                    ),
                  ],
                ),

                // Counter badge
                Chip(
                  avatar: const Icon(Icons.groups, size: 18),
                  label: Text(
                    '${_lecturers.length} Giảng viên',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Lỗi kết nối: $_error', style: const TextStyle(color: Colors.red)),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Thử lại'),
                              onPressed: _loadLecturers,
                            ),
                          ],
                        ),
                      )
                    : _lecturers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                const Text(
                                  'Không tìm thấy giảng viên nào!',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : isWide
                            ? _buildTableView(context)
                            : _buildMobileListView(context),
          ),
        ],
      ),
    );
  }

  /// Giao diện Web / Màn hình rộng: Bảng dữ liệu (Data Table)
  Widget _buildTableView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SizedBox(
              width: double.infinity,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                ),
                columns: const [
                  DataColumn(label: Text('Hình Ảnh (Image)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Mã GV (IDGV)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Họ và Tên (Fullname)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Tổng Số Lớp (SumClass)', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Thao Tác', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _lecturers.map((gv) {
                  return DataRow(
                    cells: [
                      // Image
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: SafeAvatar(
                            imageUrl: gv.image,
                            fallbackName: gv.fullname,
                            radius: 20,
                          ),
                        ),
                      ),
                      // IDGV
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Text(
                            gv.idgv,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                      ),
                      // Fullname
                      DataCell(
                        Text(
                          gv.fullname,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      // SumClass
                      DataCell(
                        Chip(
                          label: Text(
                            '${gv.sumClass} lớp',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          backgroundColor: gv.sumClass > 5 ? Colors.orange.shade100 : Colors.teal.shade50,
                        ),
                      ),
                      // Actions
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.visibility, color: Colors.teal, size: 20),
                              tooltip: 'Xem chi tiết',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                      lecturer: gv,
                                      onDataChanged: _loadLecturers,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                              tooltip: 'Sửa thông tin',
                              onPressed: () async {
                                final res = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddEditScreen(lecturer: gv),
                                  ),
                                );
                                if (res == true) _loadLecturers();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                              tooltip: 'Xóa',
                              onPressed: () => _handleDelete(gv),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Giao diện Di động (Android / Màn hình hẹp): Danh sách thẻ (Card List)
  Widget _buildMobileListView(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: _lecturers.length,
      itemBuilder: (ctx, i) {
        final gv = _lecturers[i];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    lecturer: gv,
                    onDataChanged: _loadLecturers,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SafeAvatar(
                    imageUrl: gv.image,
                    fallbackName: gv.fullname,
                    radius: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                gv.idgv,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Chip(
                              label: Text(
                                '${gv.sumClass} lớp',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              backgroundColor: gv.sumClass > 5 ? Colors.orange.shade100 : Colors.teal.shade50,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          gv.fullname,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ảnh: ${gv.image}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'view') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(
                              lecturer: gv,
                              onDataChanged: _loadLecturers,
                            ),
                          ),
                        );
                      } else if (action == 'edit') {
                        final res = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddEditScreen(lecturer: gv),
                          ),
                        );
                        if (res == true) _loadLecturers();
                      } else if (action == 'delete') {
                        _handleDelete(gv);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'view', child: Text('Xem chi tiết')),
                      const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Xóa', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
