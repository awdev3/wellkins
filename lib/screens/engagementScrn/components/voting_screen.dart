import 'package:wellkins/constants/paths.dart';

import '../../../models/history_model.dart';
import '../../../models/woo_models.dart';
import '../../../utils/formatter.dart';
import '../../../widgets/custom_prompts.dart';
import '../engagement.dart';

class VotingScreen extends StatefulWidget {
  final PageController pageCntlr;
  const VotingScreen({super.key, required this.pageCntlr});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  bool loading = false;
  bool showVoted = false;

  @override
  void initState() {
    super.initState();
    getVoting();
  }

  Future<void> getVoting([bool isRefresh = false]) async {
    final wooProvider = getWooProvider(context);
    if (isRefresh) {
      await wooProvider.getHistory(context);
    } else if (wooProvider.historyList.isEmpty) {
      await wooProvider.getHistory(context);
    }
  }

  Future<void> onVoteTap(Project project, bool isSell) async {
    final userProvider = getUserProvider(context);
    final vote = Vote(
      vote: VoteItem(
        propId: project.id,
        userId: userProvider.user!.id,
        clientName:
            '${userProvider.user!.firstName} ${userProvider.user!.lastName}',
        propName: project.propertyName,
        voteType: isSell ? 0 : 1, // yes/sell/0  no/hold/1
      ),
    );

    setState(() => loading = true);
    final wooProvider = getWooProvider(context);
    await wooProvider.submitVote(vote, context).then((value) async {
      if (mounted) {
        // TODO will need change
        //  wait for api updation for getHistory mobile
        await wooProvider.getHistory(context);
        showVoted = value;
        setState(() => loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsData.trColor,
      body: Stack(
        children: [
          Column(
            children: [
              Spacers.sb10(),
              CommonTitles.title(text: AppConstants.voting, context: context),
              Spacers.sb5(),
              Expanded(
                child: DelayedDisplay(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.fromLTRB(3.w, 3.w, 3.w, 0),
                    padding: EdgeInsets.only(top: 10.w),
                    decoration: commonDecor,
                    child: showVoted ? buildVoteResponce() : buildVotingTile(),
                  ),
                ),
              ),
            ],
          ),
          if (loading) fullLoaderWhite,
        ],
      ),
    );
  }

  Widget buildVotingTile() {
    final radius = Radius.circular(40.r);
    return DelayedDisplay(
      child: ClipRRect(
        borderRadius: BorderRadius.only(topLeft: radius, topRight: radius),
        child: Consumer<WooProvider>(
          builder: (context, snapshot, child) {
            List<History> invList = [];

            final historyList = snapshot.historyList;

            for (final item in historyList) {
              final pId = item.project.id;
              final exists = invList.any(
                (invItem) => invItem.project.id == pId,
              );
              final isAvailableToVote = item.project.isVote;
              final isUserVoted = item.historyItem.isUserVoted;
              if (!exists && isAvailableToVote && !isUserVoted) {
                invList.add(item);
              }
            }

            return snapshot.historyLoad
                ? showLoader()
                : invList.isEmpty
                ? CustomPrompts.showEmptyInfo(
                    icon: Icons.edit_off_outlined,
                    text: AppConstants.noVote,
                  )
                : RefreshIndicator(
                    onRefresh: () => getVoting(true),
                    child: ListView.builder(
                      itemCount: invList.length,
                      itemBuilder: (context, index) {
                        final history = invList[index];
                        return projectTile(history);
                      },
                    ),
                  );
          },
        ),
      ),
    );
  }

  Widget projectTile(History history) {
    final project = history.project;
    return Card(
      elevation: 6.w,
      color: ColorsData.whiteColor,
      surfaceTintColor: ColorsData.whiteColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
      margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 20.w),
      child: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: buildImage(project)),
                Spacers.sbw20(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHeader(project),
                      Spacers.sb5(),
                      const Divider(
                        thickness: 2,
                        color: ColorsData.formHintColor,
                      ),
                      buildButtons(project),
                    ],
                  ),
                ),
              ],
            ),
            Spacers.sb10(),
            buildDetails(history),
            Spacers.sb10(),
            _notes(history),
            Spacers.sb10(),
            // viewDetailsButton(history.project, context),
          ],
        ),
      ),
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
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget buildDetails(History history) {
    final amount = getSameProperyOrders(
      history,
      context,
    ).fold(0.0, (pv, e) => pv + e.historyItem.investingAmount);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerItem(
            h1: AppConstants.totalInvestments,
            d1: Frmtr.frmtCurrency(amount),
          ),
          // headerItem(
          //   h1: AppConstants.totalApplications,
          //   d1: '${getSameProperyOrders(history, context).length}',
          // ),
        ],
      ),
    );
  }

  Widget _notes(History history) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: ColorsData.trColor),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 10.w),
          childrenPadding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.w),
          iconColor: Colors.black87,
          collapsedIconColor: Colors.black87,
          collapsedBackgroundColor: const Color.fromARGB(255, 240, 255, 243),
          backgroundColor: const Color.fromARGB(255, 240, 255, 243),
          // const Color(0xffE9E9E9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          title: const TextWidget(
            text: AppConstants.viewDetails,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          children: [
            TextWidget(
              text: history.project.voteDescp,
              fontSize: 10,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  // Widget viewDetailsButton(Project project, BuildContext ctx) {
  //   return customButton(
  //     title: AppConstants.viewDetails,
  //     height: 35,
  //     stadium: true,
  //     padding: EdgeInsets.symmetric(horizontal: 25.w),
  //     icon: Icon(
  //       Icons.remove_red_eye,
  //       color: ColorsData.whiteColor,
  //       size: 13.sp,
  //     ),
  //     shadows: [
  //       const BoxShadow(
  //         color: ColorsData.formHintColor,
  //         spreadRadius: 1,
  //         blurRadius: 1,
  //         offset: Offset(0, 1),
  //       ),
  //     ],
  //     buttonColor: Colors.green,
  //     fontSize: 12,
  //     onPressed: () {
  //       Navigator.push(
  //         ctx,
  //         FadeRoute(
  //           page: ProjectDetailsScreen(
  //             project: project,
  //             pageCntlr: widget.pageCntlr,
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget buildButtons(Project project) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buttonTile(
          title: AppConstants.yes,
          color: Colors.blue,
          onTap: () async => await onVoteTap(project, true),
        ),
        Spacers.sbw10(),
        buttonTile(
          title: AppConstants.no,
          color: Colors.red,
          onTap: () async => await onVoteTap(project, false),
        ),
      ],
    );
  }

  Widget buttonTile({
    required String title,
    required MaterialColor color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: customButton(
        title: title,
        height: 34,
        stadium: true,
        gradient: LinearGradient(colors: [color, color, color.shade900]),
        shadows: [
          const BoxShadow(
            color: ColorsData.formHintColor,
            spreadRadius: 1,
            blurRadius: 1,
            offset: Offset(0, 1),
          ),
        ],
        padding: EdgeInsets.zero,
        buttonColor: ColorsData.trColor,
        fontSize: 12,
        onPressed: onTap,
      ),
    );
  }

  Widget buildImage(Project project) {
    final images = project.images;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: AspectRatio(
        aspectRatio: 1.35,
        child: ImageWidget(
          image: images.isEmpty ? '' : images.first,
          fit: BoxFit.cover,
          errorWidget: Stack(
            alignment: Alignment.center,
            children: [
              bgImage,
              ImageWidget(width: 115.w, image: Paths.logo, fit: BoxFit.cover),
            ],
          ),
        ),
      ),
    );
  }

  Widget headerItem({required String h1, required String d1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(
            text: h1,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xff252525),
          ),
          Spacers.sbw30(),
          Flexible(
            flex: 5,
            child: TextWidget(
              text: d1,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xff252525),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVoteResponce() {
    return Card(
      elevation: 3,
      color: ColorsData.whiteColor,
      surfaceTintColor: ColorsData.whiteColor,
      margin: EdgeInsets.symmetric(vertical: 40.w, horizontal: 20.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 10.w),
        child: Column(
          children: [
            const TextWidget(
              text: AppConstants.thankYou,
              fontSize: 31,
              fontWeight: FontWeight.bold,
              color: Color(0xff252525),
            ),
            Spacers.sb25(),
            const Spacer(),
            CircleAvatar(
              radius: 104.r,
              backgroundColor: Colors.green.withValues(alpha: .09),
              child: CircleAvatar(
                radius: 75.72.r,
                backgroundColor: Colors.green.withValues(alpha: .1),
                child: Container(
                  height: 89.4.w,
                  width: 89.4.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xff2E692D), Color(0xff45A843)],
                    ),
                  ),
                  child: Icon(
                    Icons.done_rounded,
                    size: 50.w,
                    color: ColorsData.whiteColor,
                  ),
                ),
              ),
            ),
            const Spacer(flex: 3),
            const TextWidget(
              text: AppConstants.voteResponce,
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: Color(0xff252525),
              textAlign: TextAlign.center,
            ),
            Spacers.sb25(),
            customButton(
              title: AppConstants.goBack,
              height: 40,
              width: 100,
              fontSize: 15,
              buttonColor: Colors.green,
              stadium: true,
              onPressed: () {
                setState(() {
                  showVoted = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  List<History> getSameProperyOrders(History history, BuildContext ctx) {
    final wooProvider = getWooProvider(ctx);

    final pId = history.project.id;
    final samePropOrders = wooProvider.historyList
        .where((item) => item.project.id == pId)
        .toList();
    return samePropOrders;
  }
}
