import 'package:flutter/material.dart';

import '../models/history_model.dart';
import '../models/noti_model.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import '../services/helpers.dart';
import '../utils/console_util.dart';
import '../utils/extensions.dart';

class NotiProvider extends ChangeNotifier {
  int unreadCount = 0;
  bool notiLoad = false;
  List<Noti> notiList = [];

  Future<void> setDeviceId({
    required String deviceId,
    required BuildContext context,
  }) async {
    try {
      final userProvider = getUserProvider(context);
      final tokenDetail = TokenDetail(
        clientId: userProvider.user!.id,
        userToken: deviceId,
      );
      final body = tokenDetailToJson(tokenDetail);
      printData(data: body);
      final data = await ApiService().postDataToApi(
        api: 'notification/addToken?',
        headers: userProvider.headers,
        payload: body,
      );

      if (data['message'] == 'created') {
        await DbService.setTokenAquired();
      }
    } catch (e) {
      printData(data: 'from setDeviceId: $e', e: true);
    }
  }

  void addCount() {
    unreadCount += 1;
    notifyListeners();
  }

  Future<void> getNotifications(BuildContext context) async {
    notiLoad = true;
    notiList.clear();
    try {
      final userProvider = getUserProvider(context);
      final userId = userProvider.user!.id.toInt;
      final clientData = NotiClientDetail(clientId: userId);
      final body = notiToJson(clientData);
      printData(data: body);
      final data = await ApiService().postDataToApi(
        api: 'notification/getNotification?',
        headers: userProvider.headers,
        payload: body,
      );

      if (data["message"] == "Success" && data['notifications'].isNotEmpty) {
        notiList = notiFromJson(data['notifications'], userId);
      }
    } catch (e) {
      printData(data: 'from getNotifications: $e', e: true);
      notiLoad = false;
    }
    notiLoad = false;
    notifyListeners();
  }

  // Future<void> setLatestDateAndTime() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   DateTime now = DateTime.now();
  //   String dateAndTime = DateFormat('yyyy-MM-dd_kk.mm.ss').format(now);
  //   prefs.setString('DateAndTime', dateAndTime);
  // }

  Future<void> getNotiUnreadCount(BuildContext context) async {
    try {
      final userProvider = getUserProvider(context);
      final id = userProvider.user!.id;
      final body = historyToJson(ClientDetail(clientId: id));

      final data = await ApiService().postDataToApi(
        api: 'notification/getCount?',
        headers: userProvider.headers,
        payload: body,
      );

      if (data['message'] == 'Success') {
        unreadCount = 0;
        unreadCount = '${data['count']}'.toInt;
        printData(data: unreadCount);
      }
    } catch (e) {
      printData(data: 'from getNotiUnreadCount $e', e: true);
    }
    notifyListeners();
  }

  Future<void> resetNotiCount(Noti noti, BuildContext context) async {
    if (!noti.isRead) {
      try {
        final userProvider = getUserProvider(context);
        final userId = userProvider.user!.id.toInt;
        final isSeen = [...noti.notificationSeen, userId];
        final resetCount = ResetCount(id: noti.id.toInt, isSeen: isSeen);
        final body = resetCountToJson([resetCount]);

        final data = await ApiService().postDataToApi(
          api: 'notification/resetCount?',
          headers: userProvider.headers,
          payload: body,
        );

        if (data['message'] == 'Notifications update successful') {
          unreadCount > 0 ? unreadCount -= 1 : 0;
          markAsRead(noti.id);
        }
      } catch (e) {
        printData(data: 'from resetNotiCount $e', e: true);
      }
      notifyListeners();
    }
  }

  void markAsRead(String notiId) {
    final index = notiList.indexWhere((e) => e.id == notiId);
    notiList[index].isRead = true;
  }
}
