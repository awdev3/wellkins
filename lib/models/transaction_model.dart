import 'dart:convert';

import '../utils/extensions.dart';
import '../utils/formatter.dart';

List<Transaction> transactionsFromJson(dynamic data) {
  final trans = data["get_transaction"][0];
  final groupedData = organiseTrans(trans);
  final gData = groupedData["get_transaction"];
  return List<Transaction>.from(gData.map((x) => Transaction.fromJson(x)));
}

class Transaction {
  String orderId;
  int propId;
  List<Operation> operations;

  Transaction({
    required this.orderId,
    required this.propId,
    required this.operations,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        orderId: '${json["order_id"]}',
        propId: json["prop_id"],
        operations: List<Operation>.from(
          json["transactions"].map((x) => Operation.fromJson(x)),
        ),
      );
}

class Operation {
  final String id;
  final String transactionDate;
  final String createdAt;
  final String updatedAt;
  final String transactionType;
  final double unitsAcquired;
  final double unitsTransferred;
  final double unitsBalance;
  final double investAmount;
  final double amountPaid;
  final double amountUnpaid;

  Operation({
    required this.id,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    required this.transactionType,
    required this.unitsAcquired,
    required this.unitsTransferred,
    required this.unitsBalance,
    required this.investAmount,
    required this.amountPaid,
    required this.amountUnpaid,
  });

  factory Operation.fromJson(Map<String, dynamic> json) => Operation(
        id: '${json["id"]}',
        transactionDate: json["transaction_date"] != null
            ? Frmtr.frmtDate(
                date: json["transaction_date"] ?? '',
                inForm: 'yyyy-MM-ddTHH:mm:ss.SSSZ',
                outForm: 'dd/MM/yyyy',
              )
            : '',
        createdAt: json["createdAt"] != null
            ? Frmtr.frmtDate(
                date: json["createdAt"] ?? '',
                inForm: 'yyyy-MM-ddTHH:mm:ss.SSSZ',
                outForm: 'dd/MM/yyyy',
              )
            : '',
        updatedAt: json["updatedAt"] != null
            ? Frmtr.frmtDate(
                date: json["updatedAt"] ?? '',
                inForm: 'yyyy-MM-ddTHH:mm:ss.SSSZ',
                outForm: 'dd/MM/yyyy',
              )
            : '',
        transactionType: json["transaction_type"],
        unitsAcquired: '${json["units_acquired"]}'.toDouble,
        unitsTransferred: '${json["units_transferred"]}'.toDouble,
        unitsBalance: '${json["units_balance"]}'.toDouble,
        investAmount: '${json["investing_amount"]}'.toDouble,
        amountPaid: '${json["amount_paid"]}'.toDouble,
        amountUnpaid: '${json["amount_unpaid"]}'.toDouble,
      );
}

Map<String, dynamic> organiseTrans(List<dynamic> transactions) {
  Map<String, dynamic> organizedData = {};

  for (final transaction in transactions) {
    final orderId = transaction['order_id'];
    final propId = transaction['prop_id'];
    final transactionData = {
      'id': transaction['id'],
      'transaction_date': transaction["transaction_date"],
      'createdAt': transaction["createdAt"],
      'updatedAt': transaction["updatedAt"],
      'transaction_type': transaction["transaction_type"],
      'units_acquired': transaction["units_acquired"],
      'units_transferred': transaction["units_transferred"],
      'units_balance': transaction["units_balance"],
      'investing_amount': transaction["investing_amount"],
      'amount_paid': transaction["amount_paid"],
      'amount_unpaid': transaction["amount_unpaid"],
    };

    if (organizedData.containsKey(orderId)) {
      organizedData[orderId]['transactions'].add(transactionData);
    } else {
      organizedData[orderId] = {
        'order_id': orderId,
        'prop_id': propId,
        'transactions': [transactionData],
      };
    }
  }

  final transactionList = organizedData.values.toList();
  final finalData = {'get_transaction': transactionList};
  // String finalJsonData = json.encode(finalData);
  // logData(data: finalJsonData);
  return finalData;
}

String getTrnsToJson(GetTransaction data) => json.encode(data.toJson());

class GetTransaction {
  String clientId;
  String orderId;
  String holderType;
  String formType;

  GetTransaction({
    required this.clientId,
    required this.orderId,
    required this.holderType,
    required this.formType,
  });

  Map<String, dynamic> toJson() => {
        "client_id": clientId,
        "order_id": orderId,
        "holder_type": holderType,
        "form_type": formType,
      };
}
