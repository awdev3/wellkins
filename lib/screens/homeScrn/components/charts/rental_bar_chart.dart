import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/strings.dart';
import '../../../../services/helpers.dart';
import '../../../../widgets/text_widget.dart';

class RentalBarChart extends StatefulWidget {
  final bool fromDash;
  const RentalBarChart({
    super.key,
    required this.fromDash,
  });

  @override
  State<StatefulWidget> createState() => RentalBarChartState();
}

class RentalBarChartState extends State<RentalBarChart> {
  Widget bottomTitles(double value, TitleMeta meta) {
    if (widget.fromDash) {
      final dashProvider = getDashProvider(context, listen: true);
      String text = '';
      if (value.toInt() >= 0 &&
          value.toInt() < dashProvider.rentalYeliedList.length) {
        text = dashProvider.rentalYeliedList[value.toInt()].month;
      }

      return SideTitleWidget(
        meta: meta,
        space: 8.w,
        child: TextWidget(
          text: text,
          fontSize: 8,
          fontWeight: FontWeight.w400,
        ),
      );
    } else {
      final invProvider = getInvProvider(context, listen: true);
      String text = '';
      if (value.toInt() >= 0 &&
          value.toInt() < invProvider.rentalYeliedList.length) {
        text = invProvider.rentalYeliedList[value.toInt()].month;
      }

      return SideTitleWidget(
        meta: meta,
        space: 8.w,
        child: TextWidget(
          text: text,
          fontSize: 8,
          fontWeight: FontWeight.w400,
        ),
      );
    }
  }

  Widget leftTitles(double value, TitleMeta meta) {
    // if (value == meta.max) {
    //   return Container();
    // }
    return SideTitleWidget(
      meta: meta,
      space: 8.w,
      child: TextWidget(
        text: meta.formattedValue,
        fontSize: 8,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  bool showRental() {
    if (widget.fromDash) {
      final dashProvider = getDashProvider(context);
      return dashProvider.rentalYeliedList.isNotEmpty;
    } else {
      final invProvider = getInvProvider(context);
      return invProvider.rentalYeliedList.isNotEmpty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return !showRental()
        ? const SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget(AppConstants.rentalYeilds),
              SizedBox(height: 5.h),
              Container(
                padding: EdgeInsets.fromLTRB(0, 15.w, 15.w, 5.w),
                margin: EdgeInsets.all(8.w),
                decoration: _decor1(),
                child: AspectRatio(
                  aspectRatio: 2,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final barsSpace = 20.w * constraints.maxWidth / 400.w;
                      final barsWidth = 10.w * constraints.maxWidth / 400.w;
                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.center,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28.w,
                                getTitlesWidget: bottomTitles,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40.w,
                                interval: 50,
                                getTitlesWidget: leftTitles,
                              ),
                            ),
                            topTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            checkToShowHorizontalLine: (value) =>
                                value % 10 == 0,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: ColorsData.formHintColor
                                  .withValues(alpha: 0.1),
                              strokeWidth: 1,
                            ),
                            drawVerticalLine: false,
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: const Border(
                              bottom:
                                  BorderSide(color: ColorsData.formHintColor),
                              left: BorderSide(color: ColorsData.formHintColor),
                            ),
                          ),
                          groupsSpace: barsSpace,
                          barGroups: getData(barsWidth, barsSpace),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          );
  }

  List<BarChartGroupData> getData(double barsWidth, double barsSpace) {
    if (widget.fromDash) {
      final dashProvider = getDashProvider(context, listen: true);
      return List.generate(
        dashProvider.rentalYeliedList.length,
        (index) => barData(
          index,
          dashProvider.rentalYeliedList[index].value,
          barsSpace,
          barsWidth,
        ),
      );
    } else {
      final invProvider = getInvProvider(context, listen: true);
      return List.generate(
        invProvider.rentalYeliedList.length,
        (index) => barData(
          index,
          invProvider.rentalYeliedList[index].value,
          barsSpace,
          barsWidth,
        ),
      );
    }
  }

  BarChartGroupData barData(
    int index,
    double value,
    double barsSpace,
    double barsWidth,
  ) {
    return BarChartGroupData(
      x: index,
      barsSpace: barsSpace,
      barRods: [
        BarChartRodData(
          toY: value,
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(2.r),
          width: barsWidth,
        ),
      ],
    );
  }

  BoxDecoration _decor1() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10.r),
      color: ColorsData.whiteColor,
      boxShadow: const [
        BoxShadow(
          color: Color.fromARGB(25, 0, 0, 0),
          spreadRadius: 1,
          blurRadius: 1,
        ),
        BoxShadow(
          color: Color.fromARGB(93, 244, 67, 54),
          spreadRadius: 1,
          blurRadius: 1,
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
