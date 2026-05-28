class AppRelease {
  final int versionCode;
  final String versionName;
  final String apkUrl;
  final String changeLog;
  final bool forceUpdate;

  AppRelease({
    required this.versionCode,
    required this.versionName,
    required this.apkUrl,
    required this.changeLog,
    required this.forceUpdate, 
  });

  factory AppRelease.fromJson(Map<String, dynamic> json) {
    return AppRelease(versionCode: json["version_code"], versionName: json["version_name"], apkUrl: json["apk_url"], changeLog: json["changelog"] ?? "", forceUpdate: json["force_update"]?? false);
  }
}