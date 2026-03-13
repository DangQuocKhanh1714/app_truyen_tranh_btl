/// File chứa dữ liệu hình ảnh của các chương - Solo Leveling: Ragnarok
class SoloLevelingRagnarokImages {
  static const String _baseUrl = "https://sv1.otruyencdn.com/uploads/20241119/b3e5b270c6b004a65606d894cf4d065e";

  // Hàm hỗ trợ tạo danh sách ảnh tự động
  static List<String> _generate(int chapter, int totalPages) {
    return List.generate(
      totalPages, 
      (index) => "$_baseUrl/chapter_$chapter/page_${index + 1}.jpg"
    );
  }

  // Giữ nguyên tên biến để các file khác không bị lỗi
  static final List<String> chapter1Images = _generate(1, 82);
  static final List<String> chapter2Images = _generate(2, 148);
  static final List<String> chapter3Images = _generate(1, 136);
  
  // Sau này thêm chương mới chỉ cần 1 dòng:
  // static final List<String> chapter3Images = _generate(3, 100);
}