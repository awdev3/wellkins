import 'package:intl/intl.dart';

class Frmtr {
  static String frmtDate({
    String date = '',
    DateTime? dateTime,
    String inForm = 'dd/MM/yyyy',
    String outForm = 'dd-MMM-yyyy',
  }) {
    if (date.isEmpty) {
      //For date and time
      final outformat = DateFormat(outForm);
      final outDate = outformat.format(dateTime!);
      return outDate;
    } else {
      //for string dates
      final informat = DateFormat(inForm);
      final outformat = DateFormat(outForm);
      final infrmtDate = informat.parse(date);
      final outfrmtDate = outformat.format(infrmtDate);
      return outfrmtDate;
    }
  }

  static String frmtCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'en_AU', symbol: '\$');
    return formatter.format(amount);
  }
}
