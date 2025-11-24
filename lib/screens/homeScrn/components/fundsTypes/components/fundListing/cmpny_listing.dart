import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:wellkins/utils/extensions.dart';

import '../../../../../../constants/colors.dart';
import '../../../../../../constants/paths.dart';
import '../../../../../../constants/strings.dart';
import '../../../../../../models/project_model.dart';
import '../../../../../../providers/woo_provider.dart';
import '../../../../../../utils/formatter.dart';
import '../../../../../../widgets/backgrounds.dart';
import '../../../../../../widgets/custom_prompts.dart';
import '../../../../../../widgets/image_widget.dart';
import '../../../../../../widgets/spacers.dart';
import '../../../../../../widgets/text_widget.dart';

class CompanyListing {
  static Widget buildFundsTile(int fundSubType, BuildContext ctx) {
    final radius = Radius.circular(40.r);
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
      child: Consumer<WooProvider>(
        builder: (context, snapshot, child) {
          // final projectList = fundType == -1
          //     ? snapshot.projectsList.where((e) => e.fundType != 1).toList()
          //     : snapshot.projectsList
          //         .where((e) => (e.fundType == fundType))
          //         // && (e.status.toLowerCase() != 'completed') &&
          //         //    (e.status.toLowerCase() != 'closed'))
          //         .toList();

          final projectList = fundSubType == -1
              // removes all mortgage funds
              ? snapshot.projectsList.where((e) => e.fundType != 1).toList()
              : snapshot.projectsList
                  .where((e) => e.fundSubType == fundSubType)
                  .toList();

          return projectList.isEmpty
              ? CustomPrompts.showEmptyInfo(
                  icon: Icons.do_not_disturb_alt,
                  text: AppConstants.noData,
                )
              : DelayedDisplay(
                  child: ListView.builder(
                    itemCount: projectList.length,
                    itemBuilder: (context, index) {
                      final project = projectList[index];
                      return fundTile(project, ctx);
                    },
                  ),
                );
        },
      ),
    );
  }

  static Widget fundTile(Project project, BuildContext ctx) {
    return Card(
      elevation: 6.w,
      color: ColorsData.whiteColor,
      surfaceTintColor: ColorsData.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
      margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildImage(project),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(project),
                Spacers.sb2(),
                const Divider(color: ColorsData.formHintColor),
                buildTable(project, ctx),
                Spacers.sb2(),
                _notes(project.desc, ctx),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildTable(Project project, BuildContext ctx) {
    final isMorgage = project.fundType == 1;
    return Table(children: [
      _buildRow(
        title1: AppConstants.totalInvestments,
        value1: Frmtr.frmtCurrency(project.facility),
        title2: AppConstants.term,
        value2: project.term,
      ),
      _buildRow(
        title1: AppConstants.propertyType,
        value1: project.fundTypeName,
        title2: isMorgage ? AppConstants.lvr : '',
        value2: isMorgage ? project.lvr : '',
      ),
      _buildRow(
        title1: '${AppConstants.minInv}:',
        value1: Frmtr.frmtCurrency(project.minInvestment.toDouble),
      ),
      if (isMorgage)
        _buildRow(
          title1: AppConstants.returns,
          value1: project.returns,
        ),
    ]);
  }

  static TableRow _buildRow({
    final String title1 = '',
    final String value1 = '',
    final String title2 = '',
    final String value2 = '',
  }) {
    return TableRow(
      children: [
        _buildCell(title1, value1),
        _buildCell(title2, value2),
      ],
    );
  }

  static Widget _buildCell(String text, String value) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: text,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: ColorsData.greyColor,
              textAlign: TextAlign.start,
            ),
            TextWidget(
              text: value,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: ColorsData.blackColor,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildImage(Project project) {
    final images = project.images;
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(30.r),
        bottom: Radius.circular(15.r),
      ),
      child: AspectRatio(
        aspectRatio: 2.2,
        child: ImageWidget(
            image: images.isEmpty ? '' : images.first,
            fit: BoxFit.cover,
            errorWidget: Stack(
              alignment: Alignment.center,
              children: [
                bgImage,
                ImageWidget(
                  width: 180.w,
                  image: Paths.logo,
                  fit: BoxFit.cover,
                ),
              ],
            )),
      ),
    );
  }

  static Widget buildHeader(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: project.propertyName,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        TextWidget(
          text: project.propType,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        ),
      ],
    );
  }

  static Widget _notes(String decp, BuildContext ctx) {
    return Theme(
      data: Theme.of(ctx).copyWith(dividerColor: ColorsData.trColor),
      child: ExpansionTile(
        tilePadding: EdgeInsets.symmetric(horizontal: 10.w),
        childrenPadding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.w),
        iconColor: Colors.black87,
        collapsedIconColor: Colors.black87,
        collapsedBackgroundColor: const Color.fromARGB(255, 240, 255, 243),
        backgroundColor: const Color.fromARGB(255, 240, 255, 243),
        // const Color(0xffE9E9E9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        title: const TextWidget(
          text: AppConstants.viewDetails,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
        children: [
          TextWidget(
            text: decp,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  // static Widget buildDetails(Project project) {
  //   return Column(
  //     mainAxisSize: MainAxisSize.max,
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const TextWidget(
  //         text: AppConstants.totalInvestments,
  //         fontSize: 12,
  //         fontWeight: FontWeight.bold,
  //         color: Color(0xff252525),
  //       ),
  //       TextWidget(
  //         text: Frmtr.frmtCurrency(project.facility),
  //         fontSize: 11,
  //         fontWeight: FontWeight.bold,
  //         color: const Color(0xff252525),
  //         maxLines: 2,
  //         overflow: TextOverflow.ellipsis,
  //       )
  //     ],
  //   );
  // }
}
