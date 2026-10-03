import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../database/daos/delete_log_dao.dart';
import '../../database/daos/document_dao.dart';
import '../../models/delete_log.dart';
import '../../models/document.dart';

class DocumentRepository {
  final DocumentDao _documentDao;
  final DeleteLogDao _deleteLogDao;

  DocumentRepository({
    DocumentDao? documentDao,
    DeleteLogDao? deleteLogDao,
  })  : _documentDao = documentDao ?? DocumentDao(),
        _deleteLogDao = deleteLogDao ?? DeleteLogDao();

  Future<List<Document>> getAllDocuments() => _documentDao.getAllDocuments();

  Future<Document?> getDocumentById(String id) => _documentDao.getDocumentById(id);

  Future<int> addDocument(Document document) async {
    final now = DateTime.now();
    final enriched = document.copyWith(
      dateCreated: document.dateCreated,
      dateTimeModified: now,
    );
    return await _documentDao.insertDocument(enriched);
  }

  Future<int> updateDocument(Document document) async {
    final enriched = document.copyWith(
      dateTimeModified: DateTime.now(),
    );
    return await _documentDao.updateDocument(enriched);
  }

  /// Soft-delete document: Removes from documents table and logs to DeleteLogs
  /// adhering to Cashew Tombstone synchronization pattern.
  Future<bool> deleteDocument(String documentId) async {
    final doc = await _documentDao.getDocumentById(documentId);
    if (doc == null) return false;

    // 1. Insert into DeleteLogs
    final log = DeleteLog(
      entryPk: doc.documentId,
      type: 'document',
      title: doc.title,
      payloadJson: jsonEncode(doc.toMap()),
      dateTimeModified: DateTime.now(),
    );
    await _deleteLogDao.insertDeleteLog(log);

    // 2. Remove from active documents table
    final deletedCount = await _documentDao.deleteDocument(documentId);
    return deletedCount > 0;
  }

  Future<bool> restoreDocument(int logId) async {
    return await _deleteLogDao.restoreDocument(logId);
  }

  Future<List<DeleteLog>> getRecycleBinLogs() async {
    return await _deleteLogDao.getAllDeleteLogs();
  }

  Future<int> deletePermanently(int logId) async {
    return await _deleteLogDao.deleteLogPermanently(logId);
  }

  Future<int> clearRecycleBin() async {
    return await _deleteLogDao.clearAllLogs();
  }

  Future<List<Document>> searchAndFilter({
    String? query,
    String? subjectFk,
    String? categoryFk,
    bool? isFavorite,
    bool? isCompleted,
    String? fileType,
    String sortBy = AppConstants.sortDateDesc,
  }) {
    return _documentDao.searchAndFilterDocuments(
      query: query,
      subjectFk: subjectFk,
      categoryFk: categoryFk,
      isFavorite: isFavorite,
      isCompleted: isCompleted,
      fileType: fileType,
      sortBy: sortBy,
    );
  }

  Future<int> toggleFavorite(String documentId, bool currentFavorite) {
    return _documentDao.toggleFavorite(documentId, !currentFavorite);
  }

  Future<int> toggleCompleted(String documentId, bool currentCompleted) {
    return _documentDao.toggleCompleted(documentId, !currentCompleted);
  }

  Future<int> getTotalCount() => _documentDao.countDocuments();

  Future<int> getTotalSizeBytes() => _documentDao.sumTotalFileSizeBytes();

  Future<Map<String, int>> getCountBySubject() => _documentDao.countDocumentsBySubject();

  Future<Map<String, int>> getCountByCategory() => _documentDao.countDocumentsByCategory();
}
