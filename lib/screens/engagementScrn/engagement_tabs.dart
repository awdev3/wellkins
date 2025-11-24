import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../providers/woo_provider.dart';
import '../../services/helpers.dart';
import '../../utils/transitions_util.dart';
import '../../utils/wellkins_icons.dart';
import '../../widgets/text_widget.dart';
import 'engagement_screen.dart';

class EngagementTabs extends StatelessWidget {
  final PageController? pageCntlr;
  final bool fromBottom;
  const EngagementTabs({
    super.key,
    this.pageCntlr,
    this.fromBottom = false,
  });

  void _changeHeader(int index, BuildContext ctx) {
    final wooProvider = getWooProvider(ctx);
    if (fromBottom) {
      _navTo(EngagementScreen(index: index), ctx);
    } else {
      if (wooProvider.tabIndex == index) {
        wooProvider.changeTab(-1);
        Navigator.pop(ctx);
      } else {
        wooProvider.changeTab(index);
        pageCntlr!.jumpToPage(index);
      }
    }
  }

  _navTo(Widget screen, BuildContext ctx) {
    final wooProvider = getWooProvider(ctx);
    if (wooProvider.tabIndex != -1 && !fromBottom) {
      Navigator.pushReplacement(ctx, FadeRoute(page: screen));
    } else {
      Navigator.push(ctx, FadeRoute(page: screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Row(
        children: [
          headerTile(
            title: AppConstants.projects,
            icon: Wellkins.star,
            ms: 400,
            index: 0,
            onTap: () {
              _changeHeader(0, context);
            },
          ),
          SizedBox(width: 10.w),
          headerTile(
            title: AppConstants.voting,
            icon: Wellkins.voting,
            ms: 600,
            index: 1,
            onTap: () {
              _changeHeader(1, context);
            },
          ),
          SizedBox(width: 10.w),
          headerTile(
            index: 2,
            title: AppConstants.wishlist,
            icon: Wellkins.heart,
            ms: 800,
            onTap: () {
              _changeHeader(2, context);
            },
          ),
        ],
      ),
    );
  }

  Widget headerTile({
    required String title,
    required IconData icon,
    required int ms,
    required int index,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: DelayedDisplay(
        delay: Duration(milliseconds: ms),
        child: GestureDetector(
          onTap: onTap,
          child: Selector<WooProvider, int>(
            selector: (context, provider) => provider.tabIndex,
            builder: (context, selectedIndex, child) {
              final tabIndex = fromBottom ? -1 : selectedIndex;
              return Container(
                decoration: decor(tabIndex, index),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          icon,
                          size: 10.sp,
                          color: tabIndex == index
                              ? ColorsData.whiteColor
                              : ColorsData.blackColor,
                        ),
                        SizedBox(height: 5.h),
                        FittedBox(
                          child: TextWidget(
                            text: title,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: tabIndex == index
                                ? ColorsData.whiteColor
                                : ColorsData.blackColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  BoxDecoration decor(int tabIndex, int index) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: ColorsData.whiteColor),
      gradient: LinearGradient(
        colors: tabIndex == index
            ? [
                ColorsData.blackColor.withValues(alpha: .6),
                ColorsData.blackColor,
              ]
            : [ColorsData.whiteColor, ColorsData.whiteColor],
      ),
      boxShadow: const [
        BoxShadow(
          color: Color.fromARGB(70, 0, 0, 0),
          spreadRadius: .2,
          blurRadius: 2,
          offset: Offset(0, 3),
        ),
      ],
    );
  }
}

// import 'package:delayed_display/delayed_display.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import '../../../constants/colors.dart';
// import '../../../constants/strings.dart';
// import '../../../utils/transitions_util.dart';
// import '../../../utils/wellkins_icons.dart';
// import '../../../widgets/text_widget.dart';
// import '../engagement_screen.dart';

// class EngagementTabs extends StatefulWidget {
//   final bool fromBottom;
//   final int index;
//   const EngagementTabs({
//     super.key,
//     this.fromBottom = false,
//     this.index = -1,
//   });

//   @override
//   State<EngagementTabs> createState() => _EngagementTabsState();
// }

// class _EngagementTabsState extends State<EngagementTabs> {
//   int selectedIndex = -1;

//   @override
//   void initState() {
//     super.initState();
//     selectedIndex = widget.index;
//   }

//   void _changeHeader(int index) {
//     if (widget.fromBottom) {
//       _navTo(EngagementScreen(index: index));
//     } else {
//       setState(() {
//         if (selectedIndex == index) {
//           selectedIndex = -1;
//           Navigator.pop(context);
//         } else {
//           selectedIndex = index;
//           _navTo(EngagementScreen(index: index));
//         }
//       });
//     }
//   }

//   _navTo(Widget screen) {
//     if (selectedIndex != -1) {
//       Navigator.pushReplacement(context, FadeRoute(page: screen));
//     } else {
//       Navigator.push(context, FadeRoute(page: screen));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return buildHeaderTiles();
//   }

//   Widget buildHeaderTiles() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 14.w),
//       child: Row(
//         children: [
//           headerTile(
//             title: AppConstants.projects,
//             icon: Wellkins.star,
//             ms: 400,
//             index: 0,
//             onTap: () {
//               _changeHeader(0);
//             },
//           ),
//           SizedBox(width: 10.w),
//           headerTile(
//             title: AppConstants.voting,
//             icon: Wellkins.voting,
//             ms: 600,
//             index: 1,
//             onTap: () {
//               _changeHeader(1);
//             },
//           ),
//           SizedBox(width: 10.w),
//           headerTile(
//             index: 2,
//             title: AppConstants.wishlist,
//             icon: Wellkins.heart,
//             ms: 800,
//             onTap: () {
//               _changeHeader(2);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget headerTile({
//     required String title,
//     required IconData icon,
//     required int ms,
//     required int index,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: DelayedDisplay(
//         delay: Duration(milliseconds: ms),
//         child: GestureDetector(
//           onTap: onTap,
//           child: Container(
//             decoration: decor(index),
//             child: Padding(
//               padding: EdgeInsets.all(6.w),
//               child: Center(
//                 child: Column(
//                   children: [
//                     Icon(
//                       icon,
//                       size: 10.sp,
//                       color: selectedIndex == index
//                           ? ColorsData.whiteColor
//                           : ColorsData.blackColor,
//                     ),
//                     SizedBox(height: 5.h),
//                     FittedBox(
//                       child: TextWidget(
//                         text: title,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                         color: selectedIndex == index
//                             ? ColorsData.whiteColor
//                             : ColorsData.blackColor,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   BoxDecoration decor(int index) {
//     return BoxDecoration(
//       borderRadius: BorderRadius.circular(10.r),
//       border: Border.all(color: ColorsData.whiteColor),
//       gradient: LinearGradient(
//         colors: selectedIndex == index
//             ? [
//                 ColorsData.blackColor.withValues(alpha: .6),
//                 ColorsData.blackColor,
//               ]
//             : [ColorsData.whiteColor, ColorsData.whiteColor],
//       ),
//       boxShadow: const [
//         BoxShadow(
//           color: Color.fromARGB(70, 0, 0, 0),
//           spreadRadius: .2,
//           blurRadius: 2,
//           offset: Offset(0, 3),
//         ),
//       ],
//     );
//   }
// }
