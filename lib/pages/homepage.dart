import 'package:flutter/material.dart';
import 'map_page.dart';
import 'login_page.dart'; // اضافه شد

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
              colors: [Color(0xFFB3E5FC), Color(0xFF0288D1)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Image.asset(
                  'assets/logo.png',
                  height: 80,
                ),
                const SizedBox(height: 12),
                const Text(
                  'سامانه مدیریت آب و فاضلاب',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF01579B),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'خوش آمدید!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      children: [
                        HomeCardButton(
                          title: 'مشاهده نقشه',
                          icon: Icons.map,
                          color: const Color(0xFF0288D1),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPage()));
                          },
                        ),
                        const SizedBox(height: 16),
                        HomeCardButton(
                          title: 'ثبت اطلاعات جدید',
                          icon: Icons.add_circle_outline,
                          color: const Color(0xFF039BE5),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const MapPage()));
                          },
                        ),
                        const SizedBox(height: 16),
                        HomeCardButton(
                          title: 'گزارش‌های ثبت‌شده',
                          icon: Icons.history,
                          color: const Color(0xFF4FC3F7),
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
                          color: const Color(0xFF01579B),
                          onTap: () {
                            // صفحه تنظیمات (در آینده)
                          },
                        ),
                        const SizedBox(height: 16),
                        // دکمه خروج
                        HomeCardButton(
                          title: 'خروج ',
                          icon: Icons.logout,
                          color: Colors.red.shade400,
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginPage()),
                                  (route) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// کد HomeCardButton بدون تغییر است.
class HomeCardButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const HomeCardButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      elevation: 8,
      color: color,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const Icon(Icons.chevron_left, color: Colors.white, size: 30),
            ],
          ),
        ),
      ),
    );
  }
}
