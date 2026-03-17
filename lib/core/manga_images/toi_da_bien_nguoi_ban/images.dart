/// File chứa dữ liệu hình ảnh của các chương - Tôi Đã Biến Người Bạn Thơ Ấu Thành Con Gái
class ChildhoodFriendImages {
  // Base URL với mã băm "d45beb07..."
  static const String _baseUrl = "https://sv1.otruyencdn.com/uploads/20231229/d45beb07ab09a86da513a9e3684ec254";

  // Hàm tạo link ảnh chuẩn cấu trúc page_X.jpg
  static List<String> _generate(String chapter, int totalPages, {int startPage = 1}) {
    return List.generate(
      totalPages, 
      (index) => "$_baseUrl/chapter_$chapter/page_${index + startPage}.jpg"
    );
  }

  // Chương 1: 8 trang ảnh
  static final List<String> chapter1Images = _generate("1", 8);

  // Chương 2: 5 trang ảnh
  static final List<String> chapter2Images = _generate("2", 5);

  // Chương 2.1: 7 trang ảnh
  static final List<String> chapter2_1Images = _generate("2.1", 7);

  // Chương 2.2: 4 trang ảnh
  static final List<String> chapter2_2Images = _generate("2.2", 4);
}