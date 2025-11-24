import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../constants/colors.dart';
import '../../../../../../constants/strings.dart';
import '../../../../../../models/returns_model.dart';
import '../../../../../../models/transaction_model.dart';
import '../../../../../../utils/formatter.dart';
import '../../../../../../widgets/text_widget.dart';

class TransReturn {
  static Widget buildOperations(List<Transaction> trnsList) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: {
          0: FixedColumnWidth(80.w),
          1: FixedColumnWidth(120.w),
          2: FixedColumnWidth(110.w),
          3: FixedColumnWidth(110.w),
          4: FixedColumnWidth(110.w),
        },
        border: TableBorder.all(color: Colors.black),
        children: [
          buildHeaderRowTrns(),
          ...trnsList.first.operations
              .map((operation) => buildDataRowTrns(operation))
        ],
      ),
    );
  }

  static Widget tableMainHeader(String text) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: const BoxDecoration(
        color: Color.fromARGB(180, 193, 227, 255),
        border: Border(
          left: BorderSide(color: Colors.black),
          right: BorderSide(color: Colors.black),
          top: BorderSide(color: Colors.black),
        ),
      ),
      child: Center(
        child: TextWidget(
          text: text,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  static TableRow buildHeaderRow() {
    return TableRow(
      decoration:
          const BoxDecoration(color: Color.fromARGB(218, 200, 230, 201)),
      children: [
        buildCell(AppConstants.date, 0, true),
        buildCell(AppConstants.descp, 1, true),
        buildCell(AppConstants.amount, 2, true),
      ],
    );
  }

  static TableRow buildHeaderRowTrns() {
    return TableRow(
      decoration:
          const BoxDecoration(color: Color.fromARGB(218, 200, 230, 201)),
      children: [
        buildCell(AppConstants.date, 0, true),
        buildCell(AppConstants.descp, 1, true),
        buildCell(AppConstants.dbt, 1, true),
        buildCell(AppConstants.crdt, 1, true),
        buildCell(AppConstants.blnc, 2, true),
      ],
    );
  }

  static TableRow buildDataRowReturn(MonthlyData monthlyData) {
    return TableRow(
      children: [
        buildCell(monthlyData.paymentDate, 0),
        buildCell(monthlyData.paymentStatus, 1),
        buildCell(Frmtr.frmtCurrency(monthlyData.returns), 2),
      ],
    );
  }

  static TableRow buildDataRowTrns(Operation operation) {
    bool isDeposit = operation.transactionType.toLowerCase() == 'allotment';
    final sucrTyp = operation.amountUnpaid.isNegative ? 'Cr' : 'Dr';
    final sucr = operation.amountUnpaid > 0 ? sucrTyp : '';
    return TableRow(
      children: [
        isDeposit
            ? buildCell(operation.createdAt, 0)
            : buildCell(operation.transactionDate, 0),
        buildCell(operation.transactionType, 1),
        isDeposit
            ? buildCell(Frmtr.frmtCurrency(operation.investAmount), 1)
            : buildCell('', 1),
        isDeposit
            ? buildCell('', 1)
            : buildCell(Frmtr.frmtCurrency(operation.amountPaid), 1),
        isDeposit
            ? buildCell('', 1)
            : buildCell(
                '${Frmtr.frmtCurrency(operation.amountUnpaid)} $sucr', 2),
      ],
    );
  }

  static Widget buildCell(String text, int index, [bool header = false]) {
    return TableCell(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: TextWidget(
          text: text,
          fontSize: 11,
          fontWeight: header ? FontWeight.bold : FontWeight.w500,
          color: ColorsData.blackColor,
          textAlign: index == 0
              ? TextAlign.start
              : index == 1
                  ? TextAlign.center
                  : TextAlign.end,
        ),
      ),
    );
  }
}
