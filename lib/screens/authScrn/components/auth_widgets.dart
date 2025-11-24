import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../constants/colors.dart';
import '../../../widgets/button_widgets.dart';
import '../../../widgets/text_widget.dart';

class AuthWidgets {
  static List<String> investmentRanges = [
    '\$0',
    '\$100k',
    '\$100k to \$200k',
    '\$200k to \$300k',
    '\$300k to \$400k',
    '\$400k to \$500k',
    '>\$500k',
  ];

  static List<String> states = [
    'NSW',
    'WA',
    'NT',
    'QLD',
    'SA',
    'VIC',
    'ACT',
    'TAS',
  ];

  static TextWidget h1(String title) {
    return TextWidget(text: title, fontSize: 13, fontWeight: FontWeight.w400);
  }

  static Widget button({
    required String title,
    required BuildContext context,
    required VoidCallback onTap,
    bool leftShade = true,
  }) {
    return customButton(
      title: title,
      stadium: true,
      height: 46,
      width: 237,
      innerPadding: EdgeInsets.all(1.w),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.bottomRight,
        colors: [
          leftShade ? ColorsData.blackColor : ColorsData.whiteColor,
          ColorsData.whiteColor,
          leftShade ? ColorsData.whiteColor : ColorsData.blackColor,
        ],
      ),
      shadows: [
        BoxShadow(
          color: Colors.black38,
          blurRadius: 3.w,
          spreadRadius: .07,
          offset: const Offset(0, 3),
        ),
      ],
      onPressed: onTap,
    );
  }
}
