import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../bottomNav/bottom_nav_bar.dart';
import '../../constants/paths.dart';
// import '../../services/helpers.dart';
// import '../../services/session_timeout.dart';
// import '../../utils/transitions_util.dart';
import '../../utils/transitions_util.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/image_widget.dart';
import '../authScrns/auth_screen.dart';
// import '../authScrn/auth_screen.dart';
// import '../bottomNav/bottom_nav_bar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // checkUser();
    Future.delayed(const Duration(seconds: 2), _navToAuth);
  }

  // void checkUser() async {
  //   final userProvider = getUserProvider(context);
  //   executePostFrameCallback(() async {
  //     await userProvider.getUserData().whenComplete(() async {
  //       await delayedCallback(milliseconds: 950, () {
  //         if (userProvider.user!.id.isNotEmpty) {
  //           final timeOut = SessionTimeout.startUserSession(context);
  //           if (!timeOut) {
  //             _navToHome();
  //           }
  //         } else {
  //           _navToAuth();
  //         }
  //       });
  //     });
  //   });
  // }

  void _navToHome() => Navigator.pushAndRemoveUntil(
    context,
    FadeRoute(page: const BottomNavBar(pageNum: 0)),
    (route) => false,
  );

  void _navToAuth() =>
      Navigator.pushReplacement(context, FadeRoute(page: const AuthScreen()));

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        bgImage,
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: DelayedDisplay(
              slidingCurve: Curves.bounceOut,
              slidingBeginOffset: const Offset(0, -10),
              child: Hero(
                tag: 'logo',
                child: ImageWidget(
                  image: Paths.logo,
                  height: 56.h,
                  width: 216.w,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
