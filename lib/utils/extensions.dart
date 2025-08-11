// extension NumberParsing on String {
//   int get toInt => (int.tryParse(this) ?? 0);
//   double get toDouble => (double.tryParse(this) ?? 0);
//   bool get isString => (int.tryParse(this) ?? 0) == 0;
// }

import 'package:flutter/services.dart';

extension NumberParsing on dynamic {
  int get toInt => (int.tryParse(this) ?? 0);
  // double get toDouble => (double.tryParse('$this') ?? 0);
  double get toDouble {
    String str = toString().replaceAll(',', '');
    return double.tryParse(str) ?? 0.0;
  }

  bool get isString => (int.tryParse('$this') ?? 0) == 0;
  String get toNrString {
    String str = toString();
    String input = '${(double.tryParse(str) ?? 0.00)}';
    List<String> numParts = input.split('.');
    bool hasDcml = numParts.length > 1;
    String intgr = numParts[0];
    String dcml = hasDcml ? numParts[1].padRight(2, '0').substring(0, 2) : '00';
    String nrNum = '$intgr.$dcml';

    return nrNum;
  }

  // String toNrString([int precision = 2]) {
  //   String input = '$this';
  //   int decimalIndex = input.indexOf('.');
  //   if (decimalIndex == -1) {
  //     return input;
  //   }
  //   precision = precision.clamp(0, (input.length) - (decimalIndex - 1));
  //   int endIndex = (decimalIndex + 1) + precision;
  //   if (endIndex > input.length) {
  //     endIndex = input.length;
  //   }
  //   return double.parse(input.substring(0, endIndex)).toString();
  // }
}

extension StringExtension on String {
  String get capitalize {
    if (isEmpty) {
      return this;
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String get toTitleCase {
    if (isEmpty) {
      return this;
    }
    return replaceAll(
      RegExp(' +'),
      ' ',
    ).split(' ').map((str) => str.capitalize).join(' ');
  }

  String get removeSpaces {
    if (isEmpty) {
      return this;
    }
    return replaceAll(RegExp(r'\s+'), '');
  }
}

//# with decimal points
class CommaSeparatedFormatter extends TextInputFormatter {
  static final RegExp _regexLeadingZero = RegExp(r'^0+(?=\d)');
  static final RegExp _regexDecimal = RegExp(r'^\d*\.?\d{0,2}');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final String newText = newValue.text
        .replaceAll(_regexLeadingZero, '')
        .replaceAll(RegExp(r'[^0-9\.]'), '');

    if (_regexDecimal.hasMatch(newText)) {
      final String formattedText = _formatNumber(newText);

      return newValue.copyWith(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

    return oldValue;
  }

  String _formatNumber(String number) {
    final List<String> parts = [];
    final int decimalIndex = number.indexOf('.');

    if (decimalIndex != -1) {
      final String integerPart = number.substring(0, decimalIndex);
      final String decimalPart = number.substring(decimalIndex);

      _formatIntegerPart(integerPart, parts);
      parts.add(
        decimalPart.length > 2 ? decimalPart.substring(0, 3) : decimalPart,
      );

      return parts.join('');
    } else {
      _formatIntegerPart(number, parts);
      return parts.join('');
    }
  }

  void _formatIntegerPart(String integerPart, List<String> parts) {
    for (int i = integerPart.length; i > 0; i -= 3) {
      parts.insert(
        0,
        i < 3 ? integerPart.substring(0, i) : integerPart.substring(i - 3, i),
      );
      if (i > 3) parts.insert(0, ',');
    }
  }
}

extension UriExtensions on Uri {
  String get fileName {
    return pathSegments.isNotEmpty ? pathSegments.last : '';
  }

  String get fileType {
    final url = toString();
    return url.split('.').last;
  }
}

//# without decimal points

// class CommaSeparatedFormatter extends TextInputFormatter {
//   static final RegExp _regexLeadingZero = RegExp(r'^0+(?=\d)');

//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     if (newValue.text.isEmpty) {
//       return newValue.copyWith(text: '');
//     }

//     final String newText = newValue.text
//         .replaceAll(_regexLeadingZero, '')
//         .replaceAll(RegExp(r'[^0-9\.]'), '');

//     if (newText.isEmpty) {
//       return newValue.copyWith(text: '');
//     }

//     final String formattedText = _formatNumber(newText);

//     return newValue.copyWith(
//       text: formattedText,
//       selection: TextSelection.collapsed(offset: formattedText.length),
//     );
//   }

//   String _formatNumber(String number) {
//     final List<String> parts = [];
//     final int decimalIndex = number.indexOf('.');

//     if (decimalIndex != -1) {
//       final String integerPart = number.substring(0, decimalIndex);
//       final String decimalPart = number.substring(decimalIndex);

//       _formatIntegerPart(integerPart, parts);
//       parts.add(decimalPart);

//       return parts.join('');
//     } else {
//       _formatIntegerPart(number, parts);
//       return parts.join('');
//     }
//   }

//   void _formatIntegerPart(String integerPart, List<String> parts) {
//     for (int i = integerPart.length; i > 0; i -= 3) {
//       parts.insert(
//         0,
//         i < 3 ? integerPart.substring(0, i) : integerPart.substring(i - 3, i),
//       );
//       if (i > 3) parts.insert(0, ',');
//     }
//   }
// }
