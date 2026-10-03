# ỨNG DỤNG QUẢN LÝ TÀI LIỆU HỌC TẬP (QLTLHT)
### Áp dụng và Phát triển dựa trên Kiến trúc Cashew (Flutter Local-First)

Ứng dụng **Quản lý Tài liệu Học tập (QLTLHT)** được thiết kế và triển khai nhằm phục vụ nhu cầu lưu trữ, phân loại, tìm kiếm và theo dõi tài liệu học tập (bài giảng, bài tập & đồ án, tài liệu tham khảo, đề thi, ghi chú). Ứng dụng áp dụng đầy đủ các nguyên lý kiến trúc của ứng dụng **Cashew** với cải tiến phân tầng Clean Architecture, module hóa DAOs, và cơ chế lưu vết xóa Tombstones.

---

## 🌟 ĐẶC ĐIỂM NỔI BẬT

1. **Kiến trúc Local-First (Offline-First)**:
   - Dữ liệu lưu trữ hoàn toàn trên thiết bị thông qua SQLite cục bộ.
   - Hoạt động mượt mà không cần mạng, độ trễ truy xuất gần bằng 0 ($< 5\text{ms}$).
2. **Phân lớp hệ thống độc lập (Modular Clean Architecture)**:
   - Khắc phục điểm yếu "Fat God-File" của Cashew bằng cách module hóa thành các DAO độc lập (`DocumentDao`, `SubjectDao`, `CategoryDao`, `DeleteLogDao`).
   - Tách biệt rõ ràng 5 tầng: Presentation -> State Management -> Domain/Repository -> Persistence -> Storage Engine.
3. **Cơ chế lưu vết xóa Tombstone Pattern (`DeleteLogs`)**:
   - Khi xóa tài liệu, hệ thống tự động ghi nhận vào bảng `delete_logs` kèm JSON payload.
   - Hỗ trợ tính năng **Thùng rác (Recycle Bin)** cho phép khôi phục nguyên trạng hoặc xóa vĩnh viễn.
4. **Tìm kiếm toàn văn & Bộ lọc đa tiêu chí (Debounced Live Search)**:
   - Tìm kiếm nhanh theo từ khóa trong tiêu đề, mô tả, tags, tên file kết hợp bộ hoãn `Debouncer (300ms)`.
   - Lọc theo môn học, theo loại tài liệu, theo định dạng file, trạng thái hoàn thành và mục yêu thích.
5. **Dashboard thống kê trực quan**:
   - 4 thẻ số đo tổng quan tiến độ học tập và dung lượng.
   - Biểu đồ tròn phân bổ tài liệu theo loại (`fl_chart`).
6. **Sao lưu & Phục hồi dữ liệu (Cashew JSON Snapshot)**:
   - Xuất dữ liệu hệ thống ra tệp JSON Snapshot và phục hồi nguyên vẹn các bảng quan hệ.

---

## 📁 CẤU TRÚC THƯ MỤC DỰ ÁN

```
lib/
├── core/
│   ├── constants/       # AppConstants, AppColors, AppIcons
│   ├── theme/           # AppTheme (Material 3, Dark/Light, Custom Palette)
│   └── utils/           # Debouncer, FileHelper, DateFormatter
├── database/
│   ├── daos/            # DocumentDao, SubjectDao, CategoryDao, DeleteLogDao
│   ├── app_database.dart# Quản lý SQLite, connection, schema version, tableUpdatesStream
│   └── initial_data.dart# Dữ liệu khởi tạo mặc định (Seeder)
├── models/              # Document, Subject, Category, DeleteLog, AppSettings
├── repositories/        # DocumentRepository, SubjectRepository, CategoryRepository
├── services/            # BackupService, StorageService
├── providers/           # DocumentProvider, SubjectProvider, CategoryProvider, SettingsProvider, StatisticsProvider
├── widgets/             # DocumentCard, SubjectCard, StatSummaryCard, CategoryChipBar, SearchBarWidget...
├── pages/               # HomePage, DocumentListPage, DocumentDetailPage, AddEditDocumentPage, SubjectPage...
└── main.dart            # Điểm vào chương trình, MultiProvider setup
```

---

## 🧪 CHẠY KIỂM THỬ TỰ ĐỘNG (UNIT TESTS)

Dự án có sẵn 20 test cases kiểm thử tự động toàn bộ các tầng:
```bash
flutter test
```

Kết quả:
```
00:01 +20: All tests passed!
```

---

## 🚀 HƯỚNG DẪN KHỞI CHẠY ỨNG DỤNG

1. Cài đặt các gói phụ thuộc:
   ```bash
   flutter pub get
   ```
2. Khởi chạy ứng dụng:
   ```bash
   # Chạy trên Windows Desktop:
   flutter run -d windows

   # Chạy trên thiết bị Android:
   flutter run -d android
   ```

---

## 📑 BÁO CÁO GIẢI TRÌNH KIẾN TRÚC CHI TIẾT
Xem chi tiết sơ đồ luồng dữ liệu, sơ đồ ERD, sơ đồ kiến trúc 5 tầng và đánh giá so sánh tại:
👉 **[BAO_CAO_KIEN_TRUC_QLTLHT.md](file:///c:/Users/Admin/Desktop/code/android/QLTLHT/BAO_CAO_KIEN_TRUC_QLTLHT.md)**
