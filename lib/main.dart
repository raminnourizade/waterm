import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'config/app_theme.dart';
import 'models/reading_model.dart'; // حتماً مسیر فایل رو درست بنویس
import 'pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  //  ثبت Adapter برای مدل ReadingModel
  Hive.registerAdapter(ReadingModelAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'اپلیکیشن موقعیت‌یاب',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', ''),
      supportedLocales: const [Locale('fa', '')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: appTheme,
      home: const LoginPage(),
    );
  }
}
