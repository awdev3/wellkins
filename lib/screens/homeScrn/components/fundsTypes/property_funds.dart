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
import '../../../../widgets/spacers.dart';
import 'fund_types.dart';
import 'components/fundListing/funds_listing_screen.dart';

class PropertyFunds extends StatelessWidget {
  final bool isInvestment;
  final bool fromDash;
  const PropertyFunds({
    super.key,
    this.isInvestment = false,
    required this.fromDash,
  });

  @override
  Widget build(BuildContext context) {
    return buildPropertyFunds(context);
  }

  Widget buildPropertyFunds(BuildContext ctx) {
    final propertFundList = FundTypes.propertFundList;
    return SizedBox(
      height: 150.w,
      child: ListView.builder(
        itemCount: propertFundList.length,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemBuilder: (BuildContext context, int index) {
          final fund = propertFundList[index];

          return propertyTile(fund, ctx);
        },
      ),
    );
  }

  Widget propertyTile(FundType fund, BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          ctx,
          FadeRoute(
            page: FundsListingScreen(
              title: '${AppConstants.propertyFunds} - ${fund.title}',
              fromDash: fromDash,
              fundSubType: fund.subType,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: 1 / 1,
            child: Container(
              padding: EdgeInsets.all(10.w),
              margin: EdgeInsets.all(7.w),
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
                  ImageWidget(
                    image: fund.image,
                    height: 31.w,
                    width: 31.w,
                    color: fund.color,
                  ),
                  Spacers.sb5(),
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
                  Spacers.sb5(),
                  TextWidget(
                    text: fund.title,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: ColorsData.blackColor,
                  ),
                  Spacers.sb5(),
                  // Flexible(
                  //   child: TextWidget(
                  //     text: fund.description,
                  //     fontSize: 10,
                  //     fontWeight: FontWeight.w500,
                  //     color: fund.color,
                  //   ),
                  // ),
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
                margin: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                  ),
                  color: const Color(0xff039E8E),
                ),
                child: const Center(
                  child: TextWidget(
                    text: '1',
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
