import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../constants/colors.dart';

Future showToast({required message}) {
  return Fluttertoast.showToast(
    msg: message.toString(),
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    timeInSecForIosWeb: 1,
    backgroundColor: const Color(0xFFDFDFDF),
    textColor: ColorsData.blackColor,
    fontSize: 16.sp,
  );
}
