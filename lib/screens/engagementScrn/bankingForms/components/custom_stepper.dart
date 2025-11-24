import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../widgets/spacers.dart';
import '../../../../widgets/text_widget.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final List<String> stepTitles;
  final Function(int) onStepTapped;

  const CustomStepper({
    super.key,
    required this.currentStep,
    required this.stepTitles,
    required this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.cyan, Colors.green],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          stepTitles.length,
          (index) => _stepItem(
            index + 1,
            stepTitles[index],
            currentStep >= index,
            index,
          ),
        ),
      ),
    );
  }

  Widget _stepItem(int stepNumber, String title, bool isActive, int stepIndex) {
    return Expanded(
      child: InkWell(
        onTap: () => onStepTapped(stepIndex),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundColor: isActive ? Colors.white : Colors.white60,
              child: currentStep > stepIndex
                  ? Icon(Icons.check, color: Colors.green, size: 18.sp)
                  : TextWidget(
                      text: "$stepNumber",
                      color: isActive ? Colors.cyan : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
            ),
            Spacers.sb5(),
            SizedBox(
              height: 32.h,
              child: TextWidget(
                text: title,
                textAlign: TextAlign.center,
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
