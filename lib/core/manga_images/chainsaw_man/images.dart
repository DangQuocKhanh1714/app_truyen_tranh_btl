/// File chứa dữ liệu hình ảnh của các chương - Chainsaw Man (Server Otruyen)
class ChainsawManImages {
  // Base URL mới với mã băm "571b042e..."
  static const String _baseUrl = "https://sv1.otruyencdn.com/uploads/20231222/571b042e15bb16aea3ea59da99b13352";

  // Hàm tạo link ảnh chuẩn cấu trúc page_X.jpg
  static List<String> _generate(int chapter, int totalPages, {int startPage = 1}) {
    return List.generate(
      totalPages, 
      (index) => "$_baseUrl/chapter_$chapter/page_${index + startPage}.jpg"
    );
  }

  // Chương 1: 50 trang ảnh
  static final List<String> chapter1Images = _generate(1, 50);

  // Chương 2: 25 trang ảnh
  static final List<String> chapter2Images = _generate(2, 25);

  // Chương 3: 19 trang ảnh
  static final List<String> chapter3Images = _generate(3, 19);
}