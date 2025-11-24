import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/colors.dart';
import '../../utils/wellkins_icons.dart';
import '../../widgets/text_widget.dart';

class CommonTitles {
  static Widget title({
    required String text,
    required BuildContext context,
    double? fontSize,
    double? iconSize,
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: IconButton(
            onPressed: () => onTap ?? Navigator.pop(context),
            icon: Icon(
              Wellkins.back,
              size: iconSize?.sp ?? 15.sp,
              color: Colors.white,
            ),
          ),
        ),
        Flexible(
          child: TextWidget(
            text: text,
            fontSize: fontSize ?? 20,
            fontWeight: FontWeight.w500,
            color: ColorsData.whiteColor,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: 15.w),
          child: IconButton(
            onPressed: null,
            icon: Icon(Wellkins.back, size: .01.sp, color: Colors.transparent),
          ),
        ),
      ],
    );
  }
}
