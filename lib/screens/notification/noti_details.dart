import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/colors.dart';
import '../../models/noti_model.dart';
import '../../services/helpers.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/common_titles.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/spacers.dart';
import '../../widgets/text_widget.dart';

class NotiDetailsScreen extends StatelessWidget {
  final Noti noti;
  const NotiDetailsScreen({super.key, required this.noti});

  @override
  Widget build(BuildContext context) {
    final notiPro = getNotiProvider(context);
    notiPro.resetNotiCount(noti, context);
    return Stack(
      children: [
        bgImage,
        Scaffold(
          backgroundColor: ColorsData.trColor,
          appBar: CustomAppBar.appbar(ctx: context, showTrailing: false),
          body: Column(
            children: [
              CommonTitles.title(
                text: noti.title,
                context: context,
              ),
              Spacers.sb10(),
              Expanded(
                child: DelayedDisplay(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
                    padding: EdgeInsets.fromLTRB(15.w, 20.w, 15.w, 0),
                    decoration: commonDecor,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (noti.image.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: ImageWidget(
                                  image: noti.image,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorWidget: const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          Spacers.sb10(),
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: TextWidget(
                              text: noti.title,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff333232),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.w),
                            child: TextWidget(
                              text: noti.body,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xff989898),
                            ),
                          ),
                          Spacers.sb50(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // void _navigateToPage(context) {
  //   if (noti.deepId != '') {
  //     if (noti.route == 'category') {
  //       navigateToProductView(isCategory: true, context: context);
  //     } else if (noti.route == 'brand') {
  //       navigateToProductView(isCategory: false, context: context);
  //     } else if (noti.route == 'product') {
  //       navigateToProductDetails(context);
  //     } else {
  //       navigateToHome(context);
  //     }
  //   } else {
  //     navigateToHome(context);
  //   }
  // }

  // void navigateToProductView({required bool isCategory, required context}) {
  // Navigator.push(
  //   context,
  //   FadeRoute(
  //     page: ProductViewScreen(
  //       id: noti.deepId.toString().toInt,
  //       category: isCategory,
  //       title: noti.categoryTitle,
  //       count: 5,
  //     ),
  //   ),
  // );
  // }

  // void navigateToProductDetails(context) {
  // Navigator.push(
  //   context,
  //   FadeRoute(
  //     page: ProductDetailsScreen(
  //       id: noti.deepId.toString().toInt,
  //     ),
  //   ),
  // );
  // }

  // void navigateToHome(context) {
  // Navigator.pushAndRemoveUntil(
  //   context,
  //   FadeRoute(
  //     page: const BottomNavBar(
  //       pageNum: 0,
  //     ),
  //   ),
  //   (route) => false,
  // );
  // }
}
