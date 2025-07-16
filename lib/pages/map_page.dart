import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'homepage.dart';
import 'login_page.dart';
import '../widgets/custom_input_dialog.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نقشه'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'خروج',
            onPressed: () => _logout(context),
          ),
        ),
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                center: LatLng(38.0816, 46.2919), // مرکز تبریز
                zoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.waterm',
                ),
              ],
            ),
            Positioned(
              bottom: 32,
              right: 32,
              child: FloatingActionButton.extended(
                onPressed: () {
                  showCustomInputDialog(context);

                  // توابع یا دیالوگ ثبت اطلاعات اینجا صدا زده می‌شود
                },
                label: const Text('ثبت اطلاعات'),
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
