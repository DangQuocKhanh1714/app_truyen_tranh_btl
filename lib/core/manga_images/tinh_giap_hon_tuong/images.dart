/// File chứa dữ liệu hình ảnh của các chương - Tinh Giáp Hồn Tướng
class TinhGiapHonTuongImages {
  static const String _baseUrl = "https://sv1.otruyencdn.com/uploads/20231230/14684460914ee29fc22fe35557a3d54e";

  // Hàm tạo link ảnh linh hoạt với trang bắt đầu
  static List<String> _generate(int chapter, int totalPages, {int startPage = 1}) {
    return List.generate(
      totalPages, 
      (index) => "$_baseUrl/chapter_$chapter/page_${index + startPage}.jpg"
    );
  }

  // Chương 0: Bắt đầu từ page_4, có 29 ảnh (từ 4 đến 32)
  static final List<String> chapter0Images = _generate(0, 29, startPage: 4);

  // Chương 1: Bắt đầu từ page_3, có 44 ảnh (từ 3 đến 46)
  static final List<String> chapter1Images = _generate(1, 44, startPage: 3);

  // Chương 2: Bắt đầu từ page_3, có 39 ảnh (từ 3 đến 41)
  static final List<String> chapter2Images = _generate(2, 39, startPage: 3);

  // Chương 3: Bắt đầu từ page_1, có 52 ảnh
  static final List<String> chapter3Images = _generate(3, 52, startPage: 1);

  // Chương 4: Bắt đầu từ page_1, có 41 ảnh
  static final List<String> chapter4Images = _generate(4, 41, startPage: 1);
}