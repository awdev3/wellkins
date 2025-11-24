import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../constants/paths.dart';
import '../../constants/strings.dart';
import '../../providers/user_provider.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/common_titles.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/spacers.dart';
import '../../widgets/text_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        bgImage,
        SafeArea(
          child: Scaffold(
            backgroundColor: ColorsData.trColor,
            appBar: CustomAppBar.appbar(ctx: context, showLeading: false),
            body: Column(
              children: [
                CommonTitles.title(
                  text: AppConstants.profile,
                  context: context,
                ),
                Expanded(
                    child: DelayedDisplay(
                  child: SizedBox(
                    width: double.infinity,
                    child: Card(
                      elevation: 6,
                      color: ColorsData.whiteColor,
                      surfaceTintColor: ColorsData.whiteColor,
                      margin: EdgeInsets.fromLTRB(15.w, 30.w, 15.w, 30.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40.r),
                      ),
                      child: Stack(
                        children: [
                          Consumer<UserProvider>(
                            builder: (context, snapshot, child) {
                              final image = snapshot.user!.image.trim();
                              return Column(
                                children: [
                                  Spacers.sb50(),
                                  CircleAvatar(
                                    radius: 66.r,
                                    backgroundColor: ColorsData.whiteColor,
                                    backgroundImage:
                                        const AssetImage(Paths.ellipse),
                                    child: image.isEmpty
                                        ? ImageWidget(
                                            image: Paths.user,
                                            height: 66.w,
                                            width: 61.w,
                                            fit: BoxFit.cover,
                                          )
                                        : CircleAvatar(
                                            radius: 64.r,
                                            backgroundColor:
                                                ColorsData.whiteColor,
                                            backgroundImage:
                                                NetworkImage(image),
                                          ),
                                  ),
                                  Spacers.sb20(),
                                  TextWidget(
                                    text:
                                        '${snapshot.user!.firstName} ${snapshot.user!.lastName}',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  Spacers.sb5(),
                                  TextWidget(
                                    text: snapshot.user!.email,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff8C8C8C),
                                    letterSpacing: 1.1,
                                  ),
                                  Spacers.sb20(),
                                  _field(
                                    AppConstants.fname,
                                    snapshot.user!.firstName,
                                  ),
                                  _field(
                                    AppConstants.lname,
                                    snapshot.user!.lastName,
                                  ),
                                  _field(
                                    AppConstants.cntct,
                                    snapshot.user!.contactNo,
                                  ),
                                  _field(
                                    AppConstants.email,
                                    snapshot.user!.email,
                                  ),
                                ],
                              );
                            },
                          ),
                          setNeuMorph(0),
                          setNeuMorph(1),
                        ],
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _field(String title, String value) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: TextWidget(
                text: title,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacers.sb2(),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 5.h,
                ),
                border: _border(),
                enabledBorder: _border(),
                focusedBorder: _border(),
                hintText: value,
                hintStyle: MyFont.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color.fromARGB(255, 118, 118, 118),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget setNeuMorph(int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.r),
        border: Border.all(
          color: ColorsData.whiteColor,
          width: 2.w,
        ),
        gradient: LinearGradient(
          stops: [.01.w, .03.w, .2.w],
          begin: index == 0 ? Alignment.centerLeft : Alignment.centerRight,
          end: index == 0 ? Alignment.centerRight : Alignment.centerLeft,
          colors: [
            Colors.black12.withValues(alpha: .2),
            Colors.transparent,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(37.r),
      borderSide: const BorderSide(color: Color(0xFF51516B)),
    );
  }
}
