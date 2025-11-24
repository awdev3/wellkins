import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellkins/constants/strings.dart';
import 'package:wellkins/screens/authScrn/components/auth_widgets.dart';
import 'package:wellkins/screens/authScrn/components/sign_in.dart';
import 'package:wellkins/screens/authScrn/components/sign_up.dart';
import 'package:wellkins/utils/transitions_util.dart';
import 'package:wellkins/widgets/backgrounds.dart';

import '../../constants/paths.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/spacers.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        bgImage,
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              Center(
                child: Animate(
                  delay: const Duration(milliseconds: 50),
                  effects: const [
                    ShakeEffect(
                      duration: Duration(milliseconds: 700),
                    ),
                  ],
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
              DelayedDisplay(
                delay: const Duration(milliseconds: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AuthWidgets.button(
                      title: AppConstants.login,
                      context: context,
                      onTap: () {
                        Navigator.push(
                            context, FadeRoute(page: const LoginScreen()));
                      },
                    ),
                    Spacers.sb20(),
                    AuthWidgets.button(
                      title: AppConstants.signUp,
                      leftShade: false,
                      context: context,
                      onTap: () {
                        Navigator.push(
                            context, FadeRoute(page: const SignupScreen()));
                      },
                    ),
                    SizedBox(height: 70.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
