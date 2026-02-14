import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';

class NoticeService {
  Future<List<dynamic>> getData() async {
    Uri endPoint = Uri.parse('https://noticewatch.onrender.com/api/notices/');

    Response response = await get(endPoint);

    List<dynamic> data = jsonDecode(response.body);

    return data;
  }

  Future<void> writeData(List<dynamic> data) async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    await asyncPrefs.setString('notices', jsonEncode(data));
  }
}
