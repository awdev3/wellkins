import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/extensions.dart';

enum MyFontFam { poppins, roboto }

enum ViewCase { lower, upper, title, caps }

class MyFont {
  static TextStyle poppins({
    required double fontSize,
    Color color = Colors.black,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return GoogleFonts.nunitoSans(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing?.w,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }

  static TextStyle robotoTextStyle({
    required double fontSize,
    Color color = Colors.black,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return GoogleFonts.roboto(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }
}

class TextWidget extends StatelessWidget {
  final String text;
  final String t2;
  final String t3;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final MyFontFam fontFam;
  final bool trOn;
  final bool t2TrOn;
  final bool t3TrOn;
  final double? height;
  final int? maxLines;
  final TextAlign? textAlign;
  final double? letterSpacing;
  final TextOverflow? overflow;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final ViewCase? viewCase;

  const TextWidget({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    this.color = Colors.black,
    this.fontFam = MyFontFam.poppins,
    this.t2 = '',
    this.t3 = '',
    this.trOn = true,
    this.t2TrOn = true,
    this.t3TrOn = true,
    this.height,
    this.letterSpacing,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.decoration,
    this.decorationColor,
    this.viewCase,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = _getTextStyle();

    final vct = _getViewCased(text);
    final vct2 = t2.isNotEmpty ? _getViewCased(t2) : t2;
    final vct3 = t3.isNotEmpty ? _getViewCased(t3) : t3;

    return Text(
      t2.isEmpty && t3.isEmpty
          ? vct
          : vct3.isEmpty
          ? '$vct $vct2'
          : '$vct $vct2  $vct3',
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: textStyle,
    );
  }

  TextStyle _getTextStyle() {
    switch (fontFam) {
      case MyFontFam.poppins:
        return MyFont.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
          letterSpacing: letterSpacing,
          decoration: decoration,
          decorationColor: decorationColor,
        );
      case MyFontFam.roboto:
        return MyFont.robotoTextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
          letterSpacing: letterSpacing,
          decoration: decoration,
          decorationColor: decorationColor,
        );
    }
  }

  String _getViewCased(String text) {
    switch (viewCase) {
      case ViewCase.lower:
        return text.toLowerCase();
      case ViewCase.upper:
        return text.toUpperCase();
      case ViewCase.title:
        return text.toTitleCase;
      case ViewCase.caps:
        return text.capitalize;
      default:
        return text;
    }
  }
}

class RichTextWidget extends StatelessWidget {
  final String text;
  final TextStyle style;
  final List<TextSpan>? children;

  const RichTextWidget({
    super.key,
    required this.text,
    required this.style,
    this.children,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(text: text, style: style, children: children),
    );
  }
}
