import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wellkins/utils/extensions.dart';
import '../constants/colors.dart';
import '../utils/textstyle_util.dart';
import 'text_widget.dart';

class CustomTextField extends StatelessWidget {
  final String? regErrorText;
  final String? errorText;
  final String? hintText;
  final String? labelText;
  final String? prefixText;
  final bool digit;
  final bool isDouble;
  final bool readOnly;
  final bool passField;
  final bool obscureText;
  final bool? outlined;
  final bool? filled;
  final Color? fillColor;
  final int? minLines;
  final int maxLines;
  final int? maxLength;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final RegExp regExpCondition;
  final InputBorder? border;
  final TextEditingController? controller;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? outPadding;
  final double bRadius;
  final bool? isDence;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final bool autoValidate;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    required this.regExpCondition,
    this.maxLines = 1,
    this.digit = false,
    this.isDouble = false,
    this.readOnly = false,
    this.passField = false,
    this.obscureText = false,
    this.minLines,
    this.regErrorText,
    this.outlined,
    this.filled,
    this.fillColor,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.focusNode,
    this.prefix,
    this.suffix,
    this.maxLength,
    this.prefixText,
    this.border,
    this.padding,
    this.outPadding,
    this.bRadius = 10,
    this.isDence,
    this.style,
    this.hintStyle,
    this.errorStyle,
    this.autoValidate = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      focusNode: focusNode,
      obscuringCharacter: '●',
      obscureText: obscureText && passField,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: digit || isDouble ? TextInputType.number : null,
      inputFormatters: digit
          ? [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(maxLength ?? 10),
            ]
          : isDouble
          ? [
              // FilteringTextInputFormatter.allow(Regx.double2RegExp),
              LengthLimitingTextInputFormatter(maxLength ?? 10),
              CommaSeparatedFormatter(),
            ]
          : null,
      style:
          style ??
          TextStyleData.formHintStyle.copyWith(color: ColorsData.blackColor),
      autovalidateMode: autoValidate
          ? AutovalidateMode.onUserInteraction
          : null,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        filled: filled,
        fillColor: fillColor,
        isDense: isDence,
        hintStyle: hintStyle ?? TextStyleData.formHintStyle,
        labelStyle: labelStyle(ColorsData.greyColor),
        floatingLabelStyle: labelStyle(ColorsData.primaryColor),
        errorStyle: errorStyle ?? TextStyleData.formErrorStyle,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        prefixIcon: prefixIcon,
        prefix: prefix,
        suffix: suffix,
        suffixIcon: suffixIcon,
        suffixIconConstraints: BoxConstraints(minWidth: 55.w, minHeight: 2.w),
        prefixText: prefixText,
        errorMaxLines: 4,
        border: outlined == null ? InputBorder.none : null,
        contentPadding: (outlined != null && outlined == true)
            ? outPadding ??
                  EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w)
            : padding,
        focusedBorder: _fieldBorder(
          color: ColorsData.blueShade,
          radius: bRadius,
        ),
        enabledBorder: _fieldBorder(
          color: ColorsData.formHintColor,
          radius: bRadius,
        ),
        errorBorder: _fieldBorder(color: Colors.red, radius: bRadius),
        focusedErrorBorder: _fieldBorder(color: Colors.red, radius: bRadius),
        disabledBorder: _fieldBorder(radius: bRadius),
      ),
      validator: (value) {
        if (value!.trim().isEmpty) {
          return errorText;
        }
        if (!regExpCondition.hasMatch(value)) {
          return regErrorText;
        }
        return null;
      },
    );
  }

  static TextStyle labelStyle(Color color) {
    return TextStyleData.formHintStyle.copyWith(fontSize: 15.sp, color: color);
  }

  InputBorder _fieldBorder({
    Color color = ColorsData.primaryColor,
    double radius = 10.0,
    double width = 1.2,
  }) {
    if (outlined != null && outlined == false) {
      return UnderlineInputBorder(borderSide: BorderSide(color: color));
    } else {
      return OutlineInputBorder(
        borderSide: BorderSide(color: color, width: width.w),
        borderRadius: BorderRadius.circular(radius.r),
      );
    }
  }
}

class CustomDropdownField extends StatelessWidget {
  final List<String> items;
  final String? value;
  final void Function(String?)? onChanged;
  final Widget? hint;
  final Widget? icon;
  final bool outlined;
  final String? errorText;
  final TextStyle? errorStyle;
  final bool autoValidate;
  final bool isExpanded;

  const CustomDropdownField({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.hint,
    this.icon,
    this.errorText,
    this.errorStyle,
    this.outlined = true,
    this.autoValidate = true,
    this.isExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      alignedDropdown: true,
      child: DropdownButtonFormField<String>(
        // value: value,
        initialValue: value,
        onChanged: onChanged,
        isExpanded: isExpanded,
        icon: icon,
        hint: hint,
        iconSize: 24.sp,
        dropdownColor: Colors.grey[50],
        autovalidateMode: autoValidate
            ? AutovalidateMode.onUserInteraction
            : null,
        style: TextStyleData.formHintStyle.copyWith(
          color: ColorsData.blackColor,
        ),
        borderRadius: BorderRadius.circular(10.r),
        decoration: InputDecoration(
          filled: true,
          fillColor: ColorsData.whiteColor,
          contentPadding: EdgeInsets.symmetric(
            vertical: 10.h,
            horizontal: 10.w,
          ),
          border: _fieldBorder(),
          focusedBorder: _fieldBorder(color: ColorsData.blueShade),
          enabledBorder: _fieldBorder(color: ColorsData.formHintColor),
          errorBorder: _fieldBorder(color: Colors.red),
          focusedErrorBorder: _fieldBorder(color: Colors.red),
          disabledBorder: _fieldBorder(color: ColorsData.primaryColor),
          errorStyle: errorStyle ?? TextStyleData.formErrorStyle,
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 10.w),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                // color: bg,
                // borderRadius: BorderRadius.circular(10.r)
                border: items.last == item
                    ? null
                    : const Border(
                        bottom: BorderSide(
                          color: ColorsData.formHintColor,
                          width: 1.0,
                        ),
                      ),
              ),
              child: TextWidget(
                text: item,
                color: ColorsData.blackColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
          );
        }).toList(),
        selectedItemBuilder: (BuildContext context) => items
            .map(
              (item) => TextWidget(
                text: item,
                color: ColorsData.blackColor,
                fontWeight: FontWeight.w500,
                fontSize: 15,
                letterSpacing: 2,
              ),
            )
            .toList(),
        validator: (value) {
          if (value == null) {
            return errorText;
          }
          return null;
        },
      ),
    );
  }

  InputBorder _fieldBorder({Color? color}) {
    if (outlined) {
      return OutlineInputBorder(
        borderSide: BorderSide(
          color: color ?? ColorsData.primaryColor,
          width: (1.2).w,
        ),
        borderRadius: BorderRadius.circular(10.r),
      );
    } else {
      return UnderlineInputBorder(
        borderSide: BorderSide(color: color ?? ColorsData.primaryColor),
      );
    }
  }
}
