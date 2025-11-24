import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LossChart extends StatelessWidget {
  final double percentageChange;

  const LossChart({super.key, required this.percentageChange});

  @override
  Widget build(BuildContext context) {
    return LineChart(
      lineChartData(),
      duration: const Duration(milliseconds: 250),
    );
  }

  LineChartData lineChartData() {
    // Define the range for the curvature adjustment
    double curveFactor = 1.0 - (percentageChange / 100);

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      minX: -1,
      maxX: 16,
      minY: 0,
      maxY: 20,
      lineBarsData: [
        LineChartBarData(
          barWidth: 1,
          isStrokeCapRound: true,
          isCurved: true,
          color: Colors.red,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.red.withValues(alpha: 0.4),
                Colors.red.withValues(alpha: 0.3),
                Colors.red.withValues(alpha: 0.2),
                Colors.red.withValues(alpha: 0.06),
                Colors.red.withValues(alpha: 0.03),
              ],
            ),
          ),
          dotData: FlDotData(
            show: true,
            checkToShowDot: (FlSpot spot, LineChartBarData barData) {
              return spot.x == 9.7;
            },
            getDotPainter: (FlSpot spot, double xPercentage,
                LineChartBarData barData, int index) {
              return FlDotCirclePainter(
                radius: 2,
                color: Colors.red,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          spots: [
            const FlSpot(-1, 7),
            const FlSpot(0, 9),
            const FlSpot(2.4, 18),
            FlSpot(7, 7 * curveFactor),
            FlSpot(9.7, 15 * curveFactor),
            FlSpot(14, 4 * curveFactor),
            const FlSpot(16, 8),
          ],
        ),
      ],
    );
  }
}


// class LineChartWidget2 extends StatelessWidget {
//   final double percentageChange;

//   const LineChartWidget2({super.key, required this.percentageChange});

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
//       minY: 0, // Adjusted minY
//       maxY: 20, // Adjusted maxY
//       lineBarsData: [
//         LineChartBarData(
//           barWidth: 1,
//           isStrokeCapRound: true,
//           isCurved: true,
//           color: Colors.red,
//           belowBarData: BarAreaData(
//               show: true,
//               gradient: LinearGradient(
//                   begin: Alignment.bottomCenter,
//                   end: Alignment.topCenter,
//                   colors: [
//                     Colors.red.withValues(alpha: 0.1),
//                     Colors.red.withValues(alpha: 0.2),
//                     Colors.red.withValues(alpha: 0.3),
//                   ])),
//           dotData: const FlDotData(show: false),
//           spots: [
//             const FlSpot(-1, 7),
//             const FlSpot(0, 9),
//             const FlSpot(2.4, 18),
//             const FlSpot(7, 7),
//             const FlSpot(9.7, 15),
//             const FlSpot(14, 4),
//             const FlSpot(16, 8),
//           ],
//         ),
//       ],
//     );
//   }

//   FlTitlesData tilesData() => const FlTitlesData(
//         show: false,
//       );
// }