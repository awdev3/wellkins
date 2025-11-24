import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/colors.dart';
import '../../services/helpers.dart';
import '../../utils/textstyle_util.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/loaders.dart';
import 'components/custom_drawer.dart';
import 'components/tab_items.dart';

class BottomNavBar extends StatefulWidget {
  final int pageNum;

  const BottomNavBar({super.key, required this.pageNum});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with WidgetsBindingObserver {
  int pageNum = 0;
  bool _isInBackground = false;

  // final firebase = FirebasePushNotification(); /TODO Change here

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // ConnectivityCheck.initialize();
    getNotiUnreadCount();
    pageNum = widget.pageNum;
    // firebase
    //   ..initialize(context)
    //   ..getToken(context); /TODO Change here
    // ForceUpdate.checkForAppUpdate(context); /TODO Change here
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final paused = state == AppLifecycleState.paused;
    final inactive = state == AppLifecycleState.inactive;
    final resumed = state == AppLifecycleState.resumed;
    if (paused || inactive) {
      _isInBackground = true; // App is going into the background
    } else if (resumed && _isInBackground) {
      _isInBackground = false; // App has returned from the background
      getNotiUnreadCount();
    }
  }

  Future<void> getNotiUnreadCount() async {
    if (mounted) {
      final notiProvider = getNotiProvider(context);
      await notiProvider.getNotiUnreadCount(context);
    }
  }

  void _onItemTapped(int index) => setState(() => pageNum = index);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        bgImage,
        Scaffold(
          backgroundColor: ColorsData.trColor,
          extendBody: true,
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar.appbar(fromHome: true, ctx: context),
          drawer: const CustomDrawer(),
          body: IndexedStack(index: pageNum, children: NavComponents.screens),
          bottomNavigationBar: Theme(
            data: ThemeData(highlightColor: Colors.transparent),
            child: Animate(
              delay: NavComponents.duration,
              effects: NavComponents.effects,
              child: Container(
                height: 75.h,
                // margin: EdgeInsets.fromLTRB(1.w, 0, 1.w, 0),
                decoration: NavComponents.decor(),
                child: Animate(
                  delay: NavComponents.duration,
                  effects: NavComponents.effects,
                  child: ClipRRect(
                    borderRadius: NavComponents.bRadius(),
                    child: BottomNavigationBar(
                      elevation: 0,
                      onTap: _onItemTapped,
                      currentIndex: pageNum,
                      items: NavComponents().tabItems,
                      type: BottomNavigationBarType.fixed,
                      backgroundColor: ColorsData.trColor,
                      selectedItemColor: ColorsData.whiteColor,
                      unselectedItemColor: const Color(0xff909090),
                      selectedLabelStyle: TextStyleData.selectedNavLbl,
                      unselectedLabelStyle: TextStyleData.unSelectedNavLbl,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        // const LuckDrawScreen(), /TODO Change here
        authLoader(context),
      ],
    );
  }
}
