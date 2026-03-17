import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_truyen_tranh/core/constants.dart'; // Đảm bảo đúng đường dẫn constants

class SupportFeedbackScreen extends StatelessWidget {
  const SupportFeedbackScreen({super.key});

  static const _feedbackEmail = 'example@domain.com';
  static const _appVersion = '1.0.0';
  static const _teamMembers = ['Thành viên 1', 'Thành viên 2', 'Thành viên 3'];

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _feedbackEmail,
      queryParameters: {'subject': 'Góp ý ứng dụng DNU Manga'},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
            child: AppBar(
              title: const Text('Hỗ trợ & Góp ý'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            children: [
              const Text('Góp ý', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.email_outlined),
                label: const Text('Gửi email góp ý'),
                onPressed: _sendEmail,
              ),
              const SizedBox(height: 24),
              const Text(
                'Câu hỏi thường gặp',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text('Làm sao để tải truyện?'),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Chọn truyện rồi nhấn nút "Tải xuống" (nếu có).'),
                  ),
                ],
              ),
              ExpansionTile(
                title: const Text('Làm sao để đổi mật khẩu?'),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('Vào mục hồ sơ và chọn chức năng đổi mật khẩu.'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Thông tin ứng dụng',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Phiên bản: $_appVersion'),
              const SizedBox(height: 4),
              Text('Nhóm: ${_teamMembers.join(', ')}'),
            ],
          ),
        ),
      ),
    );
  }
}