// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';

// import '../screens/mainScrns/force_update_screen.dart';
// import '../utils/console_util.dart';
// import '../widgets/custom_prompts.dart';

// class ForceUpdate {
//   static Future<void> checkForAppUpdate(context) async {
//     try {
//       int localVersion = Platform.isAndroid ? 17 : 20;
//       String doc = Platform.isAndroid ? 'android-version' : 'ios-version';
//       final ds = await FirebaseFirestore.instance
//           .collection('appUpdate')
//           .doc('001')
//           .get();
//       if (ds.exists && ds.data() != null) {
//         final int remoteAppVersion = ds.data()![doc];
//         if (localVersion < remoteAppVersion) {
//           printData(data: '---> update needed');
//           CustomPrompts.showAlert(
//             message: '',
//             ctx: context,
//             onConfirmTap: () {},
//             child: const ForceUpdateScreen(),
//           );
//         } else {
//           printData(data: '---> no update needed');
//         }
//       }
//     } catch (e) {
//       printData(data: 'Error checking for app update: $e', e: true);
//     }
//   }
// }
