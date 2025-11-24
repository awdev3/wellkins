import 'package:wellkins/utils/extensions.dart';
import 'package:wellkins/utils/formatter.dart';

import 'dart:convert';

String getTaxReportToJson(GetTaxReport data) => json.encode(data.toJson());

class GetTaxReport {
  final int clientId;
  final String propertyName;
  final String? year;
  final String? fromDate;
  final String? endDate;

  GetTaxReport({
    required this.clientId,
    required this.propertyName,
    this.year,
    this.fromDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() => {
        "clientId": clientId,
        "propertyName": propertyName,
        if (year != null) "year": year,
        if (fromDate != null) "fromDate": fromDate,
        if (endDate != null) "endDate": endDate,
      };
}

List<TaxReport> taxReportFromJson(dynamic str) {
  final data = str["individualOrders"];
  return List<TaxReport>.from(data.map((x) => TaxReport.fromJson(x)));
}

class TaxReport {
  final String orderPk;
  final String orderId;
  final String investingAmount;
  final String orderDate;
  final String propertyName;
  final String fullName;
  final String address;
  final String investorNumber;
  final String taxNumber;
  final String held;
  final String withHeld;
  final String totalReturns;
  // final String jointInvestorName;

  TaxReport({
    required this.orderPk,
    required this.orderId,
    required this.investingAmount,
    required this.orderDate,
    required this.propertyName,
    required this.fullName,
    required this.investorNumber,
    required this.taxNumber,
    required this.held,
    required this.withHeld,
    required this.totalReturns,
    this.address = '',
    // required this.jointInvestorName,
  });

  factory TaxReport.fromJson(Map<String, dynamic> json) => TaxReport(
        orderPk: '${json["OrderPk"]}',
        orderId: '${json["orderId"]}',
        investingAmount: Frmtr.frmtCurrency(
          '${json["investing_amount"]}'.toDouble,
        ),
        orderDate: Frmtr.frmtDate(
          date: '${json["orderDate"]}',
          inForm: 'yyyy-MM-ddTHH:mm:ss.SSSZ',
          outForm: 'dd/MM/yyyy',
        ),
        propertyName: json["propertyName"],
        fullName: json["jointInvestorName"] ?? json["full_name"],
        address: json["investorAddress"] ?? '',
        investorNumber: '${json["investorNumber"]}',
        taxNumber: '${json["taxNumber"]}',
        held: json["taxNumber"] != null ? 'Yes' : 'No',
        withHeld: json["taxNumber"] == null ? 'Withheld' : 'No',
        totalReturns: Frmtr.frmtCurrency(
          '${json["total_returns"]}'.toDouble,
        ),
        // jointInvestorName: json["jointInvestorName"],
      );
}
