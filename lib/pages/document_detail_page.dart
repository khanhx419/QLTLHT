import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_icons.dart';
import '../core/utils/date_formatter.dart';
import '../core/utils/file_helper.dart';
import '../models/document.dart';
import '../providers/document_provider.dart';
import '../widgets/confirm_dialog.dart';
import 'add_edit_document_page.dart';

class DocumentDetailPage extends StatelessWidget {
  final String documentId;

  const DocumentDetailPage({
    super.key,
    required this.documentId,
  });

  @override
  Widget build(BuildContext context) {
    final docProvider = Provider.of<DocumentProvider>(context);
    final documentList = docProvider.documents;
    final docIndex = documentList.indexWhere((d) => d.documentId == documentId);

    if (docIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết tài liệu')),
        body: const Center(
          child: Text('Tài liệu không tồn tại hoặc đã bị xóa.'),
        ),
      );
    }

    final Document doc = documentList[docIndex];
    final theme = Theme.of(context);
    final subjectColor = doc.subjectColor != null ? Color(doc.subjectColor!) : theme.colorScheme.primary;
    final categoryColor = doc.categoryColor != null ? Color(doc.categoryColor!) : Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết tài liệu'),
        actions: [
          IconButton(
            icon: Icon(
              doc.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
              color: doc.isFavorite ? Colors.amber : null,
            ),
            tooltip: 'Yêu thích',
            onPressed: () => docProvider.toggleFavorite(doc.documentId, doc.isFavorite),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Chỉnh sửa',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => AddEditDocumentPage(documentToEdit: doc),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Xóa tài liệu',
            onPressed: () async {
              final confirmed = await ConfirmDialog.show(
                context,
                title: 'Xóa tài liệu?',
                content: 'Tài liệu sẽ được chuyển vào Thùng rác. Bạn có thể khôi phục lại bất kỳ lúc nào.',
                confirmText: 'Chuyển vào thùng rác',
                isDestructive: true,
              );
              if (confirmed == true) {
                await docProvider.deleteDocument(doc.documentId);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã chuyển tài liệu vào Thùng rác')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Badges: Subject & Category
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: subjectColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: subjectColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      doc.subjectCode?.isNotEmpty == true
                          ? '${doc.subjectCode} - ${doc.subjectName ?? ''}'
                          : (doc.subjectName ?? 'Môn học'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: subjectColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  doc.categoryName ?? 'Phân loại',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: categoryColor,
                  ),
                ),
              ),
              const Spacer(),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: doc.isCompleted ? Colors.green.withOpacity(0.12) : Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      doc.isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded,
                      size: 14,
                      color: doc.isCompleted ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doc.isCompleted ? 'Đã học' : 'Đang học',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: doc.isCompleted ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            doc.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Metadata Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
              ),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  context,
                  icon: AppIcons.getFileTypeIcon(doc.fileType),
                  label: 'Định dạng tệp',
                  value: doc.fileType,
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  context,
                  icon: Icons.data_usage_rounded,
                  label: 'Kích thước',
                  value: doc.fileSizeBytes > 0 ? FileHelper.formatBytes(doc.fileSizeBytes) : 'Không xác định',
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  context,
                  icon: Icons.calendar_today_rounded,
                  label: 'Ngày tải lên',
                  value: DateFormatter.formatFull(doc.dateCreated),
                ),
                const Divider(height: 20),
                _buildInfoRow(
                  context,
                  icon: Icons.update_rounded,
                  label: 'Lần sửa cuối',
                  value: DateFormatter.formatFull(doc.dateTimeModified),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Tags section
          if (doc.tagsList.isNotEmpty) ...[
            const Text(
              'Từ khóa / Tags',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: doc.tagsList.map((tag) {
                return Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          // Description Section
          const Text(
            'Mô tả & Ghi chú',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade200,
              ),
            ),
            child: Text(
              doc.description.isNotEmpty ? doc.description : 'Không có mô tả cho tài liệu này.',
              style: TextStyle(
                fontSize: 14,
                color: doc.description.isNotEmpty ? null : Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // File / URL action
          if (doc.fileUri.isNotEmpty || doc.fileName.isNotEmpty) ...[
            const Text(
              'Tệp đính kèm & Liên kết',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.getFileTypeIcon(doc.fileType), size: 32, color: subjectColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.fileName.isNotEmpty ? doc.fileName : 'Tài liệu đính kèm',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (doc.fileUri.isNotEmpty)
                          Text(
                            doc.fileUri,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20),
                    tooltip: 'Sao chép đường dẫn',
                    onPressed: () {
                      final textToCopy = doc.fileUri.isNotEmpty ? doc.fileUri : doc.fileName;
                      Clipboard.setData(ClipboardData(text: textToCopy));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã sao chép đường dẫn vào bộ nhớ tạm')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Toggle Completed Button
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: doc.isCompleted ? Colors.grey.shade600 : Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => docProvider.toggleCompleted(doc.documentId, doc.isCompleted),
            icon: Icon(doc.isCompleted ? Icons.replay_rounded : Icons.check_circle_outline_rounded),
            label: Text(
              doc.isCompleted ? 'Đánh dấu là Chưa học' : 'Đánh dấu Đã học xong',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
