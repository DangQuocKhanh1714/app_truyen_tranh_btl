/// File chứa dữ liệu hình ảnh của các chương - Citrus
class CitrusImages {
  static const String _baseUrl = "https://sv1.otruyencdn.com/uploads/20231122/e75c9270cec74fc77144997ee31b7d13";

  // Hàm tạo link ảnh linh hoạt
  static List<String> _generate(String chapter, int totalPages, {int startPage = 1}) {
    return List.generate(
      totalPages, 
      (index) => "$_baseUrl/chapter_$chapter/page_${index + startPage}.jpg"
    );
  }

  // Chương 1: Từ page_1 đến page_36 (36 ảnh)
  static final List<String> chapter1Images = _generate("1", 36, startPage: 1);

  // Chương 1.1: Từ page_2 đến page_16 (15 ảnh)
  static final List<String> chapter1_1Images = _generate("1.1", 15, startPage: 2);

  // Chương 1.2: Từ page_1 đến page_12 (12 ảnh)
  static final List<String> chapter1_2Images = _generate("1.2", 12, startPage: 1);
}