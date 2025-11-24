import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wellkins/providers/auth_provider.dart';
import 'package:wellkins/providers/dash_provider.dart';
import 'package:wellkins/providers/user_provider.dart';
import 'package:wellkins/providers/woo_provider.dart';
import '../providers/inv_provider.dart';
import '../providers/noti_provider.dart';
import '../utils/console_util.dart';
import '../widgets/toasts.dart';

//
Widget scrollUp(BuildContext context) {
  return SizedBox(height: MediaQuery.of(context).viewInsets.bottom);
}

Future<void> delayedCallback(
  VoidCallback callback, {
  int milliseconds = 300,
}) async {
  await Future.delayed(Duration(milliseconds: milliseconds), () {
    callback();
  });
}

void executePostFrameCallback(VoidCallback callback) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    callback();
  });
}

void dismissInputFocus(BuildContext context) {
  FocusScope.of(context).unfocus();
}

Future<void> tryLaunchUrl({
  required String url,
  required String message,
  bool inline = false,
}) async {
  final Uri parsedUrl = Uri.parse(url);
  if (await canLaunchUrl(parsedUrl)) {
    try {
      await launchUrl(
        parsedUrl,
        mode: inline
            ? LaunchMode.inAppBrowserView
            : LaunchMode.externalApplication,
      );
    } catch (e) {
      printData(data: '$e');
    }
  } else {
    showToast(message: message);
  }
}

// Future<SharedPreferences> getSharedPreference() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs;
// }

//providers
AuthProvider getAuthProvider(context, {bool listen = false}) {
  return Provider.of<AuthProvider>(context, listen: listen);
}

UserProvider getUserProvider(context, {bool? listen = false}) {
  return Provider.of<UserProvider>(context, listen: listen!);
}

WooProvider getWooProvider(context, {bool listen = false}) {
  return Provider.of<WooProvider>(context, listen: listen);
}

DashProvider getDashProvider(context, {bool listen = false}) {
  return Provider.of<DashProvider>(context, listen: listen);
}

InvProvider getInvProvider(context, {bool listen = false}) {
  return Provider.of<InvProvider>(context, listen: listen);
}

NotiProvider getNotiProvider(context, {bool listen = false}) {
  return Provider.of<NotiProvider>(context, listen: listen);
}
