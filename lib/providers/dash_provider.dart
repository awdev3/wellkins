import 'package:flutter/material.dart';
import 'package:wellkins/utils/extensions.dart';

import '../models/home_models.dart';
import '../services/api_service.dart';
import '../services/helpers.dart';
import '../utils/console_util.dart';
import '../utils/formatter.dart';

class DashProvider extends ChangeNotifier {
  bool homeLoad = false;
  // final qauarterMonth = ['Jan', 'Apr', 'Jul', 'Oct'];
  final qauarterMonth = ['Mar', 'Jun', 'Sep', 'Dec'];
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  FundsTotals properyTotal = FundsTotals();
  FundsTotals mortageTotal = FundsTotals();
  TotalFunding totalFunding = TotalFunding();

  List<FundTypeTotal> fundTypeTotalList = [];
  List<RentalYeild> rentalYeliedList = [];
  List<InvestedLocation> invLocationList = [];
  PopularityFund? popularityFund;

  Future<void> getDashBoardData(BuildContext ctx) async {
    homeLoad = true;
    clearHome();
    try {
      final userProvider = getUserProvider(ctx);

      final data = await ApiService().postDataToApi(
        api: 'dashboard/getCompanyData?',
        headers: userProvider.headers,
      );

      List invLocns = data["stateDAta"] ?? [];
      List propTotals = data["propertyInfo"] ?? [];
      List funding = data["funding"] ?? [];
      List fndTypeTtl = data["propertyTypeInfo"] ?? [];
      List rentalYld = data["rentalYieldData"] ?? [];
      List popFunds = data["popularitychartData"] ?? [];

      getFundsTotal(propTotals);
      getFndTypeTotal(fndTypeTtl);
      getTotalFunding(funding);
      getRentalYeilds(rentalYld);
      getInvLocations(invLocns);
      getPopdata(popFunds);
    } catch (e, st) {
      // showToast(message: AppConstants.error);
      printData(title: 'from getHomeData', data: '$e,$st', e: true);
    } finally {
      homeLoad = false;
    }
    notifyListeners();
  }

  void clearHome() {
    properyTotal = FundsTotals();
    mortageTotal = FundsTotals();
    totalFunding = TotalFunding();
    invLocationList.clear();
    fundTypeTotalList.clear();
    rentalYeliedList.clear();
    popularityFund = null;
  }

  void getFundsTotal(List<dynamic> propTotals) {
    if (propTotals.isNotEmpty) {
      for (final item in propTotals) {
        if (item["type"] == 'property_funds') {
          properyTotal = FundsTotals(
            type: item["type"],
            amount: '${item["amount"]}'.toDouble,
            basePrice: '${item["base_price"]}'.toDouble,
            percentageDifference: '${item["percentageDifference"]}'.toDouble,
          );
        }
        if (item["type"] == 'Mortgage_fund') {
          mortageTotal = FundsTotals(
            type: item["type"],
            amount: '${item["amount"]}'.toDouble,
            basePrice: '${item["base_price"]}'.toDouble,
            percentageDifference: '${item["percentageDifference"]}'.toDouble,
          );
        }
      }
    }
  }

  void getFndTypeTotal(List<dynamic> fndTypeTtl) {
    if (fndTypeTtl.isNotEmpty) {
      fundTypeTotalList = fundTypeTotalFromJson(fndTypeTtl);
    }
  }

  void getTotalFunding(List<dynamic> funding) {
    if (funding.isNotEmpty) {
      totalFunding = TotalFunding(
        total: '${funding[0]["totalfunding"]}'.toDouble,
        percentage: '${funding[1]["funding_percentage"]}'.toDouble,
      );
    }
  }

  void getRentalYeilds(List<dynamic> rentalYlds) {
    if (rentalYlds.isNotEmpty) {
      rentalYeliedList = List.generate(rentalYlds.length, (index) {
        final value = '${rentalYlds[index]}'.toDouble;
        final month = months[index];
        return RentalYeild(value: value, month: month);
      });
    }
  }

  void getInvLocations(List<dynamic> invLocns) {
    invLocationList = [];
    if (invLocns.isNotEmpty) {
      for (int i = 0; i < invLocns.length; i++) {
        final locn = invLocns[i];
        invLocationList.add(
          InvestedLocation(
            no: '${i + 1}',
            projectCount: '${locn["occurrence"]}',
            name: locn["state"],
            populairy: '${locn["popularity"]}',
            funds: '${locn["popularity"]}',
          ),
        );
      }
    }
  }

  void getPopdata(List<dynamic> popFunds) {
    if (popFunds.isEmpty) return;
    final pFund = popFunds[0]["data"];
    final cFund = popFunds[1]["data"];
    popularityFund = PopularityFund(
      months: qauarterMonth,
      currentYear: pFund.isEmpty
          ? []
          : List.generate(pFund.length, (index) => '${pFund[index]}'.toDouble),
      previousYear: cFund.isEmpty
          ? []
          : List.generate(cFund.length, (index) => '${cFund[index]}'.toDouble),
    );
  }

  String getFundTypeTotal(int fundType) {
    if (fundType == 1) {
      return Frmtr.frmtCurrency(mortageTotal.amount);
    } else if (fundType == 2) {
      return Frmtr.frmtCurrency(properyTotal.amount);
    } else {
      final totalAmount = mortageTotal.amount + properyTotal.amount;
      return Frmtr.frmtCurrency(totalAmount);
    }
  }

  String getSubTypeTotal(int fundSubType) {
    if (fundSubType == -1) {
      return Frmtr.frmtCurrency(properyTotal.amount);
    }

    final item = fundTypeTotalList.firstWhere(
      (item) => item.type == fundSubType,
      orElse: () => FundTypeTotal(
        type: 0,
        amount: 0.0,
        basePrice: 0, // for error condition
      ),
    );
    return Frmtr.frmtCurrency(item.amount);
  }
}
