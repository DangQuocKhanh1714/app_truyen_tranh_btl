/// File chứa dữ liệu hình ảnh của các chương - Shuumatsu no Valkyrie
class ValkyrieImages {
  // Base URL với mã băm "177e96d3..." dành riêng cho bộ Valkyrie
  static const String _baseUrl = "https://sv1.otruyencdn.com/uploads/20231226/177e96d34b2cb441bb7e4b91f8a1c391";

  // Hàm tạo link ảnh chuẩn cấu trúc page_X.jpg
  static List<String> _generate(String chapter, int totalPages, {int startPage = 1}) {
    return List.generate(
      totalPages, 
      (index) => "$_baseUrl/chapter_$chapter/page_${index + startPage}.jpg"
    );
  }

  // Chương 1: Cuộc họp của các vị thần - 72 trang ảnh
  static final List<String> chapter1Images = _generate("1", 72);

  // Chương 2: Trận chiến đầu tiên - 29 trang ảnh
  static final List<String> chapter2Images = _generate("2", 29);

  // Chương 2.5: Chương đặc biệt - 32 trang ảnh
  static final List<String> chapter2_5Images = _generate("2.5", 32);
}