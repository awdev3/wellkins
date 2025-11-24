import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../screens/authScrn/auth_screen.dart';
import '../utils/console_util.dart';
import '../utils/transitions_util.dart';
import '../widgets/toasts.dart';
import 'helpers.dart';
import 'navigation_service.dart';

class SessionTimeout {
  static Timer? sessionTimer;

  static bool startUserSession(BuildContext ctx) {
    bool timeOut = false;

    final userProvider = getUserProvider(ctx);
    final user = userProvider.user;

    if (user!.tokenExpiry.isNotEmpty) {
      const int sessionMins = 0;
      final now = DateTime.now();
      const sessionDurtn = Duration(minutes: sessionMins);

      final tokenExpiry = user.tokenExpiry;
      printData(title: '----->', data: tokenExpiry);

      final tokenExp = DateTime.parse(tokenExpiry);
      printData(title: '----->', data: tokenExp);

      final timeUntilExp = tokenExp.difference(now);
      printData(title: '----->', data: timeUntilExp.inMinutes);

      if (timeUntilExp > sessionDurtn) {
        // for logged in user before expiry
        final duration = timeUntilExp - sessionDurtn;
        sessionTimer?.cancel(); // Cancel previous timer if exists
        sessionTimer = Timer(duration, () async {
          _sessionRouteClear();
          userProvider.deleteUserData();
          sessionTimer = null; // Reset sessionTimer after canceling
          timeOut = true;
          printData(title: '----->', data: "Session timedout now");
          showToast(message: AppConstants.sessionTimedOut);
        });
      } else {
        // for logged in user after expiry
        _sessionRouteClear();
        userProvider.deleteUserData();
        timeOut = true;
        printData(title: '----->', data: "Session timeout already");
        showToast(message: AppConstants.sessionTimedOut);
      }
    }
    return timeOut;
  }

  static void _sessionRouteClear() {
    final route = NavigationService.navigatorKey.currentState!;
    route.pushAndRemoveUntil(
      FadeRoute(page: const AuthScreen()),
      (route) => false,
    );
  }
}
