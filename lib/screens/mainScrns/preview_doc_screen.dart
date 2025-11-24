import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/colors.dart';
import '../../constants/paths.dart';
import '../../constants/strings.dart';
import '../../models/fund_type.dart';
import '../../models/project_model.dart';
import '../../utils/transitions_util.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/common_titles.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/spacers.dart';
import '../../widgets/text_widget.dart';
import 'image_view_screen.dart';
import 'pdf_view_screen.dart';

class PreviewDocScreen extends StatelessWidget {
  final FundDetails? details;
  final List<GeneralDocs>? generalDocs;
  const PreviewDocScreen({super.key, this.details, this.generalDocs});

  static const List<String> certList = [
    AppConstants.unitCert,
    AppConstants.termsPayment,
  ];

  void _onPdfTap({
    required bool isCert,
    required String pdfUrl,
    required BuildContext ctx,
    required bool isPdf,
    String fileName = '',
  }) {
    if (isPdf) {
      if (details != null) {
        Navigator.push(
          ctx,
          FadeRoute(
            page: PDFViewerScreen(
              orderId: details!.history.historyItem.orderId,
              propName: details!.history.project.propertyName,
              fundSubType: '${details!.history.project.fundSubType}',
              isCert: isCert,
            ),
          ),
        );
      } else if (pdfUrl.isNotEmpty) {
        Navigator.push(
          ctx,
          FadeRoute(
            page: PDFViewerScreen(pdfUrl: pdfUrl, isCert: isCert),
          ),
        );
      }
    } else {
      Navigator.push(
        ctx,
        FadeRoute(
          page: ImageViewScreen(imgUrl: pdfUrl, fileName: fileName),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        bgImage,
        Scaffold(
          backgroundColor: ColorsData.trColor,
          appBar: CustomAppBar.appbar(ctx: context, showTrailing: false),
          body: Column(
            children: [
              CommonTitles.title(
                text: details != null
                    ? AppConstants.prDocs
                    : AppConstants.gnFiles,
                context: context,
              ),
              Spacers.sb10(),
              Expanded(
                child: DelayedDisplay(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
                    padding: EdgeInsets.fromLTRB(15.w, 20.w, 15.w, 0),
                    decoration: commonDecor,
                    child: details != null
                        ? _buildUserDocs(context)
                        : _buildGeneralDocs(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserDocs(BuildContext ctx) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(bottom: 10.h),
        child: Column(
          children: [
            if (details!.history.historyItem.paidStatus == 'Payment Received')
              _pdfTile(fileName: certList[0], isCert: true, ctx: ctx),
            if (details!.history.historyItem.isApproved)
              _pdfTile(fileName: certList[1], isCert: false, ctx: ctx),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralDocs(BuildContext ctx) {
    return ListView.builder(
      itemCount: generalDocs!.length,
      itemBuilder: (BuildContext context, int index) {
        final doc = generalDocs![index];
        return _pdfTile(
          title: doc.title,
          fileName: doc.fileName,
          pdfUrl: doc.url,
          isCert: false,
          ctx: ctx,
        );
      },
    );
  }

  Widget _pdfTile({
    required String fileName,
    required bool isCert,
    required BuildContext ctx,
    String? title,
    String pdfUrl = '',
  }) {
    final isPdf = pdfUrl.endsWith('.pdf') || details != null;
    // for checking pdf file and image files
    // for checking if its from preview documents and not from general files
    return Material(
      color: ColorsData.whiteColor,
      child: Column(
        children: [
          ListTile(
            onTap: () => _onPdfTap(
              pdfUrl: pdfUrl,
              isCert: isCert,
              isPdf: isPdf,
              ctx: ctx,
              fileName: fileName,
            ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ImageWidget(
                  height: 30.w,
                  width: 30.w,
                  image: isPdf ? Paths.pdfPrv : Paths.imgPrv,
                ),
                Spacers.sbw10(),
                Expanded(
                  flex: 5,
                  child: TextWidget(
                    text: title ?? fileName,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Spacers.sbw10(),
              ],
            ),
          ),
          Divider(height: 0, indent: 20.w, endIndent: 20.w),
        ],
      ),
    );
  }
}
