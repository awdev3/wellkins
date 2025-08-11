import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../constants/paths.dart';
import 'image_widget.dart';

Widget bgImage = const Material(
  color: ColorsData.whiteColor,
  child: Stack(
    children: [
      ImageWidget(
        image: Paths.bg,
        height: double.infinity,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
      // to make bg darker
      SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: ColoredBox(color: Color.fromARGB(18, 0, 0, 0)),
      ),
    ],
  ),
);

BoxDecoration commonDecor = BoxDecoration(
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(40.r),
    topRight: Radius.circular(40.r),
  ),
  // color: ColorsData.whiteColor,
  color: Colors.grey[50],
);

BoxDecoration decorAuth = BoxDecoration(
  color: const Color(0xffEEEEEE),
  borderRadius: BorderRadius.only(
    topLeft: Radius.circular(110.r),
    topRight: Radius.circular(10.r),
  ),
);
