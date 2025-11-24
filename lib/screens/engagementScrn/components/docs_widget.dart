import '../../../utils/formatter.dart';
import '../../mainScrns/pdf_view_screen.dart';
import '../../mainScrns/preview_doc_screen.dart';
import '../engagement.dart';

class Docs {
  static void _tryDownloadFile(String url, BuildContext ctx) async {
    final wooProvider = getWooProvider(ctx);
    wooProvider.loadFileFromUrl(url).then((value) {
      wooProvider.saveFileToDir(value[1], value[0]);
    });
  }

  static Widget buildPDSButtons(
    Project project,
    BuildContext ctx, {
    bool isFund = false,
    bool isInv = false,
  }) {
    final pds = project.pds;
    final spds = project.spds;
    return Column(
      children: [
        Row(
          children: [
            Flexible(
              child: Opacity(
                opacity: pds == null ? .3 : 1,
                child: pdsButton(
                  text: AppConstants.viewPDS,
                  isFund: isFund,
                  onTap: () {
                    if (pds != null) {
                      Navigator.push(
                        ctx,
                        FadeRoute(page: PDFViewerScreen(pdfUrl: pds)),
                      );
                    }
                  },
                ),
              ),
            ),
            Spacers.sbw10(),
            Flexible(
              child: Opacity(
                opacity: spds == null ? .3 : 1,
                child: pdsButton(
                  text: AppConstants.viewSPDS,
                  isFund: isFund,
                  onTap: () {
                    if (spds != null) {
                      Navigator.push(
                        ctx,
                        FadeRoute(page: PDFViewerScreen(pdfUrl: spds)),
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        if (project.generalDocs.isNotEmpty && isInv)
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: Row(
              children: [
                Flexible(
                  child: pdsButton(
                    text: AppConstants.gnFiles,
                    isFund: isFund,
                    onTap: () {
                      Navigator.push(
                        ctx,
                        FadeRoute(
                          page: PreviewDocScreen(
                            generalDocs: project.generalDocs,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Spacers.sbw10(),
                const Spacer(),
              ],
            ),
          ),
      ],
    );
  }

  static Widget pdsButton({
    required String text,
    required VoidCallback onTap,
    bool isFund = false,
  }) {
    return customButton(
      title: text,
      height: 26,
      borderRadius: 5,
      fontSize: 11,
      padding: EdgeInsets.zero,
      shadows: [
        const BoxShadow(
          color: ColorsData.formHintColor,
          spreadRadius: .1,
          blurRadius: .3,
        ),
      ],
      buttonColor: isFund ? ColorsData.primaryColor : const Color(0xff039E8E),
      onPressed: onTap,
    );
  }

  static Widget buildDownloadFileAndPP(
    Project project,
    BuildContext ctx, {
    bool isFund = false,
  }) {
    final fsg = project.fsg;
    final tdm = project.tdm;
    return Column(
      children: [
        Opacity(
          opacity: fsg == null ? .3 : 1,
          child: downloadFile(
            text: AppConstants.dFSG,
            onTap: fsg == null ? null : () => _tryDownloadFile(fsg, ctx),
          ),
        ),
        Spacers.sb5(),
        Opacity(
          opacity: tdm == null ? .3 : 1,
          child: downloadFile(
            text: AppConstants.dTDM,
            onTap: tdm == null ? null : () => _tryDownloadFile(tdm, ctx),
          ),
        ),
        if (!isFund) ...[Spacers.sb5(), pricePerShare(project)],
        Spacers.sb10(),
      ],
    );
  }

  static Widget downloadFile({
    required String text,
    required VoidCallback? onTap,
  }) {
    return Row(
      children: [
        const TextWidget(
          text: '• ${AppConstants.viewAnd}',
          fontSize: 10.5,
          fontWeight: FontWeight.w500,
        ),
        InkWell(
          onTap: onTap,
          child: TextWidget(
            text: text,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: const Color(0xffFF5656),
            decoration: TextDecoration.underline,
            decorationColor: const Color(0xffFF5656),
          ),
        ),
      ],
    );
  }

  static Widget pricePerShare(Project project) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichTextWidget(
        text: '• ${AppConstants.pricePer}',
        style: MyFont.poppins(fontSize: 10.5, fontWeight: FontWeight.w500),
        children: [
          TextSpan(
            text: Frmtr.frmtCurrency(project.pricePerShare),
            style: MyFont.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
