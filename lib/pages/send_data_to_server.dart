import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendReadingToServer({
  required String userId,
  required String mainSubscription,
  String? subSubscription,
  required String address,
  required double lat,
  required double lng,
  double? altitude,
  double? accuracy,
  String? imagePath,
  required DateTime createdAt,
}) async {
  final url = Uri.parse('http://172.20.10.2:8000/readings/');

  try {
    final payload = {
      'user_id': userId,
      'main_subscription': mainSubscription,
      'sub_subscription': subSubscription ?? '',
      'address': address,
      'lat': lat,
      'lng': lng,
      'altitude': altitude,
      'accuracy': accuracy,
      'image_path': imagePath ?? '',
      'created_at': createdAt.toIso8601String(),
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200) {
      print('✅ اطلاعات با موفقیت ارسال شد.');
      print('پاسخ سرور: ${response.body}');
    } else {
      print('❌ ارسال با خطا مواجه شد. کد وضعیت: ${response.statusCode}');
      print('پاسخ سرور: ${response.body}');
    }
  } catch (e) {
    print('❌ خطا در اتصال به سرور: $e');
  }
}
