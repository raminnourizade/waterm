
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:waterm/pages/settings_page.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../widgets/app_logo.dart';
import '../widgets/home_card_button.dart';
import '../widgets/primary_button.dart';
import 'map_page.dart';
import 'login_page.dart';
import 'readings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> sendDataToServer() async {
    print("📡 در حال ارسال اطلاعات به سرور...");
    final url = Uri.parse('http://172.20.10.2:8000/readings/'); // آدرس سیستم شما
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': 'user123',
          'lat': 35.6892,
          'lon': 51.3890,
          'value': 22.5,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ اطلاعات با موفقیت ارسال شد');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ اطلاعات با موفقیت ارسال شد')),
        );
      } else {
        print('❌ خطا در ارسال: \${response.statusCode}');
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطا در ارسال اطلاعات')),
        );
      }
    } catch (e) {
      print('❌ خطای اتصال به سرور: \$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ خطا در اتصال به سرور')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.lightBlue, AppColors.primary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: AppConstants.padding),
                const AppLogo(),
                const SizedBox(height: 12),
                Text(
                  'سامانه جانمایی مشترکین',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  '',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: AppConstants.padding),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      children: [
                        HomeCardButton(
                          title: 'ثبت اطلاعات جدید',
                          icon: Icons.map,
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPage()));
                          },
                        ),
                        const SizedBox(height: 16),
                        HomeCardButton(
                          title:  'ارسال اطلاعات به سرور',
                          icon: Icons.add_circle_outline,
                          color: AppColors.accent,
                          onTap: () async {
                            await sendDataToServer();
                          },
                        ),
                        const SizedBox(height: 16),
                        HomeCardButton(
                          title: 'گزارش اطلاعات ثبت شده',
                          icon: Icons.history,
                          color: AppColors.accent,
                          textColor: AppColors.darkBlue,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingsPage()));
                          },
                        ),
                        const SizedBox(height: 16),
                        HomeCardButton(
                          title: 'تنظیمات',
                          icon: Icons.settings,
                          color: AppColors.darkBlue,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
