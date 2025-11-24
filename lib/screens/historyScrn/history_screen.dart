import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../constants/paths.dart';
import '../../constants/strings.dart';
import '../../models/history_model.dart';
import '../../providers/woo_provider.dart';
import '../../services/helpers.dart';
import '../../utils/formatter.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/custom_prompts.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/loaders.dart';
import '../../widgets/spacers.dart';
import '../../widgets/text_widget.dart';
import '../engagementScrn/engagement_tabs.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> getHistory(BuildContext ctx) async {
    executePostFrameCallback(() async {
      await refreshHistory(ctx);
    });
  }

  Future<void> refreshHistory(ctx) async {
    final wooProvider = getWooProvider(ctx);
    await wooProvider.getProjects(ctx).whenComplete(() async {
      await wooProvider.getHistory(ctx);
      await wooProvider.getReturns(ctx);
    });
  }

  @override
  Widget build(BuildContext context) {
    getHistory(context);
    return Scaffold(
      backgroundColor: ColorsData.trColor,
      body: Column(
        children: [
          Spacers.sb8(),
          const EngagementTabs(fromBottom: true),
          Spacers.sb15(),
          buildTitle(context),
          Spacers.sb10(),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
              padding: EdgeInsets.only(top: 10.w),
              decoration: commonDecor,
              child: buildHistoryTile(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHistoryTile() {
    final radius = Radius.circular(40.r);
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
      child: Consumer<WooProvider>(
        builder: (context, snapshot, child) {
          final historyList = snapshot.historyList;
          return snapshot.projectLoad || snapshot.historyLoad
              ? showLoader()
              : snapshot.historyList.isEmpty
              ? CustomPrompts.showEmptyInfo(
                  icon: Icons.do_not_disturb_alt,
                  text: AppConstants.noData,
                )
              : RefreshIndicator(
                  onRefresh: () async => refreshHistory(context),
                  child: ListView.builder(
                    itemCount: historyList.length,
                    itemBuilder: (context, index) {
                      final history = historyList[index];
                      return historyTile(history);
                    },
                  ),
                );
        },
      ),
    );
  }

  Widget historyTile(History history) {
    return Card(
      elevation: 6.w,
      color: ColorsData.whiteColor,
      surfaceTintColor: ColorsData.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      margin: EdgeInsets.symmetric(vertical: 8.w, horizontal: 10.w),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            invHeaderAndImage(history),
            const Divider(color: ColorsData.formHintColor),
            invDetails(history),
          ],
        ),
      ),
    );
  }

  Widget invHeaderAndImage(History history) {
    return Row(
      children: [
        invHeader(history),
        Spacers.sbw50(),
        Spacers.sbw10(),
        invImage(history),
      ],
    );
  }

  Widget invHeader(History history) {
    return Expanded(
      flex: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: AppConstants.orderID,
            t2: history.historyItem.orderId,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xff666666),
          ),
          TextWidget(
            text: history.project.propertyName,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget invImage(History history) {
    final images = history.project.images;
    return Expanded(
      flex: 2,
      child: Card(
        elevation: 4,
        color: ColorsData.whiteColor,
        surfaceTintColor: ColorsData.whiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        margin: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: AspectRatio(
            aspectRatio: 1.1,
            child: ImageWidget(
              image: images.isEmpty ? '' : images.first,
              fit: BoxFit.cover,
              errorWidget: Stack(
                alignment: Alignment.center,
                children: [
                  bgImage,
                  ImageWidget(
                    image: Paths.logo,
                    width: 70.w,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget invDetails(History history) {
    return buildTable(history);
    // Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Expanded(
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           headerItem(
    //             h1: AppConstants.investmentType,
    //             d1: history.historyItem.holderType,
    //           ),
    //           headerItem(
    //             h1: AppConstants.propertyType,
    //             d1: history.project.fundTypeName,
    //           ),
    //           headerItem(
    //             h1: AppConstants.status,
    //             d1: history.historyItem.paidStatus,
    //           ),
    //         ],
    //       ),
    //     ),
    //     SizedBox(width: 30.w),
    //     Expanded(
    //       child: headerItem(
    //         h1: AppConstants.investmentAmount,
    //         d1: Frmtr.frmtCurrency(history.historyItem.investingAmount),
    //       ),
    //     )
    //   ],
    // );
  }

  Widget buildTable(History history) {
    final isMorgage = history.project.fundType == 1;
    return Table(
      children: [
        _buildRow(
          title1: AppConstants.investmentAmount,
          value1: Frmtr.frmtCurrency(history.historyItem.investingAmount),
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
          title2: isMorgage ? AppConstants.loanAmount : AppConstants.value,
          value2: Frmtr.frmtCurrency(history.project.facility),
        ),
        _buildRow(
          title1: AppConstants.status,
          value1: history.historyItem.paidStatus,
          title2: isMorgage ? AppConstants.lvr : '',
          value2: isMorgage ? history.project.lvr : '',
        ),
        if (isMorgage)
          _buildRow(
            title1: AppConstants.returns,
            value1: history.project.returns,
          ),
      ],
    );
  }

  TableRow _buildRow({
    final String title1 = '',
    final String value1 = '',
    final String title2 = '',
    final String value2 = '',
  }) {
    return TableRow(
      children: [_buildCell(title1, value1), _buildCell(title2, value2)],
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
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: ColorsData.greyColor,
              textAlign: TextAlign.start,
            ),
            TextWidget(
              text: value,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: ColorsData.blackColor,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }

  Widget headerItem({required String h1, required String d1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: RichTextWidget(
        text: h1,
        style: MyFont.robotoTextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: const Color(0xff666666),
        ),
        children: [
          TextSpan(
            text: d1,
            style: MyFont.robotoTextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xff252525),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return const Center(
      child: TextWidget(
        text: AppConstants.history,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: ColorsData.whiteColor,
      ),
    );
  }
}
