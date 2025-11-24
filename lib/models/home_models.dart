import 'package:wellkins/utils/extensions.dart';

List<FundTypeTotal> fundTypeTotalFromJson(dynamic data) =>
    List<FundTypeTotal>.from(data.map((x) => FundTypeTotal.fromJson(x)));

class FundsTotals {
  final String type;
  final double amount;
  final double basePrice;
  final double percentageDifference;

  FundsTotals({
    this.type = '',
    this.amount = 0.0,
    this.basePrice = 0.0,
    this.percentageDifference = 0.0,
  });
}

class FundTypeTotal {
  int type;
  double amount;
  double basePrice;

  FundTypeTotal({
    required this.type,
    required this.amount,
    required this.basePrice,
  });

  factory FundTypeTotal.fromJson(Map<String, dynamic> json) => FundTypeTotal(
        type: '${json["type"]}'.toInt,
        amount: '${json["amount"]}'.toDouble,
        basePrice: '${json["base_price"]}'.toDouble,
      );
}

class TotalFunding {
  final double total;
  final double percentage;

  TotalFunding({
    this.total = 0,
    this.percentage = 0,
  });
}

class RentalYeild {
  final double value;
  final String month;

  const RentalYeild({
    required this.value,
    required this.month,
  });
}

class InvestedLocation {
  final String no;
  final String projectCount;
  final String name;
  final String populairy;
  final String funds;

  InvestedLocation({
    required this.no,
    this.projectCount = '',
    required this.name,
    this.populairy = '',
    required this.funds,
  });
}

class PopularityFund {
  final List<String> months;
  final List<double> currentYear;
  final List<double> previousYear;
  PopularityFund({
    required this.months,
    required this.currentYear,
    required this.previousYear,
  });
}
