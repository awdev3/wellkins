import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/colors.dart';
import '../../../../../widgets/text_widget.dart';
import '../../../../constants/strings.dart';
import '../../../../models/fund_type.dart';
import '../../../../providers/dash_provider.dart';
import '../../../../providers/inv_provider.dart';
import '../../../../utils/transitions_util.dart';
import '../../../../widgets/image_widget.dart';
import '../../../../widgets/loaders.dart';
import 'fund_types.dart';
import 'components/fundListing/funds_listing_screen.dart';

class MortageFunds extends StatelessWidget {
  final bool isInvestment;
  final bool fromDash;
  const MortageFunds({
    super.key,
    this.isInvestment = false,
    required this.fromDash,
  });

  @override
  Widget build(BuildContext context) {
    return buildMortageFunds(context);
  }

  Widget buildMortageFunds(BuildContext ctx) {
    final mortageFundList = FundTypes.mortageFundList;
    return SizedBox(
      height: 150.w,
      child: ListView.builder(
        itemCount: mortageFundList.length,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context, int index) {
          final fund = mortageFundList[index];

          return mortageTile(fund, ctx);
        },
      ),
    );
  }

  Widget mortageTile(FundType fund, BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          ctx,
          FadeRoute(
            page: FundsListingScreen(
              title: '${AppConstants.mortgageFunds} - ${fund.title}',
              fromDash: fromDash,
              fundSubType: fund.subType,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 4 / 3.19,
            child: Container(
              padding: EdgeInsets.all(10.w),
              margin: EdgeInsets.all(9.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: ColorsData.whiteColor,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(55, 0, 0, 0),
                    spreadRadius: 1,
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 10.h),
                  ImageWidget(
                    image: fund.image,
                    height: 31.w,
                    width: 31.w,
                    color: fund.color,
                  ),
                  SizedBox(height: 5.h),
                  const Spacer(),
                  if (fromDash)
                    Consumer<DashProvider>(
                      builder: (context, snapshot, child) {
                        return snapshot.homeLoad
                            ? showLoader(size: 12)
                            : TextWidget(
                                text: snapshot.getSubTypeTotal(fund.subType),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: ColorsData.blackColor,
                              );
                      },
                    )
                  else
                    Consumer<InvProvider>(
                      builder: (context, snapshot, child) {
                        return snapshot.homeLoad
                            ? showLoader(size: 12)
                            : TextWidget(
                                text: snapshot.getSubTypeTotal(fund.subType),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: ColorsData.blackColor,
                              );
                      },
                    ),
                  SizedBox(height: 5.h),
                  TextWidget(
                    text: fund.title,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: ColorsData.blackColor,
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ),
          if (isInvestment)
            Positioned(
              right: 0,
              top: 15.h,
              child: Container(
                height: 20.w,
                width: 40.w,
                padding: EdgeInsets.all(1.w),
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                  ),
                  color: const Color(0xff039E8E),
                ),
                child: const Center(
                  child: TextWidget(
                    text: '2',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorsData.whiteColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
