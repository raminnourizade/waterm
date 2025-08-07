import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:hive/hive.dart';
import '../config/app_colors.dart';
import '../models/reading_model.dart';

class MapPage extends StatefulWidget {
  final bool showDialogOnStart;
  const MapPage({super.key, this.showDialogOnStart = false});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with AutomaticKeepAliveClientMixin {
  LatLng _mapStartLatLng = const LatLng(35.6892, 51.3890);
  GoogleMapController? mapController;
  LatLng? _currentLatLng;
  double? _altitude;
  double? _accuracy;
  Marker? _currentMarker;
  MapType _currentMapType = MapType.satellite;

  final Set<Marker> _allMarkers = {};
  bool _locationLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.showDialogOnStart) {
        _showFormDialog();
      }
    });
    _loadMapWithCache();
  }

  /// لود نقشه با استفاده از کش یک‌ساعته
  Future<void> _loadMapWithCache() async {
    final cacheBox = await Hive.openBox('mapCache');
    final lastCacheTime = cacheBox.get('lastCacheTime');
    final lastLat = cacheBox.get('lastLat');
    final lastLng = cacheBox.get('lastLng');
    final lastMarkers = cacheBox.get('lastMarkers');

    if (lastCacheTime != null &&
        DateTime.now().difference(lastCacheTime).inMinutes < 60 &&
        lastLat != null &&
        lastLng != null) {
      _mapStartLatLng = LatLng(lastLat, lastLng);
      if (lastMarkers != null) {
        for (var m in lastMarkers) {
          _allMarkers.add(Marker(
            markerId: MarkerId(m['id']),
            position: LatLng(m['lat'], m['lng']),
            icon: BitmapDescriptor.defaultMarkerWithHue(m['color']),
            infoWindow: InfoWindow(
              title: m['title'],
              snippet: m['snippet'],
            ),
          ));
        }
      }
      setState(() {});
      _determinePosition();
    } else {
      _initMapAndLocation();
    }
  }

  /// ذخیره وضعیت نقشه در کش
  Future<void> _saveMapCache() async {
    final cacheBox = await Hive.openBox('mapCache');
    final markerList = _allMarkers.map((m) {
      return {
        'id': m.markerId.value,
        'lat': m.position.latitude,
        'lng': m.position.longitude,
        'color': m.icon == BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue)
            ? BitmapDescriptor.hueBlue
            : BitmapDescriptor.hueRed,
        'title': m.infoWindow.title ?? '',
        'snippet': m.infoWindow.snippet ?? '',
      };
    }).toList();

    await cacheBox.put('lastCacheTime', DateTime.now());
    await cacheBox.put('lastLat', _mapStartLatLng.latitude);
    await cacheBox.put('lastLng', _mapStartLatLng.longitude);
    await cacheBox.put('lastMarkers', markerList);
  }

  Future<void> _initMapAndLocation() async {
    final box = await Hive.openBox<ReadingModel>('readings');
    if (box.isNotEmpty) {
      final last = box.values.last;
      _mapStartLatLng = LatLng(last.lat, last.lng);
      _currentLatLng = _mapStartLatLng;
    }
    await _loadPreviousMarkers();
    await _determinePosition();
    _saveMapCache();
  }

  Future<void> _determinePosition() async {
    if (_locationLoaded) return;
    _locationLoaded = true;

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      _currentLatLng = LatLng(position.latitude, position.longitude);
      _altitude = position.altitude;
      _accuracy = position.accuracy;

      _currentMarker = Marker(
        markerId: const MarkerId('current_location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: _currentLatLng!,
        draggable: true,
        onDragEnd: (newPos) {
          setState(() {
            _currentLatLng = newPos;
          });
        },
      );

      setState(() {
        _allMarkers.add(_currentMarker!);
      });

      if (mapController != null) {
        mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentLatLng!),
        );
      }
      _saveMapCache();
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> _loadPreviousMarkers() async {
    final box = await Hive.openBox<ReadingModel>('readings');
    for (var reading in box.values) {
      if (reading.lat != 0 && reading.lng != 0) {
        final marker = Marker(
          markerId: MarkerId(reading.id),
          position: LatLng(reading.lat, reading.lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: reading.subscriptionNumber,
            snippet: reading.description ?? '',
            onTap: () => _showEditDialog(reading),
          ),
        );
        _allMarkers.add(marker);
      }
    }
    setState(() {});
  }

  Future<void> _goToCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    LatLng target = LatLng(position.latitude, position.longitude);

    mapController?.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: target, zoom: 16),
    ));

    _currentLatLng = target;
    _currentMarker = Marker(
      markerId: const MarkerId('current_location'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      position: target,
      draggable: true,
      onDragEnd: (newPos) {
        _currentLatLng = newPos;
      },
    );

    setState(() {
      _allMarkers.removeWhere((m) => m.markerId.value == 'current_location');
      _allMarkers.add(_currentMarker!);
    });
    _saveMapCache();
  }

  /// فرم ثبت اطلاعات
  Future<void> _showFormDialog() async {
    final subscriptionController = TextEditingController();
    final phoneController = TextEditingController();
    final descController = TextEditingController();
    XFile? image;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ثبت اطلاعات مشترک'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subscriptionController,
                decoration: const InputDecoration(labelText: 'شماره اشتراک'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'شماره موبایل'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'توضیحات'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('افزودن تصویر (اختیاری)'),
                onPressed: () async {
                  final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    image = picked;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('لغو'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('ذخیره'),
            onPressed: () async {
              final id = const Uuid().v4();
              final path = image != null
                  ? '${(await getApplicationDocumentsDirectory()).path}/$id.jpg'
                  : null;
              if (image != null && path != null) {
                await File(image!.path).copy(path);
              }
              final box = await Hive.openBox<ReadingModel>('readings');
              final newReading = ReadingModel(
                id: id,
                subscriptionNumber: subscriptionController.text,
                phone: phoneController.text,
                description: descController.text,
                lat: _currentLatLng?.latitude ?? 0,
                lng: _currentLatLng?.longitude ?? 0,
                imagePath: path,
                createdAt: DateTime.now(),
              );
              await box.add(newReading);
              await _loadPreviousMarkers();
              _saveMapCache();
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  /// فرم ویرایش اطلاعات
  Future<void> _showEditDialog(ReadingModel reading) async {
    final subscriptionController = TextEditingController(text: reading.subscriptionNumber);
    final phoneController = TextEditingController(text: reading.phone);
    final descController = TextEditingController(text: reading.description ?? '');
    XFile? image;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ویرایش اطلاعات مشترک'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subscriptionController,
                decoration: const InputDecoration(labelText: 'شماره اشتراک'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'شماره موبایل'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'توضیحات'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('تغییر تصویر'),
                onPressed: () async {
                  final picked = await ImagePicker().pickImage(source: ImageSource.camera);
                  if (picked != null) {
                    image = picked;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('لغو'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('ذخیره تغییرات'),
            onPressed: () async {
              final box = await Hive.openBox<ReadingModel>('readings');
              final index = box.values.toList().indexWhere((r) => r.id == reading.id);
              if (index != -1) {
                String? path = reading.imagePath;
                if (image != null) {
                  path = '${(await getApplicationDocumentsDirectory()).path}/${reading.id}.jpg';
                  await File(image!.path).copy(path);
                }
                final updatedReading = ReadingModel(
                  id: reading.id,
                  subscriptionNumber: subscriptionController.text,
                  phone: phoneController.text,
                  description: descController.text,
                  lat: reading.lat,
                  lng: reading.lng,
                  imagePath: path,
                  createdAt: reading.createdAt,
                );
                await box.putAt(index, updatedReading);
                await _loadPreviousMarkers();
                _saveMapCache();
              }
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نقشه و ثبت مکان مشترک'),
          backgroundColor: AppColors.primary,
          centerTitle: true,
        ),
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _mapStartLatLng,
            zoom: 16,
          ),
          onMapCreated: (controller) {
            mapController = controller;
          },
          markers: _allMarkers,
          mapType: _currentMapType,
          onTap: (LatLng newLatLng) {
            _currentLatLng = newLatLng;
            _currentMarker = Marker(
              markerId: const MarkerId('current_location'),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
              position: newLatLng,
              draggable: true,
              onDragEnd: (newPos) {
                _currentLatLng = newPos;
              },
            );
            setState(() {
              _allMarkers.removeWhere((m) => m.markerId.value == 'current_location');
              _allMarkers.add(_currentMarker!);
            });
            _saveMapCache();
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _currentMapType = _currentMapType == MapType.satellite
                      ? MapType.normal
                      : MapType.satellite;
                });
                _saveMapCache();
              },
              backgroundColor: AppColors.primary,
              tooltip: 'تغییر نوع نمایش نقشه',
              child: const Icon(Icons.map),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              onPressed: _showFormDialog,
              backgroundColor: AppColors.primary,
              tooltip: 'ثبت اطلاعات مشترک',
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 12),
            FloatingActionButton(
              onPressed: _goToCurrentLocation,
              backgroundColor: AppColors.primary,
              tooltip: 'بازگشت به موقعیت من',
              child: const Icon(Icons.my_location),
            ),
          ],
        ),
      ),
    );
  }
}
