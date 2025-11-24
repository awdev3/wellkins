import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../constants/colors.dart';
import '../../../../utils/regx.dart';
import '../../../../widgets/field_widget.dart';
import '../../../../widgets/spacers.dart';
import '../../../../widgets/text_widget.dart';
import '../../../../widgets/toasts.dart';

class FormHelpers {
  // Static Lists
  static final List<String> titles = ['Mr.', 'Mrs.', 'Miss', 'Ms.', 'Dr.'];
  static final List<String> streetTypes = [
    'Road',
    'Street',
    'Avenue',
    'Lane',
    'Drive',
  ];
  static final List<String> states = [
    'NSW',
    'VIC',
    'QLD',
    'SA',
    'WA',
    'TAS',
    'NT',
    'ACT',
  ];
  static final List<String> sources = [
    'Gain Employment',
    'Inheritance/gift',
    'Business Activity',
    'Financial investments',
    'Superannuation savings',
    'Others',
  ];
  static final List<String> designations = [
    'secretary',
    'Director',
    'Manager',
    'Trustee',
    'Other',
  ];

  // Get formatted date
  static String getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('E MMM d y').format(now);
  }

  // File picker
  static Future<List<String>?> pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        allowMultiple: true,
        onFileLoading: (FilePickerStatus status) {
          debugPrint('$status');
        },
      );

      if (result != null) {
        return result.files.map((file) => file.path!).toList();
      }
      return null;
    } catch (e) {
      showToast(message: "Error selecting files: $e");
      return null;
    }
  }

  // Check if file is image
  static bool isImageFile(String fileName) {
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    final lowerFileName = fileName.toLowerCase();
    return imageExtensions.any((ext) => lowerFileName.endsWith(ext));
  }

  // Check if file is PDF
  static bool isPdfFile(String fileName) {
    return fileName.toLowerCase().endsWith('.pdf');
  }

  // Show image preview dialog
  static void showImagePreview(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 400.w,
          height: 500.h,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: ColorsData.blueShade,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text: "Image Preview",
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Image.file(
                    File(filePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            size: 48.sp,
                            color: Colors.red,
                          ),
                          Spacers.sb10(),
                          TextWidget(
                            text: "Failed to load image",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Open PDF file
  static void openPdfFile(String filePath) {
    try {
      // OpenFile.open(filePath);
    } catch (e) {
      showToast(message: "Error opening PDF: $e");
    }
  }

  // Build Card with Header
  static Widget buildCardWithHeader(
    String title,
    Widget content, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return Card(
      elevation: 2,
      color: ColorsData.whiteColor,
      surfaceTintColor: ColorsData.whiteColor,
      child: Column(
        children: [
          buildCardHeader(title, fontSize, fontWeight),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: content,
          ),
          Spacers.sb10(),
        ],
      ),
    );
  }

  // Build Card Header
  static Widget buildCardHeader(
    String title,
    double fontSize,
    FontWeight fontWeight,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: ColorsData.blueShade,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: sectionTitle(title, fontSize, fontWeight, ColorsData.whiteColor),
    );
  }

  // Section Title
  static Widget sectionTitle(
    String title,
    double fontSize,
    FontWeight fontWeight,
    Color color,
  ) {
    return Align(
      alignment: Alignment.topLeft,
      child: TextWidget(
        text: title,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: 0.8,
      ),
    );
  }

  // Build Text Field
  static Widget buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool digit = false,
    bool readOnly = false,
    String? regErrorText,
    RegExp? regExp,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(label, 14, FontWeight.bold, ColorsData.blackColor),
        Spacers.sb8(),
        CustomTextField(
          controller: controller,
          hintText: hintText,
          errorText: "Required",
          outlined: true,
          filled: true,
          fillColor: ColorsData.whiteColor,
          digit: digit,
          readOnly: readOnly,
          regErrorText: regErrorText,
          regExpCondition: regExp ?? Regx.nameRegExp,
        ),
      ],
    );
  }

  // Build Dropdown Field
  static Widget buildDropdownField({
    required String label,
    required List<String> items,
    required String? value,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(label, 14, FontWeight.bold, ColorsData.blackColor),
        Spacers.sb8(),
        CustomDropdownField(
          items: items,
          value: value,
          hint: TextWidget(
            text: "Select",
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
          ),
          onChanged: onChanged,
          errorText: "Required",
          icon: const Icon(Icons.keyboard_arrow_down_sharp, color: Colors.grey),
        ),
      ],
    );
  }

  // Build Text Field Row
  static Widget buildTextFieldRow(List<Map<String, dynamic>> fields) {
    return Row(
      children: fields.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> field = entry.value;
        return Expanded(
          child: Padding(
            padding: index == 0 ? EdgeInsets.zero : EdgeInsets.only(left: 10.w),
            child: buildTextField(
              label: field['label'] as String,
              controller: field['controller'] as TextEditingController,
              hintText: field['hint'] as String?,
              digit: field['digit'] as bool? ?? false,
              regErrorText: field['regErrorText'] as String?,
              regExp: field['regExp'] as RegExp?,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Build Date Picker Field
  static Widget buildDatePickerField(
    BuildContext context,
    TextEditingController controller,
    String label,
  ) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: ColorsData.blueShade,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          String formattedDate =
              '${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
          controller.text = formattedDate;
        }
      },
      child: AbsorbPointer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle(label, 14, FontWeight.bold, ColorsData.blackColor),
            Spacers.sb8(),
            CustomTextField(
              controller: controller,
              hintText: "DD/MM/YYYY",
              errorText: "Required",
              outlined: true,
              filled: true,
              fillColor: Colors.white,
              regExpCondition: Regx.addressRegExp,
              suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // Build Button
  static Widget buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 18.sp) : const SizedBox.shrink(),
      label: TextWidget(
        text: label,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ColorsData.whiteColor,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  // Build File Upload Box
  static Widget buildFileUploadBox({
    required VoidCallback onTap,
    required int filesCount,
    required String documentKey,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(color: Colors.black54, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(Icons.folder_open, color: Colors.white, size: 20.sp),
                  Spacers.sbw10(),
                  Expanded(
                    child: TextWidget(
                      text: filesCount > 0
                          ? "$filesCount files selected"
                          : "Select files...",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Spacers.sbw10(),
            ElevatedButton.icon(
              onPressed: onTap,
              icon: Icon(Icons.cloud_upload, size: 16.sp),
              label: TextWidget(
                text: "Browse",
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Document Display Widget
  static Widget buildDocumentDisplayWidget(
    BuildContext context,
    String documentKey,
    String fileName,
    Function(String) onRemove,
  ) {
    bool isImage = isImageFile(fileName);
    bool isPdf = isPdfFile(fileName);
    bool isImageUrl = fileName.startsWith('http');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (isImage)
                  Container(
                    width: 50.w,
                    height: 50.h,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: Colors.blue.shade300),
                    ),
                    child: isImageUrl
                        ? Image.network(
                            fileName,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                    size: 24.sp,
                                  ),
                                ),
                          )
                        : Image.file(
                            File(fileName),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.red,
                                    size: 24.sp,
                                  ),
                                ),
                          ),
                  )
                else if (isPdf)
                  Container(
                    width: 50.w,
                    height: 50.h,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                        size: 28.sp,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 50.w,
                    height: 50.h,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.description,
                        color: ColorsData.blueShade,
                        size: 28.sp,
                      ),
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: "Image or PDF",
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: ColorsData.blackColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Spacers.sb5(),
                      TextWidget(
                        text: isImage
                            ? "Image file"
                            : isPdf
                            ? "PDF file"
                            : "Document file",
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isImage)
                IconButton(
                  onPressed: () => showImagePreview(context, fileName),
                  icon: Icon(Icons.preview, color: Colors.blue, size: 18.sp),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (isPdf)
                IconButton(
                  onPressed: () => openPdfFile(fileName),
                  icon: Icon(Icons.open_in_new, color: Colors.red, size: 18.sp),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              IconButton(
                onPressed: () => onRemove(fileName),
                icon: Icon(Icons.close, color: Colors.red, size: 18.sp),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Build Declaration Bullet
  static Widget buildDeclarationBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 6.h, right: 10.w),
          child: Container(
            width: 6.w,
            height: 6.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: ColorsData.blackColor,
            ),
          ),
        ),
        Expanded(
          child: TextWidget(
            text: text,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: ColorsData.blackColor,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
