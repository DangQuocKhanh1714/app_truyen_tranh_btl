class GrandBlueImages {
  // Đảm bảo mã băm "dedab619..." này đúng là của Grand Blue
  static const String _baseUrl = "https://sv1.otruyencdn.com/uploads/20231230/dedab619ec53ff9484f32b8aa3761676";

  static List<String> _generate(int chapter, int totalPages, {int startPage = 1}) {
    return List.generate(
      totalPages, 
      (index) => "$_baseUrl/chapter_$chapter/page_${index + startPage}.jpg"
    );
  }

  // Chương 1: 47 ảnh
  static final List<String> chapter1Images = _generate(1, 47);

  // Chương 2: 46 ảnh
  static final List<String> chapter2Images = _generate(2, 46);

  // Chương 3: 46 ảnh
  static final List<String> chapter3Images = _generate(3, 46);
}