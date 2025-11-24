import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
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

class UnregulatedTrustIndividualForm extends StatefulWidget {
  final ScrollController? scrollController;
  const UnregulatedTrustIndividualForm({super.key, this.scrollController});

  @override
  State<UnregulatedTrustIndividualForm> createState() =>
      _UnregulatedTrustIndividualFormState();
}

class _UnregulatedTrustIndividualFormState
    extends State<UnregulatedTrustIndividualForm> {
  final _trustFormKey = GlobalKey<FormState>();
  final _beneficialOwnershipFormKey = GlobalKey<FormState>();
  final _bankFormKey = GlobalKey<FormState>();
  final _identificationFormKey = GlobalKey<FormState>();
  final _declarationFormKey = GlobalKey<FormState>();
  int currentStep = 0;

  // Trust Details Controllers
  final trustNameCntlr = TextEditingController();
  final businessNameCntlr = TextEditingController();
  final abnTfnCntlr = TextEditingController();
  final trustTypeCntlr = TextEditingController();
  final countryCntlr = TextEditingController();

  // AUSTRALIAN RESIDENT TAX SECTION
  String? selectedAustralianResidentOption;
  final tfnController = TextEditingController();
  String? foreignResidentOption;
  final countryController = TextEditingController();
  final tinController = TextEditingController();
  String? noForeignResidentOption;

  List<String> selectedSources = [];
  final othersSpecifyCntlr = TextEditingController();

  // Bank Detail Controllers
  final financialInstitutionCntlr = TextEditingController();
  final accountNameCntlr = TextEditingController();
  final bsbCntlr = TextEditingController();
  final accountNumberCntlr = TextEditingController();
  String? incomeDistributionOption;

  // ============ SIGNATURES SECTION ============
  List<Map<String, dynamic>> signatures = [];
  List<SignatureController> signatureControllers = [];
  List<Uint8List?> signatureImages = [];

  // Identification Requirements
  String? selectedIdentificationOption;
  Map<String, List<String>> uploadedFiles = {'identification': []};

  final List<Map<String, String>> identificationOptions = [
    {
      'value': 'trust_deed',
      'label': 'An original certified copy or extract of the trust deed',
    },
    {
      'value': 'solicitor_letter',
      'label':
          'A letter from a solicitor or qualified accountant that confirms the name of the trust and settlor (if relevant)',
    },
    {
      'value': 'bank_statement',
      'label':
          'An original bank statement in the name of the trust issued within the last 12 months',
    },
  ];

  // TRUSTEE SECTION - DYNAMIC
  List<Map<String, dynamic>> trustees = [];
  int trusteeCount = 0;

  // BENEFICIAL OWNERSHIP SECTION - DYNAMIC
  List<Map<String, dynamic>> beneficialOwners = [];
  int beneficialOwnerCount = 0;

  // DECISION MAKER SECTION - DYNAMIC
  List<Map<String, dynamic>> decisionMakers = [];
  int decisionMakerCount = 0;

  @override
  void initState() {
    super.initState();
    _addNewTrustee();
    _addNewBeneficialOwner();
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    return DateFormat('E MMM d y').format(now);
  }

  bool _validateUpToStep(int targetStep) {
    if (targetStep >= 1) {
      if (!_trustFormKey.currentState!.validate()) {
        return false;
      }
      if (selectedSources.isEmpty) {
        showToast(message: "Please select at least one source of wealth");
        return false;
      }
      if (selectedSources.contains("Others") &&
          othersSpecifyCntlr.text.isEmpty) {
        showToast(message: "Please specify other source of wealth");
        return false;
      }
    }
    if (targetStep >= 2) {
      if (!_beneficialOwnershipFormKey.currentState!.validate()) {
        return false;
      }
    }
    if (targetStep >= 3) {
      if (!_bankFormKey.currentState!.validate()) {
        return false;
      }
    }
    if (targetStep >= 4) {
      if (!_identificationFormKey.currentState!.validate()) {
        return false;
      }
    }
    return true;
  }

  @override
  void dispose() {
    trustNameCntlr.dispose();
    businessNameCntlr.dispose();
    abnTfnCntlr.dispose();
    trustTypeCntlr.dispose();
    countryCntlr.dispose();
    tfnController.dispose();
    countryController.dispose();
    tinController.dispose();
    othersSpecifyCntlr.dispose();
    financialInstitutionCntlr.dispose();
    accountNameCntlr.dispose();
    bsbCntlr.dispose();
    accountNumberCntlr.dispose();
    for (var controller in signatureControllers) {
      controller.dispose();
    }

    // Dispose signature data controllers
    for (var signature in signatures) {
      (signature['titleCntlr'] as TextEditingController).dispose();
      (signature['designationCntlr'] as TextEditingController).dispose();
      (signature['nameCntlr'] as TextEditingController).dispose();
      (signature['dateCntlr'] as TextEditingController).dispose();
    }

    for (var trustee in trustees) {
      (trustee['firstName'] as TextEditingController).dispose();
      (trustee['middleName'] as TextEditingController).dispose();
      (trustee['surname'] as TextEditingController).dispose();
      (trustee['dob'] as TextEditingController).dispose();
      (trustee['email'] as TextEditingController).dispose();
      (trustee['phone'] as TextEditingController).dispose();
      (trustee['houseUnit'] as TextEditingController).dispose();
      (trustee['streetName'] as TextEditingController).dispose();
      (trustee['suburb'] as TextEditingController).dispose();
      (trustee['postcode'] as TextEditingController).dispose();
    }

    for (var owner in beneficialOwners) {
      (owner['firstName'] as TextEditingController).dispose();
      (owner['middleName'] as TextEditingController).dispose();
      (owner['surname'] as TextEditingController).dispose();
      (owner['dob'] as TextEditingController).dispose();
      (owner['email'] as TextEditingController).dispose();
      (owner['phone'] as TextEditingController).dispose();
      (owner['houseUnit'] as TextEditingController).dispose();
      (owner['streetName'] as TextEditingController).dispose();
      (owner['suburb'] as TextEditingController).dispose();
      (owner['postcode'] as TextEditingController).dispose();
      (owner['tfnController'] as TextEditingController).dispose();
      (owner['countryController'] as TextEditingController).dispose();
      (owner['tinController'] as TextEditingController).dispose();
    }

    for (var maker in decisionMakers) {
      (maker['firstName'] as TextEditingController).dispose();
      (maker['middleName'] as TextEditingController).dispose();
      (maker['surname'] as TextEditingController).dispose();
      (maker['dob'] as TextEditingController).dispose();
      (maker['email'] as TextEditingController).dispose();
      (maker['phone'] as TextEditingController).dispose();
      (maker['houseUnit'] as TextEditingController).dispose();
      (maker['streetName'] as TextEditingController).dispose();
      (maker['suburb'] as TextEditingController).dispose();
      (maker['postcode'] as TextEditingController).dispose();
      (maker['tfnController'] as TextEditingController).dispose();
      (maker['countryController'] as TextEditingController).dispose();
      (maker['tinController'] as TextEditingController).dispose();
    }

    super.dispose();
  }

  void _addNewTrustee() {
    setState(() {
      trusteeCount++;
      trustees.add({
        'correspondence': null,
        'title': null,
        'firstName': TextEditingController(),
        'middleName': TextEditingController(),
        'surname': TextEditingController(),
        'dob': TextEditingController(),
        'email': TextEditingController(),
        'phone': TextEditingController(),
        'houseUnit': TextEditingController(),
        'streetName': TextEditingController(),
        'streetType': null,
        'suburb': TextEditingController(),
        'state': null,
        'postcode': TextEditingController(),
        'politicallyExposed': null,
      });
      // ADD: Create corresponding signature
      signatures.add({
        'titleCntlr': TextEditingController(),
        'designationCntlr': TextEditingController(),
        'nameCntlr': TextEditingController(),
        'dateCntlr': TextEditingController(text: _getFormattedDate()),
        'designationDropdownValue': null,
      });

      //  ADD: Create signature controller
      signatureControllers.add(
        SignatureController(
          penStrokeWidth: 3,
          penColor: Colors.black,
          exportBackgroundColor: Colors.white,
        ),
      );

      //  ADD: Initialize signature image
      signatureImages.add(null);
    });
  }

  void _removeTrustee(int index) {
    setState(() {
      var trustee = trustees[index];
      (trustee['firstName'] as TextEditingController).dispose();
      (trustee['middleName'] as TextEditingController).dispose();
      (trustee['surname'] as TextEditingController).dispose();
      (trustee['dob'] as TextEditingController).dispose();
      (trustee['email'] as TextEditingController).dispose();
      (trustee['phone'] as TextEditingController).dispose();
      (trustee['houseUnit'] as TextEditingController).dispose();
      (trustee['streetName'] as TextEditingController).dispose();
      (trustee['suburb'] as TextEditingController).dispose();
      (trustee['postcode'] as TextEditingController).dispose();

      // ✅ ADD: Dispose corresponding signature controllers
      (signatures[index]['titleCntlr'] as TextEditingController).dispose();
      (signatures[index]['designationCntlr'] as TextEditingController)
          .dispose();
      (signatures[index]['nameCntlr'] as TextEditingController).dispose();
      (signatures[index]['dateCntlr'] as TextEditingController).dispose();
      signatureControllers[index].dispose();

      // ✅ ADD: Remove from all lists
      trustees.removeAt(index);
      signatures.removeAt(index);
      signatureControllers.removeAt(index);
      signatureImages.removeAt(index);
    });
  }

  void _addNewBeneficialOwner() {
    setState(() {
      beneficialOwnerCount++;
      beneficialOwners.add({
        'title': null,
        'firstName': TextEditingController(),
        'middleName': TextEditingController(),
        'surname': TextEditingController(),
        'dob': TextEditingController(),
        'email': TextEditingController(),
        'phone': TextEditingController(),
        'houseUnit': TextEditingController(),
        'streetName': TextEditingController(),
        'streetType': null,
        'suburb': TextEditingController(),
        'state': null,
        'postcode': TextEditingController(),
        'australianResident': null,
        'foreignResident': null,
        'tinOption': null,
        'tfnController': TextEditingController(),
        'countryController': TextEditingController(),
        'tinController': TextEditingController(),
        'politicallyExposed': null,
      });
    });
  }

  void _removeBeneficialOwner(int index) {
    if (index == 0) return;

    setState(() {
      var owner = beneficialOwners[index];
      (owner['firstName'] as TextEditingController).dispose();
      (owner['middleName'] as TextEditingController).dispose();
      (owner['surname'] as TextEditingController).dispose();
      (owner['dob'] as TextEditingController).dispose();
      (owner['email'] as TextEditingController).dispose();
      (owner['phone'] as TextEditingController).dispose();
      (owner['houseUnit'] as TextEditingController).dispose();
      (owner['streetName'] as TextEditingController).dispose();
      (owner['suburb'] as TextEditingController).dispose();
      (owner['postcode'] as TextEditingController).dispose();
      (owner['tfnController'] as TextEditingController).dispose();
      (owner['countryController'] as TextEditingController).dispose();
      (owner['tinController'] as TextEditingController).dispose();

      beneficialOwners.removeAt(index);
    });
  }

  void _addNewDecisionMaker() {
    setState(() {
      decisionMakerCount++;
      decisionMakers.add({
        'title': null,
        'firstName': TextEditingController(),
        'middleName': TextEditingController(),
        'surname': TextEditingController(),
        'dob': TextEditingController(),
        'email': TextEditingController(),
        'phone': TextEditingController(),
        'houseUnit': TextEditingController(),
        'streetName': TextEditingController(),
        'streetType': null,
        'suburb': TextEditingController(),
        'state': null,
        'postcode': TextEditingController(),
        'australianResident': null,
        'foreignResident': null,
        'tinOption': null,
        'tfnController': TextEditingController(),
        'countryController': TextEditingController(),
        'tinController': TextEditingController(),
        'politicallyExposed': null,
      });
    });
  }

  void _removeDecisionMaker(int index) {
    setState(() {
      var maker = decisionMakers[index];
      (maker['firstName'] as TextEditingController).dispose();
      (maker['middleName'] as TextEditingController).dispose();
      (maker['surname'] as TextEditingController).dispose();
      (maker['dob'] as TextEditingController).dispose();
      (maker['email'] as TextEditingController).dispose();
      (maker['phone'] as TextEditingController).dispose();
      (maker['houseUnit'] as TextEditingController).dispose();
      (maker['streetName'] as TextEditingController).dispose();
      (maker['suburb'] as TextEditingController).dispose();
      (maker['postcode'] as TextEditingController).dispose();
      (maker['tfnController'] as TextEditingController).dispose();
      (maker['countryController'] as TextEditingController).dispose();
      (maker['tinController'] as TextEditingController).dispose();

      decisionMakers.removeAt(index);
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
            "Trust",
            "Beneficial Ownership",
            "Bank Detail",
            "Identification Requirements",
            "Declaration",
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
          Form(key: _trustFormKey, child: trustDetailsCard()),
        if (currentStep == 1)
          Form(
            key: _beneficialOwnershipFormKey,
            child: beneficialOwnershipCard(),
          ),
        if (currentStep == 2) Form(key: _bankFormKey, child: bankDetailCard()),
        if (currentStep == 3)
          Form(
            key: _identificationFormKey,
            child: identificationRequirementsCard(),
          ),
        if (currentStep == 4)
          Form(key: _declarationFormKey, child: declarationCard()),
        Spacers.sb20(),
        _buildNavigationButtons(),
        Spacers.sb20(),
      ],
    );
  }

  // ============ TRUST DETAILS CARD ============
  Widget trustDetailsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormHelpers.buildCardWithHeader(
          "Trust Details",
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacers.sb15(),
              FormHelpers.buildTextField(
                label: "Trust name",
                controller: trustNameCntlr,
                hintText: 'Enter trust name ex. ABCD Trust',
                regErrorText: AppConstants.nameRegError,
                regExp: Regx.fullNameRegExp,
              ),
              Spacers.sb15(),
              FormHelpers.buildTextField(
                label: "Business name of the trust",
                controller: businessNameCntlr,
                hintText: 'Enter business name of the trust',
                regErrorText: AppConstants.nameRegError,
                regExp: Regx.fullNameRegExp,
              ),
              Spacers.sb15(),
              FormHelpers.buildTextField(
                label: "ABN, TFN, or TFN exemption",
                controller: abnTfnCntlr,
                hintText: 'Enter ABN',
                regErrorText: "",
                regExp: Regx.fullNameRegExp,
              ),
              Spacers.sb15(),
              FormHelpers.buildTextField(
                label: "Type of trust (e.g. SMSFs)",
                controller: trustTypeCntlr,
                hintText: 'Enter type of trust',
                regErrorText: AppConstants.nameRegError, //
                regExp: Regx.fullNameRegExp, //
              ),
              Spacers.sb15(),
              FormHelpers.buildTextField(
                label: "Country in which trust was established",
                controller: countryCntlr,
                hintText: 'ex.Australlia',
                regErrorText: AppConstants.nameRegError, //
                regExp: Regx.fullNameRegExp, //
              ),
              Spacers.sb20(),
              _questionSection(
                "Are you an Australian resident for tax purposes?",
                ["Yes", "No"],
              ),
              Spacers.sb20(),
            ],
          ),
        ),
        Spacers.sb20(),
        _buildSourcesCard(),
        Spacers.sb20(),
        _trusteeCard(),
      ],
    );
  }

  // ============ DYNAMIC TRUSTEE CARD ============
  Widget _trusteeCard() {
    return Column(
      children: [
        ...List.generate(trustees.length, (index) {
          return Column(
            children: [_buildSingleTrusteeCard(index), Spacers.sb15()],
          );
        }),

        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: _addNewTrustee,
            icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
            label: TextWidget(
              text: "Add Trustee",
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xfff93a0b),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============ SINGLE TRUSTEE CARD BUILDER ============
  Widget _buildSingleTrusteeCard(int index) {
    var trustee = trustees[index];
    bool isFirstTrustee = index == 0;
    int displayNumber = index + 1;
    bool hasYesSelected = trustees.any((t) => t['correspondence'] == 'YES');
    bool shouldShowCorrespondence =
        !hasYesSelected || trustee['correspondence'] == 'YES';
    return Card(
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: Colors.white,
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
                  text: "Trustee: $displayNumber",
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 40.w,
                  child: !isFirstTrustee
                      ? IconButton(
                          onPressed: () => _removeTrustee(index),
                          icon: const Icon(Icons.delete, color: Colors.white),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Remove Trustee',
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacers.sb15(),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (shouldShowCorrespondence) ...[
                      FormHelpers.sectionTitle(
                        "Are you the person for further correspondence?",
                        14,
                        FontWeight.bold,
                        ColorsData.blackColor,
                      ),
                      Spacers.sb8(),
                      RadioGroup<String>(
                        groupValue: trustee['correspondence'],
                        onChanged: (String? value) {
                          setState(() {
                            // If YES is selected, clear ALL directors first
                            if (value == 'YES') {
                              for (int i = 0; i < trustees.length; i++) {
                                trustees[i]['correspondence'] =
                                    null; // ✓ Clear ALL including current
                              }
                              trustee['correspondence'] =
                                  'YES'; // ✓ Then set to YES
                            } else {
                              // For NO, just set this director
                              trustee['correspondence'] = value;
                            }
                          });
                        },
                        child: Row(
                          children: [
                            Radio<String>(
                              value: "YES",
                              activeColor: Colors.amber,
                            ),
                            TextWidget(
                              text: "YES",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ColorsData.blackColor,
                            ),
                            Spacers.sbw20(),
                            Radio<String>(
                              value: "NO",
                              activeColor: Colors.amber,
                            ),
                            TextWidget(
                              text: "NO",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: ColorsData.blackColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),

                Spacers.sb15(),

                FormHelpers.buildDropdownField(
                  label: "Title",
                  items: FormHelpers.titles,
                  value: trustee['title'],
                  onChanged: (value) {
                    setState(() {
                      trustee['title'] = value;
                    });
                  },
                ),

                Spacers.sb15(),

                FormHelpers.buildTextFieldRow([
                  {
                    "label": "First name",
                    "controller": trustee['firstName'],
                    "hint": "ex.John",
                    "regErrorText": AppConstants.nameRegError, //
                    "regExp": Regx.nameRegExp, //
                  },
                  {
                    "label": "Middle name",
                    "controller": trustee['middleName'],
                    "hint": "ex.Reco",
                    "regErrorText": AppConstants.nameRegError, //
                    "regExp": Regx.nameRegExp, //
                  },
                ]),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Surname",
                  controller: trustee['surname'],
                  hintText: 'ex.Brown',
                  regErrorText: AppConstants.nameRegError, //
                  regExp: Regx.nameRegExp, //
                ),

                Spacers.sb15(),

                FormHelpers.buildDatePickerField(
                  context,
                  trustee['dob'],
                  'Date of birth (MM/DD/YYYY)',
                ),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Email",
                  controller: trustee['email'],
                  hintText: 'ex.John@gmail.com',
                  regErrorText: AppConstants.emailRegError, //
                  regExp: Regx.emailRegExp,
                ),

                Spacers.sb15(),

                FormHelpers.buildTextFieldRow([
                  {
                    "label": "Phone number",
                    "controller": trustee['phone'],
                    "hint": "ex.987678567",
                    "digit": true,
                    "regErrorText": AppConstants.phoneRegError, //
                    "regExp": Regx.nineDigitRegExp, //
                  },
                  {
                    "label": "House/Unit No",
                    "controller": trustee['houseUnit'],
                    "hint": "ex.110/412",
                    "digit": true,
                  },
                ]),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Street name",
                  controller: trustee['streetName'],
                  hintText: 'ex.Celebration',
                  regErrorText: AppConstants.nameRegError, //
                  regExp: Regx.fullNameRegExp, //
                ),

                Spacers.sb15(),

                FormHelpers.buildDropdownField(
                  label: "Street type",
                  items: FormHelpers.streetTypes,
                  value: trustee['streetType'],
                  onChanged: (value) {
                    setState(() {
                      trustee['streetType'] = value;
                    });
                  },
                ),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Suburb",
                  controller: trustee['suburb'],
                  hintText: "ex.Box Hill/Bella Vista",
                  regErrorText: AppConstants.nameRegError, //
                  regExp: Regx.fullNameRegExp, //
                ),

                Spacers.sb15(),

                FormHelpers.buildDropdownField(
                  label: "State",
                  items: FormHelpers.states,
                  value: trustee['state'],
                  onChanged: (value) {
                    setState(() {
                      trustee['state'] = value;
                    });
                  },
                ),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Postcode",
                  controller: trustee['postcode'],
                  hintText: "ex.4321",
                  digit: true,
                ),

                Spacers.sb15(),

                _questionSection("Are you a politically exposed person?", [
                  "Yes",
                  "No",
                ]),

                Spacers.sb20(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ BENEFICIAL OWNERSHIP CARD ============
  Widget beneficialOwnershipCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            border: Border(
              left: BorderSide(color: Colors.amber.shade700, width: 4.w),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.amber.shade700,
                size: 22.sp,
              ),
              Spacers.sbw10(),
              Expanded(
                child: TextWidget(
                  text:
                      "Please complete for each beneficial owner. If you are unable to ascertain the beneficial owners, please complete decision maker section below instead.",
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                  maxLines: 4,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        Spacers.sb20(),
        ...List.generate(beneficialOwners.length, (index) {
          return Column(
            children: [_buildSingleBeneficialOwnerCard(index), Spacers.sb15()],
          );
        }),

        Spacers.sb20(),

        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: _addNewBeneficialOwner,
            icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
            label: TextWidget(
              text: "Add Beneficial Owner",
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xfff93a0b),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),

        Spacers.sb20(),

        ...List.generate(decisionMakers.length, (index) {
          return Column(
            children: [_buildSingleDecisionMakerCard(index), Spacers.sb15()],
          );
        }),

        Spacers.sb20(),

        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton.icon(
            onPressed: _addNewDecisionMaker,
            icon: Icon(Icons.add, size: 18.sp, color: Colors.white),
            label: TextWidget(
              text: "Add Decision Maker",
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xfff93a0b),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============ SINGLE BENEFICIAL OWNER CARD BUILDER ============
  Widget _buildSingleBeneficialOwnerCard(int index) {
    var owner = beneficialOwners[index];
    bool isFirstOwner = index == 0;
    int displayNumber = index + 1;

    return Card(
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: Colors.white,
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
                  text: "Beneficial Owner: $displayNumber",
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                if (!isFirstOwner)
                  IconButton(
                    onPressed: () => _removeBeneficialOwner(index),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Remove Beneficial Owner',
                  ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacers.sb15(),

                FormHelpers.buildDropdownField(
                  label: "Title",
                  items: FormHelpers.titles,
                  value: owner['title'],
                  onChanged: (value) {
                    setState(() {
                      owner['title'] = value;
                    });
                  },
                ),

                Spacers.sb15(),

                FormHelpers.buildTextFieldRow([
                  {
                    "label": "First name",
                    "controller": owner['firstName'],
                    "hint": "ex.John",
                    "regErrorText": AppConstants.nameRegError,
                    "regExp": Regx.nameRegExp,
                  },
                  {
                    "label": "Middle name",
                    "controller": owner['middleName'],
                    "hint": "ex.Reco",
                    "regErrorText": AppConstants.nameRegError,
                    "regExp": Regx.nameRegExp,
                  },
                ]),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Surname",
                  controller: owner['surname'],
                  hintText: 'ex.Brown',
                  regErrorText: AppConstants.nameRegError,
                  regExp: Regx.nameRegExp,
                ),

                Spacers.sb15(),

                FormHelpers.buildDatePickerField(
                  context,
                  owner['dob'],
                  'Date of birth (DD/MM/YYYY)',
                ),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Email",
                  controller: owner['email'],
                  hintText: 'ex.John@gmail.com',
                  regErrorText: AppConstants.emailRegError,
                  regExp: Regx.emailRegExp,
                ),

                Spacers.sb15(),

                FormHelpers.buildTextFieldRow([
                  {
                    "label": "Phone number",
                    "controller": owner['phone'],
                    "hint": "ex.987678567",
                    "digit": true,
                    "regErrorText": AppConstants.phoneRegError,
                    "regExp": Regx.nineDigitRegExp,
                  },
                  {
                    "label": "House/Unit No",
                    "controller": owner['houseUnit'],
                    "hint": "ex.110/412",
                    "digit": true,
                  },
                ]),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Street name",
                  controller: owner['streetName'],
                  hintText: 'ex.Celebration',
                  regErrorText: AppConstants.nameRegError,
                  regExp: Regx.fullNameRegExp,
                ),

                Spacers.sb15(),

                FormHelpers.buildDropdownField(
                  label: "Street type",
                  items: FormHelpers.streetTypes,
                  value: owner['streetType'],
                  onChanged: (value) {
                    setState(() {
                      owner['streetType'] = value;
                    });
                  },
                ),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Suburb",
                  controller: owner['suburb'],
                  hintText: "ex.Box Hill/Bella Vista",
                  regErrorText: AppConstants.nameRegError,
                  regExp: Regx.fullNameRegExp,
                ),

                Spacers.sb15(),

                FormHelpers.buildDropdownField(
                  label: "State",
                  items: FormHelpers.states,
                  value: owner['state'],
                  onChanged: (value) {
                    setState(() {
                      owner['state'] = value;
                    });
                  },
                ),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Postcode",
                  controller: owner['postcode'],
                  hintText: "ex.4321",
                  digit: true,
                ),

                Spacers.sb15(),

                FormHelpers.buildCardWithHeader(
                  "Are you an Australian resident for tax purposes?",
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacers.sb8(),

                      SizedBox(
                        width: double.infinity,
                        child: FormHelpers.buildDropdownField(
                          label: "Please select",
                          items: ["Yes", "No"],
                          value: owner['australianResident'],
                          onChanged: (value) {
                            setState(() {
                              owner['australianResident'] = value;
                            });
                          },
                        ),
                      ),

                      if (owner['australianResident'] == "No")
                        Column(
                          children: [
                            Spacers.sb15(),
                            SizedBox(
                              width: double.infinity,
                              child: FormHelpers.buildDropdownField(
                                label:
                                    "Are you a foreign resident for tax purposes?",
                                items: ["Yes", "No"],
                                value: owner['foreignResident'],
                                onChanged: (value) {
                                  setState(() {
                                    owner['foreignResident'] = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                      if (owner['australianResident'] == "No" &&
                          owner['foreignResident'] == "No")
                        Column(
                          children: [
                            Spacers.sb15(),
                            SizedBox(
                              width: double.infinity,
                              child: FormHelpers.buildDropdownField(
                                label:
                                    "If No please select one of the following:",
                                items: [
                                  "The country of tax residency does not issue TINs",
                                  "I have not been issued with a TIN",
                                  "The country of tax residency does not require the TIN to be disclosed",
                                ],
                                value: owner['tinOption'],
                                onChanged: (value) {
                                  setState(() {
                                    owner['tinOption'] = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                      if (owner['australianResident'] == "No" &&
                          owner['foreignResident'] == "Yes")
                        Column(
                          children: [
                            Spacers.sb15(),
                            FormHelpers.buildTextFieldRow([
                              {
                                "label": "Country",
                                "controller": owner['countryController'],
                                "hint": "ex.Australlia",
                                "regErrorText": AppConstants.nameRegError,
                                "regExp": Regx.fullNameRegExp,
                              },
                              {
                                "label": "TIN",
                                "controller": owner['tinController'],
                                "hint": "345676548765",
                                "digit": true,
                              },
                            ]),
                          ],
                        ),

                      if (owner['australianResident'] == "Yes")
                        Column(
                          children: [
                            Spacers.sb15(),
                            FormHelpers.buildTextField(
                              label: "please insert your Tax File Number(TFN)",
                              controller: owner['tfnController'],
                              hintText: 'ex.245432456756',
                              digit: true,
                            ),
                          ],
                        ),

                      Spacers.sb20(),
                    ],
                  ),
                ),

                Spacers.sb15(),

                FormHelpers.buildCardWithHeader(
                  "Are you a politically exposed person?",
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacers.sb8(),
                      FormHelpers.buildDropdownField(
                        label: "Please select",
                        items: ["Yes", "No"],
                        value: owner['politicallyExposed'],
                        onChanged: (value) {
                          setState(() {
                            owner['politicallyExposed'] = value;
                          });
                        },
                      ),
                      Spacers.sb20(),
                    ],
                  ),
                ),

                Spacers.sb20(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ SINGLE DECISION MAKER CARD BUILDER ============
  Widget _buildSingleDecisionMakerCard(int index) {
    var maker = decisionMakers[index];
    int displayNumber = index + 1;

    return Card(
      elevation: 2,
      color: Colors.white,
      surfaceTintColor: Colors.white,
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
                  text: "Decision Maker: $displayNumber",
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
                IconButton(
                  onPressed: () => _removeDecisionMaker(index),
                  icon: const Icon(Icons.delete, color: Colors.white),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Remove Decision Maker',
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacers.sb15(),

                FormHelpers.buildDropdownField(
                  label: "Title",
                  items: FormHelpers.titles,
                  value: maker['title'],
                  onChanged: (value) {
                    setState(() {
                      maker['title'] = value;
                    });
                  },
                ),

                Spacers.sb15(),

                FormHelpers.buildTextFieldRow([
                  {
                    "label": "First name",
                    "controller": maker['firstName'],
                    "hint": "ex.John",
                    "regErrorText": AppConstants.nameRegError,
                    "regExp": Regx.nameRegExp,
                  },
                  {
                    "label": "Middle name",
                    "controller": maker['middleName'],
                    "hint": "ex.Reco",
                    "regErrorText": AppConstants.nameRegError,
                    "regExp": Regx.nameRegExp,
                  },
                ]),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Surname",
                  controller: maker['surname'],
                  hintText: 'ex.Brown',
                  regErrorText: AppConstants.nameRegError,
                  regExp: Regx.nameRegExp,
                ),

                Spacers.sb15(),

                FormHelpers.buildDatePickerField(
                  context,
                  maker['dob'],
                  'Date of birth (DD/MM/YYYY)',
                ),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Email",
                  controller: maker['email'],
                  hintText: 'ex.John@gmail.com',
                  regErrorText: AppConstants.emailRegError,
                  regExp: Regx.emailRegExp,
                ),

                Spacers.sb15(),

                FormHelpers.buildTextFieldRow([
                  {
                    "label": "Phone number",
                    "controller": maker['phone'],
                    "hint": "ex.987678567",
                    "digit": true,
                    "regErrorText": AppConstants.phoneRegError,
                    "regExp": Regx.nineDigitRegExp,
                  },
                  {
                    "label": "House/Unit No",
                    "controller": maker['houseUnit'],
                    "hint": "ex.110/412",
                    "digit": true,
                  },
                ]),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Street name",
                  controller: maker['streetName'],
                  hintText: 'ex.Celebration',
                  regErrorText: AppConstants.nameRegError,
                  regExp: Regx.fullNameRegExp,
                ),

                Spacers.sb15(),

                FormHelpers.buildDropdownField(
                  label: "Street type",
                  items: FormHelpers.streetTypes,
                  value: maker['streetType'],
                  onChanged: (value) {
                    setState(() {
                      maker['streetType'] = value;
                    });
                  },
                ),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Suburb",
                  controller: maker['suburb'],
                  hintText: "ex.Box Hill/Bella Vista",
                  regErrorText: AppConstants.nameRegError,
                  regExp: Regx.fullNameRegExp,
                ),

                Spacers.sb15(),

                FormHelpers.buildDropdownField(
                  label: "State",
                  items: FormHelpers.states,
                  value: maker['state'],
                  onChanged: (value) {
                    setState(() {
                      maker['state'] = value;
                    });
                  },
                ),

                Spacers.sb15(),

                FormHelpers.buildTextField(
                  label: "Postcode",
                  controller: maker['postcode'],
                  hintText: "ex.4321",
                  digit: true,
                ),

                Spacers.sb15(),

                FormHelpers.buildCardWithHeader(
                  "Are you an Australian resident for tax purposes?",
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacers.sb8(),

                      SizedBox(
                        width: double.infinity,
                        child: FormHelpers.buildDropdownField(
                          label: "Please select",
                          items: ["Yes", "No"],
                          value: maker['australianResident'],
                          onChanged: (value) {
                            setState(() {
                              maker['australianResident'] = value;
                            });
                          },
                        ),
                      ),

                      if (maker['australianResident'] == "No")
                        Column(
                          children: [
                            Spacers.sb15(),
                            SizedBox(
                              width: double.infinity,
                              child: FormHelpers.buildDropdownField(
                                label:
                                    "Are you a foreign resident for tax purposes?",
                                items: ["Yes", "No"],
                                value: maker['foreignResident'],
                                onChanged: (value) {
                                  setState(() {
                                    maker['foreignResident'] = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                      if (maker['australianResident'] == "No" &&
                          maker['foreignResident'] == "No")
                        Column(
                          children: [
                            Spacers.sb15(),
                            SizedBox(
                              width: double.infinity,
                              child: FormHelpers.buildDropdownField(
                                label:
                                    "If No please select one of the following:",
                                items: [
                                  "The country of tax residency does not issue TINs",
                                  "I have not been issued with a TIN",
                                  "The country of tax residency does not require the TIN to be disclosed",
                                ],
                                value: maker['tinOption'],
                                onChanged: (value) {
                                  setState(() {
                                    maker['tinOption'] = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                      if (maker['australianResident'] == "No" &&
                          maker['foreignResident'] == "Yes")
                        Column(
                          children: [
                            Spacers.sb15(),
                            FormHelpers.buildTextFieldRow([
                              {
                                "label": "Country",
                                "controller": maker['countryController'],
                                "hint": "ex.Australlia",
                                "regErrorText": AppConstants.nameRegError,
                                "regExp": Regx.fullNameRegExp,
                              },
                              {
                                "label": "TIN",
                                "controller": maker['tinController'],
                                "hint": "345676548765",
                                "digit": true,
                              },
                            ]),
                          ],
                        ),

                      if (maker['australianResident'] == "Yes")
                        Column(
                          children: [
                            Spacers.sb15(),
                            FormHelpers.buildTextField(
                              label: "please insert your Tax File Number(TFN)",
                              controller: maker['tfnController'],
                              hintText: 'ex.245432456756',
                              digit: true,
                            ),
                          ],
                        ),

                      Spacers.sb20(),
                    ],
                  ),
                ),

                Spacers.sb15(),

                FormHelpers.buildCardWithHeader(
                  "Are you a politically exposed person?",
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Spacers.sb8(),
                      FormHelpers.buildDropdownField(
                        label: "Please select",
                        items: ["Yes", "No"],
                        value: maker['politicallyExposed'],
                        onChanged: (value) {
                          setState(() {
                            maker['politicallyExposed'] = value;
                          });
                        },
                      ),
                      Spacers.sb20(),
                    ],
                  ),
                ),

                Spacers.sb20(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ BANK DETAIL CARD ============
  BankDetailCard bankDetailCard() {
    return BankDetailCard(
      incomeDistributionOption: incomeDistributionOption,
      onIncomeDistributionChanged: (value) {
        setState(() {
          incomeDistributionOption = value;
        });
      },
      financialInstitutionCntlr: financialInstitutionCntlr,
      accountNameCntlr: accountNameCntlr,
      bsbCntlr: bsbCntlr,
      accountNumberCntlr: accountNumberCntlr,
    );
  }

  // ============ IDENTIFICATION REQUIREMENTS CARD ============
  Widget identificationRequirementsCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormHelpers.buildCardWithHeader(
          "Trust verification details",
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Spacers.sb15(),
              FormHelpers.sectionTitle(
                "Unregulated Trusts provide an original certified copy of one identification document",
                14,
                FontWeight.w600,
                ColorsData.blackColor,
              ),
              Spacers.sb20(),
              FormHelpers.sectionTitle(
                "Choose one",
                14,
                FontWeight.bold,
                ColorsData.blackColor,
              ),
              Spacers.sb15(),

              // Wrap with RadioGroup
              RadioGroup<String>(
                groupValue: selectedIdentificationOption,
                onChanged: (String? value) {
                  setState(() {
                    selectedIdentificationOption = value;
                  });
                },
                child: Column(
                  children: [
                    ...identificationOptions.map((option) {
                      return Column(
                        children: [
                          RadioListTile<String>(
                            value: option['value']!,
                            title: TextWidget(
                              text: option['label']!,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: ColorsData.blackColor,
                            ),
                            activeColor: Colors.amber,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ),
                          Spacers.sb10(),
                        ],
                      );
                    }),
                  ],
                ),
              ),

              Spacers.sb10(),

              // FIXED: Use FormHelpers.buildFileUploadBox with async/await
              FormHelpers.buildFileUploadBox(
                onTap: () async {
                  final List<String>? files = await FormHelpers.pickFiles();
                  if (files != null && files.isNotEmpty) {
                    setState(() {
                      uploadedFiles['identification'] = [
                        ...(uploadedFiles['identification'] ?? []),
                        ...files,
                      ];
                    });
                  }
                },
                filesCount: uploadedFiles['identification']?.length ?? 0,
                documentKey: 'identification',
              ),

              if ((uploadedFiles['identification']?.length ?? 0) == 0)
                Spacers.sb8(),

              if ((uploadedFiles['identification']?.length ?? 0) > 0)
                Column(
                  children: [
                    Spacers.sb10(),
                    ...(uploadedFiles['identification'] ?? []).map((file) {
                      return Column(
                        children: [
                          Spacers.sb5(),
                          // FIXED: Use FormHelpers.buildDocumentDisplayWidget with callback
                          FormHelpers.buildDocumentDisplayWidget(
                            context,
                            'identification',
                            file,
                            (fileName) {
                              setState(() {
                                uploadedFiles['identification']?.remove(
                                  fileName,
                                );
                              });
                            },
                          ),
                          Spacers.sb8(),
                        ],
                      );
                    }),
                  ],
                ),

              Spacers.sb20(),
            ],
          ),
        ),
      ],
    );
  }

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
        FormHelpers.buildCardWithHeader(
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

          return Column(
            children: [
              Card(
                elevation: 2,
                color: ColorsData.whiteColor,
                surfaceTintColor: ColorsData.whiteColor,
                child: Column(
                  children: [
                    _buildCardHeader(
                      "Signature: ${index + 1}",
                      14,
                      FontWeight.bold,
                    ),
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

                          // Divider with OR
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
                          FormHelpers.buildTextField(
                            label: "Title",
                            controller: signature['titleCntlr'],
                            hintText: "",
                            regErrorText: AppConstants.nameRegError,
                            regExp: Regx.fullNameRegExp,
                          ),
                          Spacers.sb10(),
                          FormHelpers.buildDropdownField(
                            label: "Designation",
                            items: [
                              "secretary",
                              "Director",
                              "Manager",
                              "Trustee",
                              "Other",
                            ],
                            value: signature['designationDropdownValue'],
                            onChanged: (value) {
                              setState(() {
                                signature['designationDropdownValue'] = value;
                              });
                            },
                          ),
                          Spacers.sb10(),
                          FormHelpers.buildTextField(
                            label: "Name",
                            controller: signature['nameCntlr'],
                            hintText: "",
                            regErrorText: AppConstants.nameRegError,
                            regExp: Regx.fullNameRegExp,
                          ),
                          Spacers.sb15(),
                          FormHelpers.buildTextField(
                            label: "Date",
                            controller: signature['dateCntlr'],
                            hintText: "",
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
                ...FormHelpers.sources.map((source) {
                  bool isSelected = selectedSources.contains(source);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedSources.add(source);
                        } else {
                          selectedSources.remove(source);
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
                    regErrorText: "", //
                    regExp: Regx.fullNameRegExp, //
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ QUESTION SECTION ============
  Widget _questionSection(String title, List<String> options) {
    String? selectedOption;

    if (title.contains("Australian resident")) {
      selectedOption = selectedAustralianResidentOption;
    }

    return FormHelpers.buildCardWithHeader(
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
                }
              });
            },
          ),
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
                          "label": "Country",
                          "controller": countryController,
                          "hint": "Australia",
                          "regErrorText": AppConstants.nameRegError, //
                          "regExp": Regx.fullNameRegExp, //
                        },
                        {
                          "label": "TIN",
                          "controller": tinController,
                          "hint": "345676548765",
                          "digit": true,
                          "regErrorText": AppConstants.phoneRegError, //
                          "regExp": Regx.nineDigitRegExp, //
                        },
                      ]),
                    ],
                  ),
                if (foreignResidentOption == "No")
                  Column(
                    children: [
                      Spacers.sb15(),
                      FormHelpers.buildDropdownField(
                        label: "If No, please select one of the following",
                        items: [
                          "The country of tax residency does not issue TINs",
                          "I have not been issued with a TIN",
                          "The country of tax residency does not require the TIN to be disclosed",
                        ],
                        value: noForeignResidentOption,
                        onChanged: (value) {
                          setState(() {
                            noForeignResidentOption = value;
                          });
                        },
                      ),
                    ],
                  ),
              ],
            ),
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

  // ============ REUSABLE: BUTTON ============
  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 18.sp) : const SizedBox.shrink(),
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

  // ============ NAVIGATION BUTTONS ============\
  Widget _buildNavigationButtons() {
    double buttonWidth = 140.w;
    double buttonHeight = 45.h;
    bool isFirstStep = currentStep == 0;
    bool isDeclarationStep = currentStep == 4;

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
                        isValid = _trustFormKey.currentState!.validate();
                        if (isValid && selectedSources.isEmpty) {
                          isValid = false;
                          showToast(
                            message:
                                "Please select at least one source of wealth",
                          );
                        }
                        if (isValid) {
                          for (var trustee in trustees) {
                            bool hasYesSelected = trustees.any(
                              (d) => d['correspondence'] == 'YES',
                            );
                            bool isRadioApplicable =
                                !hasYesSelected ||
                                trustee['correspondence'] == 'YES';

                            if (isRadioApplicable &&
                                trustee['correspondence'] == null) {
                              isValid = false;
                              showToast(
                                message:
                                    "Please select correspondence for the applicable trustees",
                              );
                              break;
                            }
                          }
                        }
                        if (isValid &&
                            selectedSources.contains("Others") &&
                            othersSpecifyCntlr.text.isEmpty) {
                          isValid = false;
                          showToast(
                            message: "Please specify other source of wealth",
                          );
                        }
                      } else if (currentStep == 1) {
                        isValid = _beneficialOwnershipFormKey.currentState!
                            .validate();
                      } else if (currentStep == 2) {
                        isValid = _bankFormKey.currentState!.validate();
                      } else if (currentStep == 3) {
                        isValid = _identificationFormKey.currentState!
                            .validate();

                        if (isValid && selectedIdentificationOption == null) {
                          isValid = false;
                          showToast(
                            message: "Please select an identification option",
                          );
                        }

                        if (isValid &&
                            (uploadedFiles['identification']?.isEmpty ??
                                true)) {
                          isValid = false;
                          showToast(
                            message:
                                "Please upload at least one identification document",
                          );
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
              if (currentStep == 0 || currentStep == 1 || currentStep == 2)
                SizedBox(
                  width: buttonWidth,
                  height: buttonHeight,
                  child: _buildButton(
                    label: "Reset",
                    color: ColorsData.greyColor,
                    onPressed: () {
                      setState(() {
                        // Add reset logic here
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
}
