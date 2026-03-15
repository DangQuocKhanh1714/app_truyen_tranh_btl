import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'firebase_options.dart';

// Core & Theme
import 'core/app_theme.dart';

// Data Layer
import 'data/services/database_helper.dart';
import 'data/services/auth_service.dart';

// Logic Layer
import 'logic/auth_bloc/auth_bloc.dart';
import 'logic/auth_bloc/auth_event.dart';
import 'logic/auth_bloc/auth_state.dart';
import 'logic/manga_bloc/manga_bloc.dart';
import 'logic/manga_bloc/manga_event.dart';
import 'logic/search_bloc/search_bloc.dart';
import 'logic/theme_bloc/theme_bloc.dart';
import 'logic/font_size_cubit.dart';
import 'logic/font_family_cubit.dart';
import 'logic/category_bloc/category_bloc.dart';
import 'logic/favorite_bloc/favorite_bloc.dart';
import 'logic/history_bloc/history_bloc.dart';
import 'logic/user_bloc/user_bloc.dart';
import 'data/services/push_notification_service.dart';

// Presentation Layer
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dbHelper = DatabaseHelper();

  // Cấu hình Database cho Web/Desktop
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authService = AuthService();

  try {
    await dbHelper.database;
    await dbHelper.seedData();
  } catch (e) {
    debugPrint("Lỗi Database: $e");
  }

  await PushNotificationService.init();
  runApp(MyApp(authService: authService, dbHelper: dbHelper));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  final DatabaseHelper dbHelper;

  const MyApp({super.key, required this.authService, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc()..add(LoadThemeEvent()),
        ), // Thêm dòng này
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authService)..add(AuthCheckRequested()),
        ),
        BlocProvider<MangaBloc>(
          create: (context) => MangaBloc(dbHelper)..add(LoadMangaEvent()),
        ),
        BlocProvider<CategoryBloc>(create: (context) => CategoryBloc(dbHelper)),
        BlocProvider<SearchBloc>(create: (context) => SearchBloc(dbHelper)),
        BlocProvider<FavoriteBloc>(create: (context) => FavoriteBloc(dbHelper)),
        BlocProvider<HistoryBloc>(create: (context) => HistoryBloc(dbHelper)),
        BlocProvider<UserBloc>(create: (context) => UserBloc(dbHelper)),
        BlocProvider<FontSizeCubit>(create: (context) => FontSizeCubit()),
        BlocProvider<FontFamilyCubit>(create: (context) => FontFamilyCubit()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, mode) {
          return BlocBuilder<FontSizeCubit, double>(
            builder: (context, fontScale) {
              return MaterialApp(
                title: 'DNU Manga App',
                debugShowCheckedModeBanner: false,
                themeMode: mode,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                builder: (context, child) {
                  // Áp dụng tỷ lệ cỡ chữ toàn cục
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaleFactor: fontScale),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
                initialRoute: '/',
                routes: {
                  '/': (context) => const AuthWrapper(),
                  '/home': (context) => const HomeScreen(),
                  '/login': (context) => const LoginScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const HomeScreen();
        }
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const LoginScreen();
      },
    );
  }
}
