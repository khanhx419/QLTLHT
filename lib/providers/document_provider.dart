import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/constants/app_constants.dart';
import '../../database/app_database.dart';
import '../../models/delete_log.dart';
import '../../models/document.dart';
import '../../repositories/document_repository.dart';

class DocumentProvider extends ChangeNotifier {
  final DocumentRepository _repository;
  StreamSubscription? _dbSubscription;

  List<Document> _documents = [];
  List<DeleteLog> _recycleBinLogs = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter States
  String _searchQuery = '';
  String _selectedSubjectId = 'all';
  String _selectedCategoryId = 'all';
  bool _isFavoriteOnly = false;
  bool? _isCompletedFilter;
  String _selectedFileType = 'all';
  String _sortBy = AppConstants.sortDateDesc;

  DocumentProvider({DocumentRepository? repository})
      : _repository = repository ?? DocumentRepository() {
    _listenToDatabaseChanges();
    loadDocuments();
    loadRecycleBin();
  }

  // Getters
  List<Document> get documents => _documents;
  List<DeleteLog> get recycleBinLogs => _recycleBinLogs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String get selectedSubjectId => _selectedSubjectId;
  String get selectedCategoryId => _selectedCategoryId;
  bool get isFavoriteOnly => _isFavoriteOnly;
  bool? get isCompletedFilter => _isCompletedFilter;
  String get selectedFileType => _selectedFileType;
  String get sortBy => _sortBy;

  int get totalCount => _documents.length;
  int get recycleBinCount => _recycleBinLogs.length;

  void _listenToDatabaseChanges() {
    _dbSubscription = AppDatabase.instance.tableUpdatesStream.listen((tableName) {
      if (tableName == 'documents' || tableName == 'subjects' || tableName == 'categories') {
        loadDocuments();
      }
      if (tableName == 'delete_logs') {
        loadRecycleBin();
      }
    });
  }

  Future<void> loadDocuments() async {
    _isLoading = true;
    notifyListeners();

    try {
      _documents = await _repository.searchAndFilter(
        query: _searchQuery,
        subjectFk: _selectedSubjectId,
        categoryFk: _selectedCategoryId,
        isFavorite: _isFavoriteOnly ? true : null,
        isCompleted: _isCompletedFilter,
        fileType: _selectedFileType,
        sortBy: _sortBy,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Lỗi khi tải danh sách tài liệu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRecycleBin() async {
    try {
      _recycleBinLogs = await _repository.getRecycleBinLogs();
      notifyListeners();
    } catch (_) {}
  }

  // Filter setters
  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    loadDocuments();
  }

  void setSelectedSubject(String subjectId) {
    if (_selectedSubjectId == subjectId) return;
    _selectedSubjectId = subjectId;
    loadDocuments();
  }

  void setSelectedCategory(String categoryId) {
    if (_selectedCategoryId == categoryId) return;
    _selectedCategoryId = categoryId;
    loadDocuments();
  }

  void toggleFavoriteOnly() {
    _isFavoriteOnly = !_isFavoriteOnly;
    loadDocuments();
  }

  void setCompletedFilter(bool? isCompleted) {
    _isCompletedFilter = isCompleted;
    loadDocuments();
  }

  void setSelectedFileType(String fileType) {
    _selectedFileType = fileType;
    loadDocuments();
  }

  void setSortBy(String sort) {
    _sortBy = sort;
    loadDocuments();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedSubjectId = 'all';
    _selectedCategoryId = 'all';
    _isFavoriteOnly = false;
    _isCompletedFilter = null;
    _selectedFileType = 'all';
    _sortBy = AppConstants.sortDateDesc;
    loadDocuments();
  }

  // CRUD Operations
  Future<bool> addDocument(Document doc) async {
    try {
      final res = await _repository.addDocument(doc);
      await loadDocuments();
      return res > 0;
    } catch (e) {
      _errorMessage = 'Không thể thêm tài liệu: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDocument(Document doc) async {
    try {
      final res = await _repository.updateDocument(doc);
      await loadDocuments();
      return res > 0;
    } catch (e) {
      _errorMessage = 'Không thể cập nhật tài liệu: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDocument(String id) async {
    try {
      final success = await _repository.deleteDocument(id);
      await loadDocuments();
      await loadRecycleBin();
      return success;
    } catch (e) {
      _errorMessage = 'Không thể xóa tài liệu: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleFavorite(String id, bool currentVal) async {
    await _repository.toggleFavorite(id, currentVal);
    await loadDocuments();
  }

  Future<void> toggleCompleted(String id, bool currentVal) async {
    await _repository.toggleCompleted(id, currentVal);
    await loadDocuments();
  }

  Future<bool> restoreDocument(int logId) async {
    final success = await _repository.restoreDocument(logId);
    if (success) {
      await loadDocuments();
      await loadRecycleBin();
    }
    return success;
  }

  Future<void> permanentDelete(int logId) async {
    await _repository.deletePermanently(logId);
    await loadRecycleBin();
  }

  Future<void> clearRecycleBin() async {
    await _repository.clearRecycleBin();
    await loadRecycleBin();
  }

  @override
  void dispose() {
    _dbSubscription?.cancel();
    super.dispose();
  }
}
