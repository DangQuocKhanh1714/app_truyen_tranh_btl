/// File chứa dữ liệu hình ảnh của các chương - Sự Quyến Rũ Của 2.5D (Server Otruyen)
class Cosplay25dImages {
  // Base URL mới với mã băm "13995c13..." dành riêng cho bộ 2.5D
  static const String _baseUrl = "https://sv1.otruyencdn.com/uploads/20240224/13995c131272e5d4797bad15dd85d3fb";

  // Hàm tạo link ảnh chuẩn cấu trúc page_X.jpg
  static List<String> _generate(int chapter, int totalPages, {int startPage = 1}) {
    return List.generate(
      totalPages, 
      (index) => "$_baseUrl/chapter_$chapter/page_${index + startPage}.jpg"
    );
  }

  // Chương 1: 54 trang ảnh
  static final List<String> chapter1Images = _generate(1, 54);

  // Chương 2: 30 trang ảnh
  static final List<String> chapter2Images = _generate(2, 30);

  // Chương 3: 25 trang ảnh
  static final List<String> chapter3Images = _generate(3, 25);
}