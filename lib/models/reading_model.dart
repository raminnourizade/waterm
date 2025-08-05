import 'package:hive/hive.dart';
part 'reading_model.g.dart';

@HiveType(typeId: 0)
class ReadingModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subscriptionNumber;

  @HiveField(2)
  String phone;

  @HiveField(3)
  String description;

  @HiveField(4)
  double lat;

  @HiveField(5)
  double lng;

  @HiveField(6)
  String? imagePath; // مسیر عکس (قدیمی بوده و لازمه برگرده)

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  double? altitude; // ارتفاع

  @HiveField(9)
  double? accuracy; // دقت GPS

  ReadingModel({
    required this.id,
    required this.subscriptionNumber,
    required this.phone,
    required this.description,
    required this.lat,
    required this.lng,
    this.imagePath,
    required this.createdAt,
    this.altitude,
    this.accuracy,
  });
}
