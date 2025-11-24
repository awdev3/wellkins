import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../services/helpers.dart';
import '../../utils/console_util.dart';
import '../../utils/wellkins_icons.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/loaders.dart';
import '../../widgets/text_widget.dart';
import '../../widgets/toasts.dart';

class ImageViewScreen extends StatefulWidget {
  final String imgUrl;
  final String fileName;
  const ImageViewScreen({
    super.key,
    required this.imgUrl,
    required this.fileName,
  });

  @override
  State<ImageViewScreen> createState() => _ImageViewScreenState();
}

class _ImageViewScreenState extends State<ImageViewScreen> {
  String _filePath = '';
  bool _isLoading = false;

  Future<void> _downloadImage(String value, BuildContext context) async {
    if (value == AppConstants.download) {
      setState(() => _isLoading = true);
      final wooProvider = getWooProvider(context);
      await wooProvider.loadFileFromUrl(widget.imgUrl).then((file) {
        file.isEmpty ? onError() : _saveFile(file);
      });
    }
  }

  void _saveFile(List<String> file) {
    if (mounted) {
      final wooProvider = getWooProvider(context);
      _filePath = file[1];
      _isLoading = false;
      wooProvider.saveFileToDir(_filePath, widget.fileName, isPdf: false);
      setState(() => _isLoading = false);
    }
  }

  void onError([error = '']) {
    showToast(message: AppConstants.error);
    Navigator.pop(context);
    printData(title: 'image open error', data: error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsData.whiteColor,
      appBar: AppBar(
        leading: _backButton(context),
        title: _titleWidget(),
        actions: [
          _isLoading
              ? Padding(padding: EdgeInsets.all(8.w), child: showLoader())
              : _popMenu(context),
        ],
      ),
      body: Column(
        children: [
          const Divider(thickness: 3, height: 1),
          Expanded(
            child: InteractiveViewer(
              // clipBehavior: Clip.none,
              // trackpadScrollCausesScale: true,
              child: ImageWidget(image: widget.imgUrl, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleWidget() {
    return TextWidget(
      text: widget.fileName,
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
      onSelected: (value) async => await _downloadImage(value, context),
    );
  }
}
