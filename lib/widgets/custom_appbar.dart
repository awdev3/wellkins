import 'package:badges/badges.dart' as badges;
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../constants/paths.dart';
import '../providers/noti_provider.dart';
import '../providers/user_provider.dart';
import '../screens/bottomNav/bottom_nav_bar.dart';
import '../screens/notification/noti_screen.dart';
import '../utils/transitions_util.dart';
import '../utils/wellkins_icons.dart';
import 'image_widget.dart';
import 'text_widget.dart';

class CustomAppBar {
  static AppBar appbar({
    SystemUiOverlayStyle? systemOverlayStyle = SystemUiOverlayStyle.dark,
    required BuildContext ctx,
    bool animate = true,
    bool showLeading = true,
    bool showTrailing = true,
    bool fromHome = false,
    bool hasBack = false,
  }) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 74.h,
      backgroundColor: ColorsData.trColor,
      systemOverlayStyle: systemOverlayStyle,
      centerTitle: true,
      automaticallyImplyLeading: false,
      // title: titleWidget(),
      // leading: leadingWidget(ctx: ctx),
      // actions: actionWidgets(ctx: ctx),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          leadingWidget(
            ctx: ctx,
            showLeading: showLeading,
            hasBack: hasBack,
            fromhome: fromHome,
          ),
          titleWidget(animate, ctx),
          actionWidget(ctx: ctx, showTrailing: showTrailing),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(1.h),
        child: Divider(
          thickness: .5,
          color: ColorsData.whiteColor,
          indent: 40.w,
          endIndent: 40.w,
        ),
      ),
    );
  }

  static Widget leadingWidget({
    required bool showLeading,
    required bool hasBack,
    required bool fromhome,
    required BuildContext ctx,
  }) {
    return hasBack
        ? IconButton(
            onPressed: () {
              Navigator.pop(ctx);
            },
            icon: Icon(
              Wellkins.back,
              size: 17.sp,
              color: ColorsData.whiteColor,
            ),
          )
        : fromhome
        ? Builder(
            builder: (context) => Padding(
              padding: EdgeInsets.all(5.w),
              child: IconButton(
                onPressed: showLeading
                    ? () => Scaffold.of(context).openDrawer()
                    : null,
                icon: Icon(
                  Icons.menu_rounded,
                  size: 28.sp,
                  color: ColorsData.primaryColor,
                ),
              ),
            ),
          )
        : Opacity(
            opacity: showLeading ? 1 : 0,
            child: GestureDetector(
              onTap: () {
                // if (showLeading) {
                //   Navigator.push(
                //       ctx, FadeRoute(page: const ProfileScreen()));
                // }
              },
              child: Card(
                elevation: 4,
                margin: EdgeInsets.only(left: 10.w, right: 10.w),
                color: ColorsData.whiteColor,
                surfaceTintColor: ColorsData.whiteColor,
                shape: const CircleBorder(),
                child: CircleAvatar(
                  radius: 16.w,
                  backgroundColor: ColorsData.whiteColor,
                  backgroundImage: const AssetImage(Paths.ellipse),
                  child: Consumer<UserProvider>(
                    builder: (context, snapshot, child) {
                      final image = snapshot.user?.image.trim() ?? '';
                      return image.isEmpty
                          ? ImageWidget(
                              image: Paths.user,
                              height: 12.w,
                              width: 12.w,
                              showLoad: false,
                              fit: BoxFit.cover,
                            )
                          : CircleAvatar(
                              radius: 64.r,
                              backgroundColor: ColorsData.whiteColor,
                              backgroundImage: NetworkImage(image),
                            );
                    },
                  ),
                ),
              ),
            ),
          );
  }

  static Widget titleWidget(bool animate, BuildContext ctx) {
    return animate
        ? DelayedDisplay(
            slidingBeginOffset: const Offset(0, 5),
            child: img(ctx),
          )
        : img(ctx);
  }

  static Widget img(BuildContext ctx) {
    return GestureDetector(
      onTap: () {
        Navigator.pushAndRemoveUntil(
          ctx,
          FadeRoute(page: const BottomNavBar(pageNum: 0)),
          (route) => false,
        );
      },
      child: ImageWidget(
        image: Paths.logo,
        width: 100.w,
        // height: 36.h,
      ),
    );
  }

  static Widget actionWidget({
    required bool showTrailing,
    required BuildContext ctx,
  }) {
    return Opacity(
      opacity: showTrailing ? 1 : 0,
      child: GestureDetector(
        onTap: () {
          if (showTrailing) {
            Navigator.push(ctx, FadeRoute(page: const NotiScreen()));
          }
        },
        child: Padding(
          padding: EdgeInsets.only(left: 10.w, right: 10.w),
          child: CircleAvatar(
            radius: 16.w,
            backgroundColor: ColorsData.whiteColor,
            backgroundImage: const AssetImage(Paths.ellipse),
            child: Consumer<NotiProvider>(
              builder: (context, snapshot, child) {
                return badges.Badge(
                  badgeStyle: badges.BadgeStyle(padding: EdgeInsets.all(3.w)),
                  position: badges.BadgePosition.topEnd(),
                  badgeContent: TextWidget(
                    text: '${snapshot.unreadCount}',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: ColorsData.whiteColor,
                  ),
                  showBadge: snapshot.unreadCount > 0,
                  child: Icon(
                    Wellkins.noti,
                    size: 22.sp,
                    color: const Color(0xff264780),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // List<Widget>? actionWidgets({required BuildContext ctx}) {
  //   int notiCount = 1;
  //   return [
  //     SizedBox(width: 10.w),
  //     // Consumer<AuthProvider>(
  //     //   builder: (context, snapshot, child) {
  //     //     return
  //     GestureDetector(
  //       onTap: () {
  //         // Navigator.push(context, FadeRoute(page: const MyProfileScreen()));
  //       },
  //       child: AspectRatio(
  //         aspectRatio: 1,
  //         child: CircleAvatar(
  //           radius: 12.r,
  //           backgroundColor: ColorsData.whiteColor,
  //           backgroundImage: const AssetImage(Paths.ellipse),
  //           child: badges.Badge(
  //             badgeStyle: const badges.BadgeStyle(
  //               padding: EdgeInsets.all(3),
  //             ),
  //             position: badges.BadgePosition.topEnd(),
  //             badgeContent: TextWidget(
  //               text: notiCount > 99 ? '99+' : '$notiCount',
  //               fontSize: 9,
  //               fontWeight: FontWeight.bold,
  //               color: ColorsData.whiteColor,
  //             ),
  //             child: Icon(
  //               Wellkins.noti,
  //               size: 22.sp,
  //               color: const Color(0xff264780),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //     //   },
  //     // ),
  //     SizedBox(width: 10.w),
  //   ];
  // }
}
