import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/strings.dart';
import '../models/favorite_models.dart';
import '../models/history_model.dart';
import '../models/project_model.dart';
import '../models/returns_model.dart';
import '../models/taxreturn_model.dart';
import '../models/transaction_model.dart';
import '../models/woo_models.dart';
import '../services/api_service.dart';
import '../services/helpers.dart';
import '../utils/console_util.dart';
import '../utils/extensions.dart';
import '../widgets/toasts.dart';

class WooProvider extends ChangeNotifier {
  bool projectLoad = false;
  bool votingLoad = false;
  bool wishListLoad = false;
  bool historyLoad = false;
  bool returnsLoad = false;
  bool transLoad = false;
  bool showContest = false;
  bool newsLoad = false;

  int tabIndex = -1;

  List<Project> projectsList = [];
  List<Favorite> wishList = [];
  List<History> historyList = [];
  List<ReturnsData> returnsList = [];
  List<ContestDetails> contestDetails = [];
  List<NewsAndInsights> newsAndInsights = [];

  setProjectLoad(bool cndn) {
    projectLoad = cndn;
    notifyListeners();
  }

  setWishLoad(bool cndn) {
    wishListLoad = cndn;
    notifyListeners();
  }

  void changeTab(int index) {
    tabIndex = index;
    notifyListeners();
  }

  Future<void> getProjects(BuildContext ctx) async {
    setProjectLoad(true);
    projectsList.clear();

    try {
      final userProvider = getUserProvider(ctx);
      final body = historyToJson(ClientDetail(clientId: userProvider.user!.id));

      final data = await ApiService().postDataToApi(
        api: 'property/getPropertyMobile?',
        headers: userProvider.headers,
        payload: body,
      );

      final msg = data["message"] ?? data['error'];

      if (msg == 'Property Images') {
        projectsList = projectsFromJson(data);
      } else {
        showToast(message: msg);
      }
    } catch (e, st) {
      // showToast(message: AppConstants.error);
      printData(title: 'from getProjects', data: '$e,$st', e: true);
    } finally {
      setProjectLoad(false);
    }
  }

  Future<void> getWishList(BuildContext ctx) async {
    setWishLoad(true);
    wishList.clear();

    try {
      final userProvider = getUserProvider(ctx);
      final body = favoriteToJson(GetFavorite(userId: userProvider.user!.id));

      final data = await ApiService().postDataToApi(
        api: 'favourite/getAllFavouriteList?',
        headers: userProvider.headers,
        payload: body,
      );

      final msg = data["message"] ?? data['error'];

      if (msg == 'Success') {
        final wishListItems = tempFavFromJson(data);

        for (final project in projectsList) {
          for (final fav in wishListItems) {
            if (fav.propId == project.id) {
              wishList.add(
                Favorite(
                  id: fav.favId,
                  project: project,
                ),
              );
            }
          }
        }
      } else {
        showToast(message: msg);
      }
    } catch (e) {
      // showToast(message: AppConstants.error);
      printData(title: 'from getWishList', data: '$e', e: true);
    } finally {
      setWishLoad(false);
    }
  }

  Future<void> addToWishList(Project project, BuildContext ctx) async {
    try {
      final userProvider = getUserProvider(ctx);

      final body = addFavoriteToJson(
        FavoriteData(
          addFavourite: AddFavourite(
            userId: userProvider.user!.id,
            propId: project.id,
          ),
        ),
      );

      final data = await ApiService().postDataToApi(
        api: 'favourite/addFavorite?',
        headers: userProvider.headers,
        payload: body,
      );

      final msg = data["message"] ?? data['error'];

      if (msg == 'created') {
        final favId = data["create_enq"]["id"];
        wishList.add(
          Favorite(
            id: favId,
            project: project,
          ),
        );
      } else {
        showToast(message: msg);
      }
    } catch (e) {
      showToast(message: AppConstants.error);
      printData(title: 'from addToWishList', data: '$e', e: true);
    }
  }

  Future<void> removeFromWishList({
    required int favId,
    required BuildContext ctx,
  }) async {
    try {
      final userProvider = getUserProvider(ctx);

      final body = removeFavoriteToJson(RemoveFavorite(id: favId));

      final data = await ApiService().postDataToApi(
        api: 'favourite/delete?',
        headers: userProvider.headers,
        payload: body,
      );

      final msg = data["message"] ?? data['error'];

      if (msg == 'Delete') {
        wishList.removeWhere((e) => e.id == favId);
      } else {
        showToast(message: msg);
      }
    } catch (e) {
      showToast(message: AppConstants.error);
      printData(title: 'from removeFromWishList', data: '$e', e: true);
    }
    notifyListeners();
  }

  Future<void> getHistory(BuildContext ctx) async {
    historyLoad = true;

    try {
      final userProvider = getUserProvider(ctx);
      final body = historyToJson(ClientDetail(clientId: userProvider.user!.id));

      final data = await ApiService().postDataToApi(
        api: 'order/getOrder?',
        headers: userProvider.headers,
        payload: body,
      );

      historyList.clear();
      notifyListeners();

      final msg = data["message"] ?? data['error'];

      if (msg == 'Success') {
        final historyItems = historyItemFromJson(data);

        for (final project in projectsList) {
          for (final item in historyItems) {
            if (item.propId == project.id) {
              historyList.add(
                History(
                  historyItem: item,
                  project: project,
                ),
              );
            }
          }
        }
        historyList.sort((a, b) {
          final statusA = a.project.status.toLowerCase();
          final statusB = b.project.status.toLowerCase();
          const tr = 'trending';
          const up = 'upcoming';
          const cp = 'closed';
          if (statusA == tr) {
            return -1;
          } else if (statusA == up && statusB != tr) {
            return -1;
          } else if (statusA == cp && statusB != tr && statusB != up) {
            return -1;
          } else {
            return 1;
          }
        });
      } else {
        showToast(message: msg);
      }
    } catch (e) {
      // showToast(message: AppConstants.error);
      printData(title: 'from getHistory', data: '$e', e: true);
    } finally {
      historyLoad = false;
    }
    notifyListeners();
  }

  Future<void> getReturns(BuildContext ctx) async {
    returnsLoad = true;
    returnsList.clear();
    try {
      final userProvider = getUserProvider(ctx);
      final body = historyToJson(ClientDetail(clientId: userProvider.user!.id));

      final data = await ApiService().postDataToApi(
        api: 'returns/get?', // 'order/getReturnById?',
        headers: userProvider.headers,
        payload: body,
      );

      final msg = data["message"] ?? data['error'];
      if (msg == 'Success') {
        returnsList = returnsDataFromJson(data);
      } else {
        showToast(message: msg);
      }
    } catch (e) {
      // showToast(message: AppConstants.error);
      printData(title: 'from getReturns', data: '$e', e: true);
    } finally {
      returnsLoad = false;
    }
    notifyListeners();
  }

  Future<List<Transaction>> getTransactions(
    GetTransaction getTrns,
    BuildContext ctx,
  ) async {
    transLoad = true;
    List<Transaction> transList = [];
    try {
      final userProvider = getUserProvider(ctx);
      final body = getTrnsToJson(getTrns);

      final data = await ApiService().postDataToApi(
        api: 'order/get-transaction?',
        headers: userProvider.headers,
        payload: body,
      );

      final msg = data["message"] ?? data['error'];
      if (msg == 'Success') {
        transList = transactionsFromJson(data);
      } else {
        showToast(message: msg);
      }
    } catch (e) {
      // showToast(message: AppConstants.error);
      printData(title: 'from getTransactions', data: '$e', e: true);
    } finally {
      transLoad = false;
    }
    notifyListeners();
    return transList;
  }

  Future<bool> submitVote(Vote vote, BuildContext ctx) async {
    bool voted = false;

    try {
      final userProvider = getUserProvider(ctx);
      final body = voteToJson(vote);

      final data = await ApiService().postDataToApi(
        api: 'Voting/addVote?',
        headers: userProvider.headers,
        payload: body,
      );

      final msg = data["message"] ?? data['error'];
      if (msg == 'created') {
        voted = true;
      } else {
        showToast(message: msg);
      }
    } catch (e) {
      showToast(message: AppConstants.error);
      printData(title: 'from submitVote', data: '$e', e: true);
    }
    return voted;
  }

  Future<void> getContestItem(BuildContext ctx) async {
    try {
      contestDetails.clear();
      final userProvider = getUserProvider(ctx);

      final data = await ApiService().postDataToApi(
        api: 'draw/getAllContest?',
        headers: userProvider.headers,
      );

      final msg = data["message"] ?? data['error'];
      if (msg == 'Success') {
        contestDetails = contestDetailsFromJson(data);
        final cd = contestDetails;
        final isOver = cd.isEmpty ? true : cd[0].isOver;
        final id = userProvider.user!.id;

        showContest = cd.isNotEmpty && !isOver
            ? (cd[0].status == 0) && (!(cd[0].clientJoined.contains(id)))
            : false;
      }
    } catch (e) {
      printData(title: 'from getContestItem', data: '$e', e: true);
    }
    notifyListeners();
  }

  Future<void> joinContestItem(BuildContext ctx) async {
    try {
      final userProvider = getUserProvider(ctx);

      final body = joinContestToJson(
        JoinContest(
          draw: Draw(
            id: contestDetails[0].id,
            clientJoined: userProvider.user!.id,
          ),
        ),
      );

      final data = await ApiService().postDataToApi(
        api: 'draw/updateContest?',
        headers: userProvider.headers,
        payload: body,
      );

      final msg = data["message"] ?? data['error'];
      if (msg == 'Draw Join Details') {
        showContest = false;
        showToast(message: AppConstants.joinedContest);
      } else {
        showToast(message: msg);
      }
    } catch (e) {
      showToast(message: AppConstants.error);
      printData(title: 'from joinContestItem', data: '$e', e: true);
    }
    notifyListeners();
  }

  Future<void> getNewsAndInsights(int propId, BuildContext ctx) async {
    try {
      newsLoad = true;
      newsAndInsights.clear();
      final userProvider = getUserProvider(ctx);

      final body = propDetailToJson(PropDetail(propId: propId));

      final data = await ApiService().postDataToApi(
        api: 'blog/getAll?',
        headers: userProvider.headers,
        payload: body,
      );

      final msg = data["message"] ?? data['error'];
      if (msg == 'Success') {
        newsAndInsights = newsAndInsightsFromJson(data);
      }
    } catch (e) {
      // showToast(message: AppConstants.error);
      printData(title: 'from getNewsAndInsights', data: '$e', e: true);
    } finally {
      newsLoad = false;
    }
    notifyListeners();
  }

  Future<String> getPdfFiles(
    final String orderId,
    final String propName,
    final String fundSubType,
    final BuildContext ctx, {
    required final bool isCert,
  }) async {
    String certLink = '';
    try {
      final userProvider = getUserProvider(ctx);
      final body = unitCertDetailToJson(
        UnitCertDetail(
          orderId: orderId,
          clientId: userProvider.user!.id,
          propName: propName,
          fundSubType: fundSubType,
        ),
      );
      logData(data: body);
      final api = isCert ? 'order/convertToPdf?' : 'order/getInvoicePdf?';

      final data = await ApiService().postDataToApi(
        api: api,
        headers: userProvider.headers,
        payload: body,
      );

      final msg = data["message"] ?? data['error'];
      if (msg == 'Success') {
        certLink = data['url'];
      }
    } catch (e) {
      showToast(message: AppConstants.error);
      printData(title: 'from getUnitCertificate', data: '$e', e: true);
    } finally {
      newsLoad = false;
    }
    return certLink;
  }

  Future<List<String>> loadFileFromUrl(
    String url, {
    bool isCert = false,
  }) async {
    List<String> loadedFile = [];
    try {
      printData(data: url);
      final uri = Uri.parse(url);
      final filename = uri.fileName; // extn used
      printData(data: filename);
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = '${tempDir.path}/$filename';
      printData(data: tempFilePath);
      final file = File(tempFilePath);
      //!isCert for unit cert refresh
      if (await file.exists() && !isCert) {
        printData(data: 'file exists');
        loadedFile = [filename, tempFilePath];
      } else {
        printData(data: 'new file');
        final response = await ApiService().getDataFromApi(
          api: '',
          url: '$url?',
          showRes: false,
          decode: false,
          timeOut: 180,
        );
        if (response.statusCode == 200) {
          await file.writeAsBytes(response.bodyBytes);
          loadedFile = [filename, tempFilePath];
        }
      }
    } catch (e) {
      printData(title: 'from loadFileFromUrl', data: '$e', e: true);
      showToast(message: AppConstants.error);
    }
    return loadedFile;
  }

  Future<void> saveFileToDir(
    String tempFilePath,
    String flname, {
    bool isPdf = true,
    bool isCert = false,
  }) async {
    try {
      String fileName = fixAndGetFileName(isPdf, flname);
      if (Platform.isAndroid) {
        String dPath = '/storage/emulated/0/Download/Wellkins';
        await saveFile(dPath, tempFilePath, fileName, isCert: isCert);
      } else {
        final dDir = await getApplicationDocumentsDirectory();
        String dDirPath = dDir.path;
        if (dDirPath.isNotEmpty) {
          saveFile(dDirPath, tempFilePath, fileName, isCert: isCert);
        }
      }
    } catch (e) {
      printData(data: 'error moving  file: $e', e: true);
    }
  }

  String fixAndGetFileName(bool isPdf, String flname) {
    final fileName = isPdf
        ? flname.contains('.pdf')
            ? flname
            : '$flname.pdf'
        : flname;
    return fileName;
  }

  Future<void> saveFile(
    String dPath,
    String tempFilePath,
    String filename, {
    bool isCert = false,
  }) async {
    final dir = Directory(dPath);

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final path = '${dir.path}/$filename';
    final file = File(path); // file retreived from temp

    if (await file.exists()) {
      if (isCert) {
        await saveMultiple(
          filename: filename,
          dir: dir,
          file: file,
          tempFilePath: tempFilePath,
        );
      } else {
        _fileExists(path);
      }
    } else {
      await writeFile(
        tempFilePath: tempFilePath,
        file: file,
        path: path,
      );
    }
  }

  Future<void> saveMultiple({
    required String filename,
    required Directory dir,
    required File file,
    required String tempFilePath,
  }) async {
    List<String> filenameparts = filename.split('.');
    String extn = filenameparts.last;
    filenameparts.removeLast(); // Remove the extension(s)

    String tempName = filenameparts.join('.'); // Join for filename
    String tempPath = '${dir.path}/$tempName.$extn';
    int i = 1;

    File fileCopy = file; // copy of file
    while (await fileCopy.exists()) {
      int lpi = tempName.lastIndexOf('(');
      int lpci = tempName.lastIndexOf(')');

      if (lpi == -1 && lpci == -1) {
        // case for non existing int eg: test.pdf/jpg
        tempName = '$tempName($i)';
        tempPath = '${dir.path}/$tempName.$extn';
        fileCopy = File(tempPath);
        i += 1;
      } else {
        // case for existing int eg: test.pdf(1).pdf/jpg
        int count = tempName.substring(lpi + 1, lpci).toInt + 1;
        final nm = tempName.substring(0, lpi).trim();
        i = count;
        tempName = '$nm($i)';
        tempPath = '${dir.path}/$tempName.$extn';
        fileCopy = File(tempPath);
        i += 1;
      }
    }

    await writeFile(
      tempFilePath: tempFilePath,
      file: fileCopy,
      path: tempPath,
    );
  }

  void _fileExists(String path) {
    printData(data: 'file already exists at : $path');
    showToast(
        message: Platform.isAndroid
            ? AppConstants.alreadyDownloaded
            : AppConstants.alreadyDownloadedIos);
  }

  Future<void> writeFile({
    required String tempFilePath,
    required File file,
    required String path, // for showing path only
  }) async {
    final tempFile = File(tempFilePath);
    final tempByte = await tempFile.readAsBytes();
    file.writeAsBytes(tempByte);
    printData(data: 'file saved to directory: $path');
    showToast(
        message: Platform.isAndroid
            ? AppConstants.fileDownloaded
            : AppConstants.fileDownloadedIos);
  }

  Future<UserReceipt?> uploadUserFiles({
    required String orderId,
    required String fileName,
    required String filePath,
    required String fileType,
    required BuildContext ctx,
    String comments = '',
  }) async {
    UserReceipt? userReceipt;
    try {
      final userProvider = getUserProvider(ctx);
      final uniqNum = Random().nextInt(5);

      final body = {
        'id': userProvider.user!.id,
        'order_id': orderId,
        'docs_type': fileType,
        'comment': comments,
        'uniqno': '$uniqNum',
      };

      final data = await ApiService().postDataToApi(
        api: 'payment/uploadPaymentRecipt?',
        headers: userProvider.headers,
        payload: body,
        fileKey: 'document',
        fileName: fileName,
        filePath: filePath,
        multipart: true,
      );

      final msg = data["message"] ?? data['error'];
      if (msg == 'Success upload') {
        showToast(message: msg);
        final rFileData = data['upload_img'];
        final rFileUrl = rFileData['url'] ?? '';
        final rUri = Uri.parse(rFileUrl);
        final rFilename = rUri.fileName;
        final rFileType = rUri.fileType;
        userReceipt = UserReceipt(
          id: rFileData['id'],
          fileName: rFilename,
          fileType: rFileType,
          url: rFileUrl,
          userComment: '',
        );
        return userReceipt;
      } else {
        return userReceipt;
      }
    } catch (e) {
      showToast(message: AppConstants.error);
      printData(title: 'from uploadUserFiles', data: '$e', e: true);
      return userReceipt;
    }
  }

  Future<List<UserReceipt>> getUserReceipts(
    final String orderId,
    final BuildContext ctx,
  ) async {
    try {
      final userProvider = getUserProvider(ctx);
      final body = receiptIdToJson(ReceiptId(orderId: orderId));

      final data = await ApiService().postDataToApi(
        api: 'payment/getPaymentReceipt?',
        headers: userProvider.headers,
        payload: body,
      );

      final msg = data["message"] ?? data['error'];
      if (msg == 'Success') {
        return userReceiptsFromJson(data);
      } else {
        return [];
      }
    } catch (e) {
      printData(title: 'from getUnitCertificate', data: '$e', e: true);
      return [];
    }
  }

  Future<List<TaxReport>> getTaxReports({
    required GetTaxReport getTaxReport,
    required BuildContext ctx,
  }) async {
    try {
      final userProvider = getUserProvider(ctx);
      final body = getTaxReportToJson(getTaxReport);

      final data = await ApiService().postDataToApi(
        api: 'order/taxreturns?',
        headers: userProvider.headers,
        payload: body,
      );

      if (data != null && data['individualOrders'].isNotEmpty) {
        return taxReportFromJson(data);
      } else {
        return [];
      }
    } catch (e) {
      printData(title: 'from getTaxReports', data: '$e', e: true);
      return [];
    }
  }
}
