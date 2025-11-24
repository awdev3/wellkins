import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellkins/utils/console_util.dart';

import '../../../../../../constants/colors.dart';
import '../../../../../../constants/strings.dart';
import '../../../../../../models/fund_type.dart';
import '../../../../../../models/transaction_model.dart';
import '../../../../../../services/helpers.dart';
import '../../../../../../utils/formatter.dart';
import '../../../../../../widgets/backgrounds.dart';
import '../../../../../../widgets/common_titles.dart';
import '../../../../../../widgets/custom_appbar.dart';
import '../../../../../../widgets/loaders.dart';
import '../../../../../../widgets/spacers.dart';
import '../../../../../../widgets/text_widget.dart';
import '../../../../../engagementScrn/engagement_tabs.dart';
import 'fund_details_widgets.dart';
import 'trans_return_widgets.dart';

class FundsDetailsScreen extends StatefulWidget {
  final String title;
  final List<FundDetails> fundDetails;

  const FundsDetailsScreen({
    super.key,
    required this.title,
    required this.fundDetails,
  });

  @override
  State<FundsDetailsScreen> createState() => _FundsDetailsScreenState();
}

class _FundsDetailsScreenState extends State<FundsDetailsScreen> {
  List<Transaction> transactionList = [];

  @override
  void initState() {
    super.initState();
    getTransactions();
    getNews();
  }

  Future<void> getTransactions() async {
    if (!mounted) return;

    try {
      final wooProvider = getWooProvider(context);
      final userProvider = getUserProvider(context);

      List<Transaction> transactions = [];

      for (final items in widget.fundDetails) {
        final getTrns = GetTransaction(
          clientId: userProvider.user!.id,
          orderId: items.history.historyItem.orderId,
          holderType: items.history.historyItem.holderType,
          formType: items.history.historyItem.formType,
        );

        final trnsList = await wooProvider.getTransactions(getTrns, context);
        transactions.addAll(trnsList);

        if (!mounted) return;
      }

      if (mounted) {
        setState(() {
          transactionList = transactions;
        });
      }
    } catch (e) {
      printData(data: "Error in getTransactions: $e", e: true);
    }
  }

  Future<void> getNews() async {
    if (!mounted) return;

    try {
      final wooProvider = getWooProvider(context);

      await wooProvider.getNewsAndInsights(
        widget.fundDetails.first.history.project.id,
        context,
      );
    } catch (e) {
      printData(data: "Error in getNews: $e", e: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        bgImage,
        Scaffold(
          backgroundColor: ColorsData.trColor,
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar.appbar(ctx: context),
          body: Column(
            children: [
              Spacers.sb8(),
              const EngagementTabs(fromBottom: true),
              Spacers.sb15(),
              CommonTitles.title(
                text: widget.title,
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
                    child: fundTile(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget fundTile(BuildContext ctx) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(40.r),
        topRight: Radius.circular(40.r),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              elevation: 4,
              color: ColorsData.whiteColor,
              surfaceTintColor: ColorsData.whiteColor,
              margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopRow(),
                    Spacers.sb10(),
                    FundDetailsWidget.divider(),
                    Spacers.sb10(),
                    FundDetailsWidget.descp(widget.fundDetails.first),
                    Spacers.sb10(),
                    FundDetailsWidget.buildProjectDocs(
                      widget.fundDetails.first,
                      context,
                    ),
                    buildBottomDetails(ctx),
                    FundDetailsWidget.newsAndInsights(),
                    Spacers.sb10(),
                  ],
                ),
              ),
            ),
            scrollUp(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    final project = widget.fundDetails.first.history.project;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: FundDetailsWidget.buildImage(project.images)),
        Spacers.sbw15(),
        Expanded(
          flex: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FundDetailsWidget.buildHeader(
                project.propertyName,
                project.propType,
              ),
              Spacers.sb5(),
              FundDetailsWidget.divider(),
              FundDetailsWidget.buildDetails(widget.fundDetails),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildBottomDetails(BuildContext ctx) {
    return ListView.builder(
      itemCount: widget.fundDetails.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final details = widget.fundDetails[index];
        final detl = widget.fundDetails.first;
        final history = detl.history;
        return history.project.fundType != 1
            ? expTileHeader(ctx, index, details, propFundInv(details))
            // : details.returnsData == null // show when return available
            //     ? const SizedBox()
            : expTileHeader(
                ctx,
                index,
                details,
                expMorgageHeader(details, ctx),
              );
      },
    );
  }

  Widget propFundInv(FundDetails details) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        border: Border.all(color: ColorsData.greyColor),
      ),
      child: buildTransactions(details),
    );
  }

  Widget expMorgageHeader(FundDetails details, BuildContext ctx) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        border: Border.all(color: ColorsData.greyColor),
      ),
      child: Column(
        children: [
          if (details.returnsData != null) ...[
            FundDetailsWidget.headerItem(
              h1: AppConstants.term,
              d1: '${details.returnsData!.months} ${AppConstants.months}',
            ),
            Spacers.sb2(),
            // FundDetailsWidget.headerItem(
            //   h1: AppConstants.returns,
            //   d1: Frmtr.frmtCurrency(
            //     details.returnsData!.returns,
            //   ),
            // ),
            // Spacers.sb2(),
            FundDetailsWidget.headerItem(
              h1: AppConstants.returnsPercentage,
              d1: '${details.returnsData!.returnsPercentage} %',
            ),
            Spacers.sb2(),
            FundDetailsWidget.headerItem(
              h1: AppConstants.settlementDate,
              d1: details.returnsData!.settlementDate,
            ),
            Spacers.sb30(),
          ],
          buildOrderDetails(details),
        ],
      ),
    );
  }

  Widget buildOrderDetails(FundDetails details) {
    return Column(
      children: [
        buildTransactions(details),
        if (details.returnsData != null) ...[
          Spacers.sb30(),
          TransReturn.tableMainHeader(AppConstants.returnsHd),
          DelayedDisplay(
            child: Table(
              border: TableBorder.all(color: Colors.black),
              children: [
                TransReturn.buildHeaderRow(),
                ...details.returnsData!.monthlyDatas.map(
                  (data) => TransReturn.buildDataRowReturn(data),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget buildTransactions(FundDetails details) {
    final oId = details.history.historyItem.orderId;
    final sameTrns = transactionList.where((e) => e.orderId == oId).toList();

    return DelayedDisplay(
      child: Column(
        children: [
          // UploadFiles(details: details),
          // Spacers.sb20(),
          // FundDetailsWidget.buildPdfFile(details, context),
          // Spacers.sb20(),
          FundDetailsWidget.buildDocButtons(details, context),
          if (sameTrns.isEmpty) ...[
            Spacers.sb20(),
            showLoader(),
            Spacers.sb20(),
          ] else ...[
            Spacers.sb20(),
            TransReturn.tableMainHeader(AppConstants.investments),
            TransReturn.buildOperations(sameTrns),
          ],
        ],
      ),
    );
  }

  //   Future<List<Transaction>> getSameTrans(FundDetails details) async {
  //   final oId = details.history.historyItem.orderId;
  //   final sameTrns = transactionList.where((e) => e.orderId == oId).toList();
  //   return sameTrns;
  // }

  // Widget buildTransactions(FundDetails details, List<Transaction> sameTrns) {
  //   return FutureBuilder(
  //     future: getSameTrans(details),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return showLoader();
  //       } else if (snapshot.data == null || snapshot.data!.isEmpty) {
  //         return FundDetailsWidget.buildDocButtons(details, context);
  //       } else {
  //         return DelayedDisplay(
  //           child: Column(
  //             children: [
  //               FundDetailsWidget.buildDocButtons(details, context),
  //               Spacers.sb20(),
  //               TransReturn.tableMainHeader(AppConstants.investments),
  //               TransReturn.buildOperations(snapshot.data!),
  //             ],
  //           ),
  //         );
  //       }
  //     },
  //   );
  // }

  Widget expTileHeader(
    BuildContext ctx,
    int index,
    FundDetails details,
    Widget customChild,
  ) {
    return Theme(
      data: Theme.of(ctx).copyWith(dividerColor: ColorsData.trColor),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 10.w),
        childrenPadding: EdgeInsets.only(bottom: 20.h),
        iconColor: Colors.blue.shade200,
        collapsedIconColor: ColorsData.blackColor,
        collapsedBackgroundColor: index.isEven
            ? const Color.fromARGB(255, 239, 248, 255)
            : const Color.fromARGB(255, 255, 251, 240),
        title: TextWidget(
          text: AppConstants.orderID,
          t2: details.history.historyItem.orderId,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        subtitle: TextWidget(
          text: AppConstants.investmentAmount,
          t2: Frmtr.frmtCurrency(details.history.historyItem.investingAmount),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        children: [customChild],
      ),
    );
  }
}

// import 'package:delayed_display/delayed_display.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:provider/provider.dart';
// import 'package:wellkins/constants/paths.dart';

// import '../../../../../../constants/colors.dart';
// import '../../../../../../constants/strings.dart';
// import '../../../../../../models/fund_type.dart';
// import '../../../../../../models/returns_model.dart';
// import '../../../../../../models/transaction_model.dart';
// import '../../../../../../providers/woo_provider.dart';
// import '../../../../../../services/helpers.dart';
// import '../../../../../../utils/formatter.dart';
// import '../../../../../../utils/transitions_util.dart';
// import '../../../../../../widgets/backgrounds.dart';
// import '../../../../../../widgets/button_widgets.dart';
// import '../../../../../../widgets/common_titles.dart';
// import '../../../../../../widgets/custom_appbar.dart';
// import '../../../../../../widgets/image_widget.dart';
// import '../../../../../../widgets/loaders.dart';
// import '../../../../../../widgets/spacers.dart';
// import '../../../../../../widgets/text_widget.dart';
// import '../../../../../engagementScrn/components/docs_widget.dart';
// import '../../../../../engagementScrn/engagement_tabs.dart';
// import '../../../../../mainScrns/pdf_view_screen.dart';

// class FundsDetailsScreen extends StatefulWidget {
//   final String title;
//   final List<FundDetails> fundDetails;

//   const FundsDetailsScreen({
//     super.key,
//     required this.title,
//     required this.fundDetails,
//   });

//   @override
//   State<FundsDetailsScreen> createState() => _FundsDetailsScreenState();
// }

// class _FundsDetailsScreenState extends State<FundsDetailsScreen> {
//   List<Transaction> transactionList = [];

//   @override
//   void initState() {
//     super.initState();
//     getTransactions();
//     getNews();
//   }

//   Future<void> getTransactions() async {
//     final wooProvider = getWooProvider(context);
//     final userProvider = getUserProvider(context);
//     for (final items in widget.fundDetails) {
//       final getTrns = GetTransaction(
//         clientId: userProvider.user!.id,
//         orderId: items.history.historyItem.orderId,
//         holderType: items.history.historyItem.holderType,
//         formType: 'Individual',
//       );
//       if (transactionList.isEmpty) {
//         transactionList = await wooProvider.getTransactions(getTrns, context);
//       } else {
//         final trnsList = await wooProvider.getTransactions(getTrns, context);
//         transactionList.addAll(trnsList);
//       }
//     }
//     setState(() {});
//   }

//   Future<void> getNews() async {
//     final wooProvider = getWooProvider(context);
//     await wooProvider.getNewsAndInsights(
//       widget.fundDetails.first.history.project.id,
//       context,
//     );
//   }

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
//                 text: widget.title,
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
//                     child: fundTile(context),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }

//   Widget fundTile(BuildContext ctx) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Card(
//             elevation: 4,
//             color: ColorsData.whiteColor,
//             surfaceTintColor: ColorsData.whiteColor,
//             margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(30.r),
//             ),
//             child: Padding(
//               padding: EdgeInsets.all(10.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildTopRow(),
//                   Spacers.sb10(),
//                   _divider(),
//                   Spacers.sb10(),
//                   _buildDescp(),
//                   Spacers.sb10(),
//                   _buildProjectDocs(),
//                   buildBottomDetails(ctx),
//                   _buildNewsAndInsights(),
//                   Spacers.sb10(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopRow() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(flex: 3, child: buildImage()),
//         Spacers.sbw15(),
//         Expanded(
//           flex: 4,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               buildHeader(),
//               Spacers.sb5(),
//               _divider(),
//               buildDetails(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildImage() {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(15.r),
//       child: AspectRatio(
//         aspectRatio: 1.2,
//         child: ImageWidget(
//           image: widget.fundDetails.first.history.project.images.first,
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }

//   Widget buildHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextWidget(
//           text: widget.fundDetails.first.history.project.propertyName,
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//         TextWidget(
//           text: widget.fundDetails.first.history.project.propType,
//           fontSize: 10,
//           fontWeight: FontWeight.w600,
//         ),
//       ],
//     );
//   }

//   Widget buildDetails() {
//     final amount = widget.fundDetails
//         .fold(0.0, (total, e) => total + e.history.historyItem.investingAmount);
//     final applcnCount = widget.fundDetails.length;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         headerItem(
//           h1: AppConstants.totalInvestments,
//           d1: Frmtr.frmtCurrency(amount),
//         ),
//         headerItem(
//           h1: AppConstants.totalApplications,
//           d1: '$applcnCount',
//         ),
//       ],
//     );
//   }

//   Widget buildBottomDetails(BuildContext ctx) {
//     return ListView.builder(
//       itemCount: widget.fundDetails.length,
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemBuilder: (BuildContext context, int index) {
//         final details = widget.fundDetails[index];
//         return widget.fundDetails.first.history.project.fundType != 1
//             ? expTileHeader(ctx, index, details, propFundInv(details))
//             : details.returnsData == null
//                 ? const SizedBox()
//                 : expTileHeader(
//                     ctx, index, details, expMorgageHeader(details, ctx));
//       },
//     );
//   }

//   Widget propFundInv(FundDetails details) {
//     return Container(
//       padding: EdgeInsets.all(8.w),
//       decoration: BoxDecoration(
//         border: Border.all(color: ColorsData.greyColor),
//       ),
//       child: buildTransactions(details),
//     );
//   }

//   Widget expMorgageHeader(FundDetails details, BuildContext ctx) {
//     return Container(
//       padding: EdgeInsets.all(8.w),
//       decoration: BoxDecoration(
//         border: Border.all(color: ColorsData.greyColor),
//       ),
//       child: Column(
//         children: [
//           headerItem(
//             h1: AppConstants.term,
//             d1: '${details.returnsData!.months} ${AppConstants.months}',
//           ),
//           Spacers.sb2(),
//           headerItem(
//             h1: AppConstants.returns,
//             d1: Frmtr.frmtCurrency(
//               details.returnsData!.returns,
//             ),
//           ),
//           Spacers.sb2(),
//           headerItem(
//             h1: AppConstants.returnsPercentage,
//             d1: '${details.returnsData!.returnsPercentage} %',
//           ),
//           Spacers.sb2(),
//           headerItem(
//             h1: AppConstants.settlementDate,
//             d1: details.returnsData!.settlementDate,
//           ),
//           Spacers.sb30(),
//           _buildOrderDetails(details, ctx),
//         ],
//       ),
//     );
//   }

//   Widget _pdfFileButton({
//     required String title,
//     required FundDetails details,
//     required bool isCert,
//   }) {
//     return customButton(
//         width: 130,
//         height: 30,
//         fontSize: 12,
//         padding: EdgeInsets.zero,
//         borderRadius: 5,
//         title: title,
//         onPressed: () {
//           Navigator.push(
//             context,
//             FadeRoute(
//                 page: PDFViewerScreen(
//               orderId: details.history.historyItem.orderId,
//               propName: details.history.project.propertyName,
//               propType: '${details.history.project.fundType}',
//               isCert: isCert,
//             )),
//           );
//         });
//   }

//   Widget expTileHeader(
//     BuildContext ctx,
//     int index,
//     FundDetails details,
//     Widget customChild,
//   ) {
//     return Theme(
//       data: Theme.of(ctx).copyWith(dividerColor: ColorsData.trColor),
//       child: ExpansionTile(
//         tilePadding: EdgeInsets.symmetric(horizontal: 10.w),
//         childrenPadding: EdgeInsets.only(bottom: 20.h),
//         iconColor: Colors.blue.shade200,
//         collapsedIconColor: ColorsData.blackColor,
//         collapsedBackgroundColor: index.isEven
//             ? const Color.fromARGB(255, 239, 248, 255)
//             : const Color.fromARGB(255, 255, 251, 240),
//         title: TextWidget(
//           text: AppConstants.orderID,
//           t2: details.history.historyItem.orderId,
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//         subtitle: TextWidget(
//           text: AppConstants.investmentAmount,
//           t2: Frmtr.frmtCurrency(
//             details.history.historyItem.investingAmount,
//           ),
//           fontSize: 12,
//           fontWeight: FontWeight.w600,
//         ),
//         children: [customChild],
//       ),
//     );
//   }

//   Widget _buildOrderDetails(FundDetails details, BuildContext ctx) {
//     return Column(
//       children: [
//         buildTransactions(details),
//         Spacers.sb30(),
//         _tableMainHeader(AppConstants.returnsHd),
//         DelayedDisplay(
//           child: Table(
//             border: TableBorder.all(color: Colors.black),
//             children: [
//               _buildHeaderRow(),
//               ...details.returnsData!.monthlyDatas.map(
//                 (data) => _buildDataRowReturn(data),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildTransactions(FundDetails details) {
//     final sameTrnsList = transactionList
//         .where((e) => e.orderId == details.history.historyItem.orderId)
//         .toList();
//     return sameTrnsList.isEmpty
//         ? const SizedBox()
//         : DelayedDisplay(
//             child: Column(
//               children: [
//                 _buildPdfFile(details),
//                 Spacers.sb20(),
//                 _uploadPdfFile(details),
//                 Spacers.sb20(),
//                 _tableMainHeader(AppConstants.investments),
//                 _buildOperations(sameTrnsList),
//               ],
//             ),
//           );
//   }

//   Widget _buildPdfFile(FundDetails details) {
//     return Theme(
//       data: Theme.of(context).copyWith(dividerColor: ColorsData.trColor),
//       child: ExpansionTile(
//         tilePadding: EdgeInsets.symmetric(horizontal: 10.w),
//         childrenPadding: EdgeInsets.only(bottom: 20.h),
//         iconColor: Colors.blue.shade200,
//         collapsedIconColor: ColorsData.blackColor,
//         collapsedBackgroundColor: const Color.fromARGB(255, 255, 251, 240),
//         // backgroundColor: const Color.fromARGB(255, 255, 251, 240),
//         title: const TextWidget(
//           text: AppConstants.prDocs,
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//         children: [
//           Wrap(spacing: 7.w, runSpacing: 4.h, children: [
//             if (details.history.historyItem.paidStatus == 'Payment Received')
//               _pdfFileButton(
//                 title: AppConstants.unitCert,
//                 details: details,
//                 isCert: true,
//               ),
//             _pdfFileButton(
//               title: AppConstants.termsPayment,
//               details: details,
//               isCert: false,
//             ),
//           ]),
//         ],
//       ),
//     );
//   }

//   Widget _uploadPdfFile(FundDetails details) {
//     return Theme(
//       data: Theme.of(context).copyWith(dividerColor: ColorsData.trColor),
//       child: ExpansionTile(
//         tilePadding: EdgeInsets.symmetric(horizontal: 10.w),
//         childrenPadding: EdgeInsets.only(bottom: 20.h),
//         iconColor: Colors.blue.shade200,
//         collapsedIconColor: ColorsData.blackColor,
//         collapsedBackgroundColor: const Color.fromARGB(255, 240, 241, 255),
//         // backgroundColor: const Color.fromARGB(255, 255, 251, 240),
//         title: const TextWidget(
//           text: AppConstants.upDocs,
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//         children: [
//           Row(
//             children: [
//               ImageWidget(
//                 height: 35.w,
//                 width: 35.w,
//                 image: Paths.pdfPrv,
//               ),
//               Consumer<WooProvider>(builder: (context, snapshot, child) {
//                 return FloatingActionButton(
//                     child: snapshot.userUpload
//                         ? showLoader()
//                         : const SizedBox.shrink(),
//                     onPressed: () async {
//                       final file = await FilePicker.platform.pickFiles(
//                         type: FileType.custom,
//                         allowedExtensions: ['pdf'],
//                       );
//                       if (file != null) {
//                         print(file.files.first.path);
//                         print(file.files.first.name);
//                         if (mounted) {
//                           final wooProvider = getWooProvider(context);
//                           await wooProvider.uploadUserFiles(
//                             orderId: details.history.historyItem.orderId,
//                             fileName: file.files.first.name,
//                             filePath: file.files.first.path!,
//                             ctx: context,
//                           );
//                         }
//                       }
//                     });
//               })
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildOperations(List<Transaction> trnsList) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Table(
//         columnWidths: {
//           0: FixedColumnWidth(80.w),
//           1: FixedColumnWidth(120.w),
//           2: FixedColumnWidth(110.w),
//           3: FixedColumnWidth(110.w),
//           4: FixedColumnWidth(110.w),
//         },
//         border: TableBorder.all(color: Colors.black),
//         children: [
//           _buildHeaderRowTrns(),
//           ...trnsList.first.operations
//               .map((operation) => _buildDataRowTrns(operation))
//         ],
//       ),
//     );
//   }

//   Widget _tableMainHeader(String text) {
//     return Container(
//       padding: EdgeInsets.all(6.w),
//       decoration: const BoxDecoration(
//         color: Color.fromARGB(180, 193, 227, 255),
//         border: Border(
//           left: BorderSide(color: Colors.black),
//           right: BorderSide(color: Colors.black),
//           top: BorderSide(color: Colors.black),
//         ),
//       ),
//       child: Center(
//         child: TextWidget(
//           text: text,
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   TableRow _buildHeaderRow() {
//     return TableRow(
//       decoration:
//           const BoxDecoration(color: Color.fromARGB(218, 200, 230, 201)),
//       children: [
//         _buildCell(AppConstants.date, 0, true),
//         _buildCell(AppConstants.descp, 1, true),
//         _buildCell(AppConstants.amount, 2, true),
//       ],
//     );
//   }

//   TableRow _buildHeaderRowTrns() {
//     return TableRow(
//       decoration:
//           const BoxDecoration(color: Color.fromARGB(218, 200, 230, 201)),
//       children: [
//         _buildCell(AppConstants.date, 0, true),
//         _buildCell(AppConstants.descp, 1, true),
//         _buildCell(AppConstants.dbt, 1, true),
//         _buildCell(AppConstants.crdt, 1, true),
//         _buildCell(AppConstants.blnc, 2, true),
//       ],
//     );
//   }

//   TableRow _buildDataRowReturn(MonthlyData monthlyData) {
//     return TableRow(
//       children: [
//         _buildCell(monthlyData.paymentDate, 0),
//         _buildCell(monthlyData.paymentStatus, 1),
//         _buildCell(Frmtr.frmtCurrency(monthlyData.returns), 2),
//       ],
//     );
//   }

//   TableRow _buildDataRowTrns(Operation operation) {
//     bool isDeposit = operation.transactionType.toLowerCase() == 'allotment';
//     final sucrTyp = operation.amountUnpaid.isNegative ? 'Cr' : 'Dr';
//     final sucr = operation.amountUnpaid > 0 ? sucrTyp : '';
//     return TableRow(
//       children: [
//         !isDeposit
//             ? _buildCell(operation.transactionDate, 0)
//             : _buildCell(operation.createdAt, 0),
//         _buildCell(operation.transactionType, 1),
//         isDeposit
//             ? _buildCell(Frmtr.frmtCurrency(operation.investAmount), 1)
//             : _buildCell('', 1),
//         isDeposit
//             ? _buildCell('', 1)
//             : _buildCell(Frmtr.frmtCurrency(operation.amountPaid), 1),
//         isDeposit
//             ? _buildCell('', 1)
//             : _buildCell(
//                 '${Frmtr.frmtCurrency(operation.amountUnpaid)} $sucr', 2),
//       ],
//     );
//   }

//   Widget _buildCell(String text, int index, [bool header = false]) {
//     return TableCell(
//       child: Padding(
//         padding: EdgeInsets.all(6.w),
//         child: TextWidget(
//           text: text,
//           fontSize: 11,
//           fontWeight: header ? FontWeight.bold : FontWeight.w500,
//           color: ColorsData.blackColor,
//           textAlign: index == 0
//               ? TextAlign.start
//               : index == 1
//                   ? TextAlign.center
//                   : TextAlign.end,
//         ),
//       ),
//     );
//   }

//   Widget _buildNewsAndInsights() {
//     return Consumer<WooProvider>(
//       builder: (context, snapshot, child) {
//         final newsAndInsights = snapshot.newsAndInsights;
//         return snapshot.newsLoad
//             ? showLoader()
//             : newsAndInsights.isEmpty
//                 ? const SizedBox()
//                 : Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Spacers.sb10(),
//                       _divider(),
//                       const TextWidget(
//                         text: AppConstants.newsInsights,
//                         fontSize: 15.5,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1.4,
//                       ),
//                       ListView.builder(
//                         itemCount: newsAndInsights.length,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemBuilder: (BuildContext context, int index) {
//                           final item = newsAndInsights[index];
//                           return Padding(
//                             padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
//                             child: HtmlWidget(
//                               item.blogDesc,
//                               //   '''<div style="text-align: justify;">
//                               //     ${item.blogDesc}
//                               //  </div>''',
//                               textStyle: MyFont.poppins(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w600,
//                                 height: 1.7,
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   );
//       },
//     );
//   }

//   Widget _buildDescp() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 6.w),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const TextWidget(
//             text: AppConstants.descp,
//             fontSize: 15.5,
//             fontWeight: FontWeight.bold,
//             letterSpacing: 1.4,
//           ),
//           Spacers.sb10(),
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Flexible(
//                 child: TextWidget(
//                   text: widget.fundDetails.first.history.project.desc,
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                   textAlign: TextAlign.justify,
//                   height: 1.7,
//                 ),
//               ),
//             ],
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildProjectDocs() {
//     final project = widget.fundDetails.first.history.project;
//     final status = project.status.toLowerCase();
//     final isOver = status == 'closed' || status == 'completed';
//     return Visibility(
//       visible: isOver,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Docs.buildPDSButtons(project, context, isFund: true),
//           Spacers.sb15(),
//           Docs.buildDownloadFileAndPP(project, context, isFund: true),
//           Spacers.sb10(),
//         ],
//       ),
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
//               fontSize: 11,
//               fontWeight: FontWeight.bold,
//               color: ColorsData.blackColor,
//             ),
//           ),
//           const Spacer(),
//           Flexible(
//             flex: 3,
//             child: TextWidget(
//               text: d1,
//               fontSize: 11,
//               fontWeight: FontWeight.bold,
//               color: ColorsData.blackColor,
//               textAlign: TextAlign.end,
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Divider _divider() => const Divider(color: ColorsData.formHintColor);
// }
