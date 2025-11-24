import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../constants/colors.dart';
import '../../constants/paths.dart';
import '../../constants/strings.dart';
import '../../models/user_model.dart';
import '../../services/helpers.dart';
import '../../utils/regx.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/button_widgets.dart';
import '../../widgets/custom_prompts.dart';
import '../../widgets/field_widget.dart';
import '../../widgets/image_widget.dart';
import '../../widgets/spacers.dart';
import '../../widgets/text_widget.dart';
import '../../widgets/toasts.dart';
import '../authScrn/components/auth_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool obscureText0 = true;
  bool obscureText1 = true;
  bool obscureText2 = true;

  String userImage = '';
  String pickedImage = '';
  String imageName = '';

  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  final fnameCntlr = TextEditingController();
  final lnameCntlr = TextEditingController();
  final emailCntlr = TextEditingController();
  final phoneCntlr = TextEditingController();

  final oldPassCntlr = TextEditingController();
  final newPassCntlr = TextEditingController();
  final cnfmPassCntlr = TextEditingController();

  @override
  void initState() {
    super.initState();
    setUserDetails();
  }

  void setUserDetails() {
    final userProvider = getUserProvider(context);
    final user = userProvider.user!;

    fnameCntlr.text = user.firstName;
    lnameCntlr.text = user.lastName;
    phoneCntlr.text = user.contactNo;
    emailCntlr.text = user.email;
    userImage = user.image;
    pickedImage = '';
    imageName = '';
    setState(() {});
  }

  void _profileSaveTap() {
    dismissInputFocus(context);
    final userProvider = getUserProvider(context);
    final updatedUser = UpdatedUser(
      updatedClient: UpdatedClient(
        id: userProvider.user!.id,
        fullName: '${fnameCntlr.text.trim()} ${lnameCntlr.text.trim()}'.trim(),
      ),
    );
    userProvider.updateUserData(updatedUser: updatedUser, ctx: context);
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 20,
    );
    if (pickedFile != null) {
      pickedImage = pickedFile.path;
      imageName = pickedFile.name;
      setState(() {});
    }
  }

  Future<void> _uploadImage() async {
    final userProvider = getUserProvider(context);
    final updatedUser = UpdatedUser(
      updatedClient: UpdatedClient(
        id: userProvider.user!.id,
        fullName: '${fnameCntlr.text.trim()} ${lnameCntlr.text.trim()}'.trim(),
        image: pickedImage,
        imageName: imageName,
        imgType: pickedImage.split('.').last,
      ),
    );

    await userProvider
        .updateUserData(updatedUser: updatedUser, ctx: context)
        .whenComplete(() => setUserDetails());
  }

  void _passSaveTap() async {
    final isValid = _formKey2.currentState!.validate();
    if (isValid) {
      dismissInputFocus(context);
      final passOk = newPassCntlr.text.trim() == cnfmPassCntlr.text.trim();
      if (passOk) {
        final userProvider = getUserProvider(context);
        final changedUserPass = ChangedUserPass(
          updatedPass: UpdatedPass(
            email: userProvider.user!.email,
            oldPassword: oldPassCntlr.text.trim(),
            newPassword: newPassCntlr.text.trim(),
          ),
        );
        await userProvider
            .changeUserPass(changedUserPass: changedUserPass, ctx: context)
            .whenComplete(() {
              oldPassCntlr.clear();
              newPassCntlr.clear();
              cnfmPassCntlr.clear();
            });
      } else {
        showToast(message: AppConstants.passMissmatch);
      }
    }
  }

  void _logoutTap() {
    final authProvider = getAuthProvider(context);
    authProvider.logoutUser(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsData.trColor,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Spacers.sb15(),
          buildTitle(context),
          Spacers.sb10(),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
              padding: EdgeInsets.fromLTRB(15.w, 20.w, 15.w, 0),
              decoration: commonDecor,
              child: ListView(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 66.r,
                        backgroundColor: ColorsData.whiteColor,
                        backgroundImage: const AssetImage(Paths.ellipse),
                        child: pickedImage.isNotEmpty
                            ? CircleAvatar(
                                radius: 64.r,
                                backgroundColor: ColorsData.whiteColor,
                                backgroundImage: FileImage(
                                  File(pickedImage.trim()),
                                ),
                              )
                            : userImage.isEmpty
                            ? ImageWidget(
                                image: Paths.user,
                                height: 66.w,
                                width: 61.w,
                                fit: BoxFit.cover,
                              )
                            : CircleAvatar(
                                radius: 64.r,
                                backgroundColor: ColorsData.whiteColor,
                                backgroundImage: NetworkImage(userImage.trim()),
                              ),
                      ),
                      Positioned(
                        right: -70,
                        left: 0,
                        bottom: 3,
                        child: Center(
                          child: GestureDetector(
                            onTap: () => _showPicker(context),
                            child: ClipOval(
                              child: ColoredBox(
                                color: pickedImage.isNotEmpty
                                    ? Colors.green
                                    : Colors.black54,
                                child: Padding(
                                  padding: EdgeInsets.all(6.w),
                                  child: Icon(
                                    pickedImage.isNotEmpty
                                        ? Icons.thumb_up_alt
                                        : Icons.camera_alt,
                                    color: ColorsData.whiteColor,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (pickedImage.isNotEmpty)
                        Positioned(
                          right: 0,
                          left: -70,
                          bottom: 3,
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  pickedImage = '';
                                  imageName = '';
                                });
                              },
                              child: ClipOval(
                                child: ColoredBox(
                                  color: Colors.red,
                                  child: Padding(
                                    padding: EdgeInsets.all(6.w),
                                    child: Icon(
                                      Icons.delete,
                                      color: ColorsData.whiteColor,
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Spacers.sb20(),
                  buildCredentialFields(),
                  Spacers.sb20(),
                  buildPasswordFields(),
                  scrollUp(context),
                  Spacers.sb20(),
                  appVersionWidget(),
                  Spacers.sb5(),
                  logoutButton(),
                  Spacers.sb20(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCredentialFields() {
    return Card(
      elevation: 6,
      color: ColorsData.whiteColor,
      surfaceTintColor: ColorsData.whiteColor,
      margin: EdgeInsets.all(4.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              h2(AppConstants.chngCred),
              Spacers.sb20(),
              h1(AppConstants.fname),
              Spacers.sb5(),
              _fieldWidget(
                controller: fnameCntlr,
                errorText: AppConstants.nameError,
                regErrorText: AppConstants.nameRegError,
                regExpCondition: Regx.nameRegExp,
              ),
              Spacers.sb15(),
              h1(AppConstants.lname),
              Spacers.sb5(),
              _fieldWidget(
                controller: lnameCntlr,
                errorText: AppConstants.nameError,
                regErrorText: AppConstants.nameRegError,
                regExpCondition: Regx.nameRegExp,
              ),
              Spacers.sb15(),
              h1(AppConstants.cntct),
              Spacers.sb5(),
              _fieldWidget(
                controller: phoneCntlr,
                readOnly: true,
                errorText: AppConstants.phoneError,
                regErrorText: AppConstants.phoneRegError,
                regExpCondition: Regx.nineDigitRegExp,
              ),
              Spacers.sb15(),
              h1(AppConstants.email),
              Spacers.sb5(),
              _fieldWidget(
                controller: emailCntlr,
                readOnly: true,
                errorText: AppConstants.emailError,
                regErrorText: AppConstants.emailRegError,
                regExpCondition: Regx.emailRegExp,
              ),
              Spacers.sb30(),
              _saveButton(onTap: () => _profileSaveTap()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPasswordFields() {
    return Card(
      elevation: 6,
      color: ColorsData.whiteColor,
      surfaceTintColor: ColorsData.whiteColor,
      margin: EdgeInsets.all(4.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              h2(AppConstants.chngPass),
              Spacers.sb15(),
              h1(AppConstants.oldPass),
              Spacers.sb5(),
              _passField(
                controller: oldPassCntlr,
                errorText: AppConstants.passError,
                regErrorText: AppConstants.passRegError,
                regExpCondition: Regx.passwordRegExp,
                obscureText: obscureText0,
                suffixindex: 0,
              ),
              Spacers.sb15(),
              h1(AppConstants.pass),
              Spacers.sb5(),
              _passField(
                controller: newPassCntlr,
                errorText: AppConstants.passError,
                regErrorText: AppConstants.passRegError,
                regExpCondition: Regx.passwordRegExp,
                obscureText: obscureText1,
                suffixindex: 1,
              ),
              Spacers.sb15(),
              h1(AppConstants.cnfmPass),
              Spacers.sb5(),
              _passField(
                controller: cnfmPassCntlr,
                errorText: AppConstants.cnfmPassError,
                regErrorText: AppConstants.passRegError,
                regExpCondition: Regx.passwordRegExp,
                obscureText: obscureText2,
                suffixindex: 2,
              ),
              Spacers.sb30(),
              _saveButton(onTap: () => _passSaveTap()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saveButton({required VoidCallback onTap}) {
    return Align(
      alignment: Alignment.centerRight,
      child: customButton(
        title: AppConstants.save,
        height: 30,
        width: 60,
        fontSize: 12,
        stadium: true,
        padding: EdgeInsets.zero,
        buttonColor: Colors.blue.shade300,
        shadows: [
          const BoxShadow(
            color: Colors.black26,
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
        onPressed: onTap,
      ),
    );
  }

  Widget appVersionWidget() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextWidget(
        text: Platform.isAndroid
            ? AppConstants.androidVrsn
            : AppConstants.iosVrsn,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: ColorsData.formHintColor,
      ),
    );
  }

  Widget logoutButton() {
    return Align(
      child: AuthWidgets.button(
        title: AppConstants.logout,
        context: context,
        onTap: () => _logoutTap(),
      ),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    if (pickedImage.isNotEmpty) {
      _uploadImage();
    } else {
      await CustomPrompts.showBottomSheet(
        ctx: context,
        widget: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.r),
                      ),
                    ),
                    leading: const Icon(
                      Icons.photo_library,
                      color: Colors.white,
                    ),
                    title: const TextWidget(
                      text: AppConstants.glry,
                      fontSize: 14,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      color: ColorsData.whiteColor,
                    ),
                    tileColor: Colors.blue.shade300,
                    onTap: () {
                      _pickImage(ImageSource.gallery);
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(30.r),
                      ),
                    ),
                    leading: const Icon(
                      Icons.photo_camera,
                      color: Colors.blueGrey,
                    ),
                    title: const TextWidget(
                      text: AppConstants.cmra,
                      fontSize: 14,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                    tileColor: Colors.blue.shade100,
                    onTap: () {
                      _pickImage(ImageSource.camera);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _fieldWidget({
    required TextEditingController controller,
    required String errorText,
    required String regErrorText,
    required RegExp regExpCondition,
    bool readOnly = false,
  }) {
    return CustomTextField(
      controller: controller,
      errorText: errorText,
      regErrorText: regErrorText,
      regExpCondition: regExpCondition,
      outlined: true,
      filled: true,
      isDence: true,
      readOnly: readOnly,
      fillColor: ColorsData.whiteColor,
      bRadius: 30,
      outPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 20.w),
      style: MyFont.poppins(
        fontSize: 12,
        color: const Color.fromARGB(255, 118, 118, 118),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _passField({
    required TextEditingController controller,
    required String errorText,
    required String regErrorText,
    required RegExp regExpCondition,
    required bool obscureText,
    required int suffixindex,
  }) {
    return CustomTextField(
      controller: controller,
      errorText: errorText,
      regErrorText: regErrorText,
      regExpCondition: regExpCondition,
      passField: true,
      obscureText: obscureText,
      outlined: true,
      filled: true,
      isDence: true,
      autoValidate: false,
      fillColor: ColorsData.whiteColor,
      bRadius: 30,
      outPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 20.w),
      style: MyFont.poppins(
        fontSize: 12,
        color: const Color.fromARGB(255, 118, 118, 118),
        fontWeight: FontWeight.bold,
      ),
      suffixIcon: buildSuffixIcon(suffixindex),
    );
  }

  Widget buildSuffixIcon(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (index == 0) {
            obscureText0 = !obscureText0;
          } else if (index == 1) {
            obscureText1 = !obscureText1;
          } else {
            obscureText2 = !obscureText2;
          }
        });
      },
      child: Icon(
        (index == 0 && obscureText0) ||
                (index == 1 && obscureText1) ||
                (index == 2 && obscureText2)
            ? Icons.visibility_off
            : Icons.visibility,
        size: 20.sp,
        color: ColorsData.blueShade,
      ),
    );
  }

  Widget buildTitle(BuildContext context) {
    return const Center(
      child: TextWidget(
        text: AppConstants.settings,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: ColorsData.whiteColor,
      ),
    );
  }

  Widget h1(String title) {
    return TextWidget(
      text: title,
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: const Color(0xff252525),
    );
  }

  Widget h2(String title) {
    return TextWidget(text: title, fontSize: 19, fontWeight: FontWeight.w600);
  }
}
