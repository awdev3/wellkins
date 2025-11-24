import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../constants/strings.dart';
import '../../../../providers/dash_provider.dart';
import '../../../../providers/inv_provider.dart';
import '../../../../services/helpers.dart';
import '../../../../widgets/loaders.dart';
import '../../../../widgets/spacers.dart';
import '../../../../widgets/text_widget.dart';

class PopularityAndFundsChart extends StatelessWidget {
  final bool fromDash;
  const PopularityAndFundsChart({
    super.key,
    required this.fromDash,
  });

  Widget bottomTitles(double value, TitleMeta meta, BuildContext ctx) {
    if (fromDash) {
      String text = '';
      final dashProvider = getDashProvider(ctx);

      text = dashProvider.popularityFund!.months[value.toInt()];
      if (meta.formattedValue.contains('.')) {
        return const SizedBox();
      }

      return SideTitleWidget(
        meta: meta,
        space: 8.w,
        child: TextWidget(
          text: text,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      );
    } else {
      String text = '';
      final invProvider = getInvProvider(ctx);

      text = invProvider.popularityFund!.months[value.toInt()];
      if (meta.formattedValue.contains('.')) {
        return const SizedBox();
      }

      return SideTitleWidget(
        meta: meta,
        space: 8.w,
        child: TextWidget(
          text: text,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  Widget leftTitles(double value, TitleMeta meta) {
    // if (value == meta.max) {
    //   return const SizedBox();
    // }

    return SideTitleWidget(
      meta: meta,
      space: 8.w,
      child: TextWidget(
        text: meta.formattedValue,
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  List<FlSpot> getLineCurrentData(BuildContext ctx) {
    // return [
    //   const FlSpot(0, 40),
    //   const FlSpot(1, 55),
    //   const FlSpot(2, 80),
    //   const FlSpot(3, 90),
    // ];
    if (fromDash) {
      final List<FlSpot> data = [];
      final dashProvider = getDashProvider(ctx);
      final popularityFundList = dashProvider.popularityFund;

      for (int i = 0; i < popularityFundList!.currentYear.length; i++) {
        data.add(
          FlSpot((i).toDouble(), popularityFundList.currentYear[i]),
        );
      }
      return data;
    } else {
      final List<FlSpot> data = [];
      final invProvider = getInvProvider(ctx);
      final popularityFundList = invProvider.popularityFund;

      for (int i = 0; i < popularityFundList!.currentYear.length; i++) {
        data.add(
          FlSpot((i).toDouble(), popularityFundList.currentYear[i]),
        );
      }
      return data;
    }
  }

  List<FlSpot> getLinePreviousData(BuildContext ctx) {
    // return [
    //   const FlSpot(0, 80),
    //   const FlSpot(1, 95),
    //   const FlSpot(2, 125),
    //   const FlSpot(3, 145),
    // ];

    if (fromDash) {
      final List<FlSpot> data = [];
      final dashProvider = getDashProvider(ctx);
      final popularityFundList = dashProvider.popularityFund;

      for (int i = 0; i < popularityFundList!.previousYear.length; i++) {
        data.add(
          FlSpot(i.toDouble(), popularityFundList.previousYear[i]),
        );
      }

      return data;
    } else {
      final List<FlSpot> data = [];
      final invProvider = getInvProvider(ctx);
      final popularityFundList = invProvider.popularityFund;

      for (int i = 0; i < popularityFundList!.previousYear.length; i++) {
        data.add(
          FlSpot(i.toDouble(), popularityFundList.previousYear[i]),
        );
      }

      return data;
    }
  }

  bool showPopData(BuildContext ctx) {
    if (fromDash) {
      final dashProvider = getDashProvider(ctx);
      return dashProvider.popularityFund != null &&
          (dashProvider.popularityFund!.currentYear.isNotEmpty ||
              dashProvider.popularityFund!.previousYear.isNotEmpty);
    } else {
      final invProvider = getInvProvider(ctx);
      return invProvider.popularityFund != null &&
          (invProvider.popularityFund!.currentYear.isNotEmpty ||
              invProvider.popularityFund!.previousYear.isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return !showPopData(context)
        ? const SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget(AppConstants.popularityAndFunds),
              SizedBox(height: 20.h),
              SizedBox(
                height: 180.h,
                child: Row(
                  children: [
                    const RotatedBox(
                      quarterTurns: 3,
                      child: TextWidget(
                        text: AppConstants.inMillion,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    Spacers.sbw5(),
                    Expanded(
                      child: Column(
                        children: [
                          buildLineChart(context),
                          Spacers.sb5(),
                          const TextWidget(
                            text: AppConstants.monthsQuarterly,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      children: [
                        Spacers.sb40(),
                        yearMarkerRef(
                            AppConstants.currentYear, Colors.red.shade400),
                        yearMarkerRef(
                            AppConstants.previousYear, Colors.amber.shade400),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          );
  }

  Widget buildLineChart(BuildContext ctx) {
    return Expanded(
      child: fromDash
          ? Consumer<DashProvider>(
              builder: (context, snapshot, child) {
                return snapshot.homeLoad
                    ? showLoader()
                    : snapshot.popularityFund == null
                        ? const SizedBox()
                        : lineChartItem(ctx);
              },
            )
          : Consumer<InvProvider>(
              builder: (context, snapshot, child) {
                return snapshot.homeLoad
                    ? showLoader()
                    : snapshot.popularityFund == null
                        ? const SizedBox()
                        : lineChartItem(ctx);
              },
            ),
    );
  }

  LineChart lineChartItem(BuildContext ctx) {
    return LineChart(
      LineChartData(
        minY: 0,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        lineTouchData: lineTouchData(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28.w,
              interval: 50,
              getTitlesWidget: leftTitles,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28.w,
              getTitlesWidget: (value, meta) => bottomTitles(
                value,
                meta,
                ctx,
              ),
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          lineCurrent(ctx),
          linePrevious(ctx),
        ],
      ),
    );
  }

  LineChartBarData lineCurrent(BuildContext ctx) {
    return LineChartBarData(
      spots: getLineCurrentData(ctx),
      isCurved: false,
      color: Colors.red.shade400,
      belowBarData: BarAreaData(
        show: true,
        color: Colors.red.shade400,
      ),
      dotData: FlDotData(
        show: true,
        getDotPainter: (FlSpot spot, double xPercentage,
            LineChartBarData barData, int index) {
          return FlDotCirclePainter(
            radius: 3,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: Colors.red.shade400,
          );
        },
      ),
    );
  }

  LineChartBarData linePrevious(BuildContext ctx) {
    return LineChartBarData(
      spots: getLinePreviousData(ctx),
      isCurved: false,
      color: Colors.amber.shade400,
      dotData: FlDotData(
        show: true,
        getDotPainter: (FlSpot spot, double xPercentage,
            LineChartBarData barData, int index) {
          return FlDotCirclePainter(
            radius: 3,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: Colors.amber.shade400,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: true,
        color: Colors.amber.shade400,
      ),
    );
  }

  LineTouchData lineTouchData() {
    return LineTouchData(
      // enabled: true,
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipColor: (touchedSpot) => Colors.black.withValues(alpha: 0.65),
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((LineBarSpot touchedSpot) {
            return LineTooltipItem(
              '${touchedSpot.y}',
              MyFont.robotoTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: touchedSpot.barIndex == 0
                    ? Colors.red.shade400
                    : Colors.amber.shade400,
              ),
              // children: [
              //   TextSpan(
              //     text: ' Million',
              //     style: MyFont.robotoTextStyle(
              //       fontSize: 16,
              //       fontWeight: FontWeight.w900,
              //       color: ColorsData.whiteColor,
              //     ),
              //   )
              // ],
            );
          }).toList();
        },
      ),
      // touchCallback: (LineTouchResponse touchResponse) {},
    );
  }

  Widget yearMarkerRef(String text, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(
          width: 15.w,
          child: Divider(color: color),
        ),
        Spacers.sbw5(),
        TextWidget(
          text: text,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.05,
        ),
      ],
    );
  }

  TextWidget titleWidget(String title) {
    return TextWidget(
      text: title,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class PopularityAndFundsChart extends StatelessWidget {
//   const PopularityAndFundsChart({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 220.h,
//       child: LineChart(
//         LineChartData(
//           borderData: FlBorderData(show: false),
//           gridData: const FlGridData(show: false),
//           titlesData: const FlTitlesData(
//             topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//             rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           ),
//           lineBarsData: [
//             LineChartBarData(
//               spots: [
//                 const FlSpot(0, 3.7),
//                 const FlSpot(1, 3.9),
//                 const FlSpot(2, 4.4),
//                 const FlSpot(3, 4.5),
//               ],
//               isCurved: false,
//               color: Colors.red.shade400,
//               dotData: FlDotData(
//                 show: true,
//                 getDotPainter: (FlSpot spot, double xPercentage,
//                     LineChartBarData barData, int index) {
//                   return FlDotCirclePainter(
//                     radius: 3,
//                     color: Colors.white,
//                     strokeWidth: 2,
//                     strokeColor: Colors.red.shade400,
//                   );
//                 },
//               ),
//               belowBarData: BarAreaData(
//                 show: true,
//                 color: Colors.red.shade400,
//               ),
//             ),
//             LineChartBarData(
//               spots: [
//                 const FlSpot(0, 3.5),
//                 const FlSpot(1, 3.6),
//                 const FlSpot(2, 3.9),
//                 const FlSpot(3, 4),
//               ],
//               isCurved: false,
//               color: Colors.amber.shade400,
//               belowBarData: BarAreaData(
//                 show: true,
//                 color: Colors.amber.shade400,
//               ),
//               dotData: FlDotData(
//                 show: true,
//                 getDotPainter: (FlSpot spot, double xPercentage,
//                     LineChartBarData barData, int index) {
//                   return FlDotCirclePainter(
//                     radius: 3,
//                     color: Colors.white,
//                     strokeWidth: 2,
//                     strokeColor: Colors.amber.shade400,
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
