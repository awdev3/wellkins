import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/colors.dart';
import '../../../utils/regx.dart';
import '../../../widgets/backgrounds.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/field_widget.dart';
import '../../../widgets/spacers.dart';
import '../../../widgets/text_widget.dart';
import '../bankingForms/australian_prop_company_form.dart';
import '../bankingForms/australian_public_company_form.dart';
import '../bankingForms/individual_form.dart';
import '../bankingForms/smsf_corporate_trustee_form.dart';
import '../bankingForms/smsf_individual_trustee_form.dart';
import '../bankingForms/unregulated_trust_corporate_form.dart';
import '../bankingForms/unregulated_trust_individual_form.dart';

class ApplicationFormManual extends StatefulWidget {
  const ApplicationFormManual({super.key});

  @override
  State<ApplicationFormManual> createState() => _ApplicationFormManualState();
}

class _ApplicationFormManualState extends State<ApplicationFormManual> {
  final _scrollController = ScrollController();
  String? selectedInvestmentType;
  static List<String> investmentTypes = [
    "Individual / Joint Holding",
    "Unregulated trust with individual trustee including Family Trust",
    "Regulated trust with individual trustee including SMSFs",
    "Unregulated trust with corporate trustee including Family Trust",
    "Regulated Trust with corporate trustee including SMSFs",
    "Australian proprietary company",
    "Australian public company",
  ];

  final amountCntlr = TextEditingController();
  final unitCntlr = TextEditingController();

  @override
  void dispose() {
    _scrollController.dispose(); // Add this
    amountCntlr.dispose();
    unitCntlr.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          bgImage,
          Scaffold(
            backgroundColor: ColorsData.trColor,
            appBar: CustomAppBar.appbar(
              ctx: context,
              showLeading: false,
              hasBack: true,
            ),
            body: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
                    decoration: commonDecor,
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: EdgeInsets.all(8.w),
                      child: Column(
                        children: [
                          applicationFormCard(),
                          _buildInvestmentForm(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvestmentForm() {
    if (selectedInvestmentType == null) {
      return const SizedBox.shrink();
    }

    return switch (selectedInvestmentType!) {
      "Individual / Joint Holding" => IndividualForm(
        scrollController: _scrollController,
      ),
      "Unregulated trust with individual trustee including Family Trust" =>
        UnregulatedTrustIndividualForm(scrollController: _scrollController),
      "Regulated trust with individual trustee including SMSFs" =>
        SmsfIndividualTrusteeForm(scrollController: _scrollController),
      "Unregulated trust with corporate trustee including Family Trust" =>
        UnregulatedTrustCorporateForm(scrollController: _scrollController),
      "Regulated Trust with corporate trustee including SMSFs" =>
        SmsfCorporateTrusteeForm(scrollController: _scrollController),
      "Australian proprietary company" => AustralianPropCompanyForm(
        scrollController: _scrollController,
      ),
      "Australian public company" => AustralianPublicCompanyForm(
        scrollController: _scrollController,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildCardWithHeader(
    String title,
    Widget content, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
    bool showIcon = false,
  }) {
    return Card(
      elevation: 2,
      color: ColorsData.whiteColor,
      surfaceTintColor: ColorsData.whiteColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
      child: Column(
        children: [
          _buildCardHeader(title, fontSize, fontWeight, showIcon),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: content,
          ),
          Spacers.sb10(),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    double fontSize,
    FontWeight fontWeight,
    Color color, {
    bool showIcon = false, // Add bool parameter
  }) {
    return Align(
      alignment: Alignment.topLeft,
      child: Row(
        children: [
          if (showIcon) ...[
            Icon(Icons.description, color: color, size: 21.w),
            Spacers.sbw10(),
          ],
          Expanded(
            child: TextWidget(
              text: title,
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(
    String title,
    double fontSize,
    FontWeight fontWeight,
    bool showIcon,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
      color: ColorsData.primaryColor,
      child: _sectionTitle(
        title,
        fontSize,
        fontWeight,
        ColorsData.whiteColor,
        showIcon: showIcon,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    bool digit = false,
    RegExp? regExp,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(label, 14, FontWeight.bold, ColorsData.blackColor),
        Spacers.sb8(),
        CustomTextField(
          controller: controller,
          hintText: hintText,
          errorText: "$label is required",
          outlined: true,
          filled: true,
          fillColor: ColorsData.whiteColor,
          digit: digit,
          regExpCondition: regExp ?? Regx.nameRegExp,
        ),
      ],
    );
  }

  Widget applicationFormCard() {
    return _buildCardWithHeader(
      "Application Form - Property Fund",
      showIcon: true,
      Column(
        children: [
          Spacers.sb8(),
          _sectionTitle(
            "How do you want to invest?",
            14,
            FontWeight.w900,
            ColorsData.blackColor,
          ),
          Spacers.sb8(),
          _sectionTitle(
            "Select One",
            14,
            FontWeight.bold,
            ColorsData.blackColor,
          ),
          Spacers.sb15(),
          _investmentTypeDropDownField(),
          Spacers.sb15(),
          _sectionTitle(
            "Property name:- Land Banking- Bradfield Class",
            14,
            FontWeight.bold,
            ColorsData.blackColor,
          ),
          Spacers.sb15(),
          _buildTextField(
            label: "Total amount invested",
            controller: amountCntlr,
            hintText: "0",
            digit: true,
            regExp: Regx.phoneRegExp,
          ),
          Spacers.sb15(),
          _buildTextField(
            label: "Number of Units",
            controller: unitCntlr,
            hintText: "0",
            digit: true,
            regExp: Regx.phoneRegExp,
          ),
          Spacers.sb10(),
        ],
      ),
    );
  }

  Widget _investmentTypeDropDownField() {
    return CustomDropdownField(
      items: investmentTypes,
      value: selectedInvestmentType,
      hint: TextWidget(
        text: "-- Select Investment Type --",
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.grey,
        letterSpacing: 0.8,
      ),
      onChanged: (String? value) =>
          setState(() => selectedInvestmentType = value!),
      icon: const Icon(Icons.keyboard_arrow_down_sharp, color: Colors.grey),
    );
  }
}
