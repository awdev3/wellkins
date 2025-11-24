import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/strings.dart';
import '../../../../models/home_models.dart';
import '../../../../providers/dash_provider.dart';
import '../../../../providers/inv_provider.dart';
import '../../../../utils/extensions.dart';
import '../../../../widgets/spacers.dart';
import '../../../../widgets/text_widget.dart';

class InvestedLocationsChart extends StatelessWidget {
  final bool fromDash;
  const InvestedLocationsChart({
    super.key,
    required this.fromDash,
  });

  @override
  Widget build(BuildContext context) {
    return fromDash
        ? Consumer<DashProvider>(
            builder: (context, snapshot, child) {
              return snapshot.invLocationList.isEmpty
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        titleWidget(AppConstants.investedLocations),
                        Spacers.sb15(),
                        _buildHeaderRow(),
                        Divider(
                          thickness: .9,
                          indent: 15.w,
                          endIndent: 10.w,
                          color: ColorsData.formHintColor,
                        ),
                        ...snapshot.invLocationList
                            .map((location) => _buildDataRow(location)),
                        Spacers.sb30(),
                      ],
                    );
            },
          )
        : Consumer<InvProvider>(
            builder: (context, snapshot, child) {
              return snapshot.invLocationList.isEmpty
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        titleWidget(AppConstants.investedLocations),
                        Spacers.sb15(),
                        _buildHeaderRow(),
                        Divider(
                          thickness: .9,
                          indent: 15.w,
                          endIndent: 10.w,
                          color: ColorsData.formHintColor,
                        ),
                        Column(
                          children: snapshot.invLocationList
                              .map((location) => _buildDataRow(location))
                              .toList(),
                        )
                      ],
                    );
            },
          );
  }

  Widget _buildHeaderRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCell('#'),
        _buildCell(AppConstants.numberOfAppln),
        _buildCell(AppConstants.name),
        _buildCell(AppConstants.popularity),
        _buildCell(AppConstants.funds),
      ],
    );
  }

  Widget _buildDataRow(InvestedLocation location) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildCell(location.no, false),
          _buildCell(location.projectCount, false),
          _buildCell(location.name, false),
          _buildPopularityCell(location.populairy.toDouble),
          _buildFundsCell(location.funds),
        ],
      ),
    );
  }

  Widget _buildCell(String text, [bool isTitle = true]) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Center(
          child: FittedBox(
            child: TextWidget(
              text: text,
              fontSize: isTitle ? 11 : 10,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.w600,
              color: ColorsData.blackColor,
              textAlign: TextAlign.center,
              viewCase: isTitle ? null : ViewCase.upper,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularityCell(double popularity) {
    double value = popularity / 100;
    Color color;
    if (popularity <= 20) {
      color = Colors.red;
    } else if (popularity <= 40) {
      color = Colors.yellow;
    } else if (popularity <= 60) {
      color = Colors.orange;
    } else if (popularity <= 80) {
      color = Colors.blue;
    } else {
      color = Colors.green;
    }

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: LinearProgressIndicator(
          value: value,
          minHeight: 2.0,
          backgroundColor: ColorsData.formHintColor,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }

  Widget _buildFundsCell(String funds) {
    double value = funds.toDouble;
    Color color;
    if (value <= 20) {
      color = Colors.red;
    } else if (value <= 40.0) {
      color = Colors.yellow;
    } else if (value <= 60) {
      color = Colors.orange;
    } else if (value <= 80) {
      color = Colors.blue;
    } else {
      color = Colors.green;
    }
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(2.w),
        margin: EdgeInsets.fromLTRB(20.w, 6.w, 20.w, 6.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .2),
          borderRadius: BorderRadius.circular(3.r),
          border: Border.all(color: color.withValues(alpha: .5)),
        ),
        child: Center(
          child: TextWidget(
            text: '$funds%',
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: ColorsData.blackColor,
          ),
        ),
      ),
    );
  }

  TextWidget titleWidget(String title) {
    return TextWidget(
      text: title,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ColorsData.blackColor,
    );
  }
}
