import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/colors.dart';
import '../../../constants/paths.dart';
import '../../../constants/strings.dart';
import '../../../models/auth_models.dart';
import '../../../services/helpers.dart';
import '../../../utils/regx.dart';
import '../../../utils/transitions_util.dart';
import '../../../widgets/backgrounds.dart';
import '../../../widgets/field_widget.dart';
import '../../../widgets/image_widget.dart';
import '../../../widgets/loaders.dart';
import '../../../widgets/spacers.dart';
import '../../../widgets/text_widget.dart';
import '../../../widgets/toasts.dart';
import './../components/sign_in.dart';
import 'auth_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool obscureText1 = true;
  bool obscureText2 = true;
  String selectedAmount = '\$0';
  String selectedState = 'NSW';

  final _formKey = GlobalKey<FormState>();

  // final fnameCntlr = TextEditingController(text: 'test');
  // final lnameCntlr = TextEditingController(text: 'last');
  // final emailCntlr = TextEditingController(text: 'test@test.com');
  // final phoneCntlr = TextEditingController(text: '87654321');
  // final stateCntlr = TextEditingController(text: 'Queensland');
  // final passCntlr = TextEditingController(text: 'Test@123');
  // final cnfmPassCntlr = TextEditingController(text: 'Test@123');

  final fnameCntlr = TextEditingController();
  final lnameCntlr = TextEditingController();
  final emailCntlr = TextEditingController();
  final phoneCntlr = TextEditingController();
  // final stateCntlr = TextEditingController();
  final passCntlr = TextEditingController();
  final cnfmPassCntlr = TextEditingController();

  Future<void> _trySubmitSignUpForm() async {
    dismissInputFocus(context);
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final passOk = passCntlr.text.trim() == cnfmPassCntlr.text.trim();
      if (passOk) {
        final authProvider = getAuthProvider(context);
        final name = '${fnameCntlr.text.trim()} ${lnameCntlr.text.trim()}';
        final userData = Register(
          registerData: RegisterData(
            fullName: name,
            email: emailCntlr.text.trim(),
            contactNo: phoneCntlr.text.trim(),
            state: selectedState,
            invAmount: selectedAmount,
            password: passCntlr.text.trim(),
          ),
        );
        authProvider.registerUser(userData: userData, ctx: context);
      } else {
        showToast(message: AppConstants.passMissmatch);
      }
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
                initialChildSize: 0.77,
                minChildSize: 0.77,
                maxChildSize: 0.92,
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
                          child: Column(
                            children: [
                              buildLoginView(context),
                              _signupSwapButtons(context),
                            ],
                          ),
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
        padding: EdgeInsets.symmetric(vertical: 100.h),
        child: Hero(
          tag: 'logo',
          child: ImageWidget(image: Paths.logo, height: 48.h, width: 183.w),
        ),
      ),
    );
  }

  Widget buildLoginView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacers.sb25(),
        const Center(
          child: TextWidget(
            text: AppConstants.signUp,
            fontSize: 48,
            fontWeight: FontWeight.w500,
          ),
        ),
        buildSignUpForm(context),
        Spacers.sb25(),
      ],
    );
  }

  Widget _signupSwapButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Spacers.sb20(),
        Center(
          child: AuthWidgets.button(
            title: AppConstants.signUp,
            context: context,
            onTap: _trySubmitSignUpForm,
          ),
        ),
        Spacers.sb25(),
        const Center(
          child: TextWidget(
            text: AppConstants.haveAcnt,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        switchToLogin(context),
        Spacers.sb20(),
      ],
    );
  }

  Widget switchToLogin(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            SlideTopRoute(page: const LoginScreen()),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: const TextWidget(
            text: AppConstants.login,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildSignUpForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacers.sb20(),
          AuthWidgets.h1(AppConstants.fname),
          Spacers.sb5(),
          CustomTextField(
            controller: fnameCntlr,
            errorText: AppConstants.nameError,
            regErrorText: AppConstants.nameRegError,
            regExpCondition: Regx.nameRegExp,
            outlined: true,
            filled: true,
            fillColor: ColorsData.whiteColor,
          ),
          Spacers.sb15(),
          AuthWidgets.h1(AppConstants.lname),
          Spacers.sb5(),
          CustomTextField(
            controller: lnameCntlr,
            errorText: AppConstants.nameError,
            regErrorText: AppConstants.nameRegError,
            regExpCondition: Regx.nameRegExp,
            outlined: true,
            filled: true,
            fillColor: ColorsData.whiteColor,
          ),
          Spacers.sb15(),
          AuthWidgets.h1(AppConstants.email),
          Spacers.sb5(),
          CustomTextField(
            controller: emailCntlr,
            errorText: AppConstants.emailError,
            regErrorText: AppConstants.emailRegError,
            regExpCondition: Regx.emailRegExp,
            outlined: true,
            filled: true,
            fillColor: ColorsData.whiteColor,
          ),
          Spacers.sb15(),
          AuthWidgets.h1(AppConstants.cntct),
          Spacers.sb5(),
          CustomTextField(
            controller: phoneCntlr,
            errorText: AppConstants.phoneError,
            regErrorText: AppConstants.phoneRegError,
            regExpCondition: Regx.nineDigitRegExp,
            digit: true,
            outlined: true,
            filled: true,
            fillColor: ColorsData.whiteColor,
            prefix: const TextWidget(
              text: '${AppConstants.phoneCode} ',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: ColorsData.blackColor,
            ),
          ),
          Spacers.sb15(),
          AuthWidgets.h1(AppConstants.state),
          Spacers.sb5(),
          // CustomTextField(
          //   controller: stateCntlr,
          //   errorText: AppConstants.stateError,
          //   regErrorText: AppConstants.stateRegError,
          //   regExpCondition: Regx.nameRegExp,
          //   outlined: true,
          //   filled: true,
          //   fillColor: ColorsData.whiteColor,
          // ),
          _stateDropDownField(),
          Spacers.sb15(),
          AuthWidgets.h1(AppConstants.investmentAmount),
          Spacers.sb5(),
          // CustomTextField(
          //   controller: invCntlr,
          //   errorText: AppConstants.invError,
          //   regErrorText: AppConstants.invRegError,
          //   regExpCondition: Regx.double2RegExp,
          //   outlined: true,
          //   filled: true,
          //   isDouble: true,
          //   maxLength: 20,
          //   fillColor: ColorsData.whiteColor,
          // ),
          _invDropDownField(),
          Spacers.sb15(),
          AuthWidgets.h1(AppConstants.pass),
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

  _stateDropDownField() {
    return CustomDropdownField(
      items: AuthWidgets.states,
      value: selectedState,
      onChanged: (String? value) {
        setState(() {
          selectedState = value!;
        });
      },
      icon: const Icon(Icons.keyboard_arrow_down_sharp, color: Colors.grey),
    );
  }

  _invDropDownField() {
    return CustomDropdownField(
      items: AuthWidgets.investmentRanges,
      value: selectedAmount,
      onChanged: (String? value) {
        setState(() {
          selectedAmount = value!;
        });
      },
      icon: const Icon(Icons.keyboard_arrow_down_sharp, color: Colors.grey),
    );
  }

  Widget buildPrefixIcon({required IconData icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Icon(icon, size: 18.sp),
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
      child: Icon(
        (index == 0 && obscureText1) || (index == 1 && obscureText2)
            ? Icons.visibility_off
            : Icons.visibility,
        size: 21.sp,
        color: ColorsData.blueShade,
      ),
    );
  }
}
