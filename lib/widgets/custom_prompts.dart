import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';
import '../constants/strings.dart';
import 'image_widget.dart';
import 'spacers.dart';
import 'text_widget.dart';

class CustomPrompts {
  static void showAlert({
    required String message,
    required BuildContext ctx,
    required VoidCallback onConfirmTap,
    Widget? child,
  }) {
    showDialog<bool>(
      context: ctx,
      barrierDismissible: false,
      builder: (context) => child ?? CustomAlert(message: message),
    ).then((confirmed) {
      if (confirmed != null && confirmed) {
        onConfirmTap();
      }
    });
  }

  static void showInfo({
    required String img,
    required String title,
    String subTitle = '',
    required BuildContext ctx,
  }) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (context) =>
          CustomInfo(img: img, title: title, subTitle: subTitle),
    );
  }

  static Future<String?> showBottomSheet({
    required Widget widget,
    required BuildContext ctx,
  }) async {
    return await showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.r),
          topRight: Radius.circular(30.r),
        ),
      ),
      context: ctx,
      builder: (BuildContext context) {
        return widget;
      },
    );
  }

  static Widget showEmptyInfo({
    required String text,
    String image = '',
    IconData? icon,
    double ht = 180,
    double wt = 180,
    double fs = 22,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (image.isNotEmpty)
            ImageWidget(image: image, height: ht.w, width: wt.w)
          else
            Icon(
              icon,
              size: 60.sp,
              color: const Color.fromARGB(136, 208, 209, 210),
            ),
          Spacers.sb20(),
          TextWidget(
            text: text,
            fontSize: fs,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(204, 208, 209, 210),
          ),
          Spacers.sb50(),
        ],
      ),
    );
  }
}

class CustomAlert extends StatelessWidget {
  final String message;
  const CustomAlert({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        padding: EdgeInsets.all(12.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  radius: 12.r,
                  backgroundColor: ColorsData.formHintColor,
                  child: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Icon(
                      Icons.close,
                      size: 14.sp,
                      color: ColorsData.whiteColor,
                    ),
                  ),
                ),
              ),
            ),
            TextWidget(
              text: message,
              textAlign: TextAlign.center,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorsData.blackColor,
            ),
            SizedBox(height: 28.h),
            Padding(
              padding: const EdgeInsets.only(left: 11, right: 11),
              child: Row(
                children: [
                  buttons(AppConstants.yes, 0, context),
                  SizedBox(width: 10.w),
                  buttons(AppConstants.no, 1, context),
                ],
              ),
            ),
            SizedBox(height: 18.h),
          ],
        ),
      ),
    );
  }

  Widget buttons(String text, int index, BuildContext ctx) {
    final isButton = index == 0;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isButton) {
            Navigator.pop(ctx, true);
          } else {
            Navigator.pop(ctx, false);
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: ShapeDecoration(
            gradient: isButton
                ? null
                : const LinearGradient(
                    colors: [Color(0xff00A79D), Color(0xffD8B10F)],
                  ),
            shape: StadiumBorder(
              side: isButton
                  ? const BorderSide(color: Color(0xff6D7278))
                  : BorderSide.none,
            ),
          ),
          child: Center(
            child: TextWidget(
              text: text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isButton ? const Color(0xff6D7278) : ColorsData.whiteColor,
            ),
          ),
        ),
      ),
    );
  }
}

class CustomInfo extends StatelessWidget {
  final String img;
  final String title;
  final String subTitle;
  const CustomInfo({
    super.key,
    required this.img,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 57.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
      child: Padding(padding: EdgeInsets.all(12.w), child: infoWidget(context)),
    );
  }

  Widget infoWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 14.h),
        Align(
          alignment: Alignment.topRight,
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            customBorder: const CircleBorder(),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(Icons.close, size: 30.sp),
            ),
          ),
        ),
        ImageWidget(image: img, height: 120.h, width: 120.w),
        SizedBox(height: 11.h),
        TextWidget(
          text: title,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(0xff6D7278),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10.h),
        if (subTitle.isNotEmpty) ...[
          TextWidget(
            text: subTitle,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xff6D7278),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 60.h),
        ],
      ],
    );
  }
}
