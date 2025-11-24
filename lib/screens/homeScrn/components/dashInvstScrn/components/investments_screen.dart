import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../../constants/colors.dart';
import '../../../../../../../constants/strings.dart';
import '../../../../../../../widgets/text_widget.dart';
import '../../../../../providers/dash_provider.dart';
import '../../../../../providers/inv_provider.dart';
import '../../../../../services/helpers.dart';
import '../../../../../widgets/loaders.dart';
import '../../charts/funding_chart.dart';
import '../../charts/invested_locations_chart.dart';
import '../../charts/popularity_funds_chart.dart';
import '../../charts/rental_bar_chart.dart';
import '../../fundsTypes/mortage_funds.dart';
import '../../fundsTypes/property_funds.dart';
import 'investment_total_tile.dart';

class InvestmentsScreen extends StatelessWidget {
  final bool fromDash;
  const InvestmentsScreen({super.key, this.fromDash = true});
  //
  Future<void> getDashData(BuildContext context) async {
    final dashProvider = getDashProvider(context);
    await dashProvider.getDashBoardData(context);
  }

  //
  Future<void> getInvData(BuildContext context) async {
    final invProvider = getInvProvider(context);
    await invProvider.getDashInvData(context);
  }

  //
  Future<void> getProjects(BuildContext context) async {
    final wooProvider = getWooProvider(context);
    await wooProvider.getProjects(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: RefreshIndicator(
        onRefresh: () async {
          if (fromDash) {
            await getDashData(context);
            if (!context.mounted) return;
            await getProjects(context);
          } else {
            await getInvData(context);
            if (!context.mounted) return;
            await getProjects(context);
          }
        },
        child: ListView(
          children: [
            if (fromDash) const InvestmentTotalTile(),
            if (fromDash) SizedBox(height: 20.h),
            fundsTitleAndAmount(AppConstants.propertyFunds, 2, fromDash),
            const TextWidget(
              text: AppConstants.investments,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ColorsData.blackColor,
            ),
            SizedBox(height: 8.h),
            PropertyFunds(fromDash: fromDash),
            SizedBox(height: 20.h),
            fundsTitleAndAmount(AppConstants.mortgageFunds, 1, fromDash),
            SizedBox(height: 5.h),
            MortageFunds(fromDash: fromDash),
            SizedBox(height: 20.h),
            titleWidget(AppConstants.funding),
            FundingChart(fromDash: fromDash),
            SizedBox(height: 10.h),
            RentalBarChart(fromDash: fromDash),
            InvestedLocationsChart(fromDash: fromDash),
            PopularityAndFundsChart(fromDash: fromDash),
          ],
        ),
      ),
    );
  }

  Widget fundsTitleAndAmount(String title, int type, bool fromDash) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            titleWidget(title),
            SizedBox(width: 8.w),
            Card(
              color: ColorsData.whiteColor,
              surfaceTintColor: ColorsData.whiteColor,
              shape: const CircleBorder(),
              child: Icon(
                Icons.chevron_right,
                size: 14.sp,
              ),
            ),
          ],
        ),
        if (fromDash)
          Consumer<DashProvider>(builder: (context, snapshot, child) {
            return snapshot.homeLoad
                ? showLoader(size: 12)
                : Flexible(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10.w, 4.w, 10.w, 4.w),
                      decoration: const ShapeDecoration(
                        color: Color(0xff378BFB),
                        shape: StadiumBorder(),
                      ),
                      child: TextWidget(
                        text: snapshot.getFundTypeTotal(type),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ColorsData.whiteColor,
                      ),
                    ),
                  );
          })
        else
          Consumer<InvProvider>(builder: (context, snapshot, child) {
            return snapshot.homeLoad
                ? showLoader(size: 12)
                : Flexible(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10.w, 4.w, 10.w, 4.w),
                      decoration: const ShapeDecoration(
                        color: Color(0xff378BFB),
                        shape: StadiumBorder(),
                      ),
                      child: TextWidget(
                        text: snapshot.getFundTypeTotal(type),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: ColorsData.whiteColor,
                      ),
                    ),
                  );
          }),
      ],
    );
  }

  TextWidget titleWidget(String title) {
    return TextWidget(
      text: title,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ColorsData.blackColor,
    );
  }
}
