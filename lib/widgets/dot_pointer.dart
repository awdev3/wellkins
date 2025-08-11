import 'package:flutter/material.dart';

class DotPointer extends StatelessWidget {
  final int pageCount;
  final int selectedIndex;
  final Color primaryColor;
  final Color secondaryColor;
  const DotPointer({
    super.key,
    required this.pageCount,
    required this.selectedIndex,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return SizedBox(
      height: 20,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: pageCount,
        itemBuilder: (_, index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOutCubicEmphasized,
            decoration: BoxDecoration(
              color: selectedIndex == index ? primaryColor : secondaryColor,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.all(3),
            width: selectedIndex == index ? w * 0.018 : w * 0.012,
            height: selectedIndex == index ? w * 0.018 : w * 0.012,
          );
        },
      ),
    );
  }
}
