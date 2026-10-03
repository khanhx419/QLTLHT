import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/settings_provider.dart';
import '../services/backup_service.dart';
import 'recycle_bin_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showBackupDialog(BuildContext context) async {
    final backupService = BackupService();
    try {
      final jsonSnapshot = await backupService.exportToJson();

      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Bản sao lưu JSON (Cashew Snapshot)'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dữ liệu toàn bộ môn học, danh mục, tài liệu và DeleteLogs đã được đóng gói thành công theo chuẩn snapshot của Cashew.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                height: 140,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    jsonSnapshot,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Đóng'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text('Sao chép JSON'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonSnapshot));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã sao chép bản sao lưu JSON vào bộ nhớ tạm'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi sao lưu: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _showRestoreDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Phục hồi dữ liệu từ JSON'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dán chuỗi JSON bản sao lưu snapshot vào ô dưới đây để hợp nhất vào cơ sở dữ liệu SQLite.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: textController,
              maxLines: 6,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              decoration: const InputDecoration(
                hintText: '{\n  "app": "Quản Lý Tài Liệu Học Tập", ...\n}',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              final jsonStr = textController.text.trim();
              if (jsonStr.isEmpty) return;

              final backupService = BackupService();
              try {
                final result = await backupService.importFromJson(jsonStr);
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Phục hồi thành công: ${result['documents']} tài liệu, ${result['subjects']} môn học.',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi cú pháp JSON: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Phục hồi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt hệ thống'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section: Giao diện
          _buildSectionHeader('GIAO DIỆN & MÀU SẮC'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6_rounded),
                  title: const Text('Chế độ giao diện'),
                  subtitle: Text(_getThemeModeName(settings.themeMode)),
                  trailing: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('Theo hệ thống')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('Sáng')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('Tối')),
                    ],
                    onChanged: (mode) {
                      if (mode != null) settings.setThemeMode(mode);
                    },
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Màu sắc chủ đạo (Accent Color)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        children: AppColors.presetColors.map((color) {
                          final isSelected = settings.accentColor.value == color.value;
                          return InkWell(
                            onTap: () => settings.setAccentColor(color),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 3)
                                    : null,
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: Dữ liệu & Lưu trữ (Cashew Local-First)
          _buildSectionHeader('LƯU TRỮ & SAO LƯU (LOCAL-FIRST)'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
                  title: const Text('Sao lưu dữ liệu (Snapshot Export)'),
                  subtitle: const Text('Xuất toàn bộ cơ sở dữ liệu ra định dạng JSON'),
                  onTap: () => _showBackupDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_download_outlined, color: Colors.teal),
                  title: const Text('Phục hồi dữ liệu (Snapshot Import)'),
                  subtitle: const Text('Nạp lại dữ liệu từ tệp snapshot vào SQLite'),
                  onTap: () => _showRestoreDialog(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded, color: Colors.orange),
                  title: const Text('Thùng rác & Lịch sử xóa'),
                  subtitle: const Text('Quản lý bảng DeleteLogs (Tombstones) và khôi phục'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (c) => const RecycleBinPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: Thông tin kiến trúc
          _buildSectionHeader('THÔNG TIN KIẾN TRÚC CASHEW'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.architecture_rounded, color: theme.colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            'Phiên bản ${AppConstants.appVersion} • Schema v${AppConstants.dbVersion}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Dự án triển khai theo kiến trúc Local-First lấy cảm hứng từ ứng dụng Cashew (Flutter/SQLite), với các cải tiến quan trọng về phân tầng Clean Architecture, module hóa DAOs, phân tách trách nhiệm giữa Persistence, Repositories, Providers và UI.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
        return 'Tối';
      case ThemeMode.system:
      default:
        return 'Theo hệ thống';
    }
  }
}
