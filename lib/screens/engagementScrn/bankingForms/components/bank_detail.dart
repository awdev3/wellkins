import 'package:flutter/material.dart';
import 'package:wellkins/constants/strings.dart';
import '../../../../constants/colors.dart';
import '../../../../utils/regx.dart';
import '../../../../widgets/spacers.dart';
import 'form_helpers.dart';

class BankDetailCard extends StatelessWidget {
  final String? incomeDistributionOption;
  final Function(String?) onIncomeDistributionChanged;
  final TextEditingController financialInstitutionCntlr;
  final TextEditingController accountNameCntlr;
  final TextEditingController bsbCntlr;
  final TextEditingController accountNumberCntlr;

  const BankDetailCard({
    super.key,
    required this.incomeDistributionOption,
    required this.onIncomeDistributionChanged,
    required this.financialInstitutionCntlr,
    required this.accountNameCntlr,
    required this.bsbCntlr,
    required this.accountNumberCntlr,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormHelpers.buildCardWithHeader(
          "Income Distributions",
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacers.sb15(),
              FormHelpers.sectionTitle(
                "Do you want us to reinvest your income distributions back into the Fund?",
                14,
                FontWeight.w600,
                ColorsData.blackColor,
              ),
              Spacers.sb15(),
              FormHelpers.buildDropdownField(
                label: "Please select",
                items: ["Yes", "No"],
                value: incomeDistributionOption,
                onChanged: onIncomeDistributionChanged,
              ),
              Spacers.sb20(),
            ],
          ),
        ),

        Spacers.sb20(),

        FormHelpers.buildCardWithHeader(
          "Bank Account Details",
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacers.sb15(),
              FormHelpers.sectionTitle(
                "Please complete your bank account details below. Please note the account must be held in the name of the applicant. All payments are calculated and paid in Australian dollars.",
                12,
                FontWeight.w500,
                ColorsData.blackColor,
              ),
              Spacers.sb20(),

              Column(
                children: [
                  FormHelpers.buildTextField(
                    label: "Name of financial institution",
                    controller: financialInstitutionCntlr,
                    hintText: "Enter your financial institution",
                    regErrorText: "",
                    regExp: Regx.fullNameRegExp,
                  ),
                  Spacers.sb10(),
                  FormHelpers.buildTextField(
                    label: "Account name",
                    controller: accountNameCntlr,
                    hintText: "Enter your account name",
                    regErrorText: AppConstants.nameRegError,
                    regExp: Regx.fullNameRegExp,
                  ),
                  Spacers.sb10(),
                  FormHelpers.buildTextField(
                    label: "BSB",
                    controller: bsbCntlr,
                    hintText: "Enter BSB",
                    digit: true,
                    // regExp: Regx.phoneRegExp,
                  ),
                  Spacers.sb10(),
                  FormHelpers.buildTextField(
                    label: "Account number",
                    controller: accountNumberCntlr,
                    hintText: "Enter your account number",
                    digit: true,
                    // regExp: Regx.phoneRegExp,
                  ),
                ],
              ),

              Spacers.sb20(),
            ],
          ),
        ),
      ],
    );
  }
}
