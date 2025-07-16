import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../widgets/custom_input_dialog.dart';

class MapPage extends StatefulWidget {
  final bool showDialogOnStart;
  const MapPage({super.key, this.showDialogOnStart = false});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  void initState() {
    super.initState();
    // نمایش فرم ثبت اطلاعات در شروع، در صورت نیاز
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showDialogOnStart) {
        showCustomInputDialog(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نقشه آب و فاضلاب'),
          centerTitle: true,
          backgroundColor: AppColors.primary,
        ),
        body: Stack(
          children: [
            // نقشه
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
            // دکمه ثبت اطلاعات
            Positioned(
              bottom: 32,
              right: 32,
              child: FloatingActionButton.extended(
                onPressed: () {
                  showCustomInputDialog(context);
                },
                label: const Text('ثبت اطلاعات'),
                icon: const Icon(Icons.add),
                backgroundColor: AppColors.primary,
                elevation: AppConstants.cardElevation,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
