import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellkins/widgets/spacers.dart';

import '../../constants/colors.dart';
import '../../constants/paths.dart';
import '../../constants/strings.dart';
import '../../services/helpers.dart';
import '../../utils/console_util.dart';
import '../../utils/regx.dart';
import '../../utils/wellkins_icons.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/field_widget.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/loaders.dart';
import '../../widgets/text_widget.dart';
import '../authScrn/components/auth_widgets.dart';

class ForgotPassScreen extends StatelessWidget {
  ForgotPassScreen({super.key});

  final _formKey = GlobalKey<FormState>();

  // final emailCntlr = TextEditingController(text: 'test@test.com');
  final emailCntlr = TextEditingController();

  void sumitButtonTap(BuildContext ctx) {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      final authProvider = getAuthProvider(ctx);
      final email = emailCntlr.text.trim();
      printData(data: email);
      dismissInputFocus(ctx);
      authProvider.sendOtp(email: email, ctx: ctx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
                          child: buildForgotPass(context),
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
      ],
    );
  }

  Widget _logo() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 150.h),
        child: Hero(
          tag: 'logo',
          child: ImageWidget(image: Paths.logo, height: 48.h, width: 183.w),
        ),
      ),
    );
  }

  Widget buildForgotPass(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 25.h),
        buildTitle(context),
        SizedBox(height: 50.h),
        buildEmailField(context),
        Spacers.sb30(),
        AuthWidgets.button(
          title: AppConstants.recvrPass,
          context: context,
          onTap: () => sumitButtonTap(context),
        ),
        Spacers.sb30(),
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
          icon: Icon(Wellkins.back, size: 20.sp),
        ),
        SizedBox(width: 20.w),
        const TextWidget(
          text: AppConstants.frgtPass,
          fontSize: 32,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget buildEmailField(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: TextWidget(
              text: AppConstants.emailHere,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          const Center(
            child: TextWidget(
              text: AppConstants.accountEmail,
              fontSize: 14,
              fontWeight: FontWeight.w300,
              textAlign: TextAlign.center,
              color: Color(0xff909090),
            ),
          ),
          SizedBox(height: 20.h),
          const TextWidget(
            text: AppConstants.email,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          SizedBox(height: 5.h),
          CustomTextField(
            controller: emailCntlr,
            errorText: AppConstants.emailError,
            regErrorText: AppConstants.emailRegError,
            regExpCondition: Regx.emailRegExp,
            outlined: true,
            filled: true,
            fillColor: ColorsData.whiteColor,
          ),
        ],
      ),
    );
  }
}
