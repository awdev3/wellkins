// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:wellkins/constants/paths.dart';

// class TestScreen extends StatefulWidget {
//   const TestScreen({super.key});

//   @override
//   State<TestScreen> createState() => _TestScreenState();
// }

// class _TestScreenState extends State<TestScreen> with TickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _logoOneY;
//   late final Animation<double> _logoTwoGlow;
//   late final Animation<double> _logoOneGlow;
//   late final Animation<double> _logoFourGlow; // Glow for logoFour
//   late final Animation<double> _logoFourOpacity; // Fade-in for logoFour

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 3000),
//     );

//     // LogoOne moves from bottom to slightly under LogoTwos
//     _logoOneY = Tween<double>(begin: 1.2, end: 0.056).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
//       ),
//     );

//     // Glow intensity for LogoTwo when LogoOne reaches it
//     _logoTwoGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.55, 0.75, curve: Curves.easeOut),
//       ),
//     );

//     // Glow intensity for LogoOne after a delay
//     _logoOneGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.75, 0.9, curve: Curves.easeOut),
//       ),
//     );

//     // Fade-in and glow for LogoFour (under LogoOne)
//     _logoFourOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
//       ),
//     );

//     _logoFourGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.85, 1.0, curve: Curves.easeOut),
//       ),
//     );

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   // Shape-based glow helper
//   Widget _glowingLogo(String path, double size, double glow) {
//     return Stack(
//       alignment: Alignment.center,
//       children: [
//         // Glow: blurred duplicate behind
//         ImageFiltered(
//           imageFilter: ImageFilter.blur(sigmaX: 15 * glow, sigmaY: 15 * glow),
//           child: Image.asset(
//             path,
//             height: size,
//             color: Colors.white.withValues(alpha: .6 * glow),
//             colorBlendMode: BlendMode.srcATop,
//           ),
//         ),
//         // Original logo on top
//         Image.asset(path, height: size),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnimatedBuilder(
//         animation: _controller,
//         builder: (context, child) {
//           return Stack(
//             alignment: Alignment.center,
//             children: [
//               // Background gradient
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.black, Colors.deepPurple.shade900],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                 ),
//               ),

//               // LogoTwo (fixed center) with glow
//               Center(
//                 child: _glowingLogo(Paths.logoTwo, 55, _logoTwoGlow.value),
//               ),

//               // LogoOne (moving from bottom to under LogoTwo)
//               Align(
//                 alignment: Alignment(0, _logoOneY.value),
//                 child: _glowingLogo(Paths.logoOne, 37, _logoOneGlow.value),
//               ),

//               // LogoFour (appears under LogoOne with glow)
//               Align(
//                 alignment: const Alignment(
//                   0,
//                   0.20,
//                 ), // Adjust vertical placement
//                 child: Opacity(
//                   opacity: _logoFourOpacity.value,
//                   child: _glowingLogo(
//                     Paths.logoFour,
//                     60.h,
//                     _logoFourGlow.value,
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellkins/constants/colors.dart';
import 'package:wellkins/constants/paths.dart';
import 'package:wellkins/widgets/text_widget.dart';

import '../../constants/strings.dart';
import '../../utils/regx.dart';
import '../../widgets/field_widget.dart';
import '../../widgets/spacers.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  bool obscureText0 = true;
  bool obscureText1 = true;
  bool obscureText2 = true;

  final oldPassCntlr = TextEditingController();
  final newPassCntlr = TextEditingController();
  final cnfmPassCntlr = TextEditingController();
  void _showGlassBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // make the sheet itself transparent
      barrierColor: Colors.black.withValues(alpha: .2), // optional dim
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // stronger blur
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: .40),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              border: Border.all(
                color: Colors.white.withValues(alpha: .1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: 20.h),
                Spacers.sb20(),
                Center(child: h2(AppConstants.chngPass)),
                Spacers.sb15(),
                h1("Current Password"),
                Spacers.sb5(),
                _passField(
                  controller: oldPassCntlr,
                  errorText: AppConstants.passError,
                  regErrorText: AppConstants.passRegError,
                  regExpCondition: Regx.passwordRegExp,
                  obscureText: obscureText0,
                  suffixindex: 0,
                ),
                Spacers.sb15(),
                h1("New Password"),
                Spacers.sb5(),
                _passField(
                  controller: newPassCntlr,
                  errorText: AppConstants.passError,
                  regErrorText: AppConstants.passRegError,
                  regExpCondition: Regx.passwordRegExp,
                  obscureText: obscureText1,
                  suffixindex: 1,
                ),
                Spacers.sb15(),
                h1(AppConstants.cnfmPass),
                Spacers.sb5(),
                _passField(
                  controller: cnfmPassCntlr,
                  errorText: AppConstants.cnfmPassError,
                  regErrorText: AppConstants.passRegError,
                  regExpCondition: Regx.passwordRegExp,
                  obscureText: obscureText2,
                  suffixindex: 2,
                ),
                Spacers.sb30(),
                updateBtn(),
                Spacers.sb30(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD6C6FF),
        elevation: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage: AssetImage(Paths.profile),
            ),
            Spacers.sbw10(),
            Expanded(
              flex: 3,
              child: greetingWidget("Good Morning,", "Ann Mathew"),
            ),
            Spacer(),
            circleIcon(Icons.search, () {
              // handle search tap
            }),
            Spacers.sbw10(),

            circleIcon(Icons.notifications_none, () {
              // handle notification tap
            }),
          ],
        ),
      ),

      body: Center(
        child: ElevatedButton(
          onPressed: _showGlassBottomSheet,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ), // optional
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Show Glass BottomSheet"),
        ),
      ),
    );
  }

  Widget greetingWidget(String greeting, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: greeting,
          fontSize: 14,
          color: Color(0xff2E1F64),
          fontWeight: FontWeight.bold,
        ),
        TextWidget(
          text: name,
          overflow: TextOverflow.ellipsis,
          fontSize: 16,
          color: const Color(0xff2E1F64),
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }

  Widget circleIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 20.r,
        backgroundColor: ColorsData.whiteColor,
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  Widget _passField({
    required TextEditingController controller,
    required String errorText,
    required String regErrorText,
    required RegExp regExpCondition,
    required bool obscureText,
    required int suffixindex,
  }) {
    return CustomTextField(
      controller: controller,
      errorText: errorText,
      regErrorText: regErrorText,
      regExpCondition: regExpCondition,
      passField: true,
      obscureText: obscureText,
      outlined: true,
      filled: true,
      isDence: true,
      autoValidate: false,
      fillColor: Colors.white.withValues(alpha: .13), // glass fill

      bRadius: 30,
      outPadding: EdgeInsets.symmetric(vertical: 19.h, horizontal: 20.w),

      style: MyFont.poppins(
        fontSize: 12,
        color: ColorsData.whiteColor, // text color visible on glass
        fontWeight: FontWeight.bold,
      ),
      suffixIcon: buildSuffixIcon(suffixindex),
    );
  }

  Widget buildSuffixIcon(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (index == 0) {
            obscureText0 = !obscureText0;
          } else if (index == 1) {
            obscureText1 = !obscureText1;
          } else {
            obscureText2 = !obscureText2;
          }
        });
      },
      child: Icon(
        (index == 0 && obscureText0) ||
                (index == 1 && obscureText1) ||
                (index == 2 && obscureText2)
            ? Icons.visibility_off
            : Icons.visibility,
        size: 20.sp,
        color: ColorsData.whiteColor,
      ),
    );
  }

  Widget h1(String title) {
    return TextWidget(
      text: title,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: ColorsData.whiteColor,
    );
  }

  Widget h2(String title) {
    return TextWidget(
      text: title,
      fontSize: 19,
      fontWeight: FontWeight.bold,
      color: ColorsData.whiteColor,
    );
  }

  Widget updateBtn() {
    return SizedBox(
      width: double.infinity, // full width
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade900,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
        ),
        child: TextWidget(
          text: "Update",
          color: ColorsData.whiteColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
