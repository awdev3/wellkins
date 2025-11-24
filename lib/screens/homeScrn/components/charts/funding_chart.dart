// import 'package:arc_progress_bar_new/arc_progress_bar_new.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/strings.dart';
import '../../../../providers/dash_provider.dart';
import '../../../../providers/inv_provider.dart';
import '../../../../utils/formatter.dart';
import '../../../../widgets/spacers.dart';
import '../../../../widgets/text_widget.dart';
import 'package:wellkins/utils/extensions.dart';

class FundingChart extends StatelessWidget {
  final bool fromDash;
  const FundingChart({
    super.key,
    required this.fromDash,
  });

  @override
  Widget build(BuildContext context) {
    return buildFunding();
  }

  Widget buildFunding() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: 10.w),
        Expanded(
          flex: 4,
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TextWidget(
                  text: AppConstants.totalFunding,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ColorsData.blackColor,
                ),
                FittedBox(
                  child: fromDash
                      ? Consumer<DashProvider>(
                          builder: (context, snapshot, child) {
                            return TextWidget(
                              text: Frmtr.frmtCurrency(
                                  snapshot.totalFunding.total),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 230, 20, 20),
                            );
                          },
                        )
                      : Consumer<InvProvider>(
                          builder: (context, snapshot, child) {
                            return TextWidget(
                              text: Frmtr.frmtCurrency(
                                  snapshot.totalFunding.total),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 230, 20, 20),
                            );
                          },
                        ),
                ),
                Spacers.sb5(),
                Indicator(
                  color: Colors.green.shade300,
                  text: AppConstants.mortgageFund,
                ),
                Spacers.sb5(),
                Indicator(
                  color: Colors.amber.shade300,
                  text: AppConstants.propertyFund,
                ),
                Spacers.sb5(),
                // const TextWidget(
                //   text: 'Profit is 48% more than last month',
                //   fontSize: 12,
                //   fontWeight: FontWeight.w600,
                // ),
                // Spacers.sb5(),
              ],
            ),
          ),
        ),
        FundsPieChart(fromDash: fromDash)
        // Expanded(
        //   flex: 5,
        //   child: Column(
        //     mainAxisSize: MainAxisSize.min,
        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     children: [
        //       Padding(
        //         padding: EdgeInsets.all(20.w),
        //         child: ArcProgressBar(
        //           percentage: 80,
        //           arcThickness: 25.w,
        //           innerPadding: 7.w,
        //           animateFromLastPercent: true,
        //           handleSize: 0,
        //           backgroundColor: ColorsData.formHintColor,
        //           foregroundColor: Colors.red,
        //           bottomCenterWidget: fromDash
        //               ? Consumer<DashProvider>(
        //                   builder: (context, snapshot, child) {
        //                     final prcnt = snapshot.totalFunding.percentage
        //                         .toStringAsFixed(0);
        //                     return TextWidget(
        //                       text: '$prcnt%',
        //                       fontSize: 38,
        //                       fontWeight: FontWeight.bold,
        //                     );
        //                   },
        //                 )
        //               : Consumer<InvProvider>(
        //                   builder: (context, snapshot, child) {
        //                     final prcnt = snapshot.totalFunding.percentage
        //                         .toStringAsFixed(0);
        //                     return TextWidget(
        //                       text: '$prcnt%',
        //                       fontSize: 38,
        //                       fontWeight: FontWeight.bold,
        //                     );
        //                   },
        //                 ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
      ],
    );
  }
}

class FundsPieChart extends StatelessWidget {
  final bool fromDash;
  const FundsPieChart({super.key, required this.fromDash});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: AspectRatio(
        aspectRatio: 1.1,
        child: fromDash
            ? Consumer<DashProvider>(
                builder: (context, snapshot, child) {
                  final totalFunding = snapshot.totalFunding;
                  final totalFunds = '${totalFunding.total}'.toDouble;

                  final pValue = '${totalFunding.percentage.floor()}'.toDouble;
                  final totalPercent = totalFunds > 0 ? 100 : 0;
                  final mValue = totalFunds > 0 ? (totalPercent - pValue) : 0.0;

                  return PieChart(
                    PieChartData(
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 30.r,
                      sections: showingSections(mValue, pValue),
                    ),
                  );
                },
              )
            : Consumer<InvProvider>(
                builder: (context, snapshot, child) {
                  final totalFunding = snapshot.totalFunding;
                  final totalFunds = '${totalFunding.total}'.toDouble;

                  final pValue = '${totalFunding.percentage.floor()}'.toDouble;
                  final totalPercent = totalFunds > 0 ? 100 : 0;
                  final mValue = totalFunds > 0 ? (totalPercent - pValue) : 0.0;

                  return PieChart(
                    PieChartData(
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 30.r,
                      sections: showingSections(mValue, pValue),
                    ),
                  );
                },
              ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(double mv, double pv) {
    return mv > 0 || pv > 0
        ? List.generate(2, (i) {
            switch (i) {
              case 0: // mortage
                return PieChartSectionData(
                  color: Colors.green.shade300,
                  value: mv,
                  title: '${mv.toStringAsFixed(0)}%',
                  radius: 30.0,
                  titleStyle: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: ColorsData.blackColor,
                  ),
                );
              case 1: // propery
                return PieChartSectionData(
                  color: Colors.amber.shade300,
                  value: pv,
                  title: '${pv.toStringAsFixed(0)}%',
                  radius: 30.0,
                  titleStyle: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w900,
                    color: ColorsData.blackColor,
                  ),
                );
              default:
                throw Error();
            }
          })
        : List.generate(1, (i) {
            return PieChartSectionData(
              color: Colors.grey.shade300,
              value: 100,
              title: '${0}%',
              radius: 30.0,
              titleStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: ColorsData.blackColor,
              ),
            );
          });
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  const Indicator({
    super.key,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 8.w,
          height: 8.w,
          child: ColoredBox(color: color),
        ),
        Spacers.sbw5(),
        TextWidget(
          text: text,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        )
      ],
    );
  }
}
