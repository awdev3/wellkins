import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../constants/colors.dart';
import '../../../constants/paths.dart';
import '../../../constants/strings.dart';
import '../../../models/woo_models.dart';
import '../../../services/helpers.dart';
import '../../../utils/console_util.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/backgrounds.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/loaders.dart';
import '../../../widgets/text_widget.dart';

class ApplicationForm extends StatefulWidget {
  final int propId;
  final String propName;
  final int fundSubType;
  const ApplicationForm({
    super.key,
    required this.propId,
    required this.propName,
    required this.fundSubType,
  });

  @override
  State<ApplicationForm> createState() => _ApplicationFormState();
}

class _ApplicationFormState extends State<ApplicationForm> {
  bool _pageLoaded = false;
  late final WebViewController _controller;

  @override
  void initState() {
    setWebViewParams();
    super.initState();
  }

  setWebViewParams() {
    if (mounted) {
      final rng = math.Random();
      final ver = 'v=${rng.nextInt(100)}';
      String data = getMiscData();
      final aplcnUrl = '${Paths.website}?$data&$ver';
      final uri = Uri.parse(aplcnUrl);
      printData(data: '$uri');
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(ColorsData.whiteColor)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (cUrl) => onPaymentCompleted(url: cUrl),
            // onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(uri);

      // const a = """  "http://localhost:4200/client/client-form
      // ?id=117
      // &client_type=2
      // &token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3MTY3OTk4MjIsImV4cCI6MTcxNjg4NjIyMn0.9kAjCuMDhPAhiCaymvUyIs9nyN4ZLOnQ5W5d4FqlpYI
      // &email=jack@wellkins.com.au
      // &name=Jack Chembirika
      // &contact=0433104517
      // &type=2
      // &img=scaled_2b1b40d7-766a-49ff-81f5-664172a186b7-1_all_168319.jpg
      // &cid=458879""";
    }
  }

  String getMiscData() {
    final userProvider = getUserProvider(context);
    final user = userProvider.user!;
    final uData = applcnDataToJson(
      ApplcnData(
        id: user.id.toInt,
        clientType: user.type.toInt,
        token: user.accessToken,
        email: user.email,
        name: '${user.firstName} ${user.lastName}',
        contact: user.contactNo,
        type: user.type.toInt,
        img: user.image,
        clientId: user.clientId.toInt,
        propId: widget.propId,
        propName: widget.propName,
        fundSubType: widget.fundSubType,
      ),
    );
    printData(data: uData);
    final enData = utf8.fuse(base64).encode(uData);
    final data = 'misc=$enData';
    return data;
  }

  onPaymentCompleted({required String url}) {
    setState(() => _pageLoaded = true);

    if (url.contains("success=1")) {
      log("Order success");
    } else if (url.contains("cancel=0") || url.contains("cancel=1")) {
      log("Order cancelled from admin or gateway");
    }

    log('Page finished loading: $url');
  }

  //onPageError() {
  //showToast(message: AppConstants.someThingWentWrong.tr());
  // Navigator.pushAndRemoveUntil(context,
  //     FadeRoute(page: const BottomNavBar(pageNum: 0)), (route) => false);
  //}

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          bgImage,
          Scaffold(
            backgroundColor: ColorsData.trColor,
            appBar: CustomAppBar.appbar(
              ctx: context,
              showLeading: false,
              hasBack: true,
            ),
            body: Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
              padding: EdgeInsets.fromLTRB(4.w, 10.w, 4.w, 0),
              decoration: commonDecor,
              child: _pageLoaded ? _buildApplicationForm() : showLoader(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationForm() {
    final rd = Radius.circular(40.r);
    return DelayedDisplay(
      child: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: rd, topRight: rd),
        child: WebViewWidget(controller: _controller),
      ),
    );
  }

  Future<dynamic> showCancelAlert() {
    return showDialog(
      context: context,
      builder: (itembuilder) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.circular(20),
          ),
          title: const TextWidget(
            text: 'AppConstants.appTitle.tr().toUpperCase()',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: ColorsData.primaryColor,
          ),
          content: const TextWidget(
            text: 'AppConstants.doYouWantToCancelPayment.tr()',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: ColorsData.blackColor,
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: const TextWidget(
                text: AppConstants.yes,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorsData.primaryColor,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const TextWidget(
                text: AppConstants.no,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ColorsData.blackColor,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}




// import 'dart:convert';
// import 'dart:developer';
// import 'dart:math' as math;

// import 'package:delayed_display/delayed_display.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// import '../../../constants/colors.dart';
// import '../../../constants/paths.dart';
// import '../../../constants/strings.dart';
// import '../../../models/woo_models.dart';
// import '../../../services/helpers.dart';
// import '../../../utils/console_util.dart';
// import '../../../utils/extensions.dart';
// import '../../../widgets/backgrounds.dart';
// import '../../../widgets/custom_appbar.dart';
// import '../../../widgets/loaders.dart';
// import '../../../widgets/text_widget.dart';
// import 'package:encrypt/encrypt.dart' as encrypt;

// class ApplicationForm extends StatefulWidget {
//   final int fundType;
//   const ApplicationForm({super.key, required this.fundType});

//   @override
//   State<ApplicationForm> createState() => _ApplicationFormState();
// }

// class _ApplicationFormState extends State<ApplicationForm> {
//   bool _pageLoaded = false;
//   late final WebViewController _controller;

//   @override
//   void initState() {
//     setWebViewParams();
//     super.initState();
//   }

//   Future<void> setWebViewParams() async {
//     if (mounted) {
//       final rng = math.Random();
//       final ver = 'v=${rng.nextInt(100)}';
//       String data = await getMiscData();
//       final aplcnUrl = '${Paths.website}?$data&$ver';
//       final uri = Uri.parse(aplcnUrl);
//       logData(data: '$uri');
//       _controller = WebViewController()
//         ..setJavaScriptMode(JavaScriptMode.unrestricted)
//         ..setBackgroundColor(ColorsData.whiteColor)
//         ..setNavigationDelegate(
//           NavigationDelegate(
//             onPageFinished: (cUrl) => onPaymentCompleted(url: cUrl),
//             // onWebResourceError: (WebResourceError error) {},
//             // onNavigationRequest: (NavigationRequest request) {
//             //   return NavigationDecision.navigate;
//             // },
//           ),
//         )
//         ..loadRequest(uri);

//       // const a = """  "http://localhost:4200/client/client-form
//       // ?id=117
//       // &client_type=2
//       // &token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3MTY3OTk4MjIsImV4cCI6MTcxNjg4NjIyMn0.9kAjCuMDhPAhiCaymvUyIs9nyN4ZLOnQ5W5d4FqlpYI
//       // &email=jack@wellkins.com.au
//       // &name=Jack Chembirika
//       // &contact=0433104517
//       // &type=2
//       // &img=scaled_2b1b40d7-766a-49ff-81f5-664172a186b7-1_all_168319.jpg
//       // &cid=458879""";
//     }
//   }

//   Future<String> getMiscData() async {
//     final userProvider = getUserProvider(context);
//     final user = userProvider.user!;
//     final uData = applcnDataToJson(
//       ApplcnData(
//         id: user.id.toInt,
//         clientType: user.type.toInt,
//         // token: user.accessToken,
//         // email: user.email,
//         // name: '${user.firstName} ${user.lastName}',
//         // contact: user.contactNo,
//         // type: user.type.toInt,
//         // img: user.image,
//         // clientId: user.clientId.toInt,
//         // fundType: widget.fundType,
//       ),
//     );
//     printData(title: '--->uData\n', data: uData);
//     const input =
//         'id=1&clientType=2&token=Makethenextbirthdayyoucelebrateaspecialone&jasijsabdsaijhdbabdjiad&1234512463142653nskajddhj';
//     final uData2 = utf8.fuse(base64).encode(input);
//     final encrytedData = await encryptAndSendToServer(uData2);
//     final data = 'misc=$encrytedData';
//     // final enData = utf8.fuse(base64).encode(uData);
//     // final enData = utf8.fuse(base64).encode(encrytedData);
//     // final data = 'misc=$enData';

//     return data;
//   }

//   Future<String> encryptAndSendToServer(String plaintext) async {
//     String encryptedBase64 = '';
//     try {
//       // final iv2 = encrypt.IV.fromLength(16); //Generate IV
//       // printData(data: iv2.bytes);
//       final key = encrypt.Key.fromUtf8('46be0927a4f86577f17ce6d10bc6aa61');
//       final iv = encrypt.IV.fromBase16('a0b1c2d3e4f5060708090a0b0c0d0e0f');
//       printData(data: iv.bytes);
//       // Create an AES encrypter with the key and IV
//       final encrypter = encrypt.Encrypter(encrypt.AES(
//         key,
//         mode: encrypt.AESMode.cbc,
//         padding: null,
//       ));

//       // Encrypt the plaintext
//       final encrypted = encrypter.encrypt(plaintext, iv: iv);
//       // Convert the encrypted bytes to a base64-encoded string
//       // encryptedBase64 = base64.encode(encrypted.bytes);
//       encryptedBase64 = encrypted.base64;
//       final c = encrypt.Encrypted.from64(encryptedBase64);

//       printData(data: encryptedBase64);
//       printData(
//           title: '-------> decrypted\n', data: encrypter.decrypt(c, iv: iv));
//     } catch (e, st) {
//       printData(data: '$e,$st', e: true);
//     }

//     return encryptedBase64;
//   }

//   onPaymentCompleted({required String url}) {
//     setState(() => _pageLoaded = true);

//     if (url.contains("success=1")) {
//       log("Order success");
//     } else if (url.contains("cancel=0") || url.contains("cancel=1")) {
//       log("Order cancelled from admin or gateway");
//     }

//     log('Page finished loading: $url');
//   }

//   //onPageError() {
//   //showToast(message: AppConstants.someThingWentWrong.tr());
//   // Navigator.pushAndRemoveUntil(context,
//   //     FadeRoute(page: const BottomNavBar(pageNum: 0)), (route) => false);
//   //}

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       child: Stack(
//         children: [
//           bgImage,
//           Scaffold(
//             backgroundColor: ColorsData.trColor,
//             appBar: CustomAppBar.appbar(
//               ctx: context,
//               showLeading: false,
//               hasBack: true,
//             ),
//             body: Container(
//               width: double.infinity,
//               margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
//               padding: EdgeInsets.fromLTRB(4.w, 10.w, 4.w, 0),
//               decoration: commonDecor,
//               child: _pageLoaded ? _buildApplicationForm() : showLoader(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildApplicationForm() {
//     final rd = Radius.circular(40.r);
//     return DelayedDisplay(
//       child: ClipRRect(
//         borderRadius: BorderRadius.only(topLeft: rd, topRight: rd),
//         child: WebViewWidget(controller: _controller),
//       ),
//     );
//   }

//   Future<dynamic> showCancelAlert() {
//     return showDialog(
//         context: context,
//         builder: (itembuilder) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadiusDirectional.circular(20),
//             ),
//             title: const TextWidget(
//               text: 'AppConstants.appTitle.tr().toUpperCase()',
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//               color: ColorsData.primaryColor,
//             ),
//             content: const TextWidget(
//               text: 'AppConstants.doYouWantToCancelPayment.tr()',
//               fontSize: 15,
//               fontWeight: FontWeight.w500,
//               color: ColorsData.blackColor,
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () {},
//                 child: const TextWidget(
//                   text: AppConstants.yes,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: ColorsData.primaryColor,
//                 ),
//               ),
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: const TextWidget(
//                   text: AppConstants.no,
//                   fontSize: 12,
//                   fontWeight: FontWeight.bold,
//                   color: ColorsData.blackColor,
//                 ),
//               )
//             ],
//           );
//         });
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }
// }



// Future<String> getMiscData() async {
//     final userProvider = getUserProvider(context);
//     final user = userProvider.user!;
//     final uData = applcnDataToJson(
//       ApplcnData(
//         id: user.id.toInt,
//         clientType: user.type.toInt,
//         token: user.accessToken,
//         email: user.email,
//         name: '${user.firstName} ${user.lastName}',
//         contact: user.contactNo,
//         type: user.type.toInt,
//         img: user.image,
//         clientId: user.clientId.toInt,
//         fundType: widget.fundType,
//       ),
//     );
//     printData(title: '--->uData\n', data: uData);
//     final enData64 = utf8.fuse(base64).encode(uData);
//     // final uData2 = base64Encode(utf8.encode(uData));

//     final encrytedData = await encryptAndSendToServer(enData64);
//     final data = 'misc=$encrytedData';
//     // final enData = utf8.fuse(base64).encode(uData);
//     // final data = 'misc=$enData';

//     return data;
//   }

//   Future<String> encryptAndSendToServer(String plaintext) async {
//     String encryptedBase64 = '';
//     try {
//       // final iv2 = encrypt.IV.fromLength(16); //Generate IV
//       // printData(data: iv2.bytes);
//       final key = encrypt.Key.fromUtf8('46be0927a4f86577f17ce6d10bc6aa61');
//       final iv = encrypt.IV.fromBase16('a0b1c2d3e4f5060708090a0b0c0d0e0f');

//       // Create an AES encrypter with the key and IV
//       final encrypter = encrypt.Encrypter(encrypt.AES(
//         key,
//         mode: encrypt.AESMode.cbc,
//       ));

//       // Encrypt the plaintext
//       final encrypted = encrypter.encrypt(plaintext, iv: iv);
//       // Convert the encrypted bytes to a base64-encoded string
//       // encryptedBase64 = base64.encode(encrypted.bytes);
//       encryptedBase64 = encrypted.base64;
//       final c = encrypt.Encrypted.from64(encryptedBase64);

//       printData(title: '-------> encryptedBase64\n', data: encryptedBase64);
//       final decrypted = encrypter.decrypt(c, iv: iv);
//       printData(title: '-------> decrypted\n', data: decrypted);
//       final enData = utf8.fuse(base64).decode(decrypted);
//       // final enData = utf8.decode(base64Decode(decrypted));
//       printData(title: '-------> decrypted2\n', data: enData);
//     } catch (e, st) {
//       printData(data: '$e,$st', e: true);
//     }

//     return encryptedBase64;
//   }