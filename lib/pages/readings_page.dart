import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/reading_model.dart';
import '../config/app_colors.dart';

class ReadingsPage extends StatefulWidget {
  const ReadingsPage({super.key});

  @override
  State<ReadingsPage> createState() => _ReadingsPageState();
}

class _ReadingsPageState extends State<ReadingsPage> {
  List<ReadingModel> readings = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final box = await Hive.openBox<ReadingModel>('readings');
    setState(() {
      readings = box.values.toList();
      // مرتب‌سازی بر اساس زمان ایجاد
      readings.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    });
  }

  /// تولید رشته CSV از داده‌ها
  String _generateCsv() {
    final csvBuffer = StringBuffer();

    csvBuffer.writeln('id,subscriptionNumber,phone,description,lat,lng,createdAt');

    for (var r in readings) {
      final row = [
        r.id,
        r.subscriptionNumber.replaceAll(',', ' '),
        r.phone.replaceAll(',', ' '),
        r.description.replaceAll(',', ' '),
        r.lat.toString(),
        r.lng.toString(),
        r.createdAt.toIso8601String(),
      ].join(',');
      csvBuffer.writeln(row);
    }

    return csvBuffer.toString();
  }

  Future<bool> _checkPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (!status.isGranted) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return true;
    }
    return true;
  }

  Future<void> _saveCsvFile() async {
    if (readings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('هیچ داده‌ای برای خروجی CSV وجود ندارد')));
      return;
    }

    final hasPermission = await _checkPermission();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('دسترسی مورد نیاز داده نشد')));
      return;
    }

    try {
      final csvString = _generateCsv();

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
        String newPath = "";
        final paths = directory!.path.split("/");
        for (int i = 1; i < paths.length; i++) {
          String folder = paths[i];
          if (folder == "Android") break;
          newPath += "/$folder";
        }
        newPath += "/Download";
        directory = Directory(newPath);
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getTemporaryDirectory();
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final filePath = '${directory.path}/readings_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(filePath);

      await file.writeAsString(csvString);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فایل CSV در مسیر زیر ذخیره شد:\n$filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در ذخیره فایل: $e')),
      );
    }
  }

  void _goToMapPage() {
    if (readings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('برای نمایش نقشه، داده‌ای وجود ندارد')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadingsMapPage(readings: readings),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('اطلاعات ثبت شده'),
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'دانلود فایل CSV',
              onPressed: _saveCsvFile,
            ),
            IconButton(
              icon: const Icon(Icons.map),
              tooltip: 'نمایش روی نقشه',
              onPressed: _goToMapPage,
            ),
          ],
        ),
        body: readings.isEmpty
            ? const Center(child: Text('هیچ اطلاعاتی ثبت نشده است.'))
            : ListView.builder(
          itemCount: readings.length,
          itemBuilder: (context, index) {
            final r = readings[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text('اشتراک: ${r.subscriptionNumber}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('موبایل: ${r.phone}'),
                    Text('توضیح: ${r.description}'),
                    Text(
                        'مکان: (${r.lat.toStringAsFixed(4)}, ${r.lng.toStringAsFixed(4)})'),
                    Text('تاریخ: ${r.createdAt.toString().substring(0, 19)}'),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
      ),
    );
  }
}

class ReadingsMapPage extends StatelessWidget {
  final List<ReadingModel> readings;

  const ReadingsMapPage({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    // تولید Markers و مسیر Polyline بر اساس نقاط مرتب‌شده
    final markers = <Marker>{};
    final polylineCoordinates = <LatLng>[];

    for (int i = 0; i < readings.length; i++) {
      final r = readings[i];
      final position = LatLng(r.lat, r.lng);
      polylineCoordinates.add(position);

      markers.add(
        Marker(
          markerId: MarkerId(r.id.toString()),
          position: position,
          infoWindow: InfoWindow(
            title: 'اشتراک: ${r.subscriptionNumber}',
            snippet: 'تاریخ: ${r.createdAt.toString().substring(0, 19)}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0 ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: polylineCoordinates,
      color: Colors.blue,
      width: 5,
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('مسیر طی شده روی نقشه'),
          backgroundColor: AppColors.primary,
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: polylineCoordinates.isNotEmpty
                ? polylineCoordinates.first
                : const LatLng(0, 0),
            zoom: 14,
          ),
          markers: markers,
          polylines: {polyline},
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
        ),
      ),
    );
  }
}
