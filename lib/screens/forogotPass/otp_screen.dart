import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/paths.dart';
import '../../constants/strings.dart';
import '../../providers/auth_provider.dart';
import '../../services/helpers.dart';
import '../../utils/wellkins_icons.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/loaders.dart';
import '../../widgets/text_widget.dart';
import '../../widgets/toasts.dart';
import '../authScrn/components/auth_widgets.dart';
import 'components/otp_form.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key});

  void verifyOtp(BuildContext ctx) {
    final authProvider = getAuthProvider(ctx);
    final code = authProvider.otpCode;

    if (code.isNotEmpty) {
      dismissInputFocus(ctx);
      authProvider.verifyOtp(ctx);
    } else {
      showToast(message: AppConstants.enterOtp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      bgImage,
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          alignment: Alignment.center,
          children: [
            _logo(),
            DraggableScrollableSheet(
              initialChildSize: (0.6),
              minChildSize: (0.6),
              maxChildSize: 0.9,
              builder: (context, scrollController) {
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  decoration: decorAuth,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(110.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 26.w),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: buildEmailVerification(context),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      authLoader(context),
    ]);
  }

  Widget _logo() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 150.h),
        child: Hero(
          tag: 'logo',
          child: ImageWidget(
            image: Paths.logo,
            height: 48.h,
            width: 183.w,
          ),
        ),
      ),
    );
  }

  Widget buildEmailVerification(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 25.h),
        buildTitle(context),
        SizedBox(height: 50.h),
        buildOtpField(context),
        SizedBox(height: 20.h),
        Selector<AuthProvider, String>(
          selector: (context, provider) => provider.otpCode,
          builder: (context, code, child) {
            return Opacity(
              opacity: code.length < 6 ? .3 : 1,
              child: AbsorbPointer(
                absorbing: code.length < 6,
                child: AuthWidgets.button(
                  title: AppConstants.verify,
                  context: context,
                  onTap: () => verifyOtp(context),
                ),
              ),
            );
          },
        ),
        SizedBox(height: 100.h),
      ],
    );
  }

  Widget buildTitle(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Wellkins.back,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 20.w),
        const TextWidget(
          text: AppConstants.emailVerfn,
          fontSize: 32,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget buildOtpField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const TextWidget(
          text: AppConstants.getOtp,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 10.h),
        const TextWidget(
          text: AppConstants.enterOtp,
          fontSize: 14,
          fontWeight: FontWeight.w300,
          textAlign: TextAlign.center,
          color: Color(0xff909090),
        ),
        SizedBox(height: 20.h),
        const OtpForm(),
        SizedBox(height: 10.h),
      ],
    );
  }
}
