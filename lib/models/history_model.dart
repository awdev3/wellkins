import 'dart:convert';

import '../utils/extensions.dart';
import 'project_model.dart';

List<HistoryItem> historyItemFromJson(dynamic data) {
  final favorites = data["getOrder"];
  return List<HistoryItem>.from(favorites.map((x) => HistoryItem.fromJson(x)));
}

class History {
  HistoryItem historyItem;
  Project project;
  History({
    required this.historyItem,
    required this.project,
  });
}

class HistoryItem {
  final int id;
  final String orderId;
  final int propId;
  final String paidStatus;
  final double investingAmount;
  final String holderType;
  final String formType;
  final int investmentUnit;
  final bool isUserVoted;
  final bool isApproved;

  HistoryItem({
    required this.id,
    required this.orderId,
    required this.propId,
    required this.paidStatus,
    required this.investingAmount,
    required this.holderType,
    required this.formType,
    required this.investmentUnit,
    required this.isUserVoted,
    required this.isApproved,
  });

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json["id"],
        orderId: json["order_id"],
        propId: json["prop_id"],
        paidStatus: paymentStatus('${json["paidStatus"]}'),
        investingAmount: '${json["investing_amount"]}'.toDouble,
        holderType: json["holder_type"],
        formType: json["enq_form_data"]["investor_form_type"],
        investmentUnit: json["investment_unit"],
        isUserVoted: json["isUserVoted"] ?? false,
        isApproved: '${json["is_approved"]}'.toInt == 0 ? false : true,
      );

  static String paymentStatus(String paidStatus) {
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
      default:
        return 'Pending'; //default added by dev
    }
  }
}

String historyToJson(ClientDetail data) => json.encode(data.toJson());

class ClientDetail {
  String clientId;
  ClientDetail({required this.clientId});
  Map<String, dynamic> toJson() => {"client_id": clientId};
}
