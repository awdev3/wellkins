import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellkins/widgets/spacers.dart';

import '../constants/colors.dart';
import 'text_widget.dart';

Widget customButton({
  required String title,
  required VoidCallback? onPressed,
  //required BuildContext ctx,
  Icon? icon,
  double height = 50,
  double fontSize = 16,
  double borderWidth = 1.0,
  Color textColor = ColorsData.whiteColor,
  Color buttonColor = ColorsData.primaryColor,
  Color borderColor = Colors.transparent,
  List<BoxShadow>? shadows,
  bool stadium = false,
  double width = double.infinity,
  Gradient? gradient,
  ViewCase? viewCase,
  EdgeInsetsGeometry? padding,
  EdgeInsetsGeometry? innerPadding,
  double? borderRadius,
}) {
  return Padding(
    padding: padding ?? EdgeInsets.symmetric(horizontal: 10.w),
    child: GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: innerPadding,
        decoration: stadium
            ? ShapeDecoration(
                gradient: gradient,
                shadows: shadows,
                shape: const StadiumBorder(),
              )
            : BoxDecoration(
                gradient: gradient,
                boxShadow: shadows,
                borderRadius: BorderRadius.circular(borderRadius?.r ?? 9.r),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
        child: Container(
          width: width.w,
          height: height.h,
          decoration: stadium
              ? ShapeDecoration(
                  color: buttonColor,
                  shape: const StadiumBorder(),
                )
              : BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(borderRadius?.r ?? 9.r),
                  border: Border.all(color: borderColor, width: borderWidth),
                ),
          child: Center(
            child: icon != null
                ? FittedBox(
                    child: Padding(
                      padding: EdgeInsets.all(4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          icon,
                          Spacers.sbw5(),
                          _text(title, fontSize, textColor, viewCase),
                        ],
                      ),
                    ),
                  )
                : _text(title, fontSize, textColor, viewCase),
          ),
        ),
      ),
    ),
  );
}

Widget _text(
  String title,
  double fontSize,
  Color textColor,
  ViewCase? viewCase,
) {
  return FittedBox(
    child: TextWidget(
      text: title,
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: textColor,
      viewCase: viewCase,
    ),
  );
}
