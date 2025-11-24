import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../services/helpers.dart';
import '../../widgets/backgrounds.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/spacers.dart';
import 'engagement_tabs.dart';
import 'components/projects_screen.dart';
import 'components/voting_screen.dart';
import 'components/wishlist_screen.dart';

class EngagementScreen extends StatefulWidget {
  final int index;

  const EngagementScreen({super.key, this.index = 0});

  @override
  State<EngagementScreen> createState() => _EngagementScreenState();
}

class _EngagementScreenState extends State<EngagementScreen> {
  late PageController pageCntlr;

  List<Widget> get tabScreens {
    return [
      ProjectsScreen(pageCntlr: pageCntlr),
      VotingScreen(pageCntlr: pageCntlr),
      const WishlistScreen(),
    ];
  }

  @override
  void initState() {
    super.initState();
    getEngagements();
  }

  Future<void> getEngagements() async {
    final wooProvider = getWooProvider(context);
    pageCntlr = PageController(initialPage: widget.index);
    wooProvider.tabIndex = widget.index; //changes header tile
    executePostFrameCallback(() async {
      await wooProvider.getProjects(context);
      if (mounted) {
        await wooProvider.getWishList(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        bgImage,
        Scaffold(
          backgroundColor: ColorsData.trColor,
          extendBody: true,
          appBar: CustomAppBar.appbar(ctx: context, animate: false),
          body: Column(
            children: [
              Spacers.sb8(),
              EngagementTabs(pageCntlr: pageCntlr),
              Expanded(
                child: PageView(
                  pageSnapping: false,
                  controller: pageCntlr,
                  physics: const NeverScrollableScrollPhysics(),
                  children: tabScreens,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
