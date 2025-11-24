import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signature/signature.dart';

import '../../../../constants/colors.dart';
import '../../../../widgets/spacers.dart';
import '../../../../widgets/text_widget.dart';
import '../../../../widgets/toasts.dart';

class SignatureDialog {
  static Future<Uint8List?> show(
    BuildContext context,
    SignatureController controller,
  ) async {
    return showDialog<Uint8List>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: SizedBox(
            width: 500.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.draw_outlined,
                        color: ColorsData.blackColor,
                        size: 24.sp,
                      ),
                      Spacers.sbw10(),
                      Expanded(
                        child: TextWidget(
                          text: "Add Your Signature",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorsData.blackColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, size: 24.sp),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      // Instructions
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 18.sp,
                            ),
                            Spacers.sbw10(),
                            Expanded(
                              child: TextWidget(
                                text: "Sign clearly within the box below",
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Spacers.sb15(),

                      // Signature Canvas
                      Container(
                        height: 220.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: Signature(
                            controller: controller,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),

                      Spacers.sb20(),

                      // Action Buttons
                      Row(
                        children: [
                          // Clear Button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                controller.clear();
                              },
                              icon: Icon(Icons.refresh, size: 18.sp),
                              label: TextWidget(
                                text: "Clear",
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(
                                  color: Colors.grey.shade400,
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),

                          Spacers.sbw10(),

                          // Save Button
                          Expanded(
                            flex: 2,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (controller.isNotEmpty) {
                                  final Uint8List? data = await controller
                                      .toPngBytes();
                                  if (data != null) {
                                    Navigator.pop(context, data);
                                    showToast(
                                      message:
                                          "✅ Signature saved successfully!",
                                    );
                                  }
                                } else {
                                  showToast(
                                    message: "⚠️ Please sign before saving",
                                  );
                                }
                              },
                              icon: Icon(Icons.check_circle, size: 18.sp),
                              label: TextWidget(
                                text: "Save Signature",
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
