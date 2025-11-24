import 'package:flutter/material.dart';

import '../../../../constants/paths.dart';
import '../../../../constants/strings.dart';
import '../../../../models/fund_type.dart';

class FundTypes {
  static List<FundType> propertFundList = [
    FundType(
      image: Paths.dev,
      title: AppConstants.landDevelopment,
      // description: '+10.00% from previous year',
      color: Colors.amber,
      type: 2,
      subType: 1,
    ),
    FundType(
      image: Paths.bank,
      title: AppConstants.landBanking,
      // description: '+12.00% from previous year',
      color: Colors.blue,
      type: 2,
      subType: 0,
    ),
    FundType(
      image: Paths.rent,
      title: AppConstants.rental,
      // description: '+10.00% from previous year',
      color: Colors.green,
      type: 2,
      subType: 2,
    ),
    FundType(
      image: Paths.inv,
      title: AppConstants.totalInvestment,
      // description: '+12.00% from previous year',
      color: Colors.red,
      type: -1,
      subType: -1,
    ),
  ];

  static List<FundType> mortageFundList = [
    FundType(
      image: Paths.dev,
      title: AppConstants.poolFund,
      color: Colors.blue,
      type: 1,
      subType: 4,
    ),
    FundType(
      image: Paths.bank,
      title: AppConstants.mortgageFund,
      color: const Color(0xff039E8E),
      type: 1,
      subType: 3,
    ),
  ];
}
