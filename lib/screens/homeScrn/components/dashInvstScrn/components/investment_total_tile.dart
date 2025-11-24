import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/colors.dart';
import '../../../../../constants/strings.dart';
import '../../../../../providers/dash_provider.dart';
import '../../../../../utils/extensions.dart';
import '../../../../../utils/formatter.dart';
import '../../../../../widgets/loaders.dart';
import '../../../../../widgets/text_widget.dart';
import '../../charts/loss_chart.dart';
import '../../charts/profit_chart.dart';

class InvestmentTotalTile extends StatelessWidget {
  const InvestmentTotalTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        investmentTile(
          title: AppConstants.propertyFund,
          isProp: true,
        ),
        SizedBox(width: 12.w),
        investmentTile(
          title: AppConstants.mortgageFund,
          isProp: false,
        ),
      ],
    );
  }

  Widget investmentTile({
    required String title,
    required bool isProp,
  }) {
    return Expanded(
      child: Container(
        height: 98.w,
        padding: EdgeInsets.all(10.w),
        margin: EdgeInsets.all(2.w),
        decoration: _decor1(),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.fromLTRB(8.w, 4.w, 8.w, 4.w),
                    decoration: const ShapeDecoration(
                      color: Color(0xff378BFB),
                      shape: StadiumBorder(),
                    ),
                    child: FittedBox(
                      child: TextWidget(
                        text: title,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: ColorsData.whiteColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const TextWidget(
                    text: AppConstants.investments,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  FittedBox(
                    child: Consumer<DashProvider>(
                      builder: (context, snapshot, child) {
                        return snapshot.homeLoad
                            ? showLoader(size: 16)
                            : TextWidget(
                                text: Frmtr.frmtCurrency(isProp
                                    ? snapshot.properyTotal.amount
                                    : snapshot.mortageTotal.amount),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              );
                      },
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              flex: 3,
              child: Consumer<DashProvider>(
                builder: (context, snapshot, child) {
                  double diff = isProp
                      ? snapshot.properyTotal.percentageDifference
                      : snapshot.mortageTotal.percentageDifference;
                  double percent = diff.toNrString.toDouble;
                  bool isLoss = '$percent'.contains('-');
                  return snapshot.homeLoad
                      ? const SizedBox()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: FittedBox(
                                child: TextWidget(
                                  text: isLoss ? '$percent' : '+$percent',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isLoss
                                      ? const Color(0xffFF5656)
                                      : const Color(0xff45A843),
                                ),
                              ),
                            ),
                            Expanded(
                              child: isLoss
                                  ? LossChart(percentageChange: percent)
                                  : ProfitChart(percentageChange: percent),
                            ),
                          ],
                        );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  BoxDecoration _decor1() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10.r),
      color: ColorsData.whiteColor,
      boxShadow: const [
        BoxShadow(
          color: Color.fromARGB(55, 0, 0, 0),
          spreadRadius: 1,
          blurRadius: 1,
        ),
      ],
    );
  }
}
