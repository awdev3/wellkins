import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/colors.dart';
import '../../../../../../constants/paths.dart';
import '../../../../../../constants/strings.dart';
import '../../../../../../models/fund_type.dart';
import '../../../../../../providers/woo_provider.dart';
import '../../../../../../utils/formatter.dart';
import '../../../../../../utils/transitions_util.dart';
import '../../../../../../widgets/backgrounds.dart';
import '../../../../../../widgets/button_widgets.dart';
import '../../../../../../widgets/image_widget.dart';
import '../../../../../../widgets/loaders.dart';
import '../../../../../../widgets/spacers.dart';
import '../../../../../../widgets/text_widget.dart';
import '../../../../../engagementScrn/components/docs_widget.dart';
import '../../../../../mainScrns/preview_doc_screen.dart';
import 'user_receipts_screen.dart';

class FundDetailsWidget {
  static Widget buildImage(List<String> images) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15.r),
      child: AspectRatio(
        aspectRatio: 1.2,
        child: ImageWidget(
          image: images.isEmpty ? '' : images.first,
          fit: BoxFit.cover,
          errorWidget: Stack(
            alignment: Alignment.center,
            children: [
              bgImage,
              ImageWidget(width: 110.w, image: Paths.logo, fit: BoxFit.cover),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildHeader(String propName, String propType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(text: propName, fontSize: 16, fontWeight: FontWeight.bold),
        TextWidget(text: propType, fontSize: 10, fontWeight: FontWeight.w600),
      ],
    );
  }

  static Widget buildDetails(List<FundDetails> fundDetails) {
    final amount = fundDetails.fold(
      0.0,
      (total, e) => total + e.history.historyItem.investingAmount,
    );
    final applcnCount = fundDetails.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FundDetailsWidget.headerItem(
          h1: AppConstants.totalInvest,
          d1: Frmtr.frmtCurrency(amount),
        ),
        Spacers.sb2(),
        FundDetailsWidget.headerItem(
          h1: AppConstants.totalApplications,
          d1: '$applcnCount',
        ),
      ],
    );
  }

  static Widget descp(FundDetails details) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const TextWidget(
            text: AppConstants.descp,
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.4,
          ),
          Spacers.sb10(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: TextWidget(
                  text: details.history.project.desc,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.justify,
                  height: 1.7,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget buildProjectDocs(FundDetails details, BuildContext context) {
    final project = details.history.project;
    // final status = project.status.toLowerCase();
    // final isOver = status == 'closed' || status == 'completed';
    return
    // Visibility(
    //   visible: isOver,
    //   child:
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Docs.buildPDSButtons(project, context, isFund: true, isInv: true),
        Spacers.sb15(),
        Docs.buildDownloadFileAndPP(project, context, isFund: true),
        Spacers.sb10(),
      ],
      // ),
    );
  }

  // static Widget buildPdfFile(
  //   FundDetails details,
  //   BuildContext context,
  // ) {
  //   return Theme(
  //     data: Theme.of(context).copyWith(dividerColor: ColorsData.trColor),
  //     child: ExpansionTile(
  //       tilePadding: EdgeInsets.symmetric(horizontal: 10.w),
  //       childrenPadding: EdgeInsets.only(bottom: 20.h),
  //       iconColor: Colors.blue.shade200,
  //       collapsedIconColor: ColorsData.blackColor,
  //       collapsedBackgroundColor: const Color.fromARGB(255, 230, 255, 252),
  //       // backgroundColor: const Color.fromARGB(255, 255, 251, 240),
  //       title: const TextWidget(
  //         text: AppConstants.prDocs,
  //         fontSize: 16,
  //         fontWeight: FontWeight.bold,
  //       ),
  //       children: [
  //         Wrap(spacing: 7.w, runSpacing: 4.h, children: [
  //           if (details.history.historyItem.paidStatus == 'Payment Received')
  //             pdfFileButton(
  //               title: AppConstants.unitCert,
  //               details: details,
  //               isCert: true,
  //               context: context,
  //             ),
  //           pdfFileButton(
  //             title: AppConstants.termsPayment,
  //             details: details,
  //             isCert: false,
  //             context: context,
  //           ),
  //         ]),
  //       ],
  //     ),
  //   );
  // }

  // static Widget pdfFileButton({
  //   required String title,
  //   required FundDetails details,
  //   required bool isCert,
  //   required BuildContext context,
  // }) {
  //   return customButton(
  //       width: 130,
  //       height: 30,
  //       fontSize: 12,
  //       padding: EdgeInsets.zero,
  //       borderRadius: 5,
  //       title: title,
  //       onPressed: () {
  //         Navigator.push(
  //           context,
  //           FadeRoute(
  //               page: PDFViewerScreen(
  //             orderId: details.history.historyItem.orderId,
  //             propName: details.history.project.propertyName,
  //             propType: '${details.history.project.fundType}',
  //             isCert: isCert,
  //           )),
  //         );
  //       });
  // }

  static Widget buildDocButtons(FundDetails details, BuildContext ctx) {
    final item = details.history.historyItem;
    return Row(
      children: [
        docButton(
          text: AppConstants.prDocs,
          isEmpty: item.paidStatus != 'Payment Received' && !item.isApproved,
          onTap: () {
            Navigator.push(
              ctx,
              FadeRoute(page: PreviewDocScreen(details: details)),
            );
          },
        ),
        Spacers.sbw10(),
        docButton(
          text: AppConstants.urReceipts,
          onTap: () {
            Navigator.push(
              ctx,
              FadeRoute(page: UserReceiptsWidget(details: details)),
            );
          },
        ),
      ],
    );
  }

  static Widget docButton({
    required String text,
    required VoidCallback? onTap,
    bool isEmpty = false,
  }) {
    return Flexible(
      child: Opacity(
        opacity: isEmpty ? .3 : 1,
        child: customButton(
          title: text,
          height: 28,
          borderRadius: 5,
          fontSize: 12,
          padding: EdgeInsets.zero,
          shadows: [
            const BoxShadow(
              color: ColorsData.formHintColor,
              spreadRadius: .1,
              blurRadius: .3,
            ),
          ],
          buttonColor: ColorsData.primaryColor,
          onPressed: isEmpty ? null : onTap,
        ),
      ),
    );
  }

  static Widget newsAndInsights() {
    return Consumer<WooProvider>(
      builder: (context, snapshot, child) {
        final newsAndInsights = snapshot.newsAndInsights;
        return snapshot.newsLoad
            ? showLoader()
            : newsAndInsights.isEmpty
            ? const SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacers.sb10(),
                  FundDetailsWidget.divider(),
                  const TextWidget(
                    text: AppConstants.newsInsights,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.4,
                  ),
                  ListView.builder(
                    itemCount: newsAndInsights.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      final item = newsAndInsights[index];
                      return Padding(
                        padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
                        child: HtmlWidget(
                          item.blogDesc,
                          //   '''<div style="text-align: justify;">
                          //     ${item.blogDesc}
                          //  </div>''',
                          textStyle: MyFont.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            height: 1.7,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
      },
    );
  }

  static Widget headerItem({required String h1, required String d1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 5,
            child: TextWidget(
              text: h1,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: ColorsData.blackColor,
            ),
          ),
          Spacers.sbw5(),
          FittedBox(
            child: TextWidget(
              text: d1,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: ColorsData.blackColor,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  static Divider divider() => const Divider(color: ColorsData.formHintColor);
}
