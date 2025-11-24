import 'package:flutter/material.dart';

import '../constants/strings.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/db_service.dart';
import '../services/helpers.dart';
import '../utils/console_util.dart';
import '../widgets/toasts.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  Map<String, String> get headers {
    return {
      "Content-type": "application/json",
      "x-auth-token": user!.accessToken,
    };
  }

  Future<void> setUserData(User user) async {
    await DbService.setUserData(user);
  }

  Future<void> getUserData() async {
    _user = await DbService.getUserData();
    notifyListeners();
  }

  Future<void> deleteUserData() async {
    _user = await DbService.deleteUserData();
    notifyListeners();
  }

  Future<void> updateUserData({
    required UpdatedUser updatedUser,
    required BuildContext ctx,
  }) async {
    await DbService.checkDbChange(updatedUser).then((dbChanged) async {
      if (dbChanged && ctx.mounted) {
        final authProvider = getAuthProvider(ctx);
        authProvider.setAuthLoad(true);

        try {
          if (updatedUser.updatedClient.imageName.isNotEmpty) {
            await uploadUserImage(updatedUser: updatedUser, ctx: ctx).then((
              updated,
            ) async {
              if (updated) {
                await updateUser(updatedUser);
              }
            });
          } else {
            await updateUser(updatedUser);
          }
        } catch (e) {
          showToast(message: AppConstants.error);
          printData(title: 'from updateUserData', data: '$e', e: true);
        } finally {
          authProvider.setAuthLoad(false);
        }
      } else {
        showToast(message: AppConstants.noChanges);
      }
    });
  }

  Future<void> updateUser(UpdatedUser updatedUser) async {
    final body = updateUserToJson(updatedUser);

    final data = await ApiService().postDataToApi(
      api: 'client/update?',
      headers: headers,
      payload: body,
    );

    final msg = data["message"] ?? data['error'];

    if (msg == 'update post') {
      final updtdUser = updatedUser.copyWith(
        updatedClient: updatedUser.updatedClient.copyWith(
          image: data['userdetails']['client_image'],
        ),
      );

      _user = await DbService.updateUserData(updtdUser);
      showToast(message: AppConstants.success);
      printData(data: updtdUser.updatedClient.toString());
    } else {
      showToast(message: msg);
    }
    notifyListeners();
  }

  Future<bool> uploadUserImage({
    required UpdatedUser updatedUser,
    required BuildContext ctx,
  }) async {
    try {
      final uClient = updatedUser.updatedClient;

      final body = {"id": user!.clientId, "docs_type": uClient.imgType};

      final headers = {"x-auth-token": user!.accessToken};

      logData(title: 'uploadUserImage body : ', data: body);
      final data = await ApiService().postDataToApi(
        api: 'order/document?',
        headers: headers,
        payload: body,
        fileKey: 'document',
        fileName: uClient.imageName,
        filePath: uClient.image,
        multipart: true,
      );

      final msg = data["message"] ?? data['error'];

      if (msg == 'Success upload') {
        return true;
      } else {
        return false;
      }
    } catch (e, st) {
      showToast(message: AppConstants.error);
      printData(title: 'from uploadUserImage', data: '$e,$st', e: true);
    }
    return false;
  }

  Future<void> changeUserPass({
    required ChangedUserPass changedUserPass,
    required BuildContext ctx,
  }) async {
    final authProvider = getAuthProvider(ctx);
    authProvider.setAuthLoad(true);
    try {
      final body = changeUserPassToJson(changedUserPass);

      logData(title: 'changePass body : ', data: body);

      final data = await ApiService().postDataToApi(
        api: 'client/change-password?',
        headers: headers,
        payload: body,
      );

      final msg = data["message"] ?? data['error'];
      showToast(message: msg);
    } catch (e) {
      showToast(message: AppConstants.error);
      printData(title: 'from changeUserPass', data: '$e', e: true);
    } finally {
      authProvider.setAuthLoad(false);
    }
  }
}
