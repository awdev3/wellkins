import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../constants/colors.dart';
import '../../../constants/paths.dart';
import '../../../constants/strings.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/transitions_util.dart';
import '../../../widgets/image_widget.dart';
import '../../../widgets/spacers.dart';
import '../../../widgets/text_widget.dart';
import '../../mainScrns/profile_screen.dart';
import '../../taxReportScrn/tax_report_page.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: ColorsData.whiteColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(bottomRight: Radius.circular(40.r)),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [_userWidget(), _buildNavTiles(context)],
      ),
    );
  }

  Widget _userWidget() {
    return Consumer<UserProvider>(
      builder: (context, snapshot, child) {
        final user = snapshot.user;
        final image = user?.image.trim() ?? '';
        final noImage = image.isEmpty;
        return Stack(
          children: [
            ImageWidget(
              image: noImage ? Paths.bg : image,
              height: 340.w,
              width: double.infinity,
              fit: noImage ? BoxFit.fill : BoxFit.cover,
            ),
            if (!noImage)
              ClipRect(
                child: Center(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12.w, sigmaY: 12.w),
                    child: Container(
                      height: 340.w,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 10.w),
              child: Center(
                child: Column(
                  children: [
                    Card(
                      elevation: 3.r,
                      color: ColorsData.whiteColor,
                      shape: const CircleBorder(),
                      child: Padding(
                        padding: EdgeInsets.all(image.isEmpty ? 30.w : 2.w),
                        child: ClipOval(
                          clipBehavior: noImage ? Clip.none : Clip.antiAlias,
                          child: ImageWidget(
                            image: noImage ? Paths.user : image,
                            height: noImage ? 80.w : 150.w,
                            width: noImage ? 80.w : 150.w,
                            showLoad: true,
                            fit: noImage ? BoxFit.contain : BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Spacers.sb20(),
                    TextWidget(
                      text: '${user?.firstName ?? ''} ${user?.lastName ?? ''}',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: ColorsData.whiteColor,
                    ),
                    TextWidget(
                      text: user?.email ?? '',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: ColorsData.whiteColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNavTiles(BuildContext ctx) {
    return Column(
      children: [
        _navTile(
          ctx: ctx,
          icon: Icons.person,
          title: AppConstants.profile,
          onTap: () =>
              Navigator.push(ctx, FadeRoute(page: const ProfileScreen())),
        ),

        _navTile(
          ctx: ctx,
          icon: Icons.calculate,
          title: AppConstants.txReport,
          onTap: () =>
              Navigator.push(ctx, FadeRoute(page: const TaxReportPage())),
        ),
        // _divider,
        // _navTile(
        //   ctx: ctx,
        //   icon: Icons.group,
        //   title: AppConstants.clients,
        //   onTap: () {
        //     // Navigator.push(ctx, FadeRoute(page: const ClientsPage()));
        //   },
        // ),
        // _navTile(
        //   ctx: ctx,
        //   icon: Icons.work,
        //   title: AppConstants.jobDetails,
        //   onTap: () {},
        // ),
        // _navTile(
        //   ctx: ctx,
        //   icon: Icons.file_copy,
        //   title: AppConstants.myFiles,
        //   onTap: () =>
        //       Navigator.push(ctx, FadeRoute(page: const FileManager())),
        // ),
        // _navTile(
        //   ctx: ctx,
        //   icon: Icons.assignment,
        //   title: AppConstants.createJob,
        //   onTap: () {},
        // ),
        // _navTile(
        //   ctx: ctx,
        //   icon: Icons.group_add,
        //   title: AppConstants.addClients,
        //   onTap: () {},
        // ),
        // _navTile(
        //   ctx: ctx,
        //   icon: Icons.bookmark,
        //   title: AppConstants.quickBook,
        //   onTap: () {},
        // ),
        // _divider,
        // _navTile(
        //   ctx: ctx,
        //   icon: Icons.logout,
        //   title: AppConstants.logout,
        //   color: Colors.red,
        //   onTap: () {},
        // ),
      ],
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required BuildContext ctx,
    Color? color,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
      horizontalTitleGap: 20.w,
      minLeadingWidth: 25.w,
      leading: Icon(icon, color: color ?? ColorsData.primaryColor, size: 22.sp),
      title: TextWidget(
        text: title,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color ?? ColorsData.primaryColor,
      ),
      onTap: () {
        Navigator.pop(ctx); // Close the drawer
        onTap();
      },
    );
  }

  // static const _divider = Divider(color: ColorsData.formHintColor);
}
