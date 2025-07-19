import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool autoSync = true;
  bool takePhoto = true;
  double fontSize = 16.0;

  String fullName = 'رامین نوری زاده';
  String personnelId = '1125';
  String region = 'منطقه سه';

  late Box settingsBox;
  late Box userBox;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    settingsBox = await Hive.openBox('app_settings');
    userBox = await Hive.openBox('user_info');

    setState(() {
      autoSync = settingsBox.get('autoSync', defaultValue: true);
      takePhoto = settingsBox.get('takePhoto', defaultValue: true);
      fontSize = settingsBox.get('fontSize', defaultValue: 16.0);

      // fullName = userBox.get('fullName', defaultValue: 'نام ثبت نشده');
      // personnelId = userBox.get('personnelId', defaultValue: '---');
      // region = userBox.get('region', defaultValue: '---');
    });
  }

  void saveSetting(String key, dynamic value) {
    settingsBox.put(key, value);
  }

  void logout() {
    userBox.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("تنظیمات"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 👤 اطلاعات کاربر
          Card(
            color: Colors.blue.shade50,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.blue),
              title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("کد پرسنلی: $personnelId"),
                  Text("منطقه: $region"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ⚙️ تنظیمات همگام‌سازی
          const Text(
            "تنظیمات همگام‌سازی",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          SwitchListTile(
            title: const Text("ارسال خودکار اطلاعات هنگام اتصال به اینترنت"),
            value: autoSync,
            onChanged: (val) {
              setState(() => autoSync = val);
              saveSetting('autoSync', val);
            },
          ),
          ListTile(
            title: const Text("همگام‌سازی دستی با سرور"),
            trailing: const Icon(Icons.sync),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("در حال همگام‌سازی...")),
              );
            },
          ),
          const Divider(),

          // 📸 تنظیمات عکس‌برداری
          const Text(
            "تنظیمات عکس‌برداری",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          SwitchListTile(
            title: const Text("گرفتن عکس هنگام ثبت اشتراک"),
            value: takePhoto,
            onChanged: (val) {
              setState(() => takePhoto = val);
              saveSetting('takePhoto', val);
            },
          ),
          const Divider(),

          // 🔤 اندازه فونت
          const Text(
            "اندازه فونت",
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
          Slider(
            value: fontSize,
            min: 12,
            max: 22,
            divisions: 5,
            label: fontSize.toStringAsFixed(0),
            onChanged: (val) {
              setState(() => fontSize = val);
              saveSetting('fontSize', val);
            },
          ),
          const Divider(),

          // 🗃️ حذف داده
          ListTile(
            title: const Text("حذف اطلاعات همگام‌شده"),
            trailing: const Icon(Icons.delete),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("داده‌ها حذف شدند.")),
              );
            },
          ),

          // 🚪 خروج از حساب کاربری
          ListTile(
            title: const Text("خروج از حساب کاربری"),
            trailing: const Icon(Icons.logout),
            onTap: () => logout(),
          ),
        ],
      ),
    );
  }
}
