import 'package:delayed_display/delayed_display.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/colors.dart';
import '../../../../../../constants/paths.dart';
import '../../../../../../constants/strings.dart';
import '../../../../../../models/fund_type.dart';
import '../../../../../../models/woo_models.dart';
import '../../../../../../services/helpers.dart';
import '../../../../../../utils/console_util.dart';
import '../../../../../../utils/regx.dart';
import '../../../../../../utils/transitions_util.dart';
import '../../../../../../widgets/backgrounds.dart';
import '../../../../../../widgets/button_widgets.dart';
import '../../../../../../widgets/common_titles.dart';
import '../../../../../../widgets/custom_appbar.dart';
import '../../../../../../widgets/custom_prompts.dart';
import '../../../../../../widgets/field_widget.dart';
import '../../../../../../widgets/image_widget.dart';
import '../../../../../../widgets/loaders.dart';
import '../../../../../../widgets/spacers.dart';
import '../../../../../../widgets/text_widget.dart';
import '../../../../../../widgets/toasts.dart';
import '../../../../../mainScrns/image_view_screen.dart';
import '../../../../../mainScrns/pdf_view_screen.dart';

class UserReceiptsWidget extends StatefulWidget {
  final FundDetails details;
  const UserReceiptsWidget({super.key, required this.details});

  @override
  State<UserReceiptsWidget> createState() => _UserReceiptsWidgetState();
}

class _UserReceiptsWidgetState extends State<UserReceiptsWidget> {
  bool receiptLoad = true;
  bool uploadingFile = false;

  String filePath = '';
  String fileName = '';
  String fileType = '';

  List<UserReceipt> userReceipts = [];

  final cntlr = TextEditingController();

  @override
  void initState() {
    super.initState();
    getReceipts();
  }

  Future<void> getReceipts() async {
    final wooProvider = getWooProvider(context);
    final orderId = widget.details.history.historyItem.orderId;
    setState(() => receiptLoad = true);
    await wooProvider.getUserReceipts(orderId, context).then((receipts) {
      userReceipts = receipts;
      setState(() => receiptLoad = false);
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null) {
      final file = result.files.first;
      const maxSize = 2 * 1024 * 1024;
      if (file.size <= maxSize) {
        fileName = file.name;
        filePath = file.path!;
        fileType = file.extension!;
        printData(data: 'Name: --> $fileName');
        printData(data: 'Path: --> $filePath');
        printData(data: 'Type: --> $fileType');
        printData(data: 'Size: --> ${file.size}');

        setState(() {});
      } else {
        showToast(message: AppConstants.below2Mb);
      }
    }
  }

  Future<void> uploadUserFile(FundDetails details) async {
    final wooProvider = getWooProvider(context);
    dismissInputFocus(context);
    setState(() => uploadingFile = true);
    await wooProvider
        .uploadUserFiles(
          orderId: details.history.historyItem.orderId,
          fileName: fileName,
          filePath: filePath,
          fileType: fileType,
          comments: cntlr.text.trim(),
          ctx: context,
        )
        .then((receipt) {
          if (receipt != null) {
            fileName = '';
            filePath = '';
            fileType = '';
            cntlr.clear();
            userReceipts.insert(0, receipt);
          }
          setState(() => uploadingFile = false);
        });
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
                text: AppConstants.urReceipts,
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
                    child: Column(
                      children: [
                        Spacers.sb10(),
                        _buildFilePicker(),
                        Spacers.sb10(),
                        buildUserReceipts(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (uploadingFile) fullLoaderWhite,
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Theme(
  //     data: Theme.of(context).copyWith(dividerColor: ColorsData.trColor),
  //     child: ExpansionTile(
  //       tilePadding: EdgeInsets.symmetric(horizontal: 10.w),
  //       childrenPadding: EdgeInsets.only(bottom: 20.h),
  //       iconColor: Colors.blue.shade200,
  //       collapsedIconColor: ColorsData.blackColor,
  //       collapsedBackgroundColor: const Color.fromARGB(255, 240, 241, 255),
  //       title: const TextWidget(
  //         text: AppConstants.urReceipts,
  //         fontSize: 16,
  //         fontWeight: FontWeight.bold,
  //       ),
  //       children: [
  //         Column(
  //           children: [
  //             Spacers.sb10(),
  //             _pdfBrowser(),
  //             Spacers.sb10(),
  //             buildUserReceipts(),
  //             Spacers.sb10(),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _pdfBrowser() {
  //   return Stack(
  //     alignment: Alignment.center,
  //     children: [
  //       buildFileUpload(widget.details),
  //       if (uploadingFile) loaderOverlay(widget.details),
  //       if (uploadingFile) showLoader()
  //     ],
  //   );
  // }

  Widget _buildFilePicker() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: ColorsData.greyColor),
      ),
      child: Column(
        children: [
          ImageWidget(height: 50.w, width: 50.w, image: Paths.upload),
          Spacers.sb5(),
          const TextWidget(
            text: AppConstants.upDocs,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Spacers.sb5(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _filePickerButton(),
              if (filePath.isNotEmpty) _uploadButton(),
            ],
          ),
          if (filePath.isEmpty) ...[
            Spacers.sb5(),
            const TextWidget(
              text: AppConstants.maxSize,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Spacers.sb5(),
          ] else ...[
            Spacers.sb10(),
            _filePreview(),
            Spacers.sb5(),
            _commentField(),
            Spacers.sb10(),
          ],
        ],
      ),
    );
  }

  Widget _filePickerButton() {
    return customButton(
      height: 35.h,
      width: 130.w,
      title: filePath.isEmpty ? AppConstants.browse : AppConstants.changeFile,
      fontSize: 14,
      onPressed: () async => await _pickFile(),
    );
  }

  Widget _uploadButton() {
    return DelayedDisplay(
      child: customButton(
        height: 35.h,
        width: 130.w,
        title: AppConstants.submit,
        fontSize: 14,
        onPressed: () async => await uploadUserFile(widget.details),
      ),
    );
  }

  Widget _filePreview() {
    final isPdf = fileType == 'pdf';
    return DelayedDisplay(
      child: Row(
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
              text: fileName,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Spacers.sbw10(),
          InkWell(
            onTap: () {
              setState(() {
                fileName = '';
                filePath = '';
                cntlr.clear();
              });
            },
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Icon(Icons.delete_forever, color: Colors.red, size: 25.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentField() {
    return DelayedDisplay(
      child: CustomTextField(
        controller: cntlr,
        regExpCondition: Regx.nameRegExp,
        hintText: AppConstants.comments,
        isDence: true,
        minLines: 1,
        maxLines: 3,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
      ),
    );
  }

  // Widget loaderOverlay(FundDetails details) {
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(20.r),
  //     child: ColoredBox(
  //       color: Colors.white54,
  //       child: Opacity(
  //         opacity: 0,
  //         child: IgnorePointer(
  //           child: buildFileUpload(details),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget buildUserReceipts() {
    return receiptLoad
        ? showLoader()
        : Expanded(
            child: userReceipts.isEmpty
                ? CustomPrompts.showEmptyInfo(text: AppConstants.noData)
                : SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: DelayedDisplay(
                        slidingBeginOffset: const Offset(0, -0.35),
                        child: Column(
                          children: userReceipts
                              .map((receipt) => _receiptTile(receipt))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
          );
  }

  Widget _receiptTile(UserReceipt receipt) {
    final isPdf = receipt.fileType == 'pdf';
    return Material(
      color: ColorsData.whiteColor,
      child: Column(
        children: [
          ListTile(
            onTap: () {
              if (isPdf) {
                Navigator.push(
                  context,
                  FadeRoute(page: PDFViewerScreen(pdfUrl: receipt.url)),
                );
              } else {
                Navigator.push(
                  context,
                  FadeRoute(
                    page: ImageViewScreen(
                      imgUrl: receipt.url,
                      fileName: receipt.fileName,
                    ),
                  ),
                );
              }
            },
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
                    text: receipt.fileName,
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
