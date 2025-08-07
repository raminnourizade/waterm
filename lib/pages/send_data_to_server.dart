import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendDataToServer({
  required String userId,
  required double lat,
  required double lon,
  required double value,
}) async {
  final url = Uri.parse('http://172.20.10.2:8000/readings/');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'lat': lat,
        'lon': lon,
        'value': value,
      }),
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
