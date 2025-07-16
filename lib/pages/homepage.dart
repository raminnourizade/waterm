import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../widgets/app_logo.dart';
import '../widgets/home_card_button.dart';
import '../widgets/primary_button.dart';
import 'map_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                  'سامانه مدیریت آب و فاضلاب',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'خوش آمدید!',
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
                          title: 'مشاهده نقشه',
                          icon: Icons.map,
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPage()));
                          },
                        ),
                        const SizedBox(height: 16),
                        HomeCardButton(
                          title: 'ثبت اطلاعات جدید',
                          icon: Icons.add_circle_outline,
                          color: AppColors.accent,
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPage(showDialogOnStart: true)));
                          },
                        ),
                        const SizedBox(height: 16),
                        HomeCardButton(
                          title: 'مشاهده اطلاعات ثبت شده',
                          icon: Icons.history,
                          color: AppColors.lightBlue,
                          textColor: AppColors.darkBlue, // فقط این خط را اضافه کن
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('این بخش به زودی فعال می‌شود')),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        HomeCardButton(
                          title: 'تنظیمات',
                          icon: Icons.settings,
                          color: AppColors.darkBlue,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                // دکمه خروج
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'خروج از حساب',
                  icon: Icons.logout,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                    );
                  },
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
