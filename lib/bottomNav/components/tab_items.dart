import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/colors.dart';
import '../../../constants/strings.dart';
import '../../../utils/wellkins_icons.dart';

class NavComponents {
  static const duration = Duration(milliseconds: 50);
  static const effects = [FlipEffect(duration: Duration(milliseconds: 700))];

  static List<Widget> screens = [
    // const HomeScreen(),
    // const HistoryScreen(),
    // const SettingsScreen(),
    Center(child: const Text("screen one")),
    Center(child: const Text("screen two")),
    Center(child: const Text("screen three")),
  ];

  List<BottomNavigationBarItem> tabItems = [
    _buildNavItem(Icons.home_filled, AppConstants.home),
    _buildNavItem(Wellkins.history, AppConstants.history),
    _buildNavItem(Wellkins.settings, AppConstants.settings),
  ];

  static BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Icon(icon, size: 19.sp),
      ),
      label: label,
    );
  }

  static BoxDecoration decor() {
    return BoxDecoration(
      color: ColorsData.primaryColor,
      borderRadius: bRadius(),
    );
  }

  static BorderRadius bRadius() {
    return BorderRadius.only(
      topLeft: Radius.circular(18.r),
      topRight: Radius.circular(18.r),
      // bottomLeft: Radius.circular(50.r),
      // bottomRight: Radius.circular(50.r),
    );
  }
}
