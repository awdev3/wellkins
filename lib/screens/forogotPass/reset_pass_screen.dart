import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/colors.dart';
import '../../constants/paths.dart';
import '../../constants/strings.dart';
import '../../services/helpers.dart';
import '../../utils/regx.dart';
import '../../utils/wellkins_icons.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/field_widget.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/loaders.dart';
import '../../widgets/spacers.dart';
import '../../widgets/text_widget.dart';
import '../../widgets/toasts.dart';
import '../authScrn/components/auth_widgets.dart';

class ResetPassScreen extends StatefulWidget {
  const ResetPassScreen({super.key});

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  bool obscureText1 = true;
  bool obscureText2 = true;

  final _formKey = GlobalKey<FormState>();

  // final passCntlr = TextEditingController(text: 'Test@123');
  // final cnfmPassCntlr = TextEditingController(text: 'Test@123');

  final passCntlr = TextEditingController();
  final cnfmPassCntlr = TextEditingController();

  Future<void> _trySubmitResetPassword() async {
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final pass = passCntlr.text.trim();
      final cnfmPass = cnfmPassCntlr.text.trim();
      final passMatches = (pass == cnfmPass);
      if (passMatches) {
        final authProvider = getAuthProvider(context);
        dismissInputFocus(context);
        authProvider.resetPassword(
          pass: pass,
          ctx: context,
        );
      } else {
        showToast(message: AppConstants.passMissmatch);
      }
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
                        child: buildNewPass(context),
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

  Widget buildNewPass(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 25.h),
        buildTitle(context),
        SizedBox(height: 50.h),
        buildPassField(context),
        SizedBox(height: 30.h),
        AuthWidgets.button(
          title: AppConstants.cntnue,
          context: context,
          onTap: () {
            _trySubmitResetPassword();
          },
        ),
        SizedBox(height: 30.h),
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
          text: AppConstants.resetPass,
          fontSize: 32,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget buildPassField(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: TextWidget(
              text: AppConstants.newPass,
              fontSize: 22,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacers.sb10(),
          const Center(
            child: TextWidget(
              text: AppConstants.newPassInfo,
              fontSize: 14,
              fontWeight: FontWeight.w300,
              textAlign: TextAlign.center,
              color: Color(0xff909090),
            ),
          ),
          Spacers.sb20(),
          const TextWidget(
            text: AppConstants.pass,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          Spacers.sb5(),
          CustomTextField(
            controller: passCntlr,
            errorText: AppConstants.passError,
            regErrorText: AppConstants.passRegError,
            regExpCondition: Regx.passwordRegExp,
            passField: true,
            obscureText: obscureText1,
            outlined: true,
            filled: true,
            fillColor: ColorsData.whiteColor,
            suffix: buildSuffixIcon(0),
          ),
          Spacers.sb15(),
          AuthWidgets.h1(AppConstants.cnfmPass),
          Spacers.sb5(),
          CustomTextField(
            controller: cnfmPassCntlr,
            errorText: AppConstants.cnfmPassError,
            regErrorText: AppConstants.passRegError,
            regExpCondition: Regx.passwordRegExp,
            passField: true,
            obscureText: obscureText2,
            outlined: true,
            filled: true,
            fillColor: ColorsData.whiteColor,
            suffix: buildSuffixIcon(1),
          ),
          scrollUp(context),
        ],
      ),
    );
  }

  Widget buildSuffixIcon(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (index == 0) {
            obscureText1 = !obscureText1;
          } else {
            obscureText2 = !obscureText2;
          }
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 0.w),
        child: Icon(
          (index == 0 && obscureText1) || (index == 1 && obscureText2)
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 18.sp,
          color: ColorsData.blueShade,
        ),
      ),
    );
  }
}
