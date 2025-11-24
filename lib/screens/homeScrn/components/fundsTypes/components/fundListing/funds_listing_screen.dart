import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wellkins/constants/paths.dart';

import '../../../../../../constants/colors.dart';
import '../../../../../../constants/strings.dart';
import '../../../../../../models/fund_type.dart';
import '../../../../../../models/history_model.dart';
import '../../../../../../models/returns_model.dart';
import '../../../../../../providers/woo_provider.dart';
import '../../../../../../services/helpers.dart';
import '../../../../../../utils/formatter.dart';
import '../../../../../../utils/transitions_util.dart';
import '../../../../../../widgets/backgrounds.dart';
import '../../../../../../widgets/button_widgets.dart';
import '../../../../../../widgets/common_titles.dart';
import '../../../../../../widgets/custom_appbar.dart';
import '../../../../../../widgets/custom_prompts.dart';
import '../../../../../../widgets/image_widget.dart';
import '../../../../../../widgets/spacers.dart';
import '../../../../../../widgets/text_widget.dart';
import '../../../../../engagementScrn/engagement_tabs.dart';
import '../fundDetails/funds_details_screen.dart';
import './cmpny_listing.dart';

class FundsListingScreen extends StatelessWidget {
  final String title;
  final bool fromDash;
  final int fundSubType;
  const FundsListingScreen({
    super.key,
    required this.title,
    required this.fromDash,
    required this.fundSubType,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        bgImage,
        Scaffold(
          backgroundColor: ColorsData.trColor,
          appBar: CustomAppBar.appbar(ctx: context),
          body: Column(
            children: [
              Spacers.sb8(),
              const EngagementTabs(fromBottom: true),
              Spacers.sb15(),
              CommonTitles.title(
                text: title,
                fontSize: 16,
                iconSize: 12,
                context: context,
              ),
              Spacers.sb10(),
              Expanded(
                child: DelayedDisplay(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
                    padding: EdgeInsets.only(top: 10.w),
                    decoration: commonDecor,
                    child: fromDash
                        ? CompanyListing.buildFundsTile(fundSubType, context)
                        : buildFundsTileClient(context),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildFundsTileClient(BuildContext ctx) {
    final radius = Radius.circular(40.r);
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
      child: Consumer<WooProvider>(
        builder: (context, snapshot, child) {
          final historyList = fundSubType == -1
              //  removes all mortgage funds
              ? snapshot.historyList
                  .where((e) => e.project.fundType != 1)
                  .toList()
              : snapshot.historyList
                  .where((e) => e.project.fundSubType == fundSubType)
                  .toList();

          List<History> invList = [];

          for (final item in historyList) {
            final pId = item.project.id;
            final exists = invList.any((item) => item.project.id == pId);
            if (!exists) {
              invList.add(item);
            }
          }

          return invList.isEmpty
              ? CustomPrompts.showEmptyInfo(
                  icon: Icons.do_not_disturb_alt,
                  text: AppConstants.noData,
                )
              : DelayedDisplay(
                  child: ListView.builder(
                    itemCount: invList.length,
                    itemBuilder: (context, index) {
                      final history = invList[index];
                      return fundTile(history, ctx);
                    },
                  ),
                );
        },
      ),
    );
  }

  Widget fundTile(History history, BuildContext ctx) {
    return Card(
      elevation: 6.w,
      color: ColorsData.whiteColor,
      surfaceTintColor: ColorsData.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
      margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildImage(history),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(history),
                Spacers.sb2(),
                const Divider(color: ColorsData.formHintColor),
                buildTable(history, ctx),
                Spacers.sb5(),
                buildButton(history, ctx),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTable(History history, BuildContext ctx) {
    final isMortgage = history.project.fundType == 1;
    return Table(children: [
      _buildRow(
        title1: AppConstants.totalInvestments,
        value1: Frmtr.frmtCurrency(getTotalInv(history, ctx)),
        title2: AppConstants.totalApplications,
        value2: '${getSameProperyOrders(history, ctx).length}',
      ),
      _buildRow(
        title1: AppConstants.investmentType,
        value1: history.historyItem.holderType,
        title2: AppConstants.term,
        value2: history.project.term,
      ),
      _buildRow(
        title1: AppConstants.propertyType,
        value1: history.project.fundTypeName,
        title2: isMortgage ? AppConstants.loanAmount : AppConstants.value,
        value2: Frmtr.frmtCurrency(history.project.facility),
      ),
      _buildRow(
        title1: AppConstants.status,
        value1: history.historyItem.paidStatus,
        title2: isMortgage ? AppConstants.lvr : '',
        value2: isMortgage ? history.project.lvr : '',
      ),
      if (isMortgage)
        _buildRow(
          title1: AppConstants.returns,
          value1: history.project.returns,
        ),
    ]);
  }

  TableRow _buildRow({
    final String title1 = '',
    final String value1 = '',
    final String title2 = '',
    final String value2 = '',
  }) {
    return TableRow(
      children: [
        _buildCell(title1, value1),
        _buildCell(title2, value2),
      ],
    );
  }

  Widget _buildCell(String text, String value) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: text,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ColorsData.greyColor,
              textAlign: TextAlign.start,
            ),
            TextWidget(
              text: value,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ColorsData.blackColor,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton(History history, BuildContext ctx) {
    return Center(
      child: customButton(
        title: AppConstants.viewDetails,
        height: 34,
        stadium: true,
        icon: Icon(
          Icons.remove_red_eye,
          color: ColorsData.whiteColor,
          size: 15.sp,
        ),
        shadows: [
          const BoxShadow(
            color: ColorsData.formHintColor,
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
        buttonColor: Colors.green,
        fontSize: 14,
        onPressed: () {
          final fundDetails = getFundDetails(history, ctx);
          Navigator.push(
            ctx,
            FadeRoute(
              page: FundsDetailsScreen(
                title: title,
                fundDetails: fundDetails,
              ),
            ),
          );
        },
      ),
    );
  }

  double getTotalInv(History history, BuildContext ctx) {
    final amount = getSameProperyOrders(history, ctx)
        .fold(0.0, (pv, e) => pv + e.historyItem.investingAmount);
    return amount;
  }

  List<History> getSameProperyOrders(History history, BuildContext ctx) {
    final wooProvider = getWooProvider(ctx);

    final pId = history.project.id;
    final samePropOrders = wooProvider.historyList
        .where((item) => item.project.id == pId)
        .toList();
    return samePropOrders;
  }

  List<FundDetails> getFundDetails(History history, BuildContext ctx) {
    final wooProvider = getWooProvider(ctx);
    final List<FundDetails> fundDetails = [];
    final fundType = history.project.fundType;

    final samePropOrders = getSameProperyOrders(history, ctx);

    // Create a map to easily access returns by orderId
    final Map<String, ReturnsData?> returnsMap = {
      for (final rData in wooProvider.returnsList) rData.orderId: rData
    };

    for (final his in samePropOrders) {
      if (fundType == 1) {
        fundDetails.add(
          FundDetails(
            history: his,
            returnsData: returnsMap[his.historyItem.orderId],
          ),
        );
      } else {
        fundDetails.add(FundDetails(history: his));
      }
    }

    // Ensure at least one FundDetails entry exists
    if (fundDetails.isEmpty) {
      fundDetails.add(FundDetails(history: history));
    }

    return fundDetails;
  }

  // List<FundDetails> getFundDetails(History history, BuildContext ctx) {
  //   final wooProvider = getWooProvider(ctx);
  //   final List<FundDetails> fundDetails = [];
  //   final fundType = history.project.fundType;

  //   final samePropOrders = getSameProperyOrders(history, ctx);

  //   for (final his in samePropOrders) {
  //     if (fundType == 1) {
  //       for (final rData in wooProvider.returnsList) {
  //         fundDetails.add(
  //           FundDetails(
  //             history: his,
  //             returnsData:
  //                 his.historyItem.orderId == rData.orderId ? rData : null,
  //           ),
  //         );
  //       }
  //       // for (final rData in wooProvider.returnsList) {
  //       //   if (his.historyItem.orderId == rData.orderId) {
  //       //     fundDetails.add(
  //       //       FundDetails(
  //       //         history: his,
  //       //         returnsData: rData,
  //       //       ),
  //       //     );
  //       //   }
  //       // }
  //     } else {
  //       fundDetails.add(FundDetails(history: his));
  //     }
  //   }

  //   if (fundDetails.isEmpty) {
  //     fundDetails.add(FundDetails(history: history));
  //   }
  //   return fundDetails;
  // }

  Widget buildImage(History history) {
    final images = history.project.images;
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(30.r),
        bottom: Radius.circular(15.r),
      ),
      child: AspectRatio(
        aspectRatio: 2.2,
        child: ImageWidget(
          image: images.isEmpty ? '' : images.first,
          fit: BoxFit.cover,
          errorWidget: Stack(
            alignment: Alignment.center,
            children: [
              bgImage,
              ImageWidget(
                width: 180.w,
                image: Paths.logo,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHeader(History history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: history.project.propertyName,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        TextWidget(
          text: history.project.propType,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
      ],
    );
  }

  // Widget buildDetails(History history, BuildContext ctx) {
  //   double amount = getTotalInv(history, ctx);
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       headerItem(
  //         h1: AppConstants.totalInvestments,
  //         d1: Frmtr.frmtCurrency(amount),
  //       ),
  //       headerItem(
  //         h1: AppConstants.totalApplications,
  //         d1: '${getSameProperyOrders(history, ctx).length}',
  //       ),
  //     ],
  //   );
  // }

//   Widget headerItem({
//     required String h1,
//     required String d1,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 1.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Flexible(
//             flex: 5,
//             child: TextWidget(
//               text: h1,
//               fontSize: 9,
//               fontWeight: FontWeight.w400,
//               color: const Color(0xff252525),
//             ),
//           ),
//           const Spacer(),
//           Flexible(
//             flex: 3,
//             child: TextWidget(
//               text: d1,
//               fontSize: 9,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xff252525),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           )
//         ],
//       ),
//     );
//   }
}

// import 'package:delayed_display/delayed_display.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:wellkins/models/fund_type.dart';

// import '../../../../../constants/colors.dart';
// import '../../../../../constants/strings.dart';
// import '../../../../../models/history_model.dart';
// import '../../../../../models/returns_model.dart';
// import '../../../../../providers/woo_provider.dart';
// import '../../../../../services/helpers.dart';
// import '../../../../../utils/formatter.dart';
// import '../../../../../utils/transitions_util.dart';
// import '../../../../../widgets/backgrounds.dart';
// import '../../../../../widgets/button_widgets.dart';
// import '../../../../../widgets/common_titles.dart';
// import '../../../../../widgets/custom_appbar.dart';
// import '../../../../../widgets/image_widget.dart';
// import '../../../../../widgets/spacers.dart';
// import '../../../../../widgets/text_widget.dart';
// import '../../../../engagementScrn/engagement_tabs.dart';
// import 'funds_details_screen.dart';

// class FundsListingScreen extends StatelessWidget {
//   final String title;
//   final int? fundType;
//   const FundsListingScreen({
//     super.key,
//     required this.title,
//     required this.fundType,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         bgImage,
//         Scaffold(
//           backgroundColor: ColorsData.trColor,
//           appBar: CustomAppBar.appbar(ctx: context),
//           body: Column(
//             children: [
//               Spacers.sb8(),
//               const EngagementTabs(fromBottom: true),
//               Spacers.sb15(),
//               CommonTitles.title(
//                 text: title,
//                 fontSize: 16,
//                 iconSize: 12,
//                 context: context,
//               ),
//               Spacers.sb10(),
//               Expanded(
//                 child: DelayedDisplay(
//                   child: Container(
//                     width: double.infinity,
//                     margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
//                     padding: EdgeInsets.fromLTRB(10.w, 20.w, 10.w, 0),
//                     decoration: commonDecor,
//                     child: fundType == null
//                         ? const SizedBox()
//                         : buildFundsTile(context),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }

//   Widget buildFundsTile(BuildContext ctx) {
//     return Consumer<WooProvider>(
//       builder: (context, snapshot, child) {
//         final historyList = snapshot.historyList
//             .where((e) => e.project.fundType == fundType)
//             .toList();

//         List<History> invList = [];

//         for (final item in historyList) {
//           final pId = item.project.id;
//           final exists = invList.any((item) => item.project.id == pId);
//           if (!exists) {
//             invList.add(item);
//           }
//         }

//         return DelayedDisplay(
//           child: ListView.builder(
//             itemCount: invList.length,
//             itemBuilder: (context, index) {
//               final history = invList[index];
//               return fundTile(history, ctx);
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget fundTile(History history, BuildContext ctx) {
//     return SizedBox(
//       height: 200.h,
//       child: Card(
//         elevation: 6,
//         color: ColorsData.whiteColor,
//         surfaceTintColor: ColorsData.whiteColor,
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
//         margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
//         child: Padding(
//           padding: EdgeInsets.all(10.w),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(child: buildImage(history)),
//               Spacers.sbw25(),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     buildHeader(history),
//                     Spacers.sb5(),
//                     const Divider(color: ColorsData.formHintColor),
//                     buildDetails(history, ctx),
//                     const Spacer(),
//                     buildButton(history, ctx),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildButton(History history, BuildContext ctx) {
//     return customButton(
//       title: AppConstants.viewDetails,
//       height: 32,
//       width: 135,
//       stadium: true,
//       icon: Icon(
//         Icons.remove_red_eye,
//         color: ColorsData.whiteColor,
//         size: 13.sp,
//       ),
//       shadows: [
//         const BoxShadow(
//           color: ColorsData.formHintColor,
//           spreadRadius: 1,
//           blurRadius: 1,
//           offset: Offset(0, 1),
//         ),
//       ],
//       buttonColor: Colors.green,
//       fontSize: 11,
//       onPressed: () {
//         // final sameProperyOrders = getSameProperyOrders(history, ctx);
//         // final orderReturns = getOrderReturns(ctx);
//         final fundDetails = getFundDetails(history, ctx);
//         Navigator.push(
//           ctx,
//           FadeRoute(
//             page: FundsDetailsScreen(
//               title: title,
//               fundDetails: fundDetails,
//               // sameProperyOrders: sameProperyOrders,
//               // orderReturns: orderReturns,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   List<History> getSameProperyOrders(History history, BuildContext ctx) {
//     final wooProvider = getWooProvider(ctx);

//     final pId = history.project.id;
//     final samePropOrders = wooProvider.historyList
//         .where((item) => item.project.id == pId)
//         .toList();
//     return samePropOrders;
//   }

//   List<ReturnsData> getOrderReturns(BuildContext ctx) {
//     // final oId = history.historyItem.orderId;
//     // final orderReturns =
//     //     wooProvider.returnsList.where((item) => item.orderId == oId).toList();
//     final wooProvider = getWooProvider(ctx);
//     final List<ReturnsData> orderReturns = [];
//     final historyList = wooProvider.historyList
//         .where((e) => e.project.fundType == fundType)
//         .toList();

//     for (final history in historyList) {
//       for (final returns in wooProvider.returnsList) {
//         if (history.historyItem.orderId == returns.orderId) {
//           orderReturns.add(returns);
//         }
//       }
//     }

//     return orderReturns;
//   }

//   List<FundDetails> getFundDetails(History history, BuildContext ctx) {
//     final wooProvider = getWooProvider(ctx);
//     final List<FundDetails> fundDetails = [];
//     final pId = history.project.id;

//     final samePropOrders = wooProvider.historyList
//         .where((item) => item.project.id == pId)
//         .toList();

//     for (final his in samePropOrders) {
//       for (final rData in wooProvider.returnsList) {
//         if (his.historyItem.orderId == rData.orderId) {
//           fundDetails.add(
//             FundDetails(
//               history: his,
//               returnsData: rData,
//             ),
//           );
//         }
//       }
//     }

//     return fundDetails;
//   }

//   Widget buildImage(History history) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(15.r),
//       child: ImageWidget(
//         height: double.infinity,
//         width: double.infinity,
//         image: history.project.images[0],
//         fit: BoxFit.cover,
//       ),
//     );
//   }

//   Widget buildHeader(History history) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextWidget(
//           text: history.project.propertyName,
//           fontSize: 12,
//           fontWeight: FontWeight.bold,
//           maxLines: 2,
//           overflow: TextOverflow.ellipsis,
//         ),
//         TextWidget(
//           text: history.project.propType,
//           fontSize: 8,
//           fontWeight: FontWeight.w300,
//         ),
//       ],
//     );
//   }

//   Widget buildDetails(History history, BuildContext ctx) {
//     final amount = getSameProperyOrders(history, ctx)
//         .fold(0.0, (pv, e) => pv + e.historyItem.investingAmount);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         headerItem(
//           h1: AppConstants.totalInvestments,
//           d1: Frmtr.frmtCurrency(amount),
//         ),
//         headerItem(
//           h1: AppConstants.totalApplications,
//           d1: '${getSameProperyOrders(history, ctx).length}',
//         ),
//       ],
//     );
//   }

//   Widget headerItem({
//     required String h1,
//     required String d1,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 1.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Flexible(
//             flex: 5,
//             child: TextWidget(
//               text: h1,
//               fontSize: 9,
//               fontWeight: FontWeight.w400,
//               color: const Color(0xff252525),
//             ),
//           ),
//           const Spacer(),
//           Flexible(
//             flex: 3,
//             child: TextWidget(
//               text: d1,
//               fontSize: 9,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xff252525),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// import 'package:delayed_display/delayed_display.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../../../constants/colors.dart';
// import '../../../../../constants/strings.dart';
// import '../../../../../utils/transitions_util.dart';
// import '../../../../../widgets/backgrounds.dart';
// import '../../../../../widgets/button_widgets.dart';
// import '../../../../../widgets/common_titles.dart';
// import '../../../../../widgets/custom_appbar.dart';
// import '../../../../../widgets/image_widget.dart';
// import '../../../../../widgets/spacers.dart';
// import '../../../../../widgets/text_widget.dart';
// import '../../../../engagementScrn/components/engagement_tabs.dart';
// import '../../../../engagementScrn/components/voting_screen.dart';
// import 'funds_details_screen.dart';

// class FundsListingScreen extends StatelessWidget {
//   final String title;
//   final int fundType;
//   const FundsListingScreen({
//     super.key,
//     required this.title,
//     required this.fundType,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         bgImage,
//         Scaffold(
//           backgroundColor: ColorsData.trColor,
//           appBar: CustomAppBar.appbar(ctx: context),
//           body: Column(
//             children: [
//               Spacers.sb8(),
//               const EngagementTabs(fromBottom: true),
//               Spacers.sb15(),
//               CommonTitles.title(
//                 text: title,
//                 fontSize: 16,
//                 iconSize: 12,
//                 context: context,
//               ),
//               Spacers.sb10(),
//               Expanded(
//                 child: DelayedDisplay(
//                   child: Container(
//                     width: double.infinity,
//                     margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
//                     padding: EdgeInsets.fromLTRB(10.w, 20.w, 10.w, 0),
//                     decoration: commonDecor,
//                     child: buildFundsTile(context),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }

//   Widget buildFundsTile(BuildContext ctx) {
//     return DelayedDisplay(
//       child: ListView.builder(
//         itemCount: votingProjectList.length,
//         itemBuilder: (context, index) {
//           final fund = votingProjectList[index];
//           return fundTile(fund, ctx);
//         },
//       ),
//     );
//   }

//   Widget fundTile(VotingProject fund, BuildContext ctx) {
//     return Card(
//       elevation: 6,
//       color: ColorsData.whiteColor,
//       surfaceTintColor: ColorsData.whiteColor,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
//       margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
//       child: Padding(
//         padding: EdgeInsets.all(10.w),
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(child: buildImage(fund)),
//                 Spacers.sbw25(),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       buildHeader(fund),
//                       Spacers.sb5(),
//                       const Divider(color: ColorsData.formHintColor),
//                       buildDetails(fund),
//                       Spacers.sb30(),
//                       buildButton(fund, ctx),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildButton(VotingProject fund, BuildContext ctx) {
//     return customButton(
//       title: AppConstants.viewDetails,
//       height: 32,
//       width: 135,
//       stadium: true,
//       icon: Icon(
//         Icons.remove_red_eye,
//         color: ColorsData.whiteColor,
//         size: 13.sp,
//       ),
//       shadows: [
//         const BoxShadow(
//           color: ColorsData.formHintColor,
//           spreadRadius: 1,
//           blurRadius: 1,
//           offset: Offset(0, 1),
//         ),
//       ],
//       buttonColor: Colors.green,
//       fontSize: 11,
//       onPressed: () {
//         Navigator.push(
//           ctx,
//           FadeRoute(
//             page: FundsDetailsScreen(
//               title: title,
//               fund: fund,
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget buildImage(VotingProject project) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(15.r),
//       child: AspectRatio(
//         aspectRatio: 1.2,
//         child: ImageWidget(
//           image: project.image,
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }

//   Widget buildHeader(VotingProject project) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextWidget(
//           text: project.name,
//           fontSize: 14,
//           fontWeight: FontWeight.w600,
//         ),
//         TextWidget(
//           text: project.type,
//           fontSize: 8,
//           fontWeight: FontWeight.w300,
//         ),
//       ],
//     );
//   }

//   Widget buildDetails(VotingProject project) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         headerItem(
//           h1: AppConstants.totalInvestments,
//           d1: '\$${project.totalInvestment}',
//         ),
//         headerItem(
//           h1: AppConstants.totalApplications,
//           d1: project.totalApplication,
//         ),
//       ],
//     );
//   }

//   Widget headerItem({
//     required String h1,
//     required String d1,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 1.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Flexible(
//             flex: 5,
//             child: TextWidget(
//               text: h1,
//               fontSize: 9,
//               fontWeight: FontWeight.w400,
//               color: const Color(0xff252525),
//             ),
//           ),
//           const Spacer(),
//           Flexible(
//             flex: 3,
//             child: TextWidget(
//               text: d1,
//               fontSize: 9,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xff252525),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
