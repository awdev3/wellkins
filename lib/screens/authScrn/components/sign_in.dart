import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/colors.dart';
import '../../../constants/paths.dart';
import '../../../constants/strings.dart';
import '../../../models/auth_models.dart';
import '../../../services/db_service.dart';
import '../../../services/helpers.dart';
import '../../../utils/regx.dart';
import '../../../utils/transitions_util.dart';
import '../../../widgets/backgrounds.dart';
import '../../../widgets/field_widget.dart';
import '../../../widgets/image_widget.dart';
import '../../../widgets/loaders.dart';
import '../../../widgets/spacers.dart';
import '../../../widgets/text_widget.dart';
import '../../forogotPass/forgot_pass_screen.dart';
import './../components/auth_widgets.dart';
import 'sign_up.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool obscureText = true;
  bool rememberMe = false;

  final _formKey = GlobalKey<FormState>();

  // final emailCntlr = TextEditingController(text: 'test2@test.com');
  // final passCntlr = TextEditingController(text: 'Test@123');
  final emailCntlr = TextEditingController();
  final passCntlr = TextEditingController();

  @override
  void initState() {
    super.initState();
    getRememberMe();
  }

  Future<void> _trySubmitSignInForm() async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      final authProvider = getAuthProvider(context);
      dismissInputFocus(context);

      final email = emailCntlr.text.trim();
      final pass = passCntlr.text.trim();
      final userData = Login(
        loginData: LoginData(userEmail: email, password: pass),
      );
      await authProvider.loginUser(userData: userData, ctx: context);
      await setRememberMe(email, pass);
    }
  }

  Future<void> setRememberMe(String email, String pass) async {
    await DbService.setRememberMe(
      email: email,
      password: pass,
      rememberMe: rememberMe,
    );
  }

  Future<void> getRememberMe() async {
    final rData = await DbService.getRememberMe();
    if (rData.rememberMe) {
      setState(() {
        emailCntlr.text = rData.rEmail;
        passCntlr.text = rData.rPassword;
        rememberMe = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        bgImage,
        Scaffold(
          backgroundColor: Colors.transparent,
          // resizeToAvoidBottomInset: false,
          body: Stack(
            alignment: Alignment.center,
            children: [
              _logo(),
              DraggableScrollableSheet(
                initialChildSize: (0.7),
                minChildSize: (0.7),
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
                          child: Column(
                            children: [
                              buildLoginView(context),
                              loginSwapButtons(context),
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
        padding: EdgeInsets.symmetric(vertical: 150.h),
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
            text: AppConstants.login,
            fontSize: 48,
            fontWeight: FontWeight.w500,
          ),
        ),
        buildLoginForm(context),
      ],
    );
  }

  Widget loginSwapButtons(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Spacers.sb25(),
          Center(
            child: AuthWidgets.button(
              title: AppConstants.login,
              context: context,
              onTap: _trySubmitSignInForm,
            ),
          ),
          Spacers.sb25(),
          const Center(
            child: TextWidget(
              text: AppConstants.dontHaveAcnt,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ),
          switchToSignUp(context),
          Spacers.sb25(),
        ],
      ),
    );
  }

  Widget switchToSignUp(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            SlideTopRoute(page: const SignupScreen()),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: const TextWidget(
            text: AppConstants.signUp,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildLoginForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacers.sb20(),
          const TextWidget(
            text: AppConstants.email,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
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
            obscureText: obscureText,
            outlined: true,
            filled: true,
            fillColor: ColorsData.whiteColor,
            suffixIcon: buildSuffixIcon(),
          ),
          Spacers.sb5(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [buildRememberMe(), buildforgotPass()],
          ),
          // scrollUp(context),
        ],
      ),
    );
  }

  Widget buildRememberMe() {
    return TextButton.icon(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        foregroundColor: ColorsData.formHintColor,
      ),
      onPressed: () {
        setState(() {
          rememberMe = !rememberMe;
        });
      },
      icon: Icon(
        rememberMe
            ? Icons.check_box_rounded
            : Icons.check_box_outline_blank_rounded,
        size: 20.sp,
        color: rememberMe ? ColorsData.blueShade : ColorsData.greyColor,
      ),
      label: const TextWidget(
        text: AppConstants.rememberMe,
        color: Color(0xff7B7B7B),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget buildforgotPass() {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          SlideLeftRoute(page: ForgotPassScreen()),
        );
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        foregroundColor: ColorsData.formHintColor,
      ),
      child: const TextWidget(
        text: AppConstants.frgtPass,
        color: Color(0xff7B7B7B),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget buildSuffixIcon() {
    return GestureDetector(
      onTap: () {
        setState(() {
          obscureText = !obscureText;
        });
      },
      child: Icon(
        obscureText ? Icons.visibility_off : Icons.visibility,
        size: 21.sp,
        color: ColorsData.blueShade,
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../constants/colors.dart';
// import '../../../constants/paths.dart';
// import '../../../constants/strings.dart';
// import '../../../models/auth_models.dart';
// import '../../../services/db_service.dart';
// import '../../../services/helpers.dart';
// import '../../../utils/regx.dart';
// import '../../../utils/transitions_util.dart';
// import '../../../widgets/backgrounds.dart';
// import '../../../widgets/field_widget.dart';
// import '../../../widgets/image_widget.dart';
// import '../../../widgets/loaders.dart';
// import '../../../widgets/spacers.dart';
// import '../../../widgets/text_widget.dart';
// import '../../forogotPass/forgot_pass_screen.dart';
// import './../components/auth_widgets.dart';
// import 'sign_up.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   bool obscureText = true;
//   bool rememberMe = false;

//   final _formKey = GlobalKey<FormState>();

//   // final emailCntlr = TextEditingController(text: 'test2@test.com');
//   // final passCntlr = TextEditingController(text: 'Test@123');
//   final emailCntlr = TextEditingController();
//   final passCntlr = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     getRememberMe();
//   }

//   Future<void> _trySubmitSignInForm() async {
//     final isValid = _formKey.currentState!.validate();
//     if (isValid) {
//       final authProvider = getAuthProvider(context);
//       dismissInputFocus(context);

//       final email = emailCntlr.text.trim();
//       final pass = passCntlr.text.trim();
//       final userData = Login(
//         loginData: LoginData(
//           userEmail: email,
//           password: pass,
//         ),
//       );
//       await authProvider.loginUser(userData: userData, ctx: context);
//       await setRememberMe(email, pass);
//     }
//   }

//   Future<void> setRememberMe(String email, String pass) async {
//     await DbService.setRememberMe(
//       email: email,
//       password: pass,
//       rememberMe: rememberMe,
//     );
//   }

//   Future<void> getRememberMe() async {
//     final rData = await DbService.getRememberMe();
//     if (rData.rememberMe) {
//       setState(() {
//         emailCntlr.text = rData.rEmail;
//         passCntlr.text = rData.rPassword;
//         rememberMe = true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(children: [
//       bgImage,
//       Scaffold(
//         backgroundColor: Colors.transparent,
//         resizeToAvoidBottomInset: false,
//         body: Center(
//           child: Padding(
//             padding: EdgeInsets.fromLTRB(4.w, 4.w, 4.w, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Spacer(flex: 2),
//                 _logo(),
//                 const Spacer(flex: 2),
//                 buildLoginView(context)
//               ],
//             ),
//           ),
//         ),
//       ),
//       authLoader(context),
//     ]);
//   }

//   Widget _logo() {
//     return Hero(
//       tag: 'logo',
//       child: ImageWidget(
//         image: Paths.logo,
//         height: 48.h,
//         width: 183.w,
//       ),
//     );
//   }

//   Widget buildLoginView(BuildContext context) {
//     return Expanded(
//       flex: 8,
//       child: Container(
//         height: double.infinity,
//         width: double.infinity,
//         padding: EdgeInsets.symmetric(horizontal: 30.w),
//         decoration: decorAuth,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Spacers.sb25(),
//             const Center(
//               child: TextWidget(
//                 text: AppConstants.login,
//                 fontSize: 48,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             buildLoginForm(context),
//             Spacers.sb25(),
//             Center(
//               child: AuthWidgets.button(
//                 title: AppConstants.login,
//                 context: context,
//                 onTap: _trySubmitSignInForm,
//               ),
//             ),
//             Spacers.sb25(),
//             const Center(
//               child: TextWidget(
//                 text: AppConstants.dontHaveAcnt,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//             switchToSignUp(context),
//             Spacers.sb25(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget switchToSignUp(BuildContext context) {
//     return Center(
//       child: InkWell(
//         onTap: () {
//           Navigator.pushReplacement(
//             context,
//             SlideTopRoute(page: const SignupScreen()),
//           );
//         },
//         child: Padding(
//           padding: EdgeInsets.all(4.w),
//           child: const TextWidget(
//             text: AppConstants.signUp,
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildLoginForm(BuildContext context) {
//     return Expanded(
//       child: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Spacers.sb20(),
//               const TextWidget(
//                 text: AppConstants.email,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w400,
//               ),
//               Spacers.sb5(),
//               CustomTextField(
//                 controller: emailCntlr,
//                 errorText: AppConstants.emailError,
//                 regErrorText: AppConstants.emailRegError,
//                 regExpCondition: Regx.emailRegExp,
//                 outlined: true,
//                 filled: true,
//                 fillColor: ColorsData.whiteColor,
//               ),
//               Spacers.sb15(),
//               const TextWidget(
//                 text: AppConstants.pass,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w400,
//               ),
//               Spacers.sb5(),
//               CustomTextField(
//                 controller: passCntlr,
//                 errorText: AppConstants.passError,
//                 regErrorText: AppConstants.passRegError,
//                 regExpCondition: Regx.passwordRegExp,
//                 passField: true,
//                 obscureText: obscureText,
//                 outlined: true,
//                 filled: true,
//                 fillColor: ColorsData.whiteColor,
//                 suffixIcon: buildSuffixIcon(),
//               ),
//               Spacers.sb5(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   buildRememberMe(),
//                   buildforgotPass(),
//                 ],
//               ),
//               scrollUp(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildRememberMe() {
//     return TextButton.icon(
//       style: TextButton.styleFrom(
//         padding: EdgeInsets.symmetric(horizontal: 10.w),
//         foregroundColor: ColorsData.formHintColor,
//       ),
//       onPressed: () {
//         setState(() {
//           rememberMe = !rememberMe;
//         });
//       },
//       icon: Icon(
//         rememberMe
//             ? Icons.check_box_rounded
//             : Icons.check_box_outline_blank_rounded,
//         size: 20.sp,
//         color: rememberMe ? ColorsData.blueShade : ColorsData.greyColor,
//       ),
//       label: const TextWidget(
//         text: AppConstants.rememberMe,
//         color: Color(0xff7B7B7B),
//         fontSize: 10,
//         fontWeight: FontWeight.w500,
//       ),
//     );
//   }

//   Widget buildforgotPass() {
//     return TextButton(
//       onPressed: () {
//         Navigator.pushReplacement(
//             context, SlideLeftRoute(page: ForgotPassScreen()));
//       },
//       style: TextButton.styleFrom(
//         padding: EdgeInsets.symmetric(horizontal: 10.w),
//         foregroundColor: ColorsData.formHintColor,
//       ),
//       child: const TextWidget(
//         text: AppConstants.frgtPass,
//         color: Color(0xff7B7B7B),
//         fontSize: 10,
//         fontWeight: FontWeight.w500,
//       ),
//     );
//   }

//   Widget buildSuffixIcon() {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           obscureText = !obscureText;
//         });
//       },
//       child: Icon(
//         obscureText ? Icons.visibility_off : Icons.visibility,
//         size: 21.sp,
//         color: ColorsData.blueShade,
//       ),
//     );
//   }
// }
