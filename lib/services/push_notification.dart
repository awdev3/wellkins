// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:wellkins/services/db_service.dart';

// import '../utils/console_util.dart';
// import 'helpers.dart';

// const AndroidNotificationChannel channel = AndroidNotificationChannel(
//   'high_importance_channel', // id
//   'High Importance Notifications', // title
//   description: 'This channel is used for important notifications.',
//   importance: Importance.high,
//   playSound: true,
// );

// final localNotiPlugin = FlutterLocalNotificationsPlugin();

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   logData(title: 'bg message arrived --> ', data: '${message.data}');
//   logData(
//     title: 'bg image --> ',
//     data: '${message.notification?.android?.imageUrl}',
//   );
// }

// class FirebasePushNotification {
//   //initialization
//   initialize(context) async {
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     await localNotiPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);

//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     getIosPermission();

//     // onSelectBackgroundNotification();

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       logData(title: 'fgnd message arrived --> ', data: '${message.data}');
//       RemoteNotification? notification = message.notification;
//       if (notification != null) {
//         final notiProvider = getNotiProvider(context);
//         notiProvider.addCount();
//         Map<String, dynamic> data = message.data;

//         String imgPath = '';
//         bool isImageNoti = false;
//         BigPictureStyleInformation? bigPictureStyleInformation;

//         final androidNoti = message.notification?.android;
//         final appleNoti = message.notification?.apple;
//         final imgUrl = androidNoti?.imageUrl ?? appleNoti?.imageUrl;

//         if (imgUrl != null) {
//           imgPath = await saveFile(imgUrl, 'bigPic.jpg');
//           final byteFile = await File(imgPath).readAsBytes();
//           isImageNoti = byteFile.isNotEmpty;
//           final base64File = base64Encode(byteFile);
//           final bigPic = ByteArrayAndroidBitmap.fromBase64String(base64File);
//           bigPictureStyleInformation = BigPictureStyleInformation(bigPic);
//           // largeIcon: ByteArrayAndroidBitmap.fromBase64String(base64Encode(response.bodyBytes),),
//         }
//         if (isImageNoti) {
//           localNotiPlugin.show(
//             notification.hashCode,
//             notification.title,
//             notification.body,
//             NotificationDetails(
//               android: AndroidNotificationDetails(
//                 channel.id,
//                 channel.name,
//                 channelDescription: channel.description,
//                 playSound: true,
//                 color: Colors.blue,
//                 icon: '@mipmap/ic_launcher',
//                 styleInformation: bigPictureStyleInformation,
//               ),
//               iOS: DarwinNotificationDetails(
//                 attachments: <DarwinNotificationAttachment>[
//                   DarwinNotificationAttachment(imgPath)
//                 ],
//               ),
//             ),
//             payload: jsonEncode(data),
//           );
//         } else {
//           localNotiPlugin.show(
//             notification.hashCode,
//             notification.title,
//             notification.body,
//             NotificationDetails(
//               android: AndroidNotificationDetails(
//                 channel.id,
//                 channel.name,
//                 channelDescription: channel.description,
//                 playSound: true,
//                 color: Colors.blue,
//                 icon: '@mipmap/ic_launcher',
//               ),
//               iOS: const DarwinNotificationDetails(),
//             ),
//             payload: jsonEncode(data),
//           );
//         }
//       }
//     });

//     const initSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const initSettingsDarwin = DarwinInitializationSettings(
//       requestSoundPermission: false,
//       requestBadgePermission: false,
//       requestAlertPermission: false,
//       // onDidReceiveLocalNotification: onDidReceiveLocalNotification
//     );

//     const initializationSettings = InitializationSettings(
//       android: initSettingsAndroid,
//       iOS: initSettingsDarwin,
//     );

//     localNotiPlugin.initialize(
//       initializationSettings,
//       // onDidReceiveNotificationResponse: onSelectForegroundNotification,
//     );
//   }

//   Future<void> getIosPermission() async {
//     NotificationSettings settings =
//         await FirebaseMessaging.instance.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//     printData(data: 'User granted permission: ${settings.authorizationStatus}');
//   }

//   Future<void> getToken(ctx) async {
//     final noti = getNotiProvider(ctx);
//     final isTknAquired = await DbService.getTokenStatus();
//     final tkn = await FirebaseMessaging.instance.getToken();
//     printData(data: 'device token/id:  $tkn');
//     if (!isTknAquired) {
//       final token = await FirebaseMessaging.instance.getToken();
//       noti.setDeviceId(deviceId: '$token', context: ctx);
//     }
//   }

//   Future<String> saveFile(String url, String fileName) async {
//     final directory = await getTemporaryDirectory();
//     final String filePath = '${directory.path}/$fileName';
//     final response = await get(Uri.parse(url));
//     final File file = File(filePath);
//     await file.writeAsBytes(response.bodyBytes);
//     return filePath;
//   }

//   // Future<void> onSelectBackgroundNotification() async {
//   //   // RemoteMessage? initialMessage =
//   //   //     await FirebaseMessaging.instance.getInitialMessage();
//   //   log('background Message has been opened');

//   //   // if (initialMessage != null) {
//   //   //   _handleMessage(initialMessage.data);
//   //   // }

//   //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//   //     printData(data: 'opened from onMessageOpenedApp event');
//   //     // RemoteNotification? notification = message.notification;
//   //     // if (notification != null) {
//   //     //   _handleMessage(message.data);
//   //     // }
//   //   });
//   // }

//   // Future<dynamic> onSelectForegroundNotification(
//   //     NotificationResponse notificationResponse) async {
//   //   var data = jsonDecode(notificationResponse.payload ?? '');
//   //   printData(data: 'data $data');
//   //   // _handleMessage(data);
//   // }

//   // Future<dynamic> onDidReceiveLocalNotification(
//   //     int id, String? title, String? body, payload) async {
//   //   // display a dialog with the notification details, tap ok to go to another page
//   //   var route = NavigationService.navigatorKey.currentState;
//   //   showDialog(
//   //     context: route!.context,
//   //     builder: (BuildContext context) => CupertinoAlertDialog(
//   //       title: Text(title!),
//   //       content: Text(body!),
//   //       actions: [
//   //         CupertinoDialogAction(
//   //           isDefaultAction: true,
//   //           child: const Text('Ok'),
//   //           onPressed: () async {
//   //             _handleMessage(payload);
//   //           },
//   //         )
//   //       ],
//   //     ),
//   //   );
//   // }

//   // void _handleMessage(Map<String, dynamic> data) {
//   //   if (data['deep'] != '') {
//   //     if (data['route'] == 'category') {
//   //       navigateToProductView(isCategory: true, data: data);
//   //     } else if (data['route'] == 'brand') {
//   //       navigateToProductView(isCategory: false, data: data);
//   //     } else if (data['route'] == 'product') {
//   //       navigateToProductDetails(data: data);
//   //     } else {
//   //       navigateToHome();
//   //     }
//   //   } else {
//   //     navigateToHome();
//   //   }
//   // }

//   // void navigateToProductView({
//   //   required bool isCategory,
//   //   required Map<String, dynamic> data,
//   // }) {
//   //   var route = NavigationService.navigatorKey.currentState;
//   //   route?.push(
//   //     FadeRoute(
//   //       page: ProductViewScreen(
//   //         id: data['deep'].toString().toInt,
//   //         category: isCategory,
//   //         title: data['label'] ?? AppConstants.shopNow.tr(),
//   //         count: 0,
//   //       ),
//   //     ),
//   //   );
//   // }

//   // void navigateToProductDetails({required Map<String, dynamic> data}) {
//   //   var route = NavigationService.navigatorKey.currentState;
//   //   route?.push(
//   //     FadeRoute(
//   //       page: ProductDetailsScreen(
//   //         id: data['deep'].toString().toInt,
//   //       ),
//   //     ),
//   //   );
//   // }

//   // void navigateToHome() {
//   //   var route = NavigationService.navigatorKey.currentState;
//   //   route?.pushAndRemoveUntil(
//   //     MaterialPageRoute(
//   //       builder: (_) => const BottomNavBar(
//   //         pageNum: 0,
//   //       ),
//   //     ),
//   //     (route) => false,
//   //   );
//   // }

//   // Future<void> downloadFile(String uri) async {
//   //   final url = Uri.parse(uri);
//   //   final request = http.Request('GET', url);
//   //   final response = await http.Client().send(request);
//   //   final totalBytes = response.contentLength ?? 0;
//   //   int receivedBytes = 0;

//   //   final Directory directory = await getApplicationDocumentsDirectory();
//   //   final File file = File('${directory.path}/file.zip');
//   //   final sink = file.openWrite();

//   //   response.stream.listen(
//   //     (data) {
//   //       receivedBytes += data.length;
//   //       final progress = (receivedBytes / totalBytes * 100).toInt();
//   //       showNotification(progress);
//   //       sink.add(data);
//   //     },
//   //     onDone: () async {
//   //       await sink.close();
//   //       showNotification(100);
//   //     },
//   //     onError: (error) {
//   //       print('Error downloading file: $error');
//   //     },
//   //     cancelOnError: true,
//   //   );
//   // }

//   // Future<void> showNotification(int progress) async {
//   //   AndroidNotificationDetails androidNotificationDetails =
//   //       AndroidNotificationDetails(
//   //     'download_channel',
//   //     'Download Progress',
//   //     channelDescription:
//   //         'This channel is used for download progress notifications',
//   //     importance: Importance.max,
//   //     priority: Priority.high,
//   //     showProgress: true,
//   //     maxProgress: 100,
//   //     progress: progress,
//   //   );

//   //   NotificationDetails notificationDetails =
//   //       NotificationDetails(android: androidNotificationDetails);

//   //   await localNotiPlugin.show(
//   //     0,
//   //     'Download Progress',
//   //     '$progress%',
//   //     notificationDetails,
//   //   );
//   // }
// }
