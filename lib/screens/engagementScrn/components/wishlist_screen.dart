import '../../../constants/paths.dart';
import '../../../utils/extensions.dart';
import '../../../utils/formatter.dart';
import '../../../widgets/custom_prompts.dart';
import '../engagement.dart';
import 'project_details_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsData.trColor,
      body: Column(
        children: [
          Spacers.sb10(),
          CommonTitles.title(text: AppConstants.wishlist, context: context),
          Spacers.sb5(),
          Expanded(
            child: DelayedDisplay(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
                padding: EdgeInsets.only(top: 10.w),
                decoration: commonDecor,
                child: buildWishlist(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWishlist() {
    final radius = Radius.circular(40.r);
    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
      child: Consumer<WooProvider>(
        builder: (context, snapshot, child) {
          final wishList = snapshot.wishList;
          return snapshot.wishListLoad || snapshot.projectLoad
              ? showLoader()
              : wishList.isEmpty
              ? CustomPrompts.showEmptyInfo(
                  icon: Icons.favorite_border_outlined,
                  text: AppConstants.noWish,
                )
              : DelayedDisplay(
                  child: ListView.builder(
                    itemCount: wishList.length,
                    itemBuilder: (ctx, index) {
                      final fav = wishList[index];
                      return wishTile(fav.project, fav.id, ctx);
                    },
                  ),
                );
        },
      ),
    );
  }

  Widget wishTile(Project project, int favId, BuildContext ctx) {
    return Card(
      elevation: 6.w,
      color: ColorsData.whiteColor,
      surfaceTintColor: ColorsData.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35.r)),
      margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 20.w),
      child: Column(
        children: [
          buildImage(project),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildHeader(project),
                Spacers.sb5(),
                const Divider(color: ColorsData.formHintColor),
                buildDetails(project),
                Spacers.sb20(),
                buildButtons(project, favId, ctx),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtons(Project project, int favId, BuildContext ctx) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.w),
      child: Row(
        children: [
          WishRemoveButton(favId: favId),
          viewDetailsButton(ctx, project),
        ],
      ),
    );
  }

  Widget viewDetailsButton(BuildContext ctx, Project project) {
    return Expanded(
      child: customButton(
        title: AppConstants.viewDetails,
        height: 35,
        stadium: true,
        icon: Icon(
          Icons.remove_red_eye,
          color: ColorsData.whiteColor,
          size: 13.sp,
        ),
        shadows: [
          const BoxShadow(
            color: ColorsData.formHintColor,
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
        buttonColor: Colors.green,
        fontSize: 11,
        onPressed: () {
          Navigator.push(
            ctx,
            FadeRoute(
              page: ProjectDetailsScreen(project: project, fromWish: true),
            ),
          );
        },
      ),
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

  Widget buildImage(Project project) {
    final color = _getStatusColor(project.status);
    final images = project.images;

    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(35.r),
            bottom: Radius.circular(10.r),
          ),
          child: AspectRatio(
            aspectRatio: 2.4,
            child: ImageWidget(
              image: images.isEmpty ? '' : images.first,
              fit: BoxFit.cover,
              errorWidget: Stack(
                alignment: Alignment.center,
                children: [
                  bgImage,
                  ImageWidget(
                    width: 180.w,
                    image: Paths.logo,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          ),
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
          constraints: BoxConstraints(minWidth: 100.w),
          child: TextWidget(
            text: project.status,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: ColorsData.whiteColor,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget buildHeader(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: project.propertyName,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        TextWidget(
          text: project.propType,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          letterSpacing: 1.1,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: AppConstants.minInv,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xff252525),
              letterSpacing: 1.1,
            ),
            const Spacer(),
            TextWidget(
              text: Frmtr.frmtCurrency(project.minInvestment.toDouble),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xff252525),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildDetails(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        headerItem(h1: AppConstants.term, d1: project.term),
        headerItem(
          h1: project.fundType == 1
              ? AppConstants.loanAmount
              : AppConstants.value,
          d1: Frmtr.frmtCurrency(project.facility),
        ),
        if (project.fundType == 1)
          headerItem(h1: AppConstants.lvr, d1: project.lvr),
        if (project.fundType == 1)
          headerItem(h1: AppConstants.returns, d1: project.returns),
      ],
    );
  }

  Widget headerItem({
    required String h1,
    required String d1,
    EdgeInsetsGeometry? padding,
  }) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: 2.h, horizontal: 15.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: TextWidget(
              text: h1,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xff252525),
            ),
          ),
          const Spacer(),
          Flexible(
            child: TextWidget(
              text: d1,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xff252525),
            ),
          ),
        ],
      ),
    );
  }
}

class WishRemoveButton extends StatefulWidget {
  final int favId;
  const WishRemoveButton({super.key, required this.favId});

  @override
  State<WishRemoveButton> createState() => _WishRemoveButtonState();
}

class _WishRemoveButtonState extends State<WishRemoveButton> {
  bool isLoading = false;

  Future<void> _removeTap(int favId, BuildContext ctx) async {
    if (mounted) {
      setState(() => isLoading = true);
    }
    final wooProvider = getWooProvider(ctx);
    await wooProvider.removeFromWishList(favId: favId, ctx: ctx);
    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Expanded(child: showLoader(size: 14))
        : Expanded(
            child: customButton(
              title: AppConstants.removeItem,
              icon: Icon(
                Icons.remove_shopping_cart,
                color: ColorsData.whiteColor,
                size: 13.sp,
              ),
              height: 35,
              stadium: true,
              shadows: shadows,
              padding: EdgeInsets.zero,
              buttonColor: Colors.blue,
              fontSize: 11,
              onPressed: () async => _removeTap(widget.favId, context),
            ),
          );
  }

  List<BoxShadow> get shadows {
    return [
      const BoxShadow(
        color: ColorsData.formHintColor,
        spreadRadius: 1,
        blurRadius: 1,
        offset: Offset(0, 1),
      ),
    ];
  }
}

// import '../../../utils/formatter.dart';
// import '../../../widgets/custom_prompts.dart';
// import '../engagement.dart';
// import 'project_details_screen.dart';

// class WishlistScreen extends StatelessWidget {
//   const WishlistScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorsData.trColor,
//       body: Column(
//         children: [
//           Spacers.sb10(),
//           CommonTitles.title(
//             text: AppConstants.wishlist,
//             context: context,
//           ),
//           Spacers.sb5(),
//           Expanded(
//             child: DelayedDisplay(
//               child: Container(
//                 width: double.infinity,
//                 margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
//                 padding: EdgeInsets.fromLTRB(10.w, 20.w, 10.w, 0),
//                 decoration: commonDecor,
//                 child: buildWishlistTile(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildWishlistTile() {
//     return Consumer<WooProvider>(
//       builder: (context, snapshot, child) {
//         final wishList = snapshot.wishList;
//         return snapshot.wishListLoad || snapshot.projectLoad
//             ? showLoader()
//             : wishList.isEmpty
//                 ? CustomPrompts.showEmptyInfo(
//                     icon: Icons.favorite_border_outlined,
//                     text: AppConstants.noWish,
//                   )
//                 : DelayedDisplay(
//                     child: ListView.builder(
//                       itemCount: wishList.length,
//                       itemBuilder: (context, index) {
//                         final favorite = wishList[index];
//                         return favoriteTile(snapshot, favorite, context);
//                       },
//                     ),
//                   );
//       },
//     );
//   }

//   Widget favoriteTile(
//     WooProvider snapshot,
//     Favorite favorite,
//     BuildContext ctx,
//   ) {
//     return SizedBox(
//       height: 230.h,
//       child: Card(
//         elevation: 6,
//         color: ColorsData.whiteColor,
//         surfaceTintColor: ColorsData.whiteColor,
//         shape:
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
//         margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 5.w),
//         child: Padding(
//           padding: EdgeInsets.all(10.w),
//           child: Row(
//             children: [
//               Expanded(child: buildImage(favorite.project)),
//               Spacers.sbw20(),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     buildHeader(favorite.project),
//                     Spacers.sb5(),
//                     const Divider(color: ColorsData.formHintColor),
//                     buildDetails(favorite.project),
//                     const Spacer(),
//                     buildButtons(snapshot, favorite, ctx),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildButtons(
//     WooProvider snapshot,
//     Favorite favorite,
//     BuildContext ctx,
//   ) {
//     return Row(
//       children: [
//         WishRemoveButton(favId: favorite.id),
//         Spacers.sbw10(),
//         buttonTile(
//           title: AppConstants.viewDetails,
//           color: Colors.green,
//           onTap: () {
//             Navigator.push(
//               ctx,
//               FadeRoute(
//                 page: ProjectDetailsScreen(
//                   project: favorite.project,
//                   fromWish: true,
//                 ),
//               ),
//             );
//           },
//         ),
//       ],
//     );
//   }

//   Widget buttonTile({
//     required String title,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return Expanded(
//       child: customButton(
//         title: title,
//         height: 30,
//         stadium: true,
//         shadows: [
//           const BoxShadow(
//             color: ColorsData.formHintColor,
//             spreadRadius: 1,
//             blurRadius: 1,
//             offset: Offset(0, 1),
//           ),
//         ],
//         padding: EdgeInsets.zero,
//         buttonColor: color,
//         fontSize: 10,
//         onPressed: onTap,
//       ),
//     );
//   }

//   Widget buildImage(Project project) {
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(20.r),
//       child: ImageWidget(
//         height: double.infinity,
//         width: double.infinity,
//         image: project.images[0],
//         fit: BoxFit.cover,
//       ),
//     );
//   }

//   Widget buildHeader(Project project) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextWidget(
//           text: project.propertyName,
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//         ),
//         TextWidget(
//           text: project.propType,
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//         ),
//       ],
//     );
//   }

//   Widget buildDetails(Project project) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         headerItem(
//           h1: AppConstants.term,
//           d1: project.term,
//         ),
//         headerItem(
//           h1: project.fundType == 1
//               ? AppConstants.loanAmount
//               : AppConstants.value,
//           d1: Frmtr.frmtCurrency(project.facility),
//         ),
//         if (project.fundType == 1)
//           headerItem(
//             h1: AppConstants.lvr,
//             d1: project.lvr,
//           ),
//         if (project.fundType == 1)
//           headerItem(
//             h1: AppConstants.returns,
//             d1: project.returns,
//           ),
//       ],
//     );
//   }

//   Widget headerItem({
//     required String h1,
//     required String d1,
//   }) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 1.h),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Flexible(
//             child: TextWidget(
//               text: h1,
//               fontSize: 10.5,
//               fontWeight: FontWeight.w600,
//               color: const Color(0xff252525),
//             ),
//           ),
//           Spacers.sbw10(),
//           Flexible(
//             flex: 2,
//             child: TextWidget(
//               text: d1,
//               fontSize: 10.5,
//               fontWeight: FontWeight.w600,
//               color: const Color(0xff252525),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

// class WishRemoveButton extends StatefulWidget {
//   final int favId;
//   const WishRemoveButton({super.key, required this.favId});

//   @override
//   State<WishRemoveButton> createState() => _WishRemoveButtonState();
// }

// class _WishRemoveButtonState extends State<WishRemoveButton> {
//   bool isLoading = false;

//   Future<void> _removeTap(int favId, BuildContext ctx) async {
//     if (mounted) {
//       setState(() => isLoading = true);
//     }
//     final wooProvider = getWooProvider(ctx);
//     await wooProvider.removeFromWishList(favId: favId, ctx: ctx);
//     if (mounted) {
//       setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return isLoading
//         ? Expanded(child: showLoader(size: 14))
//         : Expanded(
//             child: customButton(
//               title: AppConstants.remove,
//               height: 30,
//               stadium: true,
//               shadows: shadows,
//               padding: EdgeInsets.zero,
//               buttonColor: Colors.blue,
//               fontSize: 10,
//               onPressed: () async => _removeTap(widget.favId, context),
//             ),
//           );
//   }

//   List<BoxShadow> get shadows {
//     return [
//       const BoxShadow(
//         color: ColorsData.formHintColor,
//         spreadRadius: 1,
//         blurRadius: 1,
//         offset: Offset(0, 1),
//       ),
//     ];
//   }
// }
