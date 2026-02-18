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

  Future<String> getHash() async {
     Uri endPoint = Uri.parse('https://noticewatch.onrender.com/api/notifier/');

     Response response = await get(endPoint);

      String serverHash = response.body;

      return serverHash;
  }

  Future<void> writeHash(String hash) async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    await asyncPrefs.setString('hash', hash);
  }
}
