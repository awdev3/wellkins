import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellkins/providers/woo_provider.dart';

import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../services/helpers.dart';
import '../../utils/console_util.dart';
import '../../utils/wellkins_icons.dart';
import '../../widgets/loaders.dart';
import '../../widgets/text_widget.dart';
import '../../widgets/toasts.dart';

class PDFViewerScreen extends StatefulWidget {
  final String orderId;
  final String propName;
  final String fundSubType;
  final String pdfUrl;
  final bool isCert;
  const PDFViewerScreen({
    super.key,
    this.orderId = '',
    this.propName = '',
    this.fundSubType = '',
    this.pdfUrl = '',
    this.isCert = true,
  });

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String _filePath = '';
  String _filename = '';
  bool _isLoading = true;

  // late PDFViewController _pdfViewController;
  // int _currentPage = 1;
  // int? _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _initPDF();
  }

  Future<void> _initPDF() async {
    final wooProvider = getWooProvider(context);
    if (widget.pdfUrl.isEmpty) {
      await wooProvider
          .getPdfFiles(
            widget.orderId,
            widget.propName,
            widget.fundSubType,
            context,
            isCert: widget.isCert,
          )
          .then((pdfUrl) async {
            await _loadPdf(wooProvider, pdfUrl);
          });
    } else {
      await _loadPdf(wooProvider, widget.pdfUrl);
    }
  }

  Future<void> _loadPdf(WooProvider wooProvider, String pdfUrl) async {
    //for unit cert refresh
    final isFromCert = widget.pdfUrl.isEmpty && widget.isCert;

    await wooProvider.loadFileFromUrl(pdfUrl, isCert: isFromCert).then((file) {
      if (file.isEmpty) {
        onError();
      } else {
        if (mounted) {
          setState(() {
            _filename = file[0];
            _filePath = file[1];
            _isLoading = false;
          });
        }
      }
    });
  }

  void onError([error = '']) {
    showToast(message: AppConstants.error);
    Navigator.pop(context);
    printData(title: 'pdf open error', data: error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsData.whiteColor,
      appBar: AppBar(
        leading: _backButton(context),
        title: _titleWidget(),
        actions: _isLoading ? null : [_popMenu(context)],
      ),
      body: _isLoading
          ? showLoader()
          :
            // Stack(
            //     children: [
            Column(
              children: [
                const Divider(thickness: 3, height: 1),
                Expanded(
                  child: PDFView(
                    filePath: _filePath,
                    pageSnap: false,
                    pageFling: false,
                    autoSpacing: false,
                    onError: (error) => onError(error),
                    // onPageChanged: (page, total) {
                    //   _currentPage = page! + 1;
                    //   _totalPages = total!;
                    //   setState(() {});
                    // },
                  ),
                ),
              ],
            ),
      // Positioned(
      //   left: 0,
      //   right: 0,
      //   bottom: 10,
      //   child: Center(
      //     child: TextWidget(
      //       // '$_currentPage / $_totalPages',
      //       text: 'Page $_currentPage of $_totalPages',
      //       fontSize: 14,
      //       fontWeight: FontWeight.w500,
      //       color: Colors.black54,
      //       fontFam: MyFontFam.roboto,
      //     ),
      //   ),
      // ),
      //   ],
      // ),
    );
  }

  Widget _titleWidget() {
    return TextWidget(
      text: _filename,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );
  }

  Widget _backButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: Icon(Wellkins.back, size: 14.sp),
    );
  }

  Widget _popMenu(BuildContext context) {
    return PopupMenuButton(
      surfaceTintColor: ColorsData.whiteColor,
      icon: Icon(Icons.more_vert, size: 22.sp, color: ColorsData.blackColor),
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: AppConstants.download,
            height: 30.h,
            child: const TextWidget(
              text: AppConstants.download,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ];
      },
      onSelected: (value) {
        if (value == AppConstants.download) {
          final wooProvider = getWooProvider(context);
          //for unit cert multiple file save
          final isFromCert = widget.pdfUrl.isEmpty && widget.isCert;
          wooProvider.saveFileToDir(_filePath, _filename, isCert: isFromCert);
        }
      },
    );
  }
}

// class PDFViewerPage extends StatefulWidget {
//   @override
//   _PDFViewerPageState createState() => _PDFViewerPageState();
// }

// class _PDFViewerPageState extends State<PDFViewerPage> {
//   final String _pdfPath =
//       'assets/example.pdf'; // Replace with your PDF file path
//   late PDFViewController _pdfViewController;
//   int _currentPage = 1;
//   int _totalPages = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('PDF Viewer'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: PDFView(
//               filePath: _pdfPath,
//               onViewCreated: (PDFViewController controller) {
//                 _pdfViewController = controller;
//                 _pdfViewController.getCurrentPage().then((value) {
//                   setState(() {
//                     _currentPage = value;
//                   });
//                 });
//                 _pdfViewController.getPageCount().then((value) {
//                   setState(() {
//                     _totalPages = value;
//                   });
//                 });
//               },
//               onPageChanged: (int page, int total) {
//                 setState(() {
//                   _currentPage = page;
//                   _totalPages = total;
//                 });
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Page $_currentPage of $_totalPages'),
//                 Expanded(
//                   child: Scrollbar(
//                     child: PDFSlider(
//                       currentPage: _currentPage,
//                       totalPages: _totalPages,
//                       onPageChanged: (page) {
//                         _pdfViewController.setPage(page);
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class PDFSlider extends StatefulWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  const PDFSlider({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  State<PDFSlider> createState() => _PDFSliderState();
}

class _PDFSliderState extends State<PDFSlider> {
  @override
  Widget build(BuildContext context) {
    return Slider(
      value: widget.currentPage.toDouble(),
      min: 1,
      max: widget.totalPages.toDouble(),
      divisions: widget.totalPages - 1,
      label: 'Page ${widget.currentPage}',
      onChanged: (value) {
        widget.onPageChanged(value.toInt());
      },
    );
  }
}
