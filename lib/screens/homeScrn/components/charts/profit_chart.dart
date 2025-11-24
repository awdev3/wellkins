import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProfitChart extends StatelessWidget {
  final double percentageChange;

  const ProfitChart({super.key, required this.percentageChange});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      lineChartData(),
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData lineChartData() {
    // Determine the maximum value based on percentage change
    double maxValue = 5; // Default maximum value
    if (percentageChange > 0) {
      maxValue += maxValue * (percentageChange / 100);
    }

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      minX: 0,
      maxX: 15,
      minY: 0,
      maxY: maxValue, // Adjusted maximum value
      lineBarsData: [
        LineChartBarData(
          barWidth: 1,
          isStrokeCapRound: true,
          isCurved: true,
          color: Colors.green,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green.withValues(alpha: 0.8),
                Colors.green.withValues(alpha: 0.4),
                Colors.green.withValues(alpha: 0.2),
                Colors.green.withValues(alpha: 0.03),
              ],
            ),
          ),
          dotData: FlDotData(
            show: true,
            checkToShowDot: (FlSpot spot, LineChartBarData barData) {
              return spot.x == 13.4;
            },
            getDotPainter: (FlSpot spot, double xPercentage,
                LineChartBarData barData, int index) {
              return FlDotCirclePainter(
                radius: 2,
                color: Colors.green,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          spots: [
            const FlSpot(0, 0),
            const FlSpot(1, 0.4),
            const FlSpot(3, 1.8),
            const FlSpot(5.8, 1.5),
            const FlSpot(7.8, 3.2),
            const FlSpot(9.4, 3.8),
            const FlSpot(11.8, 2.2),
            const FlSpot(13.4, 3),
            FlSpot(15, maxValue),
            FlSpot(15.5, maxValue * 1.05),
          ],
        ),
      ],
    );
  }
}

// class LineChartWidget extends StatelessWidget {
//   final double value; // Value between -1 and 1

//   const LineChartWidget({super.key, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return LineChart(
//       lineChartData(),
//       duration: const Duration(milliseconds: 250),
//     );
//   }

//   LineChartData lineChartData() {
//     return LineChartData(
//       gridData: const FlGridData(show: false),
//       titlesData: tilesData(),
//       borderData: FlBorderData(show: false),
//       minX: 0,
//       maxX: 15,
//       minY: 0,
//       maxY: 5,
//       lineBarsData: [
//         LineChartBarData(
//           barWidth: 1,
//           isStrokeCapRound: true,
//           isCurved: true,
//           color: Colors.green,
//           belowBarData: BarAreaData(
//               show: true,
//               gradient: LinearGradient(
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                   colors: [
//                     Colors.green.withValues(alpha: 0.1),
//                     Colors.green.withValues(alpha: 0.2),
//                     Colors.green.withValues(alpha: 0.4),
//                   ])),
//           dotData: const FlDotData(show: false),
//           spots: [
//             // FlSpot(0, 0),
//             // FlSpot(1, value * 10),
//             // FlSpot(2, 0),
//             // FlSpot(-0.8, -0.25),
//             // FlSpot(0, 0),
//             // FlSpot(2, 1.5),
//             // FlSpot(3, 1),
//             // FlSpot(5, 3),
//             // FlSpot(7, 3.5),
//             // FlSpot(9, 2.2),
//             // FlSpot(11, 3.2),
//             // FlSpot(13, 4.5),
//             // FlSpot(14, 4.7),

//             FlSpot(0, 0),
//             FlSpot(1, 0.4),
//             FlSpot(3, 1.8),
//             FlSpot(5.8, 1.5),
//             FlSpot(7.4, 3.6),
//             FlSpot(9.4, 3.9),
//             FlSpot(11.4, 2.6),
//             FlSpot(13, 3),
//             FlSpot(15, 6),
//             FlSpot(15.5, 6.3),
//           ],
//         ),
//       ],
//     );
//   }

//   FlTitlesData tilesData() => FlTitlesData(
//         show: false,
//         // bottomTitles: AxisTitles(sideTitles:side ),
//         // rightTitles: AxisTitles(sideTitles:SideTitles(showTitles: false) ),
//         //   topTitles: AxisTitles(sideTitles:SideTitles(showTitles: false) ),
//         //    leftTitles : leftTiles(),
//       );

//   // AxisTitles leftTiles() => AxisTitles(sideTitles: );
// }
