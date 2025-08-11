import 'package:flutter/material.dart';

import '../widgets/text_widget.dart';
import '/constants/colors.dart';

class TextStyleData {
  ///
  static TextStyle selectedNavLbl = MyFont.poppins(
    color: ColorsData.whiteColor,
    fontSize: 10.5,
    fontWeight: FontWeight.bold,
  );

  ///
  static TextStyle unSelectedNavLbl = MyFont.poppins(
    color: ColorsData.greyColor,
    fontSize: 10.5,
    fontWeight: FontWeight.w500,
  );

  ///
  static TextStyle formHintStyle = MyFont.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: ColorsData.formHintColor,
  );

  ///
  static TextStyle formErrorStyle = MyFont.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.red,
  );
}
