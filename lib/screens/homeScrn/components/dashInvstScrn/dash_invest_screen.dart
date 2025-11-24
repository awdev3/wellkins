import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/colors.dart';
import '../../../../../constants/strings.dart';
import '../../../../../widgets/text_widget.dart';
import '../../../../widgets/backgrounds.dart';
import 'components/investments_screen.dart';

class DashAndInvestScreen extends StatefulWidget {
  const DashAndInvestScreen({super.key});

  @override
  State<DashAndInvestScreen> createState() => _DashAndInvestScreenState();
}

class _DashAndInvestScreenState extends State<DashAndInvestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_tabChanged);
  }

  void _tabChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            DelayedDisplay(
              slidingBeginOffset: const Offset(-0.35, 0),
              child: buildTabBar(),
            ),
            SizedBox(height: 12.h),
            buildTabBarView(),
          ],
        ),
      ),
    );
  }

  Widget buildTabBar() {
    return Container(
      height: 66.w,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: const ShapeDecoration(
        color: ColorsData.whiteColor,
        shape: StadiumBorder(),
        shadows: [
          BoxShadow(
            color: Color.fromARGB(100, 0, 0, 0),
            spreadRadius: .2,
            blurRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        unselectedLabelColor: const Color(0xff293042),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        overlayColor: overlayColor(),
        indicator: tabIndicator(_tabController.index),
        labelStyle: MyFont.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: ColorsData.whiteColor,
        ),
        indicatorPadding: EdgeInsets.all(3.w),
        labelPadding: EdgeInsets.only(left: 24.w, right: 24.w),
        tabs: [
          tabText(AppConstants.dashboard),
          tabText(AppConstants.myInvestments),
        ],
      ),
    );
  }

  Widget buildTabBarView() {
    return Expanded(
      child: DelayedDisplay(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
          padding: EdgeInsets.fromLTRB(15.w, 20.w, 15.w, 0),
          decoration: commonDecor,
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              InvestmentsScreen(),
              InvestmentsScreen(fromDash: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget tabText(String text) {
    return FittedBox(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.w, horizontal: 4.w),
        child: Text(text),
      ),
    );
  }

  WidgetStatePropertyAll<Color?> overlayColor() {
    return const WidgetStatePropertyAll(ColorsData.trColor);
  }

  ShapeDecoration tabIndicator(int index) {
    return ShapeDecoration(
      shape: const StadiumBorder(),
      gradient: LinearGradient(
        colors: index == 0
            ? [const Color(0xff1274AC), const Color(0xff007F84)]
            : [const Color(0xff3E4071), const Color(0xff57639A)],
      ),
      shadows: const [
        BoxShadow(
          color: Color.fromARGB(55, 0, 0, 0),
          spreadRadius: 1,
          blurRadius: 4,
        ),
      ],
    );
  }
}
