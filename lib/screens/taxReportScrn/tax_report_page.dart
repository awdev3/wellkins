import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../constants/strings.dart';
import '../../models/taxreturn_model.dart';
import '../../providers/woo_provider.dart';
import '../../services/helpers.dart';
import '../../utils/console_util.dart';
import '../../utils/extensions.dart';
import '../../utils/formatter.dart';
import '../../utils/regx.dart';
import '../../utils/textstyle_util.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/button_widgets.dart';
import '../../widgets/common_titles.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/field_widget.dart';
import '../../widgets/loaders.dart';
import '../../widgets/spacers.dart';
import '../../widgets/text_widget.dart';
import 'pdf_components.dart';

class TaxReportPage extends StatefulWidget {
  const TaxReportPage({super.key});

  @override
  State<TaxReportPage> createState() => _TaxReportPageState();
}

class _TaxReportPageState extends State<TaxReportPage> {
  String? selectedUnit;
  String? selectedYear;
  DateTime? fromDate;
  DateTime? toDate;
  bool isYear = true;
  bool isDataLoading = false;

  final _formKey = GlobalKey<FormState>();

  final ausFinYearStart = DateTime(2023, 7, 1);
  final ausFinYearEnd = DateTime(DateTime.now().year + 1, 6, 30);

  List<String> classOfunits = [];
  List<String> financialYears = [];

  @override
  void initState() {
    super.initState();
    _calculateData();
  }

  Future<void> _calculateData() async {
    final wooProvider = getWooProvider(context);
    financialYears = _getAustralianFinancialYears();

    if (wooProvider.historyList.isEmpty) {
      await wooProvider.getHistory(context);
    }

    classOfunits = wooProvider.historyList
        .map((e) => e.project.propertyName)
        .toSet()
        .toList();
  }

  List<String> _getAustralianFinancialYears() {
    const startYear = 2023;
    final currentYear = DateTime.now().year;
    final length = (currentYear - startYear) + 1;
    return List.generate(length, (index) {
      int year = startYear + index;
      return '$year-${year + 1}';
    });
  }

  Future<void> _selectDate({
    required BuildContext context,
    required bool isStart,
  }) async {
    DateTime initialDate = isStart
        ? fromDate ?? ausFinYearStart
        : toDate ?? (fromDate ?? ausFinYearStart);

    DateTime firstDate = ausFinYearStart;
    DateTime lastDate = ausFinYearEnd;

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          fromDate = picked;
          if (toDate != null && picked.isAfter(toDate!)) {
            toDate = null;
          }
        } else {
          toDate = picked;
        }
      });
    }
  }

  bool _validateDateRange() {
    if (fromDate == null || toDate == null) return false;

    return fromDate!
            .isAfter(ausFinYearStart.subtract(const Duration(days: 1))) &&
        toDate!.isBefore(ausFinYearEnd.add(const Duration(days: 1))) &&
        fromDate!.isBefore(toDate!);
  }

  String getPropId(String propertyName) {
    final wooProvider = getWooProvider(context);
    final historyList = wooProvider.historyList;
    final history = historyList.firstWhere(
      (e) => e.project.propertyName == propertyName,
    );
    return '${history.project.id}';
  }

  Future<void> _fetchAndGenerateTaxReports(BuildContext context) async {
    final wooProvider = getWooProvider(context);
    final userProvider = getUserProvider(context);

    setState(() => isDataLoading = true);

    try {
      final userId = userProvider.user!.id.toInt;
      final taxReports = await wooProvider.getTaxReports(
        ctx: context,
        getTaxReport: GetTaxReport(
          clientId: userId,
          propertyName: selectedUnit!,
          year: !isYear || selectedYear == null ? null : selectedYear,
          fromDate: fromDate == null || isYear
              ? null
              : Frmtr.frmtDate(dateTime: fromDate, outForm: 'yyyy-MM-dd'),
          endDate: toDate == null || isYear
              ? null
              : Frmtr.frmtDate(dateTime: toDate, outForm: 'yyyy-MM-dd'),
        ),
      );
      if (!context.mounted) return;
      if (taxReports.isNotEmpty) {
        final propId = getPropId(selectedUnit!);
        await PdfComponents.generateAndOpenPdf(
          taxReports,
          isYear ? selectedYear! : '${toDate!.year}',
          '${userId}_ ${isYear ? selectedYear!.split('-').last : toDate!.year}_$propId',
          context,
        );
      }
    } catch (e) {
      printData(data: 'Error fetching tax reports: $e', e: true);
    } finally {
      _formKey.currentState!.reset();
      selectedUnit = null;
      selectedYear = null;
      fromDate = null;
      toDate = null;
      setState(() => isDataLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: isDataLoading,
      child: Stack(
        children: [
          bgImage,
          Scaffold(
            backgroundColor: ColorsData.trColor,
            appBar: CustomAppBar.appbar(ctx: context),
            body: Column(
              children: [
                CommonTitles.title(
                  text: AppConstants.txReport,
                  context: context,
                ),
                Spacers.sb10(),
                Expanded(
                  child: DelayedDisplay(
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
                      padding: EdgeInsets.fromLTRB(15.w, 20.w, 15.w, 0),
                      decoration: commonDecor,
                      child: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Spacers.sb30(),
                              _buildDropdownField(
                                title: AppConstants.clsOfUnits,
                                items: classOfunits,
                                value: selectedUnit,
                                onChanged: (value) =>
                                    setState(() => selectedUnit = value),
                              ),
                              Spacers.sb30(),
                              _buildToggleOptions(),
                              Spacers.sb10(),
                              if (isYear)
                                _buildYearSelection()
                              else
                                _buildDateRangeSelection(),
                              Spacers.sb50(),
                              isDataLoading
                                  ? showLoader()
                                  : Center(
                                      child: customButton(
                                        width: 200,
                                        stadium: true,
                                        title: AppConstants.download,
                                        viewCase: ViewCase.title,
                                        onPressed: () async {
                                          final isValid =
                                              _formKey.currentState!.validate();
                                          if (isValid) {
                                            if (!isYear &&
                                                !_validateDateRange()) {
                                              _showSnack(context);
                                              return;
                                            }
                                            await _fetchAndGenerateTaxReports(
                                                context);
                                          }
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        ),
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

  void _showSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade900,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.w),
        content: const TextWidget(
          text: AppConstants.dateError,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: ColorsData.whiteColor,
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String title,
    required List<String> items,
    String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: title,
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        Spacers.sb5(),
        if (title == AppConstants.clsOfUnits)
          Consumer<WooProvider>(
            builder: (context, snapshot, child) {
              return snapshot.historyLoad
                  ? showLoader()
                  : CustomDropdownField(
                      items: items,
                      value: value,
                      autoValidate: true,
                      hint: const TextWidget(
                        text: AppConstants.chooseOption,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: ColorsData.formHintColor,
                      ),
                      onChanged: onChanged,
                      errorText: AppConstants.pleaseChoose,
                    );
            },
          )
        else
          CustomDropdownField(
            items: items,
            value: value,
            autoValidate: true,
            hint: const TextWidget(
              text: AppConstants.chooseOption,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: ColorsData.formHintColor,
            ),
            onChanged: onChanged,
            errorText: AppConstants.pleaseChoose,
          ),
      ],
    );
  }

  Widget _buildToggleOptions() {
    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            value: isYear,
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const TextWidget(
              text: AppConstants.year,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            onChanged: (_) => setState(() {
              if (!isYear) {
                isYear = true;
                selectedYear = null;
              }
            }),
          ),
        ),
        Spacers.sbw10(),
        Expanded(
          child: CheckboxListTile(
            value: !isYear,
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const TextWidget(
              text: AppConstants.dtRange,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            onChanged: (_) => setState(() {
              if (isYear) {
                isYear = false;
                fromDate = null;
                toDate = null;
              }
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildYearSelection() {
    return DelayedDisplay(
      slidingBeginOffset: const Offset(0, 0),
      child: _buildDropdownField(
        title: AppConstants.finclYear,
        items: financialYears,
        value: selectedYear,
        onChanged: (value) => setState(() => selectedYear = value),
      ),
    );
  }

  Widget _buildDateRangeSelection() {
    return Animate(
      effects: const [FadeEffect(duration: Duration(milliseconds: 800))],
      child: Row(
        children: [
          _buildDateField(
            title: AppConstants.from,
            date: fromDate,
            onSelect: () => _selectDate(context: context, isStart: true),
          ),
          Spacers.sbw20(),
          _buildDateField(
            title: AppConstants.to,
            date: toDate,
            onSelect: () => _selectDate(context: context, isStart: false),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String title,
    required DateTime? date,
    required VoidCallback onSelect,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: title,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          Spacers.sb5(),
          CustomTextField(
            readOnly: true,
            isDence: true,
            regExpCondition: Regx.nameRegExp,
            hintText:
                date != null ? _formatDate(date) : AppConstants.selectDate,
            hintStyle: date == null
                ? TextStyleData.formHintStyle
                : TextStyleData.formHintStyle
                    .copyWith(color: ColorsData.blackColor),
            suffixIcon: IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: onSelect,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
















// import 'package:delayed_display/delayed_display.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// import 'constants/colors.dart';
// import 'constants/strings.dart';
// import 'models/history_model.dart';
// import 'services/helpers.dart';
// import 'utils/regx.dart';
// import 'widgets/backgrounds.dart';
// import 'widgets/button_widgets.dart';
// import 'widgets/field_widget.dart';
// import 'widgets/spacers.dart';
// import 'widgets/text_widget.dart';

// class TaxStatement extends StatefulWidget {
//   const TaxStatement({super.key});

//   @override
//   State<TaxStatement> createState() => _TaxStatementState();
// }

// class _TaxStatementState extends State<TaxStatement> {
//   String? selectedUnit;
//   String? selectedYear;
//   DateTime? fromDate;
//   DateTime? toDate;
//   bool isYear = true;

//   List<History> transactions = [];
//   List<String> financialYears = [];

//   @override
//   void initState() {
//     super.initState();
//     final wooProvider = getWooProvider(context);
//     transactions = wooProvider.historyList;
//     financialYears = getAustralianFinancialYears();
//   }

//   List<String> getAustralianFinancialYears() {
//     int startYear = 2023;
//     int endYear = DateTime.now().year;
//     List<String> financialYears = [];

//     for (int year = startYear; year <= endYear; year++) {
//       String fy = '$year-${year + 1}';
//       financialYears.add(fy);
//     }

//     return financialYears;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorsData.trColor,
//       resizeToAvoidBottomInset: false,
//       body: Column(
//         children: [
//           Spacers.sb15(),
//           buildTitle(context),
//           Spacers.sb10(),
//           Expanded(
//             child: Container(
//               width: double.infinity,
//               margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
//               padding: EdgeInsets.fromLTRB(15.w, 20.w, 15.w, 0),
//               decoration: commonDecor,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Spacers.sb30(),
//                   const TextWidget(
//                     text: AppConstants.clsOfUnits,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w400,
//                   ),
//                   Spacers.sb5(),
//                   CustomDropdownField(
//                     items: transactions
//                         .map((e) => e.project.propertyName)
//                         .toSet()
//                         .toList(),
//                     value: selectedUnit,
//                     hint: const Text('choose an option'),
//                     onChanged: (value) {
//                       setState(() => selectedUnit = value);
//                     },
//                   ),
//                   Spacers.sb30(),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: CheckboxListTile(
//                           value: isYear,
//                           dense: true,
//                           contentPadding: EdgeInsets.zero,
//                           controlAffinity: ListTileControlAffinity.leading,
//                           title: const TextWidget(
//                             text: AppConstants.year,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w400,
//                           ),
//                           onChanged: (v) => setState(() {
//                             if (!isYear) {
//                               isYear = true;
//                               selectedYear = null;
//                             }
//                           }),
//                         ),
//                       ),
//                       Spacers.sbw10(),
//                       Expanded(
//                         child: CheckboxListTile(
//                           value: !isYear,
//                           dense: true,
//                           controlAffinity: ListTileControlAffinity.leading,
//                           contentPadding: EdgeInsets.zero,
//                           title: const TextWidget(
//                             text: AppConstants.dtRange,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w400,
//                           ),
//                           onChanged: (v) => setState(() {
//                             isYear = false;
//                           }),
//                         ),
//                       ),
//                     ],
//                   ),
//                   Spacers.sb10(),
//                   if (isYear)
//                     DelayedDisplay(
//                       slidingBeginOffset: const Offset(0, 0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const TextWidget(
//                             text: AppConstants.finclYear,
//                             fontSize: 13,
//                             fontWeight: FontWeight.w400,
//                           ),
//                           Spacers.sb5(),
//                           CustomDropdownField(
//                             items: financialYears,
//                             value: selectedYear,
//                             hint: const Text('choose an option'),
//                             onChanged: (value) {
//                               setState(() => selectedYear = value);
//                             },
//                           ),
//                         ],
//                       ),
//                     )
//                   else
//                     Animate(
//                       effects: const [
//                         FadeEffect(duration: Duration(milliseconds: 800))
//                       ],
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const TextWidget(
//                                   text: AppConstants.from,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                                 Spacers.sb5(),
//                                 CustomTextField(
//                                   readOnly: true,
//                                   isDence: true,
//                                   // controller: _startController,
//                                   regExpCondition: Regx.nameRegExp,
//                                   suffixIcon: IconButton(
//                                     onPressed: () async {},
//                                     icon: const Icon(Icons.date_range),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Spacers.sbw20(),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const TextWidget(
//                                   text: AppConstants.to,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w400,
//                                 ),
//                                 Spacers.sb5(),
//                                 CustomTextField(
//                                   readOnly: true,
//                                   isDence: true,
//                                   // controller: _endController,
//                                   regExpCondition: Regx.nameRegExp,
//                                   suffixIcon: IconButton(
//                                     onPressed: () async {},
//                                     icon: const Icon(Icons.date_range),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   Spacers.sb50(),
//                   Spacers.sb50(),
//                   Center(
//                     child: customButton(
//                       width: 200,
//                       stadium: true,
//                       title: AppConstants.download,
//                       viewCase: ViewCase.title,
//                       onPressed: () {},
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Widget buildTitle(BuildContext context) {
//   return const Center(
//     child: TextWidget(
//       text: AppConstants.txReport,
//       fontSize: 20,
//       fontWeight: FontWeight.w500,
//       color: ColorsData.whiteColor,
//     ),
//   );
// }
