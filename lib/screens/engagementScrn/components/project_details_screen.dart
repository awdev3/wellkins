import 'package:wellkins/constants/paths.dart';
import 'package:wellkins/widgets/dot_pointer.dart';

import '../engagement.dart';
import 'application_form_manual.dart';
import 'docs_widget.dart';
import 'wish_add_button.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Project project;
  final bool fromWish;
  final PageController? pageCntlr;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
    this.fromWish = false,
    this.pageCntlr,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  bool consent = false;
  int _selImageIndex = 0;
  // bool submitting = false;
  // bool submitted = false;
  // bool downloading = false;
  // final _formKey = GlobalKey<FormState>();
  // final unitCntlr = TextEditingController();
  // final amountCntlr = TextEditingController();

  Future<void> _submitTap() async {
    Navigator.push(
      context,
      FadeRoute(
        // page: ApplicationForm(
        //   propId: widget.project.id,
        //   propName: widget.project.propertyName,
        //   fundSubType: widget.project.fundSubType,
        // ),
        //TODO: Enable after testing
        page: ApplicationFormManual(),
      ),
    );
  }

  // Future<void> _submitTap() async {
  //   final isvalid = _formKey.currentState!.validate();
  //   dismissInputFocus(context);
  //   if (isvalid) {
  //     if (mounted) {
  //       setState(() => submitting = true);
  //     }

  //     await delayedCallback(milliseconds: 1000, () {}).whenComplete(() {
  //       if (mounted) {
  //         setState(() {
  //           submitting = false;
  //           submitted = true;
  //           unitCntlr.clear();
  //           amountCntlr.clear();
  //         });
  //       }
  //     });
  //   }
  // }

  // void onAmtInvested(String amt) {
  //   final cAmt = amt.replaceAll(',', '');
  //   unitCntlr.text = (cAmt.toDouble / widget.project.pricePerShare).toNrString;
  // }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        bgImage,
        Scaffold(
          backgroundColor: ColorsData.trColor,
          resizeToAvoidBottomInset: false,
          appBar: CustomAppBar.appbar(ctx: context),
          body: Column(
            children: [
              CommonTitles.title(text: AppConstants.projects, context: context),
              Spacers.sb10(),
              Expanded(
                child: DelayedDisplay(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
                    padding: EdgeInsets.only(top: 10.w),
                    decoration: commonDecor,
                    child: buildProjectDetails(),
                    // submitted ? buildInvResponce() : buildProjectDetails(),
                  ),
                ),
              ),
            ],
          ),
        ),
        // if (submitting) fullLoaderWhite
      ],
    );
  }

  Widget buildProjectDetails() {
    final radius = Radius.circular(40.r);
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
      child: SingleChildScrollView(
        child: DelayedDisplay(
          child: Card(
            elevation: 6.h,
            color: ColorsData.whiteColor,
            surfaceTintColor: ColorsData.whiteColor,
            margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: _projectDetails(),
          ),
        ),
      ),
    );
  }

  Column _projectDetails() {
    final status = widget.project.status.toLowerCase();
    final isOver = status == 'closed' || status == 'completed';
    final isUpcoming = status == 'upcoming';
    return Column(
      children: [
        _buildImages(),
        Spacers.sb10(),
        buildHeader(),
        _divider(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _projectDespn(),
              Spacers.sb15(),
              if (!isOver) ...[
                Docs.buildPDSButtons(widget.project, context),
                Spacers.sb15(),
                Docs.buildDownloadFileAndPP(widget.project, context),
                Spacers.sb10(),
                if (!isUpcoming) ...[
                  _buildDeclaration(),
                  Spacers.sb10(),
                  _buildButtons(),
                  Spacers.sb30(),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'trending':
        return Colors.green;
      case 'upcoming':
        return Colors.blue;
      case 'closed':
        return Colors.red;
      default:
        return ColorsData.greyColor;
    }
  }

  Widget _buildImages() {
    final prjct = widget.project;
    final images = prjct.images;
    final color = _getStatusColor(prjct.status);
    return SizedBox(
      height: 207.h,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          images.isEmpty
              ? Stack(
                  alignment: Alignment.center,
                  children: [
                    bgImage,
                    ImageWidget(
                      width: 180.w,
                      image: Paths.logo,
                      fit: BoxFit.cover,
                    ),
                  ],
                )
              : PageView.builder(
                  itemCount: images.length,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (v) => setState(() => _selImageIndex = v),
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: .5.w),
                      child: ImageWidget(
                        image: images[index],
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
          Container(
            margin: EdgeInsets.all(30.w),
            padding: EdgeInsets.fromLTRB(12.w, 2.w, 12.w, 2.w),
            decoration: ShapeDecoration(
              color: color,
              shape: const StadiumBorder(
                side: BorderSide(color: ColorsData.whiteColor),
              ),
            ),
            child: TextWidget(
              text: prjct.status,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ColorsData.whiteColor,
            ),
          ),
          if (images.length > 1)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: EdgeInsets.only(bottom: 5.w),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: ShapeDecoration(
                  color: ColorsData.blackColor.withValues(alpha: .5),
                  shape: const StadiumBorder(),
                ),
                child: DotPointer(
                  pageCount: images.length,
                  selectedIndex: _selImageIndex,
                  primaryColor: ColorsData.whiteColor,
                  secondaryColor: ColorsData.whiteColor.withValues(alpha: .5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 2,
            child: TextWidget(
              text: widget.project.propertyName,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacers.sbw30(),
          WishAddButton(
            project: widget.project,
            fromWish: widget.fromWish,
            fromDetails: true,
            pageCntlr: widget.pageCntlr,
          ),
        ],
      ),
    );
  }

  Divider _divider() {
    return Divider(
      indent: 15.w,
      endIndent: 15.w,
      color: const Color.fromARGB(100, 0, 0, 0),
    );
  }

  TextWidget _projectDespn() {
    return TextWidget(
      text: widget.project.desc,
      fontSize: 10.5,
      fontWeight: FontWeight.w500,
      height: 2,
      textAlign: TextAlign.justify,
    );
  }

  // Widget _buildFields() {
  //   return
  //       // Form(
  //       //   key: _formKey,
  //       //   child:
  //       Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       RichTextWidget(
  //         text: '• ${AppConstants.pricePer}',
  //         style: MyFont.poppins(
  //           fontSize: 10.5,
  //           fontWeight: FontWeight.w500,
  //         ),
  //         children: [
  //           TextSpan(
  //             text: Frmtr.frmtCurrency(widget.project.pricePerShare),
  //             style: MyFont.poppins(
  //               fontSize: 10.5,
  //               fontWeight: FontWeight.w500,
  //               color: Colors.red,
  //             ),
  //           )
  //         ],
  //       ),
  //       Spacers.sb10(),
  //       // _formheader(AppConstants.amountInvested),
  //       // _formField(amountCntlr, 20),
  //       // Spacers.sb10(),
  //       // _formheader(AppConstants.unitToInvest),
  //       // _formField(unitCntlr),
  //     ],
  //     // ),
  //   );
  // }

  // Widget _formheader(String labelText) {
  //   return TextWidget(
  //     text: labelText,
  //     fontSize: 11,
  //     fontWeight: FontWeight.w400,
  //     height: 2,
  //     textAlign: TextAlign.justify,
  //   );
  // }

  // Widget _formField(TextEditingController controller, [int? maxLength]) {
  //   return SizedBox(
  //     width: 145.w,
  //     child: CustomTextField(
  //       controller: controller,
  //       regExpCondition: Regx.doubleRegExp,
  //       errorText: AppConstants.emptyError,
  //       outlined: true,
  //       isDouble: true,
  //       filled: true,
  //       isDence: true,
  //       bRadius: 5,
  //       readOnly: controller == unitCntlr,
  //       maxLength: maxLength,
  //       prefix: controller == amountCntlr
  //           ? const TextWidget(
  //               text: '\$',
  //               fontSize: 10,
  //               fontWeight: FontWeight.w400,
  //             )
  //           : null,
  //       onChanged:
  //           controller == amountCntlr ? (amt) => onAmtInvested(amt) : null,
  //       style: MyFont.poppins(fontSize: 10),
  //       errorStyle: TextStyleData.formErrorStyle.copyWith(fontSize: 8),
  //       fillColor: ColorsData.whiteColor,
  //       outPadding: EdgeInsets.symmetric(
  //         vertical: 8.h,
  //         horizontal: 10.w,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildDeclaration() {
    return Row(
      children: [
        Transform.scale(
          scale: 1.h,
          child: Checkbox(
            value: consent,
            side: const BorderSide(color: ColorsData.greyColor),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onChanged: (v) {
              setState(() {
                consent = v!;
              });
            },
          ),
        ),
        Spacers.sbw5(),
        const Flexible(
          child: TextWidget(
            text: AppConstants.investDeclaration,
            fontSize: 9,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buttonTile(
            title: AppConstants.close,
            color: const Color.fromARGB(203, 255, 86, 86),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          Spacers.sbw10(),
          Opacity(
            opacity: consent ? 1 : .4,
            child: AbsorbPointer(
              absorbing: !consent,
              child: _buttonTile(
                title: AppConstants.next,
                color: Colors.green,
                onTap: () async => await _submitTap(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buttonTile({
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return customButton(
      title: title,
      height: 33,
      width: 80,
      fontSize: 13,
      stadium: true,
      padding: EdgeInsets.zero,
      shadows: [
        const BoxShadow(
          color: ColorsData.formHintColor,
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ],
      buttonColor: color,
      onPressed: onTap,
    );
  }

  // Widget buildInvResponce() {
  //   return Card(
  //     elevation: 3,
  //     color: ColorsData.whiteColor,
  //     surfaceTintColor: ColorsData.whiteColor,
  //     margin: EdgeInsets.symmetric(vertical: 40.w, horizontal: 20.w),
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(30.r),
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 10.w),
  //       child: Column(
  //         children: [
  //           const TextWidget(
  //             text: AppConstants.thankYou,
  //             fontSize: 31,
  //             fontWeight: FontWeight.bold,
  //             color: Color(0xff252525),
  //           ),
  //           Spacers.sb25(),
  //           const Spacer(),
  //           CircleAvatar(
  //             radius: 104.r,
  //             backgroundColor: Colors.green.withValues(alpha: .09),
  //             child: CircleAvatar(
  //               radius: 75.72.r,
  //               backgroundColor: Colors.green.withValues(alpha: .1),
  //               child: Container(
  //                 height: 89.4.w,
  //                 width: 89.4.w,
  //                 decoration: const BoxDecoration(
  //                   shape: BoxShape.circle,
  //                   gradient: LinearGradient(
  //                     colors: [
  //                       Color(0xff2E692D),
  //                       Color(0xff45A843),
  //                     ],
  //                   ),
  //                 ),
  //                 child: Icon(
  //                   Icons.done_rounded,
  //                   size: 50.w,
  //                   color: ColorsData.whiteColor,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           const Spacer(flex: 3),
  //           const TextWidget(
  //             text: AppConstants.invResponce,
  //             fontSize: 18,
  //             fontWeight: FontWeight.w300,
  //             color: Color(0xff252525),
  //             textAlign: TextAlign.center,
  //           ),
  //           Spacers.sb40(),
  //           Spacers.sb40(),
  //           Row(
  //             children: [
  //               Expanded(
  //                 child: customButton(
  //                   title: AppConstants.goBack,
  //                   height: 45,
  //                   fontSize: 15,
  //                   buttonColor: Colors.green,
  //                   stadium: true,
  //                   onPressed: () {
  //                     setState(() {
  //                       submitted = false;
  //                     });
  //                   },
  //                 ),
  //               ),
  //               Spacers.sbw10(),
  //               Expanded(
  //                 child: customButton(
  //                   title: AppConstants.visitWeb,
  //                   height: 45,
  //                   fontSize: 15,
  //                   buttonColor: Colors.green,
  //                   stadium: true,
  //                   onPressed: () {
  //                     tryLaunchUrl(
  //                       url: Paths.website,
  //                       message: AppConstants.error,
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

// const TextWidget(
//   text: AppConstants.unitToInvest,
//   fontSize: 11,
//   fontWeight: FontWeight.w400,
//   height: 2,
//   textAlign: TextAlign.justify,
// ),
// SizedBox(
//   width: 145.w,
//   child: CustomTextField(
//     controller: unitCntlr,
//     regExpCondition: Regx.phoneRegExp,
//     regErrorText: AppConstants.emptyError,
//     outlined: true,
//     digit: true,
//     filled: true,
//     isDence: true,
//     bRadius: 5,
//     fillColor: ColorsData.whiteColor,
//     style: MyFont.poppins(fontSize: 8),
//     outPadding: const EdgeInsets.symmetric(
//       vertical: 6,
//       horizontal: 10,
//     ),
//   ),
// ),
// Spacers.sb10(),
// const TextWidget(
//   text: AppConstants.amountInvested,
//   fontSize: 11,
//   fontWeight: FontWeight.w400,
//   height: 2,
//   textAlign: TextAlign.justify,
// ),
// SizedBox(
//   width: 145.w,
//   child: CustomTextField(
//     controller: amountCntlr,
//     regExpCondition: Regx.phoneRegExp,
//     regErrorText: AppConstants.emptyError,
//     outlined: true,
//     digit: true,
//     filled: true,
//     isDence: true,
//     bRadius: 5,
//     maxLength: 20,
//     style: MyFont.poppins(fontSize: 8),
//     fillColor: ColorsData.whiteColor,
//     outPadding: const EdgeInsets.symmetric(
//       vertical: 6,
//       horizontal: 10,
//     ),
//   ),
// ),
