/// File chứa dữ liệu hình ảnh của các chương - Ông Chồng Yakuza
class YakuzaHusbandImages {
  // Base URL với mã băm "b7995509..." dành riêng cho bộ này
  static const String _baseUrl = "https://sv1.otruyencdn.com/uploads/20231222/b799550976d27f8e59c7eb4081335660";

  // Hàm tạo link ảnh chuẩn cấu trúc page_X.jpg
  static List<String> _generate(int chapter, int totalPages, {int startPage = 1}) {
    return List.generate(
      totalPages, 
      (index) => "$_baseUrl/chapter_$chapter/page_${index + startPage}.jpg"
    );
  }

  // Chương 1: 16 trang ảnh
  static final List<String> chapter1Images = _generate(1, 16);

  // Chương 2: 16 trang ảnh
  static final List<String> chapter2Images = _generate(2, 16);

  // Chương 3: 16 trang ảnh
  static final List<String> chapter3Images = _generate(3, 16);
}