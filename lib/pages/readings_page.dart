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
  List<ReadingModel> filteredReadings = [];

  DateTime? startDate;
  DateTime? endDate;
  String subscriptionFilter = '';
  LatLngBounds? mapBoundsFilter;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final box = await Hive.openBox<ReadingModel>('readings');
    setState(() {
      readings = box.values.toList();
      readings.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      filteredReadings = List.from(readings);
    });
  }

  void _applyFilters() {
    setState(() {
      filteredReadings = readings.where((r) {
        bool match = true;

        // فیلتر تاریخ
        if (startDate != null) {
          match &= r.createdAt.isAfter(startDate!) || r.createdAt.isAtSameMomentAs(startDate!);
        }
        if (endDate != null) {
          match &= r.createdAt.isBefore(endDate!) || r.createdAt.isAtSameMomentAs(endDate!);
        }

        // فیلتر شماره اشتراک
        if (subscriptionFilter.isNotEmpty) {
          match &= r.subscriptionNumber.contains(subscriptionFilter);
        }

        // فیلتر محدوده نقشه
        if (mapBoundsFilter != null) {
          match &= mapBoundsFilter!.contains(LatLng(r.lat, r.lng));
        }

        return match;
      }).toList();
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    DateTime initial = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
      _applyFilters();
    }
  }

  String _generateCsv() {
    final csvBuffer = StringBuffer();
    csvBuffer.writeln('id,subscriptionNumber,phone,description,lat,lng,altitude,accuracy,createdAt');

    for (var r in filteredReadings) {
      final row = [
        r.id,
        r.subscriptionNumber.replaceAll(',', ' '),
        r.phone.replaceAll(',', ' '),
        r.description.replaceAll(',', ' '),
        r.lat.toString(),
        r.lng.toString(),
        r.altitude?.toStringAsFixed(2) ?? '',
        r.accuracy?.toStringAsFixed(2) ?? '',
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
    if (filteredReadings.isEmpty) {
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
    if (filteredReadings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('برای نمایش نقشه، داده‌ای وجود ندارد')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadingsMapPage(
          readings: filteredReadings,
          onBoundsSelected: (bounds) {
            setState(() {
              mapBoundsFilter = bounds;
            });
            _applyFilters();
          },
        ),
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
        body: Column(
          children: [
            // بخش فیلترها
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(labelText: 'شماره اشتراک'),
                      onChanged: (val) {
                        subscriptionFilter = val;
                        _applyFilters();
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: () => _pickDate(isStart: true),
                  ),
                  IconButton(
                    icon: const Icon(Icons.date_range_outlined),
                    onPressed: () => _pickDate(isStart: false),
                  ),
                ],
              ),
            ),
            Expanded(
              child: filteredReadings.isEmpty
                  ? const Center(child: Text('هیچ اطلاعاتی ثبت نشده است.'))
                  : ListView.builder(
                itemCount: filteredReadings.length,
                itemBuilder: (context, index) {
                  final r = filteredReadings[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      title: Text('اشتراک: ${r.subscriptionNumber}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('موبایل: ${r.phone}'),
                          Text('توضیح: ${r.description}'),
                          Text('(${r.lat.toStringAsFixed(4)}, ${r.lng.toStringAsFixed(4)})'),
                          Text('ارتفاع: ${r.altitude?.toStringAsFixed(2) ?? "-"} متر'),
                          Text('دقت: ${r.accuracy?.toStringAsFixed(2) ?? "-"} متر'),
                          Text('تاریخ: ${r.createdAt.toString().substring(0, 19)}'),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReadingsMapPage extends StatefulWidget {
  final List<ReadingModel> readings;
  final Function(LatLngBounds)? onBoundsSelected;

  const ReadingsMapPage({super.key, required this.readings, this.onBoundsSelected});

  @override
  State<ReadingsMapPage> createState() => _ReadingsMapPageState();
}

class _ReadingsMapPageState extends State<ReadingsMapPage> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{};
    final polylineCoordinates = <LatLng>[];

    for (int i = 0; i < widget.readings.length; i++) {
      final r = widget.readings[i];
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
          title: const Text('مسیر روی نقشه'),
          backgroundColor: AppColors.primary,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'انتخاب محدوده فعلی',
              onPressed: () async {
                if (_controller != null) {
                  final bounds = await _controller!.getVisibleRegion();
                  widget.onBoundsSelected?.call(bounds);
                  Navigator.pop(context);
                }
              },
            )
          ],
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: polylineCoordinates.isNotEmpty
                ? polylineCoordinates.first
                : const LatLng(0, 0),
            zoom: 14,
          ),
          onMapCreated: (controller) => _controller = controller,
          markers: markers,
          polylines: {polyline},
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
        ),
      ),
    );
  }
}
