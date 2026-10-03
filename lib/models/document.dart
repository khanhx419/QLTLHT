class Document {
  final String documentId;
  final String title;
  final String description;
  final String subjectFk;
  final String categoryFk;
  final String fileType;
  final String fileName;
  final String fileUri;
  final int fileSizeBytes;
  final String tags;
  final bool isFavorite;
  final bool isCompleted;
  final DateTime dateCreated;
  final DateTime dateTimeModified;

  // Joined presentation fields
  final String? subjectName;
  final String? subjectCode;
  final int? subjectColor;
  final String? categoryName;
  final int? categoryColor;

  Document({
    required this.documentId,
    required this.title,
    this.description = '',
    required this.subjectFk,
    required this.categoryFk,
    required this.fileType,
    this.fileName = '',
    this.fileUri = '',
    this.fileSizeBytes = 0,
    this.tags = '',
    this.isFavorite = false,
    this.isCompleted = false,
    required this.dateCreated,
    required this.dateTimeModified,
    this.subjectName,
    this.subjectCode,
    this.subjectColor,
    this.categoryName,
    this.categoryColor,
  });

  List<String> get tagsList => tags.isEmpty
      ? []
      : tags.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Document copyWith({
    String? documentId,
    String? title,
    String? description,
    String? subjectFk,
    String? categoryFk,
    String? fileType,
    String? fileName,
    String? fileUri,
    int? fileSizeBytes,
    String? tags,
    bool? isFavorite,
    bool? isCompleted,
    DateTime? dateCreated,
    DateTime? dateTimeModified,
    String? subjectName,
    String? subjectCode,
    int? subjectColor,
    String? categoryName,
    int? categoryColor,
  }) {
    return Document(
      documentId: documentId ?? this.documentId,
      title: title ?? this.title,
      description: description ?? this.description,
      subjectFk: subjectFk ?? this.subjectFk,
      categoryFk: categoryFk ?? this.categoryFk,
      fileType: fileType ?? this.fileType,
      fileName: fileName ?? this.fileName,
      fileUri: fileUri ?? this.fileUri,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isCompleted: isCompleted ?? this.isCompleted,
      dateCreated: dateCreated ?? this.dateCreated,
      dateTimeModified: dateTimeModified ?? this.dateTimeModified,
      subjectName: subjectName ?? this.subjectName,
      subjectCode: subjectCode ?? this.subjectCode,
      subjectColor: subjectColor ?? this.subjectColor,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'title': title,
      'description': description,
      'subjectFk': subjectFk,
      'categoryFk': categoryFk,
      'fileType': fileType,
      'fileName': fileName,
      'fileUri': fileUri,
      'fileSizeBytes': fileSizeBytes,
      'tags': tags,
      'isFavorite': isFavorite ? 1 : 0,
      'isCompleted': isCompleted ? 1 : 0,
      'dateCreated': dateCreated.toIso8601String(),
      'dateTimeModified': dateTimeModified.toIso8601String(),
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      documentId: map['documentId'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      subjectFk: map['subjectFk'] as String,
      categoryFk: map['categoryFk'] as String,
      fileType: map['fileType'] as String? ?? 'PDF',
      fileName: map['fileName'] as String? ?? '',
      fileUri: map['fileUri'] as String? ?? '',
      fileSizeBytes: (map['fileSizeBytes'] as num?)?.toInt() ?? 0,
      tags: map['tags'] as String? ?? '',
      isFavorite: (map['isFavorite'] == 1 || map['isFavorite'] == true),
      isCompleted: (map['isCompleted'] == 1 || map['isCompleted'] == true),
      dateCreated: DateTime.tryParse(map['dateCreated'] as String? ?? '') ?? DateTime.now(),
      dateTimeModified: DateTime.tryParse(map['dateTimeModified'] as String? ?? '') ?? DateTime.now(),
      subjectName: map['subjectName'] as String?,
      subjectCode: map['subjectCode'] as String?,
      subjectColor: map['subjectColor'] as int?,
      categoryName: map['categoryName'] as String?,
      categoryColor: map['categoryColor'] as int?,
    );
  }
}
