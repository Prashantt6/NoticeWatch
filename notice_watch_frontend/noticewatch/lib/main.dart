import 'package:flutter/material.dart';
import 'package:noticewatch/pages/notifications_list_page.dart';
import 'package:noticewatch/pages/notice_page.dart';
import 'package:noticewatch/repository.dart';
import 'dart:async';
import 'package:noticewatch/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

// TODO : Add error handling
// TODO : Add local notifications
// TODO : Only update shared preferences ( notices ) is the server sends new data

@pragma('vm:entry-point')
void callBackDispatcher() async{
  Workmanager().executeTask((task, inputData) async {
    
   await pollServer();
   print('Ran dispatcher');
    return Future.value(true);
  });
}

Map<String, WidgetBuilder> routes = {
  '/notice': (context) {
    return NoticePage();
  },
};
final service = NoticeService();

Future<void> pollServer() async {
  final hash = await service.getHash();
  
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  final rawHash = await asyncPrefs.getString('hash');

  if(hash.trim().isEmpty)
  {
    print('Error fetching data from server');
  }
  else if(hash==rawHash)
  {
    print('No new data');
  }
  else {

    final data = await service.getData();
    await service.writeData(data);

    await service.writeHash(hash);

    NotificationService().showNotification(title: 'New Notice', body: 'A new notice has been published.');
    
  }

}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  

  NotificationService().initNotification();

  await pollServer();

  await Workmanager().initialize(
    callBackDispatcher,
    isInDebugMode: false,
  );

  Workmanager().registerPeriodicTask('pollServer', 'pollServer', frequency: Duration(minutes: 15),constraints: Constraints(networkType: NetworkType.connected));

  runApp(MaterialApp(routes: routes, home: NotificationPage()));
}
