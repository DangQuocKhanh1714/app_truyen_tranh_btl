import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_truyen_tranh/core/constants.dart'; // Import hằng số

import '../../core/cache_helper.dart';
import '../../data/services/push_notification_service.dart';
import '../../logic/theme_bloc/theme_bloc.dart';
import '../../logic/font_family_cubit.dart';
import '../../logic/font_size_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _notificationsKey = 'notificationsEnabled';
  static const _pushTopicKey = 'pushNewChapterEnabled';

  bool _notificationsEnabled = true;
  bool _subscribedToNewChapter = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    final pushEnabled = prefs.getBool(_pushTopicKey) ?? false;

    if (pushEnabled) {
      await PushNotificationService.subscribeToNewChapterTopic();
    }

    setState(() {
      _notificationsEnabled = notificationsEnabled;
      _subscribedToNewChapter = pushEnabled;
      _isLoading = false;
    });
  }

  Future<void> _updateNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _updatePushSubscription(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushTopicKey, value);

    if (value) {
      await PushNotificationService.subscribeToNewChapterTopic();
    } else {
      await PushNotificationService.unsubscribeFromNewChapterTopic();
    }

    setState(() {
      _subscribedToNewChapter = value;
    });
  }

  Future<void> _clearCache() async {
    setState(() => _isLoading = true);
    await CacheHelper.clearCache();
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa bộ nhớ đệm')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
            child: AppBar(
              title: const Text('Cài đặt ứng dụng'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center( // Thêm Center
              child: ConstrainedBox( // Thêm ConstrainedBox
                constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
                child: ListView(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  children: [
                    const Text(
                      'Giao diện',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<ThemeBloc, ThemeMode>(
                      builder: (context, mode) {
                        return SwitchListTile(
                          title: const Text('Chế độ tối (Dark Mode)'),
                          value: mode == ThemeMode.dark,
                          onChanged: (_) => themeBloc.add(ToggleThemeEvent()),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Thông báo',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Nhận thông báo chương mới'),
                      subtitle: const Text(
                        'Bật/tắt để nhận thông báo khi có chương mới',
                      ),
                      value: _subscribedToNewChapter,
                      onChanged: _updatePushSubscription,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Cỡ chữ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<FontSizeCubit, double>(
                      builder: (context, scale) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Slider(
                              min: 0.8,
                              max: 1.4,
                              divisions: 6,
                              label: '${(scale * 100).round()}%',
                              value: scale,
                              onChanged: (value) => context
                                  .read<FontSizeCubit>()
                                  .updateFontScale(value),
                            ),
                            Text('Cỡ chữ hiện tại: ${(scale * 100).round()}%'),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Font đọc truyện',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<FontFamilyCubit, String>(
                      builder: (context, family) {
                        final options = [
                          'Roboto',
                          'Merriweather',
                          'Noto Sans',
                          'Open Sans',
                        ];
                        return DropdownButtonFormField<String>(
                          value: options.contains(family) ? family : options.first,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Font chữ',
                          ),
                          items: options
                              .map(
                                (f) => DropdownMenuItem(value: f, child: Text(f)),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              context.read<FontFamilyCubit>().updateFontFamily(
                                    value,
                                  );
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Bộ nhớ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Xóa bộ nhớ đệm'),
                      onPressed: _clearCache,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}