import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import '../widgets/safe_avatar.dart';

class StatsScreen extends StatefulWidget {
  final Map<String, dynamic>? initialStats;
  const StatsScreen({super.key, this.initialStats});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _stats;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialStats != null) {
      _stats = widget.initialStats;
      _isLoading = false;
    } else {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getStats();
      setState(() {
        _stats = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showExportJsonModal() async {
    try {
      final jsonStr = await ApiService.exportJson();
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Xuất dữ liệu QLHocPhan.GiangVien'),
          content: SizedBox(
            width: double.maxFinite,
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
              label: const Text('Sao chép JSON'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã sao chép JSON vào bộ nhớ tạm!')),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống Kê Nâng Cao'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Xuất tệp JSON',
            onPressed: _showExportJsonModal,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Lỗi: $_error', style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _loadStats, child: const Text('Thử lại')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // KPI Row
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _buildKpiCard(
                                title: 'Tổng Giảng Viên',
                                value: '${_stats?['totalLecturers'] ?? 0}',
                                icon: Icons.people,
                                color: Colors.blue,
                              ),
                              _buildKpiCard(
                                title: 'Tổng Số Lớp',
                                value: '${_stats?['totalClasses'] ?? 0}',
                                icon: Icons.class_,
                                color: Colors.purple,
                              ),
                              _buildKpiCard(
                                title: 'Trung Bình Lớp/GV',
                                value: '${_stats?['avgClasses'] ?? 0}',
                                icon: Icons.analytics,
                                color: Colors.green,
                              ),
                              _buildKpiCard(
                                title: 'Số Lớp Nhiều Nhất',
                                value: '${_stats?['maxClasses'] ?? 0}',
                                icon: Icons.trending_up,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Phân bổ số lớp
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Phân Bổ Tải Giảng Dạy (Số Lớp / Giảng Viên)',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildBar(
                                    label: 'Dưới 3 lớp (Khối lượng nhẹ)',
                                    count: _stats?['distribution']?['under3'] ?? 0,
                                    total: _stats?['totalLecturers'] ?? 1,
                                    color: Colors.teal,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildBar(
                                    label: '3 - 6 lớp (Đạt chuẩn định mức)',
                                    count: _stats?['distribution']?['from3to6'] ?? 0,
                                    total: _stats?['totalLecturers'] ?? 1,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildBar(
                                    label: 'Trên 6 lớp (Vượt định mức cao)',
                                    count: _stats?['distribution']?['over6'] ?? 0,
                                    total: _stats?['totalLecturers'] ?? 1,
                                    color: Colors.deepOrange,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Top Lecturers
                          if (_stats?['topLecturers'] != null &&
                              (_stats!['topLecturers'] as List).isNotEmpty)
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Giảng Viên Phụ Trách Nhiều Lớp Nhất',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ...(_stats!['topLecturers'] as List).asMap().entries.map(
                                      (entry) {
                                        final index = entry.key;
                                        final item = entry.value as Map<String, dynamic>;
                                        final fullname = item['Fullname'] ?? 'Chưa có tên';
                                        final idgv = item['IDGV'] ?? 'N/A';
                                        final sumClass = item['SumClass'] ?? 0;
                                        final imageUrl = item['Image'] ?? '';

                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              _buildRankBadge(index),
                                              const SizedBox(width: 10),
                                              SafeAvatar(
                                                imageUrl: imageUrl,
                                                fallbackName: fullname,
                                                radius: 20,
                                              ),
                                            ],
                                          ),
                                          title: Text(
                                            fullname,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                            'Mã GV: $idgv',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          trailing: Chip(
                                            label: Text('$sumClass lớp'),
                                            backgroundColor: Colors.amber.shade100,
                                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            padding: const EdgeInsets.symmetric(horizontal: 4),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: 175,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBar({
    required String label,
    required int count,
    required int total,
    required Color color,
  }) {
    final double percent = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text('$count GV (${(percent * 100).toStringAsFixed(0)}%)',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: percent,
          color: color,
          backgroundColor: Colors.grey.shade200,
          minHeight: 10,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    );
  }

  Widget _buildRankBadge(int index) {
    Color badgeColor;
    Color textColor = Colors.white;
    if (index == 0) {
      badgeColor = const Color(0xFFFFB300); // Gold / Top 1
    } else if (index == 1) {
      badgeColor = const Color(0xFF78909C); // Silver / Top 2
    } else if (index == 2) {
      badgeColor = const Color(0xFF8D6E63); // Bronze / Top 3
    } else {
      badgeColor = Colors.blueGrey.shade200;
      textColor = Colors.black87;
    }

    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        '#${index + 1}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: textColor,
        ),
      ),
    );
  }
}
