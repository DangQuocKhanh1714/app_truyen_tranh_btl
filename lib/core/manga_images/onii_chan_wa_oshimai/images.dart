/// File chứa dữ liệu hình ảnh của các chương - Onii-Chan Wa Oshimai! (Server Otruyen)
class OniichanImages {
  // Base URL mới với mã băm "b688eb18..."
  static const String _baseUrl = "https://sv1.otruyencdn.com/uploads/20231229/b688eb183fe95887339ab5e3b090c4be";

  // Hàm tạo link ảnh linh hoạt, xử lý được cả chương "1" và "1.5"
  static List<String> _generate(String chapter, int totalPages, {int startPage = 1}) {
    return List.generate(
      totalPages, 
      (index) => "$_baseUrl/chapter_$chapter/page_${index + startPage}.jpg"
    );
  }

  // Chương 1: 15 trang ảnh
  static final List<String> chapter1Images = _generate("1", 15);

  // Chương 1.5: 7 trang ảnh
  static final List<String> chapter1_5Images = _generate("1.5", 7);

  // Chương 2: 11 trang ảnh
  static final List<String> chapter2Images = _generate("2", 11);

  // Chương 3: 12 trang ảnh
  static final List<String> chapter3Images = _generate("3", 12);
}