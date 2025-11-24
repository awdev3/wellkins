import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../models/noti_model.dart';
import '../../providers/noti_provider.dart';
import '../../services/helpers.dart';
import '../../utils/formatter.dart';
import '../../utils/transitions_util.dart';
import '../../utils/wellkins_icons.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/common_titles.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_prompts.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/loaders.dart';
import '../../widgets/spacers.dart';
import '../../widgets/text_widget.dart';
import 'noti_details.dart';

class NotiScreen extends StatelessWidget {
  const NotiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final noti = getNotiProvider(context);
    // noti.setLatestDateAndTime();
    noti.getNotifications(context);
    noti.getNotiUnreadCount(context);
    return Stack(
      children: [
        bgImage,
        Scaffold(
          backgroundColor: ColorsData.trColor,
          appBar: CustomAppBar.appbar(ctx: context, showTrailing: false),
          body: Column(
            children: [
              CommonTitles.title(
                text: AppConstants.noti,
                context: context,
              ),
              Spacers.sb10(),
              Expanded(
                child: DelayedDisplay(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
                    padding: EdgeInsets.fromLTRB(15.w, 20.w, 15.w, 0),
                    decoration: commonDecor,
                    child: Consumer<NotiProvider>(
                      builder: (context, snapshot, child) {
                        return snapshot.notiLoad
                            ? showLoader()
                            : snapshot.notiList.isEmpty
                                ? CustomPrompts.showEmptyInfo(
                                    icon: Icons.notifications_none,
                                    text: AppConstants.noNoti,
                                  )
                                : buildNotiTile(snapshot);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildNotiTile(NotiProvider snapshot) {
    return DelayedDisplay(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: snapshot.notiList.length,
        itemBuilder: (context, index) {
          final notification = snapshot.notiList[index];
          return notificationTile(notification, context);
        },
      ),
    );
  }

  Widget notificationTile(Noti noti, BuildContext context) {
    final now = DateTime.now();
    String frmtdNow = Frmtr.frmtDate(dateTime: now);
    String formatedDate = noti.date == frmtdNow ? 'NOW' : noti.date;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          FadeRoute(page: NotiDetailsScreen(noti: noti)),
        );
      },
      child: Stack(
        children: [
          Card(
            elevation: 3,
            color: ColorsData.whiteColor,
            surfaceTintColor: ColorsData.whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (noti.image.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.r),
                        child: ImageWidget(
                          image: noti.image,
                          // height: 115.w,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorWidget: const SizedBox.shrink(),
                        ),
                      ),
                    ),
                  Spacers.sb10(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Wellkins.noti,
                        size: 12.sp,
                        color: noti.isRead ? Colors.grey : Colors.green,
                      ),
                      Spacers.sbw10(),
                      TextWidget(
                        text: formatedDate,
                        color: const Color(0xffA2A0AD),
                        fontSize: 11,
                        fontWeight:
                            noti.isRead ? FontWeight.w400 : FontWeight.w500,
                      ),
                    ],
                  ),
                  Spacers.sb10(),
                  TextWidget(
                    text: noti.title,
                    color: const Color(0xff0F0734),
                    fontSize: 14,
                    fontWeight: noti.isRead ? FontWeight.w600 : FontWeight.bold,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Spacers.sb10(),
                  TextWidget(
                    text: noti.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    color: const Color(0xff6D7278),
                    fontSize: 13,
                    fontWeight: noti.isRead ? FontWeight.w400 : FontWeight.w500,
                  ),
                  Spacers.sb10(),
                ],
              ),
            ),
          ),
          if (!noti.isRead)
            Positioned(
              top: 20,
              right: 20,
              child: CircleAvatar(
                radius: 6.r,
                backgroundColor: Colors.green,
              ),
            ),
        ],
      ),
    );
  }
}
