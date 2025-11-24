import 'package:flutter/material.dart';

import '../constants/colors.dart';
import 'history_model.dart';
import 'returns_model.dart';

class FundType {
  final String image;
  final String title;
  final String description;
  final Color color;
  final int type;
  final int subType;

  FundType({
    required this.image,
    required this.title,
    required this.type,
    required this.subType,
    this.description = '',
    this.color = ColorsData.blackColor,
  });
}

class FundDetails {
  History history;
  ReturnsData? returnsData;
  FundDetails({
    required this.history,
    this.returnsData,
  });
}
