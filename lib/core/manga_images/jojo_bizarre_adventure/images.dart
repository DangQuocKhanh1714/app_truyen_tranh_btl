/// File chứa dữ liệu hình ảnh của các chương - Jojo's Bizarre Adventure (Server Otruyen)
class JojoImages {
  // Base URL mới với mã băm "a676a66e..."
  static const String _baseUrl = "https://sv1.otruyencdn.com/uploads/20231211/a676a66e85447c047dd889b5837fc442";

  // Hàm tạo link ảnh chuẩn cấu trúc page_X.jpg
  static List<String> _generate(int chapter, int totalPages, {int startPage = 1}) {
    return List.generate(
      totalPages, 
      (index) => "$_baseUrl/chapter_$chapter/page_${index + startPage}.jpg"
    );
  }

  // Chương 199: 20 trang ảnh
  static final List<String> chapter199Images = _generate(199, 20);

  // Chương 200: 21 trang ảnh
  static final List<String> chapter200Images = _generate(200, 21);
}