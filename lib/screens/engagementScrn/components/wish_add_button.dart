import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/colors.dart';
import '../../../constants/strings.dart';
import '../../../models/project_model.dart';
import '../../../services/helpers.dart';
import '../../../widgets/button_widgets.dart';
import '../../../widgets/loaders.dart';

class WishAddButton extends StatefulWidget {
  final Project project;
  final PageController? pageCntlr;
  final bool fromWish;
  final bool fromDetails;
  const WishAddButton({
    super.key,
    required this.project,
    this.pageCntlr,
    this.fromWish = false,
    this.fromDetails = false,
  });

  @override
  State<WishAddButton> createState() => _WishAddButtonState();
}

class _WishAddButtonState extends State<WishAddButton> {
  bool isLoading = false;
  bool inWish = false;

  @override
  void initState() {
    super.initState();
    _checkInWish();
  }

  void _checkInWish() {
    final wooProvider = getWooProvider(context);
    final wishList = wooProvider.wishList;
    for (int i = 0; i < wishList.length; i++) {
      if (wishList[i].project.id == widget.project.id) {
        inWish = true;
      }
    }
  }

  Future<void> _wishListTap(int propId, bool inWish) async {
    final wooProvider = getWooProvider(context);
    if (inWish) {
      if (widget.fromWish) {
        Navigator.pop(context);
      } else {
        if (widget.fromDetails) {
          Navigator.pop(context);
          wooProvider.changeTab(2);
          widget.pageCntlr!.jumpToPage(2);
        } else {
          wooProvider.changeTab(2);
          widget.pageCntlr!.jumpToPage(2);
        }
      }
    } else {
      _setLoading(true);
      await wooProvider.addToWishList(widget.project, context);
      _checkInWish();
      _setLoading(false);
    }
  }

  void _setLoading(bool cndn) {
    if (mounted) {
      setState(() => isLoading = cndn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Expanded(child: showLoader(size: widget.fromWish ? 20 : 24))
        : buttonTile(
            title:
                inWish ? AppConstants.viewWishlist : AppConstants.addToWishlist,
            icon: Icons.shopping_cart,
            color: Colors.blue,
            gradient: inWish,
            onTap: () => _wishListTap(widget.project.id, inWish),
          );
  }

  Widget buttonTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool gradient = false,
  }) {
    final propStatus = widget.project.status.toLowerCase();
    final isOver = propStatus == 'closed' || propStatus == 'completed';
    return Expanded(
      child: AbsorbPointer(
        absorbing: isOver && !inWish,
        child: Opacity(
          opacity: isOver && !inWish ? 0.2 : 1,
          child: customButton(
            title: title,
            height: widget.fromDetails ? 24 : 35,
            stadium: true,
            icon: Icon(
              icon,
              color: ColorsData.whiteColor,
              size: widget.fromDetails ? 9.sp : 13.sp,
            ),
            gradient: !gradient
                ? null
                : LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.blue,
                      Colors.blue.shade900,
                    ],
                  ),
            shadows: [
              const BoxShadow(
                color: ColorsData.formHintColor,
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
            buttonColor: !gradient ? color : ColorsData.trColor,
            fontSize: widget.fromDetails ? 8 : 11,
            onPressed: onTap,
          ),
        ),
      ),
    );
  }
}
