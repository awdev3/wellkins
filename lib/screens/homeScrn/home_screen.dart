import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../services/helpers.dart';
import '../../widgets/spacers.dart';
import '../engagementScrn/engagement_tabs.dart';
import 'components/dashInvstScrn/dash_invest_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> getHomeDashInvData(BuildContext context) async {
    final dashProvider = getDashProvider(context);
    final invProvider = getInvProvider(context);
    dashProvider.getDashBoardData(context);
    invProvider.getDashInvData(context);
  }

  @override
  Widget build(BuildContext context) {
    getHomeDashInvData(context);

    return Scaffold(
      backgroundColor: ColorsData.trColor,
      body: Column(
        children: [
          Spacers.sb8(),
          const EngagementTabs(fromBottom: true),
          Spacers.sb15(),
          const DashAndInvestScreen(),
          Spacers.sb20(),
        ],
      ),
    );
  }
}

// Expanded(
  //   child: Container(
  //     height: 95.h,
  //     padding: EdgeInsets.all(10.w),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(10.r),
  //       color: ColorsData.whiteColor,
  //       boxShadow: const [
  //         BoxShadow(
  //           color: Color.fromARGB(55, 0, 0, 0),
  //           spreadRadius: 1,
  //           blurRadius: 4,
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Container(
  //               padding: EdgeInsets.fromLTRB(
  //                   10.w, 4.w, 10.w, 4.w),
  //               decoration: const ShapeDecoration(
  //                 color: Color(0xff378BFB),
  //                 shape: StadiumBorder(),
  //               ),
  //               child: const FittedBox(
  //                 child: TextWidget(
  //                   text: AppConstants.mortgageFund,
  //                   fontSize: 11,
  //                   fontWeight: FontWeight.w500,
  //                   color: ColorsData.whiteColor,
  //                 ),
  //               ),
  //             ),
  //             const Spacer(),
  //             const TextWidget(
  //               text: AppConstants.investments,
  //               fontSize: 10,
  //               fontWeight: FontWeight.bold,
  //             ),
  //             const TextWidget(
  //               text: '\$50,000,000',
  //               fontSize: 14,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ],
  //         ),
  //         SizedBox(width: 2.w),
  //         const Expanded(
  //           child: Column(
  //             mainAxisAlignment:
  //                 MainAxisAlignment.spaceBetween,
  //             children: [
  //               Flexible(
  //                 child: FittedBox(
  //                   child: TextWidget(
  //                     text: '-10%',
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.bold,
  //                     color: Colors.red,
  //                   ),
  //                 ),
  //               ),
  //               // Spacer(),
  //               Expanded(
  //                 child: LossChart(percentageChange: -10),
  //               ),
  //             ],
  //           ),
  //         )
  //       ],
  //     ),
  //   ),
  // ),
