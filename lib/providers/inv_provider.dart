import 'package:flutter/material.dart';

import '../models/history_model.dart';
import '../models/home_models.dart';
import '../services/api_service.dart';
import '../services/helpers.dart';
import '../utils/console_util.dart';
import '../utils/extensions.dart';
import '../utils/formatter.dart';

class InvProvider extends ChangeNotifier {
  bool homeLoad = false;
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

  TotalFunding totalFunding = TotalFunding();

  List<FundTypeTotal> fundTypeTotalList = [];
  List<RentalYeild> rentalYeliedList = [];
  List<InvestedLocation> invLocationList = [];
  PopularityFund? popularityFund;

  Future<void> getDashInvData(BuildContext ctx) async {
    homeLoad = true;
    try {
      clearHome();
      final userProvider = getUserProvider(ctx);

      final data = await ApiService().postDataToApi(
        api: 'dashboard/getClientDashboard?',
        headers: userProvider.headers,
        payload: historyToJson(
          ClientDetail(clientId: userProvider.user!.id),
        ),
      );

      List invLocns = data["stateDAta"] ?? [];
      List fndTypeTtl = data["projectTypeData"] ?? [];
      List rentalYld = data["rentalYieldData"] ?? [];
      List popFunds = data["popularitychartData"] ?? [];

      getFndTypeTotal(fndTypeTtl);
      getTotalFunding(data);
      getRentalYeilds(rentalYld);
      getInvLocations(invLocns);
      getPopdata(popFunds);
    } catch (e, st) {
      // showToast(message: AppConstants.error);
      printData(title: 'from getDashInvData', data: '$e,$st', e: true);
    } finally {
      homeLoad = false;
    }
    notifyListeners();
  }

  void clearHome() {
    totalFunding = TotalFunding();
    invLocationList.clear();
    fundTypeTotalList.clear();
    rentalYeliedList.clear();
    popularityFund = null;
  }

  List<double> getFundsTotal() {
    double propertyTotal = 0.0;
    double mortgageTotal = 0.0;
    if (fundTypeTotalList.isNotEmpty) {
      final mTypes = [3, 4];
      for (final item in fundTypeTotalList) {
        if (mTypes.contains(item.type)) {
          mortgageTotal += item.amount;
        } else {
          propertyTotal += item.amount;
        }
      }
    }
    return [propertyTotal, mortgageTotal];
  }

  void getFndTypeTotal(List<dynamic> fndTypeTtl) {
    if (fndTypeTtl.isNotEmpty) {
      fundTypeTotalList = fundTypeTotalFromJson(fndTypeTtl);
    }
  }

  void getTotalFunding(dynamic data) {
    totalFunding = TotalFunding(
      total: '${data["totalInvestment"]}'.toDouble,
      percentage: '${data["fundingpercentageDifference"]}'.toDouble,
    );
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
      currentYear:
          List.generate(pFund.length, (index) => '${pFund[index]}'.toDouble),
      previousYear:
          List.generate(cFund.length, (index) => '${cFund[index]}'.toDouble),
    );
  }

  String getFundTypeTotal(int fundType) {
    final [propertyTotal, mortgageTotal] = getFundsTotal();
    if (fundType == 1) {
      return Frmtr.frmtCurrency(mortgageTotal);
    } else if (fundType == 2) {
      return Frmtr.frmtCurrency(propertyTotal);
    } else {
      final totalAmount = mortgageTotal + propertyTotal;
      return Frmtr.frmtCurrency(totalAmount);
    }
  }

  String getSubTypeTotal(int fundSubType) {
    final [propertyTotal, mortgageTotal] = getFundsTotal();
    if (fundSubType == -1) {
      return Frmtr.frmtCurrency(propertyTotal);
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
