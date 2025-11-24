import 'package:wellkins/utils/console_util.dart';

import '../utils/extensions.dart';
import '../utils/formatter.dart';

List<ReturnsData> returnsDataFromJson(dynamic data) {
  final rData = data["data"];
  final groupedData = groupJsonData(rData);
  logData(data: groupedData);
  final gData = groupedData["data"];
  return List<ReturnsData>.from(gData.map((x) => ReturnsData.fromJson(x)));
}

class ReturnsData {
  final String orderId;
  final int months;
  final double returns;
  final double returnsPercentage;
  final double investingAmount;
  final String orderCreateDate;
  final String paymentDoneDate;
  final String settlementDate;
  final List<MonthlyData> monthlyDatas;
  // final String bsb;
  // final String paidStatus;
  // final String holderType;
  // String accountName;
  // String accountNumber;
  // String incomeDistributions;
  // String financialInstitution;
  // String isForeignTax;
  // String isForeignTaxN;
  // String isForeignTaxTin;
  // String isForeignTaxCountry;
  ReturnsData({
    required this.orderId,
    required this.months,
    required this.returns,
    required this.returnsPercentage,
    required this.investingAmount,
    required this.orderCreateDate,
    required this.paymentDoneDate,
    required this.settlementDate,
    required this.monthlyDatas,
    // required this.bsb,
    // required this.paidStatus,
    // required this.holderType,
    // required this.accountName,
    // required this.accountNumber,
    // required this.isForeignTax,
    // required this.isForeignTaxN,
    // required this.isForeignTaxTin,
    // required this.isForeignTaxCountry,
  });

  factory ReturnsData.fromJson(Map<String, dynamic> json) => ReturnsData(
        orderId: json["order_id"],
        months: json["months"],
        returns: '${json["returns"]}'.toDouble,
        returnsPercentage: ('${json["returnsPercentage"]}'.toDouble * 100),
        // paidStatus: paymentStatus('${json["paidStatus"]}'),
        investingAmount: '${json["investing_amount"]}'.toDouble,
        // holderType: json["holder_type"],
        orderCreateDate: Frmtr.frmtDate(
          date: json["order_create_date"],
          inForm: 'yyyy-MM-ddTHH:mm:ss.SSSZ',
          outForm: 'dd/MM/yyyy',
        ),
        paymentDoneDate: Frmtr.frmtDate(
          date: json["payment_done_date"],
          inForm: 'yyyy-MM-ddTHH:mm:ss.SSSZ',
          outForm: 'dd/MM/yyyy',
        ),
        settlementDate: Frmtr.frmtDate(
          date: json["settlement_date"],
          inForm: 'yyyy-MM-dd',
          outForm: 'dd/MM/yyyy',
        ),
        // bsb: json["BSB"],
        monthlyDatas: List<MonthlyData>.from(
          json["monthly_payments"].map((x) => MonthlyData.fromJson(x)),
        ),
      );
}

class MonthlyData {
  final String orderId;
  final double amountPaid;
  final double amountUnpaid;
  final String month;
  final String paymentDate;
  final String paymentStatus;
  final double returns;

  MonthlyData({
    required this.orderId,
    required this.amountPaid,
    required this.amountUnpaid,
    required this.month,
    required this.paymentDate,
    required this.paymentStatus,
    required this.returns,
  });

  factory MonthlyData.fromJson(Map<String, dynamic> json) => MonthlyData(
        orderId: json["order_id"],
        amountPaid: '${json["amount_paid"]}'.toDouble,
        amountUnpaid: '${json["amount_unpaid"]}'.toDouble,
        month: json["returns_month"],
        paymentStatus: getPaymentStatus('${json["paidStatus"]}'),
        paymentDate: Frmtr.frmtDate(
          date: json["paymentDate"],
          inForm: 'yyyy-MM-ddTHH:mm:ss.SSSZ',
          outForm: 'dd/MM/yyyy',
        ),
        returns: '${json["returns"]}'.toDouble,
      );

  static String getPaymentStatus(String paidStatus) {
    switch (paidStatus) {
      case '0':
        return 'Under Review';
      case '1':
        return 'Approved';
      case '2':
        return 'First Installment Done';
      case '3':
        return 'Rejected';
      case '4':
        return 'Payment Received';
      case '5':
        return 'Payment Settled';
      default:
        return 'Pending'; //default added by dev
    }
  }
}

Map<String, dynamic> groupJsonData(List<dynamic> originalResult) {
  // Creating a base structure
  Map<String, dynamic> restructuredData = {"data": []};
  // Grouping data by order_id
  Map<String, List<Map<String, dynamic>>> groupedData = {};

  for (final item in originalResult) {
    String orderId = item['investment_data']['order_id'];
    if (!groupedData.containsKey(orderId)) {
      groupedData[orderId] = [];
    }
    groupedData[orderId]?.add(item);
  }

  // Restructuring grouped data
  // Looping thorugh and taking the first with same order id
  groupedData.forEach((orderId, items) {
    final invData = items[0]['investment_data'];
    Map<String, dynamic> orderData = {
      "order_id": orderId,
      "prop_id": items[0]['prop_id'],
      "months": invData['months'],
      "returns": invData['returns'],
      "returnsPercentage": invData['returnsPercentage'],
      "paidStatus": invData['paidStatus'],
      "totalExtraAmt": invData['totalExtraAmt'],
      "investing_amount": invData['investing_amount'],
      "holder_type": invData['holder_type'],
      "settlement_date": invData['settlement_date'],
      "paymentDate": invData['paymentDate'],
      "payment_done_date": invData['payment_done_date'],
      "order_create_date": invData['order_create_date'],
      "monthly_payments": [], // To group and add monthly payments
    };

    // Grouping monthly payments by order_id
    for (final item in items) {
      final invData = item['investment_data'];
      Map<String, dynamic> monthlyPayment = {
        "order_id": invData['order_id'],
        "amount_paid": invData['amount_paid'],
        "amount_unpaid": invData['amount_unpaid'],
        "paymentDate": invData['paymentDate'],
        "returns_month": item['returns_month'],
        "paidStatus": "5",
        "returns": invData['returns'],
      };
      orderData['monthly_payments'].add(monthlyPayment);
    }

    restructuredData['data'].add(orderData);
  });

  return restructuredData;
}

// import '../utils/extensions.dart';
// import '../utils/formatter.dart';

// List<ReturnsData> returnsDataFromJson(dynamic data) {
//   final rData = data["result"];
//   final groupedData = groupJsonData(rData);
//   final gData = groupedData["result"];
//   return List<ReturnsData>.from(gData.map((x) => ReturnsData.fromJson(x)));
// }

// class ReturnsData {
//   final String orderId;
//   final int months;
//   final double returns;
//   final double returnsPercentage;
//   final double investingAmount;
//   final String orderCreateDate;
//   final String paymentDoneDate;
//   final String settlementDate;
//   final String bsb;
//   final List<MonthlyData> monthlyDatas;
//   // final String paidStatus;
//   // final String holderType;
//   // String accountName;
//   // String accountNumber;
//   // String incomeDistributions;
//   // String financialInstitution;
//   // String isForeignTax;
//   // String isForeignTaxN;
//   // String isForeignTaxTin;
//   // String isForeignTaxCountry;
//   ReturnsData({
//     required this.orderId,
//     required this.months,
//     required this.returns,
//     required this.returnsPercentage,
//     required this.investingAmount,
//     required this.orderCreateDate,
//     required this.paymentDoneDate,
//     required this.settlementDate,
//     required this.bsb,
//     required this.monthlyDatas,
//     // required this.paidStatus,
//     // required this.holderType,
//     // required this.accountName,
//     // required this.accountNumber,
//     // required this.isForeignTax,
//     // required this.isForeignTaxN,
//     // required this.isForeignTaxTin,
//     // required this.isForeignTaxCountry,
//   });

//   factory ReturnsData.fromJson(Map<String, dynamic> json) => ReturnsData(
//         orderId: json["order_id"],
//         months: json["months"],
//         returns: '${json["returns"]}'.toDouble,
//         returnsPercentage: ('${json["returnsPercentage"]}'.toDouble * 100),
//         // paidStatus: paymentStatus('${json["paidStatus"]}'),
//         investingAmount: '${json["investing_amount"]}'.toDouble,
//         // holderType: json["holder_type"],
//         orderCreateDate: Frmtr.frmtDate(
//           date: json["order_create_date"],
//           inForm: 'yyyy-MM-ddTHH:mm:ss.SSSZ',
//           outForm: 'dd/MM/yyyy',
//         ),
//         paymentDoneDate: Frmtr.frmtDate(
//           date: json["payment_done_date"],
//           inForm: 'yyyy-MM-ddTHH:mm:ss.SSSZ',
//           outForm: 'dd/MM/yyyy',
//         ),
//         settlementDate: Frmtr.frmtDate(
//           date: json["settlement_date"],
//           inForm: 'yyyy-MM-dd',
//           outForm: 'dd/MM/yyyy',
//         ),

//         bsb: json["BSB"],
//         monthlyDatas: List<MonthlyData>.from(
//           json["monthly_payments"].map((x) => MonthlyData.fromJson(x)),
//         ),
//       );
// }

// class MonthlyData {
//   final String orderId;
//   final double amountPaid;
//   final double amountUnpaid;
//   final String month;
//   final String paymentDate;
//   final String paymentStatus;

//   MonthlyData({
//     required this.orderId,
//     required this.amountPaid,
//     required this.amountUnpaid,
//     required this.month,
//     required this.paymentDate,
//     required this.paymentStatus,
//   });

//   factory MonthlyData.fromJson(Map<String, dynamic> json) => MonthlyData(
//         orderId: json["order_id"],
//         amountPaid: '${json["amount_paid"]}'.toDouble,
//         amountUnpaid: '${json["amount_unpaid"]}'.toDouble,
//         month: json["month"],
//         paymentStatus: getPaymentStatus('${json["paidStatus"]}'),
//         paymentDate: Frmtr.frmtDate(
//           date: json["paymentDate"],
//           inForm: 'yyyy-MM-ddTHH:mm:ss.SSSZ',
//           outForm: 'dd/MM/yyyy',
//         ),
//       );

//   static String getPaymentStatus(String paidStatus) {
//     switch (paidStatus) {
//       case '0':
//         return 'Under Review';
//       case '1':
//         return 'Approved';
//       case '2':
//         return 'First Installment Done';
//       case '3':
//         return 'Rejected';
//       case '4':
//         return 'Payment Received';
//       default:
//         return 'Pending'; //default added by dev
//     }
//   }
// }

// Map<String, dynamic> groupJsonData(List<dynamic> originalResult) {
//   //
//   List<Map<String, dynamic>> restructuredResult = [];
//   Map<String, List<Map<String, dynamic>>> groupedResults = {};

//   for (final item in originalResult) {
//     String orderId = item['order_id'];
//     if (!groupedResults.containsKey(orderId)) {
//       groupedResults[orderId] = [];
//     }
//     groupedResults[orderId]?.add({
//       'order_id': item['order_id'],
//       'amount_paid': item['amount_paid'],
//       'amount_unpaid': item['amount_unpaid'],
//       'paymentDate': item['paymentDate'],
//       'month': item['month'],
//       'paidStatus': item["paidStatus"],
//     });
//   }

//   groupedResults.forEach((orderId, monthlyPayments) {
//     Map<String, dynamic> mainResultItem = originalResult
//         .firstWhere((item) => item['order_id'] == orderId, orElse: () => null);
//     mainResultItem.remove('paymentDate');
//     mainResultItem.remove('month');
//     mainResultItem['monthly_payments'] = monthlyPayments;
//     restructuredResult.add(mainResultItem);
//   });

//   // Creates JSON data with the restructured result
//   Map<String, dynamic> finalJsonData = {'result': restructuredResult};

//   // Print the final JSON data
//   // logData(data: jsonEncode(finalJsonData));
//   return finalJsonData;
// }

// import 'package:wellkins/utils/extensions.dart';
// import 'package:wellkins/utils/formatter.dart';

// List<ReturnsData> returnsDataFromJson(dynamic data) {
//   final rData = data["result"];
//   return List<ReturnsData>.from(rData.map((x) => ReturnsData.fromJson(x)));
// }

// class ReturnsData {
//   int clientId;
//   int resultClientId;
//   int months;
//   double returns;
//   double returnsPercentage;
//   String paidStatus;
//   double investingAmount;
//   String holderType;
//   double amountPaid;
//   double amountUnpaid;
//   String orderId;
//   String orderCreateDate;
//   String paymentDoneDate;
//   String settlementDate;
//   String propertyName;
//   String fullName;
//   String clientEmail;
//   String bsb;
//   String accountName;
//   // String isForeignTax;
//   // String isForeignTaxN;
//   String accountNumber;
//   // String isForeignTaxTin;
//   // String isForeignTaxCountry;
//   String incomeDistributions;
//   String financialInstitution;
//   String paymentDate;
//   String month;

//   ReturnsData({
//     required this.clientId,
//     required this.resultClientId,
//     required this.months,
//     required this.returns,
//     required this.returnsPercentage,
//     required this.paidStatus,
//     required this.investingAmount,
//     required this.holderType,
//     required this.amountPaid,
//     required this.amountUnpaid,
//     required this.orderId,
//     required this.orderCreateDate,
//     required this.paymentDoneDate,
//     required this.settlementDate,
//     required this.propertyName,
//     required this.fullName,
//     required this.clientEmail,
//     required this.bsb,
//     required this.accountName,
//     // required this.isForeignTax,
//     // required this.isForeignTaxN,
//     required this.accountNumber,
//     // required this.isForeignTaxTin,
//     // required this.isForeignTaxCountry,
//     required this.incomeDistributions,
//     required this.financialInstitution,
//     required this.paymentDate,
//     required this.month,
//   });

//   factory ReturnsData.fromJson(Map<String, dynamic> json) => ReturnsData(
//         clientId: json["clientId"],
//         resultClientId: json["client_id"],
//         months: json["months"],
//         returns: '${json["returns"]}'.toDouble,
//         returnsPercentage: '${json["returnsPercentage"]}'.toDouble,
//         paidStatus: paymentStatus('${json["paidStatus"]}'),
//         investingAmount: '${json["investing_amount"]}'.toDouble,
//         holderType: json["holder_type"],
//         amountPaid: '${json["amount_paid"]}'.toDouble,
//         amountUnpaid: '${json["amount_unpaid"]}'.toDouble,
//         orderId: json["order_id"],
//         orderCreateDate: Frmtr.frmtDate(
//           date: json["order_create_date"],
//           inForm: 'yyyy-MM-ddTHH:mm:ss.SSSZ',
//           outForm: 'yyyy-MMM-dd',
//         ),
//         paymentDoneDate: Frmtr.frmtDate(
//           date: json["payment_done_date"],
//           inForm: 'yyyy-MM-ddTHH:mm:ss.SSSZ',
//           outForm: 'yyyy-MMM-dd',
//         ),
//         settlementDate: json["settlement_date"],
//         propertyName: json["property_name"],
//         fullName: json["full_name"],
//         clientEmail: json["client_email"],
//         bsb: json["BSB"],
//         accountName: json["Account_name"],
//         // isForeignTax: json["isForeignTax"],
//         // isForeignTaxN: json["isForeignTaxN"],
//         accountNumber: json["Account_number"],
//         // isForeignTaxTin: json["isForeignTaxTin"],
//         // isForeignTaxCountry: json["isForeignTaxCountry"],
//         incomeDistributions: json["income_distributions"],
//         financialInstitution: json["financial_institution"],
//         paymentDate: Frmtr.frmtDate(
//           date: json["paymentDate"],
//           inForm: 'yyyy-MM-ddTHH:mm:ss.SSSZ',
//           outForm: 'yyyy-MMM-dd',
//         ),
//         month: json["month"],
//       );

//   static String paymentStatus(String paidStatus) {
//     switch (paidStatus) {
//       case '0':
//         return 'Under Review';
//       case '1':
//         return 'Approved';
//       case '2':
//         return 'First Installment Done';
//       case '3':
//         return 'Rejected';
//       case '4':
//         return 'Payment Received';
//       default:
//         return 'Pending'; //default added by dev
//     }
//   }
// }
