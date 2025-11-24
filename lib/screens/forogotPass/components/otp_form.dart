import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/colors.dart';
import '../../../constants/strings.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/helpers.dart';
import '../../../utils/console_util.dart';
import '../../../utils/textstyle_util.dart';

class OtpForm extends StatefulWidget {
  const OtpForm({super.key});

  @override
  State<OtpForm> createState() => _OtpFormState();
}

class _OtpFormState extends State<OtpForm> {
  List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());

  // @override
  // void initState() {
  //   super.initState();
  //   focusNodes.first.requestFocus();
  // }

  void _resendOtp(BuildContext ctx) async {
    final authProvider = getAuthProvider(context);
    final resendOff = authProvider.resendOff;

    if (resendOff) {
      return;
    }

    _resetFields();
    await authProvider.sendOtp(isResend: true, ctx: ctx).whenComplete(() {
      _setLoadAndTimer(authProvider);
    });
  }

  void _setLoadAndTimer(AuthProvider authProvider) {
    authProvider.setRecendLoad(true);
    Timer(const Duration(seconds: 60), () {
      authProvider.setRecendLoad(false);
    });
  }

  void _resetFields() {
    setState(() {
      controllers = List.generate(6, (index) => TextEditingController());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (index) => buildOtpField(index)),
          ),
          const SizedBox(height: 10),
          buildResend(context),
        ],
      ),
    );
  }

  Widget buildResend(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: '${AppConstants.noOtp}  ',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff909090),
            ),
          ),
          resendButton(context),
        ],
      ),
    );
  }

  TextSpan resendButton(BuildContext context) {
    final authProvider = getAuthProvider(context, listen: true);
    return TextSpan(
      text: AppConstants.resend,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: authProvider.resendOff
            ? const Color.fromARGB(58, 151, 71, 255)
            : const Color(0xff9747FF),
      ),
      recognizer: TapGestureRecognizer()..onTap = () => _resendOtp(context),
    );
  }

  Widget buildOtpField(int index) {
    return Container(
      width: 50.w,
      height: 50.w,
      margin: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: ColorsData.whiteColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (KeyEvent event) => onBackSpace(event, index),
        child: Center(
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            obscureText: true,
            obscuringCharacter: '✱',
            maxLength: 1,
            style: TextStyleData.formHintStyle.copyWith(
              color: ColorsData.blackColor,
            ),
            onChanged: (value) => onChanged(value, index),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ),
    );
  }

  void onChanged(String number, int index) {
    final authProvider = getAuthProvider(context);
    if (number.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(focusNodes[index + 1]);
    }
    String otp = controllers.map((cntlr) => cntlr.text).join();
    authProvider.setOtpCode(otp);
    printData(data: authProvider.otpCode);
    if (otp.length == 6) {
      printData(data: "Success! OTP Entered: $otp");
      dismissInputFocus(context);
    }
  }

  void onBackSpace(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (index > 0) {
        FocusScope.of(context).requestFocus(focusNodes[index - 1]);
      }
    }
  }

  @override
  void dispose() {
    for (final node in focusNodes) {
      node.dispose();
    }
    for (final cntlr in controllers) {
      cntlr.dispose();
    }
    super.dispose();
  }
}

// void onChnaged(String value, int index) {
  //   printData(data: value);
  //   if (value.isNotEmpty && index < 3) {
  //     FocusScope.of(context).requestFocus(focusNodes[index + 1]);
  //   }
  //   // else if (value.isEmpty && index > 0) {
  //   //   FocusScope.of(context).requestFocus(focusNodes[index - 1]);
  //   // }
  //   if (index == 3 && value.isNotEmpty) {
  //     String otp = controllers.map((controller) => controller.text).join();
  //     if (otp.length == 4) {
  //       showToast(message: 'Success! OTP Entered: $otp');
  //       print("Success! OTP Entered: $otp");
  //       dismissInputFocus(context);
  //     }
  //   }
  // }















// import 'dart:async';

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../constants/colors.dart';
// import '../../../constants/strings.dart';
// import '../../../providers/auth_provider.dart';
// import '../../../services/helpers.dart';
// import '../../../utils/console_util.dart';
// import '../../../utils/textstyle_util.dart';

// class OtpForm extends StatefulWidget {
//   const OtpForm({super.key});

//   @override
//   State<OtpForm> createState() => _OtpFormState();
// }

// class _OtpFormState extends State<OtpForm> {
//   List<TextEditingController> controllers =
//       List.generate(4, (index) => TextEditingController());
//   List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());

//   // @override
//   // void initState() {
//   //   super.initState();
//   //   focusNodes.first.requestFocus();
//   // }

//   void _resendOtp(BuildContext ctx) async {
//     final authProvider = getAuthProvider(context);
//     final resendOff = authProvider.resendOff;

//     if (resendOff) {
//       return;
//     }

//     _resetFields();
//     await authProvider.sendOtp(isResend: true, ctx: ctx).whenComplete(() {
//       _setLoadAndTimer(authProvider);
//     });
//   }

//   void _setLoadAndTimer(AuthProvider authProvider) {
//     authProvider.setRecendLoad(true);
//     Timer(const Duration(seconds: 60), () {
//       authProvider.setRecendLoad(false);
//     });
//   }

//   void _resetFields() {
//     setState(() {
//       controllers = List.generate(4, (index) => TextEditingController());
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(4, (index) => buildOtpField(index)),
//           ),
//           const SizedBox(height: 10),
//           buildResend(context),
//         ],
//       ),
//     );
//   }

//   Widget buildResend(BuildContext context) {
//     return RichText(
//       textAlign: TextAlign.center,
//       text: TextSpan(
//         children: [
//           TextSpan(
//             text: '${AppConstants.noOtp}  ',
//             style: TextStyle(
//               fontSize: 14.sp,
//               fontWeight: FontWeight.w600,
//               color: const Color(0xff909090),
//             ),
//           ),
//           resendButton(context),
//         ],
//       ),
//     );
//   }

//   TextSpan resendButton(BuildContext context) {
//     final authProvider = getAuthProvider(context, listen: true);
//     return TextSpan(
//       text: AppConstants.resend,
//       style: TextStyle(
//         fontSize: 15.sp,
//         fontWeight: FontWeight.w600,
//         color: authProvider.resendOff
//             ? const Color.fromARGB(58, 151, 71, 255)
//             : const Color(0xff9747FF),
//       ),
//       recognizer: TapGestureRecognizer()..onTap = () => _resendOtp(context),
//     );
//   }

//   Widget buildOtpField(int index) {
//     return Container(
//       width: 50.w,
//       height: 50.w,
//       margin: EdgeInsets.all(5.w),
//       decoration: BoxDecoration(
//         color: ColorsData.whiteColor,
//         borderRadius: BorderRadius.circular(10.r),
//       ),
//       child: RawKeyboardListener(
//         focusNode: FocusNode(),
//         onKey: (RawKeyEvent event) => onBackSpace(event, index),
//         child: Center(
//           child: TextField(
//             controller: controllers[index],
//             focusNode: focusNodes[index],
//             textAlign: TextAlign.center,
//             keyboardType: TextInputType.number,
//             obscureText: true,
//             obscuringCharacter: '✱',
//             maxLength: 1,
//             style: TextStyleData.formHintStyle
//                 .copyWith(color: ColorsData.blackColor),
//             onChanged: (value) => onChanged(value, index),
//             decoration: const InputDecoration(
//               border: InputBorder.none,
//               counterText: '',
//               contentPadding: EdgeInsets.zero,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void onChanged(String number, int index) {
//     final authProvider = getAuthProvider(context);
//     if (number.isNotEmpty && index < 3) {
//       FocusScope.of(context).requestFocus(focusNodes[index + 1]);
//     }
//     String otp = controllers.map((cntlr) => cntlr.text).join();
//     authProvider.otpCode = otp;
//     printData(data: authProvider.otpCode);
//     if (otp.length == 4) {
//       printData(data: "Success! OTP Entered: $otp");
//       dismissInputFocus(context);
//     }
//   }

//   void onBackSpace(RawKeyEvent event, int index) {
//     if (event is RawKeyDownEvent &&
//         event.logicalKey == LogicalKeyboardKey.backspace) {
//       if (index > 0) {
//         FocusScope.of(context).requestFocus(focusNodes[index - 1]);
//       }
//     }
//   }

//   @override
//   void dispose() {
//     for (final node in focusNodes) {
//       node.dispose();
//     }
//     for (final cntlr in controllers) {
//       cntlr.dispose();
//     }
//     super.dispose();
//   }
// }

// // void onChnaged(String value, int index) {
//   //   printData(data: value);
//   //   if (value.isNotEmpty && index < 3) {
//   //     FocusScope.of(context).requestFocus(focusNodes[index + 1]);
//   //   }
//   //   // else if (value.isEmpty && index > 0) {
//   //   //   FocusScope.of(context).requestFocus(focusNodes[index - 1]);
//   //   // }
//   //   if (index == 3 && value.isNotEmpty) {
//   //     String otp = controllers.map((controller) => controller.text).join();
//   //     if (otp.length == 4) {
//   //       showToast(message: 'Success! OTP Entered: $otp');
//   //       print("Success! OTP Entered: $otp");
//   //       dismissInputFocus(context);
//   //     }
//   //   }
//   // }
