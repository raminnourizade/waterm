import 'package:hive/hive.dart';
part 'reading_model.g.dart';

@HiveType(typeId: 0)
class ReadingModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String mainSubscription; // اشتراک اصلی

  @HiveField(2)
  String? subSubscription; // اشتراک فرعی (اختیاری)

  @HiveField(3)
  String address; // آدرس

  @HiveField(4)
  double lat; // عرض جغرافیایی

  @HiveField(5)
  double lng; // طول جغرافیایی

  @HiveField(6)
  double? altitude; // ارتفاع

  @HiveField(7)
  double? accuracy; // دقت GPS

  @HiveField(8)
  String? imagePath; // مسیر عکس

  @HiveField(9)
  DateTime createdAt; // زمان ثبت


  ReadingModel({
    required this.id,
    required this.mainSubscription,
    this.subSubscription,
    required this.address,
    required this.lat,
    required this.lng,
    this.altitude,
    this.accuracy,
    this.imagePath,
    required this.createdAt,

  });
}
