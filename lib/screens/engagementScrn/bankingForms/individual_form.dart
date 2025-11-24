import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:signature/signature.dart';

import '../../../constants/colors.dart';
import '../../../constants/strings.dart';
import '../../../utils/regx.dart';
import '../../../widgets/image_widget.dart';
import '../../../widgets/spacers.dart';
import '../../../widgets/text_widget.dart';
import '../../../widgets/toasts.dart';
import 'components/bank_detail.dart';
import 'components/custom_stepper.dart';
import 'components/form_helpers.dart';
import 'components/signature_dialog.dart';

class IndividualForm extends StatefulWidget {
  final ScrollController? scrollController;
  const IndividualForm({super.key, this.scrollController});

  @override
  State<IndividualForm> createState() => _IndividualFormState();
}

class _IndividualFormState extends State<IndividualForm> {
  // ADD FORM KEYS
  final _personalDetailsFormKey = GlobalKey<FormState>();
  final _bankFormKey = GlobalKey<FormState>();
  final _identificationFormKey = GlobalKey<FormState>();
  final _declarationFormKey = GlobalKey<FormState>();

  int currentStep = 0;

  String? selectedTitle;
  String? selectedStreetType;
  String? selectedReinvest;

  final amountCntlr = TextEditingController();
  final unitCntlr = TextEditingController();
  final firstNameCntlr = TextEditingController();
  final middleNameCntlr = TextEditingController();
  final surnameCntlr = TextEditingController();
  final dobCntlr = TextEditingController();
  final emailCntlr = TextEditingController();
  final phoneCntlr = TextEditingController();
  final houseUnitCntlr = TextEditingController();
  final streetNameCntlr = TextEditingController();
  final suburbCntlr = TextEditingController();
  final postcodeCntlr = TextEditingController();
  final financialInstCntlr = TextEditingController();
  final accountNameCntlr = TextEditingController();
  final bsbCntlr = TextEditingController();
  final accountNumberCntlr = TextEditingController();

  String? selectedCorrespondence;

  // === AUSTRALIAN RESIDENT TAX SECTION ===
  String? selectedAustralianResidentOption;
  final tfnController = TextEditingController();
  String? foreignResidentOption;
  final countryController = TextEditingController();
  final tinController = TextEditingController();
  String? noForeignResidentOption;

  // === POLITICALLY EXPOSED SECTION ===
  String? selectedPoliticallyExposedOption;

  // === SOLE TRADER SECTION ===
  String? selectedSoleTraderOption;
  final businessNameController = TextEditingController();
  final soleTraderHouseUnitController = TextEditingController();
  final soleTraderStreetNameController = TextEditingController();
  String? soleTraderStreetType;
  final soleTraderSuburbController = TextEditingController();
  String? soleTraderState;
  final soleTraderPostcodeController = TextEditingController();
  final abnController = TextEditingController();

  // === IDENTIFICATION SECTION ===
  String? selectedIdentificationOption;
  String? selectedPrimaryDocument; // For OPTION 1
  String? selectedCategoryA; // For OPTION 2
  String? selectedCategoryB;
  Map<String, List<String>> uploadedFiles = {'categoryA': [], 'categoryB': []};

  // Signature Section Controllers
  List<Map<String, dynamic>> signatures = [];
  List<SignatureController> signatureControllers = [];
  List<Uint8List?> signatureImages = [];

  @override
  void initState() {
    super.initState();
    _addSignature();
  }

  void _addSignature() {
    signatures.add({
      'titleCntlr': TextEditingController(),
      'designationCntlr': TextEditingController(),
      'nameCntlr': TextEditingController(),
      'dateCntlr': TextEditingController(text: FormHelpers.getFormattedDate()),
      'designationDropdownValue': null,
    });

    signatureControllers.add(
      SignatureController(
        penStrokeWidth: 3,
        penColor: Colors.black,
        exportBackgroundColor: Colors.white,
      ),
    );

    signatureImages.add(null);
  }

  @override
  void dispose() {
    // Dispose main form controllers
    amountCntlr.dispose();
    unitCntlr.dispose();
    firstNameCntlr.dispose();
    middleNameCntlr.dispose();
    surnameCntlr.dispose();
    dobCntlr.dispose();
    emailCntlr.dispose();
    phoneCntlr.dispose();
    houseUnitCntlr.dispose();
    streetNameCntlr.dispose();
    suburbCntlr.dispose();
    postcodeCntlr.dispose();
    financialInstCntlr.dispose();
    accountNameCntlr.dispose();
    bsbCntlr.dispose();
    accountNumberCntlr.dispose();

    // Dispose tax section controllers
    tfnController.dispose();
    countryController.dispose();
    tinController.dispose();

    // Dispose sole trader controllers
    businessNameController.dispose();
    soleTraderHouseUnitController.dispose();
    soleTraderStreetNameController.dispose();
    soleTraderSuburbController.dispose();
    soleTraderPostcodeController.dispose();
    abnController.dispose();

    // Dispose source of wealth controller
    othersSpecifyCntlr.dispose();

    // Dispose all joint holder controllers
    for (var holder in jointHolders) {
      (holder['firstNameCtrl'] as TextEditingController).dispose();
      (holder['middleNameCtrl'] as TextEditingController).dispose();
      (holder['surnameCtrl'] as TextEditingController).dispose();
      (holder['dobCtrl'] as TextEditingController).dispose();
      (holder['emailCtrl'] as TextEditingController).dispose();
      (holder['phoneCtrl'] as TextEditingController).dispose();
      (holder['houseUnitCtrl'] as TextEditingController).dispose();
      (holder['streetNameCtrl'] as TextEditingController).dispose();
      (holder['suburbCtrl'] as TextEditingController).dispose();
      (holder['postcodeCtrl'] as TextEditingController).dispose();
      (holder['jointTfnController'] as TextEditingController).dispose();
      (holder['jointCountryController'] as TextEditingController).dispose();
      (holder['jointTinController'] as TextEditingController).dispose();
      (holder['othersCtrl'] as TextEditingController).dispose();
    }

    // Dispose all signature controllers (NEW - ADDED)
    for (var controller in signatureControllers) {
      controller.dispose();
    }

    // Dispose all signature text field controllers (NEW - ADDED)
    for (var signature in signatures) {
      (signature['titleCntlr'] as TextEditingController).dispose();
      (signature['designationCntlr'] as TextEditingController).dispose();
      (signature['nameCntlr'] as TextEditingController).dispose();
      (signature['dateCntlr'] as TextEditingController).dispose();
    }

    super.dispose();
  }

  bool _validateUpToStep(int targetStep) {
    if (targetStep >= 1) {
      if (!_personalDetailsFormKey.currentState!.validate()) {
        return false;
      }
      if (selectedSources.isEmpty) {
        showToast(message: "Please select at least one source of wealth");
        return false;
      }
    }
    if (targetStep >= 2) {
      if (!_bankFormKey.currentState!.validate()) {
        return false;
      }
    }
    if (targetStep >= 3) {
      if (!_identificationFormKey.currentState!.validate()) {
        return false;
      }
    }
    return true;
  }

  final sources = [
    "Gain Employment",
    "Inheritance/gift",
    "Business Activity",
    "Financial investments",
    "Superannuation savings",
    "Others",
  ];

  List<String> selectedSources = [];
  final othersSpecifyCntlr = TextEditingController();

  List<String> identificationOptions = [
    "OPTION 1 – provide ONE original certified copy of one primary identification document",
    "OPTION 2 – provide TWO original certified copies of secondary identification documents One from A and one from B",
  ];

  // OPTION 1: Primary Identification Documents
  List<String> primaryDocuments = [
    "1) Valid Australian state or territory driver's licence containing a photograph of the person",
    "2) Australian passport (a passport expired within the preceding two years is acceptable)",
    "3) Card issued by a state or territory for the purposes of providing a person’s age containing a photograph of the person",
    "4) Valid foreign passport or similar travel document containing a photograph and the signature of the person (and if applicable, an English translation by an accredited translator)",
  ];

  List<String> categoryADocuments = [
    "1) Australian birth certificate",
    "2) Australian citizenship certificate",
    "3) Foreign citizenship certificate (and if applicable, an English translation by an accredited translator)",
    "4) Foreign birth certificate (and if applicable, an English translation by an accredited translator)",
    "5) Pension card issued by Centrelink",
    "6) Health card issued by Centrelink",
    "7) Valid Medicare card",
  ];
  List<String> categoryBDocuments = [
    "1) A document issued by the Commonwealth or a state or territory within the preceding 12 months that records the provision of financial benefits",
    "2) A document issued by the ATO within the preceding 12 months that records a debt payable by the individual to the Commonwealth (or the Commonwealth to the individual), which contains the individual’s name and residential address(block out any TFN references)",
    "3) A document issued by a local government body or utilities provider within the preceding three months which records the provision of services to that address or to that person (must contain the individual’s name and residential address)",
    "4) Australian marriage certificate",
  ];

  // List<int> jointHolders = [];
  List<Map<String, dynamic>> jointHolders = [];

  // // ============ GET FILE EXTENSION ============
  // String _getFileExtension(String fileName) {
  //   return fileName.split('.').last.toUpperCase();
  // }

  void _addJointHolder() {
    setState(() {
      jointHolders.add({
        'holderNumber': jointHolders.length + 1,
        'selectedTitle': null,
        'firstNameCtrl': TextEditingController(),
        'middleNameCtrl': TextEditingController(),
        'surnameCtrl': TextEditingController(),
        'dobCtrl': TextEditingController(),
        'emailCtrl': TextEditingController(),
        'phoneCtrl': TextEditingController(),
        'houseUnitCtrl': TextEditingController(),
        'streetNameCtrl': TextEditingController(),
        'selectedStreetType': null,
        'suburbCtrl': TextEditingController(),
        'postcodeCtrl': TextEditingController(),
        'selectedState': null,
        'selectedCorrespondence': 'NO',
        'selectedAustralianResidentOption': null,
        'jointTfnController': TextEditingController(),
        'jointForeignResidentOption': null,
        'jointCountryController': TextEditingController(),
        'jointTinController': TextEditingController(),
        'jointNoForeignResidentOption': null,
        'selectedPoliticallyExposedOption': null,
        'selectedSources': <String>[],
        'othersCtrl': TextEditingController(),
      });
      _addSignature();
    });
  }

  void _removeJointHolder(int index) {
    setState(() {
      // Dispose all controllers for this joint holder before removing
      (jointHolders[index]['firstNameCtrl'] as TextEditingController).dispose();
      (jointHolders[index]['middleNameCtrl'] as TextEditingController)
          .dispose();
      (jointHolders[index]['surnameCtrl'] as TextEditingController).dispose();
      (jointHolders[index]['dobCtrl'] as TextEditingController).dispose();
      (jointHolders[index]['emailCtrl'] as TextEditingController).dispose();
      (jointHolders[index]['phoneCtrl'] as TextEditingController).dispose();
      (jointHolders[index]['houseUnitCtrl'] as TextEditingController).dispose();
      (jointHolders[index]['streetNameCtrl'] as TextEditingController)
          .dispose();
      (jointHolders[index]['suburbCtrl'] as TextEditingController).dispose();
      (jointHolders[index]['postcodeCtrl'] as TextEditingController).dispose();
      (jointHolders[index]['jointTfnController'] as TextEditingController)
          .dispose();
      (jointHolders[index]['jointCountryController'] as TextEditingController)
          .dispose();
      (jointHolders[index]['jointTinController'] as TextEditingController)
          .dispose();
      (jointHolders[index]['othersCtrl'] as TextEditingController).dispose();

      // Remove the joint holder first
      jointHolders.removeAt(index);

      // Update holder numbers for remaining joint holders after the removed index
      for (int i = index; i < jointHolders.length; i++) {
        jointHolders[i]['holderNumber'] = i + 1;
      }

      int signatureIndex = index + 1;
      if (signatureIndex < signatures.length) {
        (signatures[signatureIndex]['titleCntlr'] as TextEditingController)
            .dispose();
        (signatures[signatureIndex]['designationCntlr']
                as TextEditingController)
            .dispose();
        (signatures[signatureIndex]['nameCntlr'] as TextEditingController)
            .dispose();
        (signatures[signatureIndex]['dateCntlr'] as TextEditingController)
            .dispose();
        signatureControllers[signatureIndex].dispose();

        signatures.removeAt(signatureIndex);
        signatureControllers.removeAt(signatureIndex);
        signatureImages.removeAt(signatureIndex);
      }
    });
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollController?.hasClients ?? false) {
        widget.scrollController!.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacers.sb20(),
        CustomStepper(
          currentStep: currentStep,
          stepTitles: [
            'Personal details',
            'Bank Detail',
            'Identification Requirements',
            'Declaration',
          ],
          onStepTapped: (index) {
            if (index > currentStep) {
              bool canProceed = _validateUpToStep(index);
              if (canProceed) {
                setState(() => currentStep = index);
              } else {
                showToast(
                  message:
                      "Please complete all required fields in the previous step",
                );
              }
            } else {
              setState(() {
                currentStep = index;
              });
              _scrollToTop();
            }
          },
        ),

        Spacers.sb20(),
        if (currentStep == 0)
          Form(key: _personalDetailsFormKey, child: personalDetailsCard()),
        if (currentStep == 1) Form(key: _bankFormKey, child: bankDetailCard()),
        if (currentStep == 2)
          Form(
            key: _identificationFormKey,
            child: identificationRequirementsCard(),
          ),
        if (currentStep == 3)
          Form(key: _declarationFormKey, child: declarationCard()),
        Spacers.sb20(),
        _buildNavigationButtons(),
        Spacers.sb20(),
      ],
    );
  }

  BankDetailCard bankDetailCard() {
    return BankDetailCard(
      incomeDistributionOption: selectedReinvest,
      onIncomeDistributionChanged: (value) {
        setState(() {
          selectedReinvest = value;
        });
      },
      financialInstitutionCntlr: financialInstCntlr,
      accountNameCntlr: accountNameCntlr,
      bsbCntlr: bsbCntlr,
      accountNumberCntlr: accountNumberCntlr,
    );
  }

  Widget _buildCardWithHeader(
    String title,
    Widget content, {
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return Card(
      elevation: 2,
      color: ColorsData.whiteColor,
      surfaceTintColor: ColorsData.whiteColor,
      child: Column(
        children: [
          _buildCardHeader(title, fontSize, fontWeight),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: content,
          ),
          Spacers.sb10(),
        ],
      ),
    );
  }

  // ============ REUSABLE WIDGET: Card Header ============
  Widget _buildCardHeader(
    String title,
    double fontSize,
    FontWeight fontWeight,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: ColorsData.blueShade,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: FormHelpers.sectionTitle(
        title,
        fontSize,
        fontWeight,
        ColorsData.whiteColor,
      ),
    );
  }

  // ============ PERSONAL DETAILS CARD ============
  Widget personalDetailsCard() {
    return _buildCardWithHeader(
      "Personal Details",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacers.sb15(),
          buildCorrespondenceRadio(
            currentValue: selectedCorrespondence,
            onChanged: (value) {
              if (value == 'YES') {
                selectedCorrespondence = null;
                for (int i = 0; i < jointHolders.length; i++) {
                  jointHolders[i]['selectedCorrespondence'] = null;
                }
                selectedCorrespondence = 'YES';
              } else {
                selectedCorrespondence = value!;
              }
            },
          ),
          Spacers.sb15(),
          FormHelpers.buildDropdownField(
            label: "Title",
            items: FormHelpers.titles,
            value: selectedTitle,
            onChanged: (value) => setState(() => selectedTitle = value),
          ),
          Spacers.sb15(),
          FormHelpers.buildTextFieldRow([
            {
              'label': 'First name',
              'controller': firstNameCntlr,
              'hint': 'John',
              'regErrorText': AppConstants.nameRegError,
              'regExp': Regx.nameRegExp,
            },
            {
              'label': 'Middle name',
              'controller': middleNameCntlr,
              'hint': 'Reco',
              'regErrorText': AppConstants.nameRegError,
              'regExp': Regx.nameRegExp,
            },
          ]),
          Spacers.sb15(),
          FormHelpers.buildTextField(
            label: "Surname",
            controller: surnameCntlr,
            hintText: 'Smith',
            regErrorText: AppConstants.nameRegError,
            regExp: Regx.nameRegExp,
          ),
          Spacers.sb15(),
          FormHelpers.buildDatePickerField(
            context,
            dobCntlr,
            'Date of birth (DD/MM/YYYY)',
          ),
          Spacers.sb15(),
          FormHelpers.buildTextField(
            label: "Email",
            controller: emailCntlr,
            hintText: 'email@example.com',
            regErrorText: AppConstants.emailRegError,
            regExp: Regx.emailRegExp,
          ),
          Spacers.sb15(),
          FormHelpers.buildTextField(
            label: "Phone Number",
            controller: phoneCntlr,
            hintText: '987678567',
            digit: true,
            regErrorText: AppConstants.phoneRegError,
            regExp: Regx.nineDigitRegExp,
          ),
          Spacers.sb15(),
          FormHelpers.buildTextFieldRow([
            {
              'label': 'House/Unit No',
              'controller': houseUnitCntlr,
              'hint': '110',
              'digit': true,
            },
            {
              'label': 'Street name',
              'controller': streetNameCntlr,
              'hint': 'Celebration',
              "regErrorText": AppConstants.nameRegError,
              "regExp": Regx.fullNameRegExp,
            },
          ]),
          Spacers.sb15(),
          FormHelpers.buildDropdownField(
            label: "Street Type",
            items: FormHelpers.streetTypes,
            value: selectedStreetType,
            onChanged: (value) => setState(() => selectedStreetType = value),
          ),
          Spacers.sb15(),
          FormHelpers.buildTextFieldRow([
            {
              'label': 'Suburb',
              'controller': suburbCntlr,
              'hint': 'Box Hill',
              'regErrorText': AppConstants.nameRegError,
              'regExp': Regx.fullNameRegExp,
            },
            {
              'label': 'Postcode',
              'controller': postcodeCntlr,
              'hint': '2000',
              'digit': true,
            },
          ]),
          Spacers.sb20(),
          _questionSection("Are you an Australian resident for tax purposes?", [
            "Yes",
            "No",
          ]),
          Spacers.sb20(),
          _questionSection("Are you a politically exposed person?", [
            "Yes",
            "No",
          ]),
          Spacers.sb20(),
          _questionSection("Are you applying as a sole trader?", ["Yes", "No"]),
          Spacers.sb20(),
          _buildSourcesCard(),

          Spacers.sb20(),
          ...jointHolders.map(
            (index) =>
                Column(children: [_jointHolderCard(index), Spacers.sb15()]),
          ),
        ],
      ),
    );
  }

  // ============ CORRESPONDENCE RADIO ============
  Widget buildCorrespondenceRadio({
    required String? currentValue,
    required Function(String?) onChanged,
    StateSetter? setCardState,
  }) {
    // Check if Personal Details OR any Joint Holder has selected YES
    bool hasYesSelected =
        selectedCorrespondence == 'YES' ||
        jointHolders.any((h) => h['selectedCorrespondence'] == 'YES');

    // Show correspondence only if no one has YES, or this holder has YES
    bool shouldShowCorrespondence = !hasYesSelected || currentValue == 'YES';

    if (!shouldShowCorrespondence) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormHelpers.sectionTitle(
          'Are you the person for further correspondence?',
          14,
          FontWeight.bold,
          ColorsData.blackColor,
        ),
        Spacers.sb8(),
        RadioGroup<String>(
          groupValue: currentValue,
          onChanged: (String? value) {
            if (setCardState != null) {
              // Joint Holder case
              setCardState(() {
                onChanged(value);
              });
            } else {
              // Personal Details case
              setState(() {
                onChanged(value);
              });
            }
          },
          child: Row(
            children: [
              Radio<String>(value: 'YES', activeColor: Colors.amber),
              TextWidget(
                text: 'YES',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorsData.blackColor,
              ),
              Spacers.sbw20(),
              Radio<String>(value: 'NO', activeColor: Colors.amber),
              TextWidget(
                text: 'NO',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: ColorsData.blackColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============ SOURCE OF WEALTH CARD ============
  Widget _buildSourcesCard() {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      surfaceTintColor: ColorsData.whiteColor,
      color: ColorsData.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            "Please identify the source of your assets or wealth that are used for investment purposes.",
            14,
            FontWeight.bold,
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...sources.map((source) {
                  bool isSelected = selectedSources.contains(source);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedSources.add(source);
                        } else {
                          selectedSources.remove(source);
                          // Clear the "Others" text field when unchecked
                          if (source == "Others") {
                            othersSpecifyCntlr.clear();
                          }
                        }
                      });
                    },
                    title: TextWidget(
                      text: source,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ColorsData.blackColor,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: ColorsData.blueShade,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }),

                if (selectedSources.contains("Others")) ...[
                  Spacers.sb15(),
                  FormHelpers.buildTextField(
                    label: "Other - please specify:",
                    controller: othersSpecifyCntlr,
                    hintText: 'Ex.Funds',
                    regErrorText: "",
                    regExp: Regx.fullNameRegExp,
                  ),
                ],
              ],
            ),
          ),
          Spacers.sb10(),
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
            child: SizedBox(
              height: 45.h,
              child: _buildButton(
                label: "Add Joint Holder",
                color: Color(0xfff93a0b),
                onPressed: _addJointHolder,
              ),
            ),
          ),
          Spacers.sb10(),
        ],
      ),
    );
  }

  // ============ QUESTION SECTION ============
  Widget _questionSection(String title, List<String> options) {
    String? selectedOption;
    if (title.contains("Australian resident")) {
      selectedOption = selectedAustralianResidentOption;
    } else if (title.contains("politically exposed")) {
      selectedOption = selectedPoliticallyExposedOption;
    } else if (title.contains("sole trader")) {
      selectedOption = selectedSoleTraderOption;
    }

    return _buildCardWithHeader(
      title,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacers.sb8(),
          FormHelpers.buildDropdownField(
            label: "Please select",
            items: options,
            value: selectedOption,
            onChanged: (value) {
              setState(() {
                if (title.contains("Australian resident")) {
                  selectedAustralianResidentOption = value;
                  foreignResidentOption = null;
                  noForeignResidentOption = null;
                } else if (title.contains("politically exposed")) {
                  selectedPoliticallyExposedOption = value;
                } else if (title.contains("sole trader")) {
                  selectedSoleTraderOption = value;
                }
              });
            },
          ),
          // Australian Resident YES
          if (title.contains("Australian resident") && selectedOption == "Yes")
            Column(
              children: [
                Spacers.sb15(),
                FormHelpers.buildTextField(
                  label: "Please insert your Tax File Number(TFN)",
                  controller: tfnController,
                  hintText: '245432456756',
                  digit: true,
                ),
              ],
            ),
          // Australian Resident NO
          if (title.contains("Australian resident") && selectedOption == "No")
            Column(
              children: [
                Spacers.sb15(),
                FormHelpers.buildDropdownField(
                  label: "Are you a foreign resident for tax purposes?",
                  items: ["Yes", "No"],
                  value: foreignResidentOption,
                  onChanged: (value) {
                    setState(() {
                      foreignResidentOption = value;
                      noForeignResidentOption = null;
                    });
                  },
                ),
                if (foreignResidentOption == "Yes")
                  Column(
                    children: [
                      Spacers.sb15(),
                      FormHelpers.buildTextFieldRow([
                        {
                          'label': 'Country',
                          'controller': countryController,
                          'hint': 'Australia',
                          'regErrorText': AppConstants.nameRegError,
                          'regExp': Regx.fullNameRegExp,
                        },
                        {
                          'label': 'TIN',
                          'controller': tinController,
                          'hint': '345676548765',
                          'digit': true,
                        },
                      ]),
                    ],
                  ),
                if (foreignResidentOption == "No")
                  Column(
                    children: [
                      Spacers.sb15(),
                      FormHelpers.buildDropdownField(
                        label: "If No please select one of the following",
                        items: [
                          "The country of tax residency does not issue TINs",
                          "I have not been issued with a TIN",
                          "The country of tax residency does not require the TIN to be disclosed",
                        ],
                        value: noForeignResidentOption,
                        onChanged: (value) =>
                            setState(() => noForeignResidentOption = value),
                      ),
                    ],
                  ),
              ],
            ),
          // Sole Trader YES
          if (title.contains("sole trader") && selectedOption == "Yes")
            Column(
              children: [
                Spacers.sb15(),
                FormHelpers.buildTextField(
                  label: "Business name",
                  controller: businessNameController,
                  hintText: 'IT Solutions',
                  regErrorText: AppConstants.nameRegError,
                  regExp: Regx.fullNameRegExp,
                ),
                Spacers.sb15(),
                FormHelpers.buildTextFieldRow([
                  {
                    'label': 'House/Unit no',
                    'controller': soleTraderHouseUnitController,
                    'hint': '110/412',
                    'digit': true,
                  },
                  {
                    'label': 'Street name',
                    'controller': soleTraderStreetNameController,
                    'hint': 'Celebration',
                    'regErrorText': AppConstants.nameRegError,
                    'regExp': Regx.fullNameRegExp,
                  },
                ]),
                Spacers.sb15(),
                FormHelpers.buildDropdownField(
                  label: "Street type",
                  items: FormHelpers.streetTypes,
                  value: soleTraderStreetType,
                  onChanged: (value) =>
                      setState(() => soleTraderStreetType = value),
                ),
                Spacers.sb15(),
                FormHelpers.buildTextField(
                  label: "Suburb",
                  controller: soleTraderSuburbController,
                  hintText: 'Box Hill',
                  regErrorText: AppConstants.nameRegError,
                  regExp: Regx.fullNameRegExp,
                ),
                Spacers.sb15(),
                FormHelpers.buildDropdownField(
                  label: "State",
                  items: ["NSW", "VIC", "QLD", "SA", "WA", "TAS", "NT", "ACT"],
                  value: soleTraderState,
                  onChanged: (value) => setState(() => soleTraderState = value),
                ),
                Spacers.sb15(),
                FormHelpers.buildTextField(
                  label: "Postcode",
                  controller: soleTraderPostcodeController,
                  hintText: '4112',
                  digit: true,
                ),
                Spacers.sb15(),
                FormHelpers.buildTextField(
                  label: "ABN",
                  controller: abnController,
                  hintText: 'Enter ABN',
                  digit: true,
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ============ JOINT HOLDER CARD ============
  Widget _jointHolderCard(Map<String, dynamic> holder) {
    int index = holder['holderNumber'];
    return Card(
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      margin: EdgeInsets.only(bottom: 15.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 54.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: ColorsData.blueShade,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: "Joint Holder: $index",
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () {
                    int index = jointHolders.indexOf(holder);
                    if (index != -1) {
                      _removeJointHolder(index);
                    }
                  },
                  icon: Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: StatefulBuilder(
              builder: (context, setCardState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacers.sb15(),
                    buildCorrespondenceRadio(
                      currentValue: holder['selectedCorrespondence'],
                      onChanged: (value) {
                        if (value == 'YES') {
                          selectedCorrespondence = null;
                          for (int i = 0; i < jointHolders.length; i++) {
                            jointHolders[i]['selectedCorrespondence'] = null;
                          }
                          holder['selectedCorrespondence'] = 'YES';
                        } else {
                          holder['selectedCorrespondence'] = value!;
                        }
                      },
                      setCardState: setCardState,
                    ),
                    Spacers.sb15(),
                    FormHelpers.buildDropdownField(
                      label: "Title",
                      items: FormHelpers.titles,
                      value: holder['selectedTitle'],
                      onChanged: (value) =>
                          setCardState(() => holder['selectedTitle'] = value),
                    ),
                    Spacers.sb15(),
                    FormHelpers.buildTextFieldRow([
                      {
                        'label': 'First name',
                        'controller': holder['firstNameCtrl'],
                        'hint': 'John',
                        'regErrorText': AppConstants.nameRegError,
                        'regExp': Regx.nameRegExp,
                      },
                      {
                        'label': 'Middle name',
                        'controller': holder['middleNameCtrl'],
                        'hint': 'Reco',
                        'regErrorText': AppConstants.nameRegError,
                        'regExp': Regx.nameRegExp,
                      },
                    ]),
                    Spacers.sb15(),
                    FormHelpers.buildTextField(
                      label: "Surname",
                      controller: holder['surnameCtrl'],
                      hintText: 'Brown',
                      regErrorText: AppConstants.nameRegError,
                      regExp: Regx.nameRegExp,
                    ),
                    Spacers.sb15(),
                    FormHelpers.sectionTitle(
                      'Date of birth (DD/MM/YYYY)',
                      14,
                      FontWeight.bold,
                      ColorsData.blackColor,
                    ),
                    Spacers.sb8(),
                    FormHelpers.buildDatePickerField(
                      context,
                      holder['dobCtrl'],
                      "DD/MM/YYYY",
                    ),
                    Spacers.sb15(),
                    FormHelpers.buildTextField(
                      label: "Email",
                      controller: holder['emailCtrl'],
                      hintText: 'email@example.com',
                      regErrorText: AppConstants.emailRegError,
                      regExp: Regx.emailRegExp,
                    ),
                    Spacers.sb15(),
                    FormHelpers.buildTextFieldRow([
                      {
                        'label': 'Phone number',
                        'controller': holder['phoneCtrl'],
                        'hint': '987678567',
                        'digit': true,
                        'regErrorText': AppConstants.phoneRegError,
                        'regExp': Regx.nineDigitRegExp,
                      },
                      {
                        'label': 'House/Unit no',
                        'controller': holder['houseUnitCtrl'],
                        'hint': '110/412',
                        'digit': true,
                      },
                    ]),
                    Spacers.sb15(),
                    FormHelpers.buildTextField(
                      label: "Street name",
                      controller: holder['streetNameCtrl'],
                      hintText: 'Celebration',
                      regErrorText: AppConstants.nameRegError,
                      regExp: Regx.fullNameRegExp,
                    ),
                    Spacers.sb15(),
                    FormHelpers.buildDropdownField(
                      label: "Street type",
                      items: FormHelpers.streetTypes,
                      value: holder['selectedStreetType'],
                      onChanged: (value) => setCardState(
                        () => holder['selectedStreetType'] = value,
                      ),
                    ),
                    Spacers.sb15(),
                    FormHelpers.buildTextFieldRow([
                      {
                        'label': 'Suburb',
                        'controller': holder['suburbCtrl'],
                        'hint': 'Box Hill',
                        'regErrorText': AppConstants.nameRegError,
                        'regExp': Regx.fullNameRegExp,
                      },
                      {
                        'label': 'Postcode',
                        'controller': holder['postcodeCtrl'],
                        'hint': '2000',
                        'digit': true,
                      },
                    ]),
                    Spacers.sb15(),
                    FormHelpers.buildDropdownField(
                      label: "State",
                      items: [
                        "NSW",
                        "VIC",
                        "QLD",
                        "SA",
                        "WA",
                        "TAS",
                        "NT",
                        "ACT",
                      ],
                      value: holder['selectedState'],
                      onChanged: (value) =>
                          setCardState(() => holder['selectedState'] = value),
                    ),

                    // ===== AUSTRALIAN RESIDENT QUESTION =====
                    Spacers.sb20(),
                    _questionSectionForJoint(
                      title: "Are you an Australian resident for tax purposes?",
                      options: ["Yes", "No"],
                      selectedOption:
                          holder['selectedAustralianResidentOption'],
                      onChanged: (value) {
                        setCardState(() {
                          holder['selectedAustralianResidentOption'] = value;
                          holder['jointForeignResidentOption'] = null;
                          holder['jointNoForeignResidentOption'] = null;
                        });
                      },
                      setCardState: setCardState,
                      holder: holder,
                      // YES - Show TFN field
                      yesContent: FormHelpers.buildTextField(
                        label: "Please insert your Tax File Number(TFN)",
                        controller: holder['jointTfnController'],
                        hintText: '245432456756',
                        digit: true,
                      ),
                      // NO - Show foreign resident dropdown
                      noContent: Column(
                        children: [
                          FormHelpers.buildDropdownField(
                            label:
                                "Are you a foreign resident for tax purposes?",
                            items: ["Yes", "No"],
                            value: holder['jointForeignResidentOption'],
                            onChanged: (value) {
                              setCardState(() {
                                holder['jointForeignResidentOption'] = value;
                                holder['jointNoForeignResidentOption'] = null;
                              });
                            },
                          ),
                          if (holder['jointForeignResidentOption'] == "Yes")
                            Column(
                              children: [
                                Spacers.sb15(),
                                FormHelpers.buildTextFieldRow([
                                  {
                                    'label': 'Country',
                                    'controller':
                                        holder['jointCountryController'],
                                    'hint': 'Australia',
                                    'regErrorText': AppConstants.nameRegError,
                                    'regExp': Regx.fullNameRegExp,
                                  },
                                  {
                                    'label': 'TIN',
                                    'controller': holder['jointTinController'],
                                    'hint': '345676548765',
                                    'digit': true,
                                    'regErrorText': AppConstants.phoneRegError,
                                    'regExp': Regx.nineDigitRegExp,
                                  },
                                ]),
                              ],
                            ),
                          if (holder['jointForeignResidentOption'] == "No")
                            Column(
                              children: [
                                Spacers.sb15(),
                                FormHelpers.buildDropdownField(
                                  label:
                                      "If No please select one of the following",
                                  items: [
                                    "The country of tax residency does not issue TINs",
                                    "I have not been issued with a TIN",
                                    "The country of tax residency does not require the TIN to be disclosed",
                                  ],
                                  value: holder['jointNoForeignResidentOption'],
                                  onChanged: (value) => setCardState(
                                    () =>
                                        holder['jointNoForeignResidentOption'] =
                                            value,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),

                    // ===== POLITICALLY EXPOSED QUESTION =====
                    Spacers.sb20(),
                    _questionSectionForJoint(
                      title: "Are you a politically exposed person?",
                      options: ["Yes", "No"],
                      selectedOption:
                          holder['selectedPoliticallyExposedOption'],
                      onChanged: (value) {
                        setCardState(() {
                          holder['selectedPoliticallyExposedOption'] = value;
                        });
                      },
                      setCardState: setCardState,
                      holder: holder,
                    ),

                    Spacers.sb20(),
                    _buildSourcesCardForJoint(
                      holder['selectedSources'],
                      setCardState,
                      holder['othersCtrl'],
                    ),
                    Spacers.sb20(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 45.h,
                            child: _buildButton(
                              label: "Remove",
                              color: Colors.red,
                              onPressed: () {
                                int index = jointHolders.indexOf(holder);
                                // if (index != -1) {
                                _removeJointHolder(index);
                                // }
                              },
                            ),
                          ),
                        ),
                        Spacers.sbw10(),
                        Expanded(
                          child: SizedBox(
                            height: 45.h,
                            child: _buildButton(
                              label: "Add Joint Holder",
                              color: Colors.deepOrange,
                              onPressed: _addJointHolder,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Spacers.sb10(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============ CORRESPONDENCE RADIO FOR JOINT HOLDER ============

  // ============ QUESTION SECTION FOR JOINT HOLDER ============
  Widget _questionSectionForJoint({
    required String title,
    required List<String> options,
    required String? selectedOption,
    required Function(String?) onChanged,
    required StateSetter setCardState,
    required Map<String, dynamic> holder,
    Widget? yesContent,
    Widget? noContent,
  }) {
    return _buildCardWithHeader(
      title,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacers.sb8(),
          FormHelpers.buildDropdownField(
            label: "Please select",
            items: options,
            value: selectedOption,
            onChanged: onChanged,
          ),
          if (selectedOption == "Yes" && yesContent != null)
            Column(children: [Spacers.sb15(), yesContent]),
          if (selectedOption == "No" && noContent != null)
            Column(children: [Spacers.sb15(), noContent]),
        ],
      ),
    );
  }

  // ============ SOURCE CARD FOR JOINT HOLDER ============
  Widget _buildSourcesCardForJoint(
    List<String> selectedJointSources,
    StateSetter setCardState,
    TextEditingController othersCtrl,
  ) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      surfaceTintColor: ColorsData.whiteColor,
      color: ColorsData.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(
            "Please identify the source of your assets or wealth that are used for investment purposes.",
            14,
            FontWeight.bold,
          ),
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...sources.map((source) {
                  bool isSelected = selectedJointSources.contains(source);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setCardState(() {
                        if (value == true) {
                          selectedJointSources.add(source);
                        } else {
                          selectedJointSources.remove(source);
                          if (source == "Others") {
                            othersCtrl.clear();
                          }
                        }
                      });
                    },
                    title: TextWidget(
                      text: source,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ColorsData.blackColor,
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: ColorsData.blueShade,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  );
                }),

                if (selectedJointSources.contains("Others")) ...[
                  Spacers.sb15(),
                  FormHelpers.buildTextField(
                    label: "Other - please specify:",
                    controller: othersCtrl,
                    hintText: 'Ex.Funds',
                    regErrorText: "",
                    regExp: Regx.fullNameRegExp,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget identificationRequirementsCard() {
    return FormHelpers.buildCardWithHeader(
      "Individual Identification Applicant 1",
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Spacers.sb10(),
          // Main identification option dropdown
          FormHelpers.buildDropdownField(
            label: "Please select",
            items: identificationOptions,
            value: selectedIdentificationOption,
            onChanged: (value) => setState(() {
              selectedIdentificationOption = value;
              // Reset dependent fields when option changes
              selectedPrimaryDocument = null;
              selectedCategoryA = null;
              selectedCategoryB = null;
              uploadedFiles['primary'] = [];
              uploadedFiles['categoryA'] = [];
              uploadedFiles['categoryB'] = [];
            }),
          ),
          Spacers.sb20(),

          // ===== OPTION 1: Show Single Primary Document Dropdown =====
          if (selectedIdentificationOption == identificationOptions[0])
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySection(
                  title: "Choose one primary identification document",
                  documents: primaryDocuments,
                  selectedValue: selectedPrimaryDocument,
                  onChanged: (value) =>
                      setState(() => selectedPrimaryDocument = value),
                  documentKey: 'primary',
                ),
                Spacers.sb20(),
              ],
            ),

          // ===== OPTION 2: Show Category A & B Dropdowns =====
          if (selectedIdentificationOption == identificationOptions[1])
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySection(
                  title: "Category A - Select one document",
                  documents: categoryADocuments,
                  selectedValue: selectedCategoryA,
                  onChanged: (value) =>
                      setState(() => selectedCategoryA = value),
                  documentKey: 'categoryA',
                ),
                Spacers.sb20(),
                _buildCategorySection(
                  title: "Category B - One document",
                  documents: categoryBDocuments,
                  selectedValue: selectedCategoryB,
                  onChanged: (value) =>
                      setState(() => selectedCategoryB = value),
                  documentKey: 'categoryB',
                ),
                Spacers.sb20(),
              ],
            ),
        ],
      ),
    );
  }

  // ============ CATEGORY SECTION WIDGET ============
  Widget _buildCategorySection({
    required String title,
    required List<String> documents,
    required String? selectedValue,
    required Function(String?) onChanged,
    required String documentKey,
  }) {
    return Card(
      elevation: 2,
      color: ColorsData.whiteColor,
      surfaceTintColor: ColorsData.whiteColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text: title,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ColorsData.blackColor,
                ),
                FormHelpers.buildDropdownField(
                  label: "",
                  items: documents,
                  value: selectedValue,
                  onChanged: onChanged,
                ),
                Spacers.sb15(),
                FormHelpers.sectionTitle(
                  "Select the files",
                  13,
                  FontWeight.w700,
                  ColorsData.blackColor,
                ),
                Spacers.sb8(),

                // FIXED: Use FormHelpers.buildFileUploadBox with async/await
                FormHelpers.buildFileUploadBox(
                  onTap: () async {
                    final List<String>? files = await FormHelpers.pickFiles();
                    if (files != null && files.isNotEmpty) {
                      setState(() {
                        uploadedFiles[documentKey] = [
                          ...(uploadedFiles[documentKey] ?? []),
                          ...files,
                        ];
                      });
                    }
                  },
                  filesCount: uploadedFiles[documentKey]?.length ?? 0,
                  documentKey: documentKey,
                ),

                if ((uploadedFiles[documentKey]?.length ?? 0) == 0)
                  Spacers.sb8(),

                // Display uploaded files with thumbnails
                if ((uploadedFiles[documentKey]?.length ?? 0) > 0)
                  Column(
                    children: [
                      Spacers.sb10(),
                      ...(uploadedFiles[documentKey] ?? []).map((file) {
                        return Column(
                          children: [
                            Spacers.sb5(),
                            // FIXED: Use FormHelpers.buildDocumentDisplayWidget with callback
                            FormHelpers.buildDocumentDisplayWidget(
                              context,
                              documentKey,
                              file,
                              (fileName) {
                                setState(() {
                                  uploadedFiles[documentKey]?.remove(fileName);
                                });
                              },
                            ),
                            Spacers.sb8(),
                          ],
                        );
                      }),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ REUSABLE: BUTTON ============
  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 18.sp) : SizedBox.shrink(),
      label: TextWidget(
        text: label,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: ColorsData.whiteColor,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  // ============ NAVIGATION BUTTONS WITH FULL VALIDATION ============
  Widget _buildNavigationButtons() {
    double buttonWidth = 140.w;
    double buttonHeight = 45.h;
    bool isFirstStep = currentStep == 0;
    bool isDeclarationStep = currentStep == 3;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (!isFirstStep)
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: _buildButton(
                    label: "Back",
                    icon: Icons.arrow_back,
                    color: Colors.cyan,
                    onPressed: () {
                      setState(() {
                        currentStep--;
                      });

                      _scrollToTop();
                    },
                  ),
                )
              else
                SizedBox(width: buttonWidth),

              if (isDeclarationStep)
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: _buildButton(
                    label: "Submit",
                    icon: Icons.check,
                    color: Colors.green.shade700,
                    onPressed: () {
                      if (!_declarationFormKey.currentState!.validate()) {
                        showToast(
                          message: "Please fill in all required fields",
                        );
                        return;
                      }

                      // 2. Validate ALL directors have signed
                      bool allSigned = true;
                      for (int i = 0; i < signatureImages.length; i++) {
                        if (signatureImages[i] == null) {
                          allSigned = false;
                          break;
                        }
                      }

                      if (!allSigned) {
                        showToast(message: "All must sign before submission");
                        return;
                      }

                      // 3. If all validations pass
                      showToast(message: "Application submitted successfully!");
                    },
                  ),
                )
              else
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: _buildButton(
                    label: "Next",
                    icon: Icons.arrow_forward,
                    color: Colors.indigo,
                    onPressed: () {
                      bool isValid = false;

                      if (currentStep == 0) {
                        isValid = _personalDetailsFormKey.currentState!
                            .validate();
                        if (isValid && selectedSources.isEmpty) {
                          isValid = false;
                          showToast(
                            message:
                                "Please select at least one source of wealth",
                          );
                        }
                        if (isValid &&
                            selectedSources.contains("Others") &&
                            othersSpecifyCntlr.text.trim().isEmpty) {
                          isValid = false;
                          showToast(
                            message: "Please specify other source of wealth",
                          );
                        }
                      } else if (currentStep == 1) {
                        isValid = _bankFormKey.currentState!.validate();
                      } else if (currentStep == 2) {
                        isValid = _identificationFormKey.currentState!
                            .validate();

                        if (isValid && selectedIdentificationOption == null) {
                          isValid = false;
                          showToast(
                            message: "Please select an identification option",
                          );
                        }

                        if (isValid &&
                            selectedIdentificationOption ==
                                identificationOptions[0]) {
                          if (selectedPrimaryDocument == null) {
                            isValid = false;
                            showToast(
                              message: "Please select a primary document",
                            );
                          } else if (uploadedFiles['primary']?.isEmpty ??
                              true) {
                            isValid = false;
                            showToast(
                              message: "Please upload the primary document",
                            );
                          }
                        }

                        if (isValid &&
                            selectedIdentificationOption ==
                                identificationOptions[1]) {
                          if (selectedCategoryA == null ||
                              selectedCategoryB == null) {
                            isValid = false;
                            showToast(
                              message:
                                  "Please select documents from both Category A and B",
                            );
                          } else if ((uploadedFiles['categoryA']?.isEmpty ??
                                  true) ||
                              (uploadedFiles['categoryB']?.isEmpty ?? true)) {
                            isValid = false;
                            showToast(
                              message:
                                  "Please upload documents for both categories",
                            );
                          }
                        }
                      }

                      if (isValid) {
                        setState(() {
                          currentStep++;
                        });
                        _scrollToTop();
                      }
                    },
                  ),
                ),
            ],
          ),

          Spacers.sb15(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (currentStep == 0 || currentStep == 1)
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: _buildButton(
                    label: "Reset",
                    color: ColorsData.greyColor,
                    onPressed: () {
                      setState(() {
                        if (currentStep == 0) {
                          // Reset Personal Details
                          firstNameCntlr.clear();
                          middleNameCntlr.clear();
                          surnameCntlr.clear();
                          dobCntlr.clear();
                          emailCntlr.clear();
                          phoneCntlr.clear();
                          houseUnitCntlr.clear();
                          streetNameCntlr.clear();
                          suburbCntlr.clear();
                          postcodeCntlr.clear();
                          selectedTitle = null;
                          selectedStreetType = null;
                          selectedSources.clear();
                          selectedAustralianResidentOption = null;
                          selectedPoliticallyExposedOption = null;
                          selectedSoleTraderOption = null;
                          tfnController.clear();
                          countryController.clear();
                          tinController.clear();
                          jointHolders.clear();
                        } else if (currentStep == 1) {
                          // Reset Bank Details
                          financialInstCntlr.clear();
                          accountNameCntlr.clear();
                          bsbCntlr.clear();
                          accountNumberCntlr.clear();
                          selectedReinvest = null;
                        }
                      });
                      showToast(message: "Form reset successfully!");
                    },
                  ),
                )
              else
                SizedBox(width: buttonWidth),

              SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: _buildButton(
                  label: "Save Draft",
                  color: const Color(0xff20c997),
                  onPressed: () {
                    showToast(message: "Draft saved successfully!");
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============ HELPER METHODS ============

  void _showSignatureDialog(int index) async {
    final Uint8List? data = await SignatureDialog.show(
      context,
      signatureControllers[index],
    );

    if (data != null) {
      setState(() {
        signatureImages[index] = data;
      });
    }
  }

  // ============ DECLARATION CARD ============
  Widget declarationCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCardWithHeader(
          "I/We declare and/or acknowledge and agree that:",
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacers.sb15(),

              FormHelpers.buildDeclarationBullet(
                "I/we have received this Application Form attached to, or accompanied by, the PDS and SPDS;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "I/we have read the PDS and SPDS, and have received and accepted the offer in it in Australia;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "I/we have read the FSG, TMD and Brochure and have received and accepted the offer in it in Australia;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "if I/we do not provide all or part of the information required by the Application Form, the Responsible Entity will not be able to accept my/our application and I/we will not be able to acquire units;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "I/we are bound by the provisions of the Constitution of the Fund as amended from time to time;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "I/we have legal power to invest;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "I/we represent and warrant that I/we am/are a wholesale client within the meaning of section 761G of the Corporations Act 2001 (Cth);",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "my/our application is not a result of an unsolicited meeting with or telephone call from another person",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "I/we understand the risks of subscribing for the units;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "I/we understand that an investment in the Fund is subject to investment risks including possible delays in repayment and possible loss of income or capital invested;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "an investment in the Fund or the acquisition of units does not represent an investment in or a deposit or other liability of the Responsible Entity or its related entities;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "I/we have relied on my/our own independent investigation, enquiries and appraisals, and have obtained or have had the opportunity to obtain legal, accounting, tax and financial advice, in connection with the Fund before deciding to subscribe for units;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "I/we have all regulatory approvals required in Australia and any other relevant jurisdiction to hold units and become a unit holder of the Fund;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "the Responsible Entity may be required to collect and verify certain information from me/us to facilitate the Responsible Entity's compliance with Australian anti-money laundering and counter-terrorism financing legislation, and that under this legislation the Responsible Entity may be required to conduct on-going customer due diligence in respect of, and collect further information in relation to, me/us whilst I/we am/are a unit holder of the Fund;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "if this Application Form is signed under power of attorney, I/we have no knowledge of the revocation of that power of attorney;",
              ),

              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "if this is a joint application, each of us is able to operate our investment in the Fund and is able to bind the other(s) to any transaction including investments, switches or withdrawals by any available method;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "my/our personal information will be collected, used and disclosed on terms described in the PDS and SPDS;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "I/we authorise the Responsible Entity to give information relating to my/our account and investment in that account to my/our adviser;",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "I/we will provide the Responsible Entity or its nominees any information that the Responsible Entity reasonably requires in order to enable the Responsible Entity to meet its compliance, reporting and other obligations under the USA's Foreign Account Tax Compliance Act and all associated rules and regulations from time to time (including, without limitation, the Inter-Governmental Agreement (IGA) entered into between the governments of the USA and Australia), and that the Responsible Entity or its agents may disclose such information to the Australian Taxation Office who may in turn disclose the information to the Internal Revenue Service of the USA; and",
              ),
              Spacers.sb10(),

              FormHelpers.buildDeclarationBullet(
                "if I/we have provided us or our nominee with information about my/our status or designation under or for the purposes of FATCA (including, but without limitation, USA residency or citizenship status and FATCA status as a particular entity type) and all associated rules and regulations, such information is true and correct and the Responsible Entity will treat such information as true and correct without any additional validation or confirmation being undertaken by the Responsible Entity except where it has a legal obligation to do so.",
              ),

              Spacers.sb20(),
            ],
          ),
        ),

        Spacers.sb20(),

        // ============ SIGNATURE SECTION ============
        ...signatures.asMap().entries.map((entry) {
          int index = entry.key;
          var signature = entry.value;
          String holderLabel = index == 0
              ? "Primary Holder Signature"
              : "Joint Holder $index Signature";

          return Column(
            children: [
              Card(
                elevation: 2,
                color: ColorsData.whiteColor,
                surfaceTintColor: ColorsData.whiteColor,
                child: Column(
                  children: [
                    _buildCardHeader(holderLabel, 14, FontWeight.bold),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 15.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🖊️ DIGITAL SIGNATURE SECTION
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: "Digital Signature",
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ColorsData.blackColor,
                              ),
                              Spacers.sb8(),
                              GestureDetector(
                                onTap: () => _showSignatureDialog(index),
                                child: Container(
                                  height: 180.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: signatureImages[index] != null
                                        ? Colors.grey.shade50
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: signatureImages[index] != null
                                          ? Colors.green.shade400
                                          : Colors.grey.shade400,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: signatureImages[index] != null
                                      ? Stack(
                                          children: [
                                            Center(
                                              child: Padding(
                                                padding: EdgeInsets.all(16.w),
                                                child: Image.memory(
                                                  signatureImages[index]!,
                                                  fit: BoxFit.contain,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 8.h,
                                              right: 8.w,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 8.w,
                                                  vertical: 4.h,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green.shade600,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        12.r,
                                                      ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.check,
                                                      color: Colors.white,
                                                      size: 12.sp,
                                                    ),
                                                    SizedBox(width: 4.w),
                                                    TextWidget(
                                                      text: "Signed",
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.edit_outlined,
                                                size: 32.sp,
                                                color: Colors.grey.shade400,
                                              ),
                                              Spacers.sb8(),
                                              TextWidget(
                                                text: "Tap to Sign",
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey.shade700,
                                              ),
                                            ],
                                          ),
                                        ),
                                ),
                              ),
                              if (signatureImages[index] != null)
                                Padding(
                                  padding: EdgeInsets.only(top: 8.h),
                                  child: TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        signatureImages[index] = null;
                                        signatureControllers[index].clear();
                                      });
                                    },
                                    icon: Icon(
                                      Icons.close,
                                      size: 14.sp,
                                      color: Colors.red.shade600,
                                    ),
                                    label: TextWidget(
                                      text: "Clear",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red.shade600,
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Spacers.sb20(),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: TextWidget(
                                  text: "OR",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              Expanded(
                                child: Divider(color: Colors.grey.shade300),
                              ),
                            ],
                          ),

                          Spacers.sb20(),

                          // 📱 QR CODE SECTION
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: "Sign via QR Code",
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: ColorsData.blackColor,
                              ),
                              Spacers.sb8(),
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    TextWidget(
                                      text:
                                          "Scan to sign on your mobile device",
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade700,
                                      textAlign: TextAlign.center,
                                    ),
                                    Spacers.sb10(),
                                    Container(
                                      width: 120.w,
                                      height: 120.h,
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                        border: Border.all(
                                          color: Colors.grey.shade300,
                                          width: 1,
                                        ),
                                      ),
                                      child: ImageWidget(
                                        image:
                                            'https://api.qrserver.com/v1/create-qr-code/?size=120x120&data=SignatureUpload',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    Spacers.sb10(),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          showToast(
                                            message:
                                                "Signature retrieved from QR scan",
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xff20c997,
                                          ),
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12.h,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              6.r,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: TextWidget(
                                          text: "Done",
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Spacers.sb8(),
                                    TextWidget(
                                      text:
                                          "Click Done after scanning and uploading",
                                      fontSize: 10,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade600,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          Spacers.sb30(),

                          // ============ FORM FIELDS ============
                          FormHelpers.sectionTitle(
                            "Signed, sealed and delivered by:",
                            14,
                            FontWeight.bold,
                            ColorsData.blackColor,
                          ),
                          Spacers.sb15(),
                          // Additional signature fields (title, designation, name, date)
                          FormHelpers.buildTextField(
                            label: "Title",
                            controller: signature['titleCntlr'],
                            hintText: 'Mr./Mrs./Ms.',
                            regErrorText: AppConstants.nameRegError,
                            regExp: Regx.nameRegExp,
                          ),
                          Spacers.sb15(),

                          FormHelpers.buildDropdownField(
                            label: "Designation",
                            items: ["Director", "Trustee", "Member", "Other"],
                            value: signature['designationDropdownValue'],
                            onChanged: (value) {
                              setState(() {
                                signature['designationDropdownValue'] = value;
                              });
                            },
                          ),
                          Spacers.sb15(),

                          FormHelpers.buildTextField(
                            label: "Name",
                            controller: signature['nameCntlr'],
                            hintText: 'Full Name',
                            regErrorText: AppConstants.nameRegError,
                            regExp: Regx.fullNameRegExp,
                          ),
                          Spacers.sb15(),

                          FormHelpers.buildTextField(
                            label: "Date",
                            controller: signature['dateCntlr'],
                            hintText: '',
                            readOnly: true,
                          ),
                          Spacers.sb25(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Spacers.sb20(),
            ],
          );
        }),
      ],
    );
  }
}
