import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

class DbService {
  static const _storage = FlutterSecureStorage();

  static Future<void> setUserData(User user) async {
    await _storage.write(key: 'userId', value: user.id);
    await _storage.write(key: 'clientId', value: user.clientId);
    await _storage.write(key: 'firstName', value: user.firstName);
    await _storage.write(key: 'lastName', value: user.lastName);
    await _storage.write(key: 'email', value: user.email);
    await _storage.write(key: 'image', value: user.image);
    await _storage.write(key: 'contactNo', value: user.contactNo);
    await _storage.write(key: 'type', value: user.type);
    await _storage.write(key: 'isDelete', value: '${user.isDelete}');
    await _storage.write(key: 'accessToken', value: user.accessToken);
    await _storage.write(key: 'tokenExpiry', value: user.tokenExpiry);
  }

  static Future<User> getUserData() async {
    final userId = await _storage.read(key: 'userId') ?? '';
    final clientId = await _storage.read(key: 'clientId') ?? '';
    final firstName = await _storage.read(key: 'firstName') ?? '';
    final lastName = await _storage.read(key: 'lastName') ?? '';
    final email = await _storage.read(key: 'email') ?? '';
    final image = await _storage.read(key: 'image') ?? '';
    final contactNo = await _storage.read(key: 'contactNo') ?? '';
    final type = await _storage.read(key: 'type') ?? '';
    final isDelete = await _storage.read(key: 'isDelete') ?? '';
    final accessToken = await _storage.read(key: 'accessToken') ?? '';
    final tokenExpiry = await _storage.read(key: 'tokenExpiry') ?? '';

    final user = User(
      id: userId,
      clientId: clientId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      image: image,
      contactNo: contactNo,
      type: type,
      isDelete: isDelete.toLowerCase() == 'true',
      accessToken: accessToken,
      tokenExpiry: tokenExpiry,
    );

    return user;
  }

  static Future<User> updateUserData(UpdatedUser updatedUser) async {
    //
    final client = updatedUser.updatedClient;
    final fullName = client.fullName;
    List<String> nameParts = fullName.split(" ");
    final firstName = nameParts[0];
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

    await _storage.write(key: 'firstName', value: firstName);
    await _storage.write(key: 'lastName', value: lastName);
    if (client.image.isNotEmpty) {
      await _storage.write(key: 'image', value: client.image);
    }

    final updatedData = await getUserData();
    return updatedData;
  }

  static Future<bool> checkDbChange(UpdatedUser updatedUser) async {
    final user = await getUserData();

    if (user.id.isEmpty) {
      return false;
    }

    final uClient = updatedUser.updatedClient;
    final fullName = uClient.fullName;
    List<String> nameParts = fullName.split(" ");
    final firstName = nameParts[0];
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(" ") : "";

    if (firstName.isNotEmpty && firstName != user.firstName) {
      return true;
    }
    if (lastName.isNotEmpty && lastName != user.lastName) {
      return true;
    }
    if (uClient.image.isNotEmpty) {
      return true;
    }

    return false;
  }

  static Future<dynamic> deleteUserData() async {
    await _storage.delete(key: 'userId');
    await _storage.delete(key: 'clientId');
    await _storage.delete(key: 'firstName');
    await _storage.delete(key: 'lastName');
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'image');
    await _storage.delete(key: 'password');
    await _storage.delete(key: 'contactNo');
    await _storage.delete(key: 'type');
    await _storage.delete(key: 'isDelete');
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'tokenExpiry');
    return null;
  }

  //## remember me ##
  static Future<void> setRememberMe({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    if (rememberMe) {
      await _storage.write(key: 'rEmail', value: email);
      await _storage.write(key: 'rPassword', value: password);
      await _storage.write(key: 'rememberMe', value: 'true');
    } else {
      await deleteRememberMe();
    }
  }

  static Future<RememberMe> getRememberMe() async {
    final remmebrMe = await _storage.read(key: 'rememberMe') == 'true';
    final rEmail = await _storage.read(key: 'rEmail') ?? '';
    final rPassword = await _storage.read(key: 'rPassword') ?? '';

    return RememberMe(
      rememberMe: remmebrMe,
      rEmail: rEmail,
      rPassword: rPassword,
    );
  }

  static Future<void> deleteRememberMe() async {
    await _storage.delete(key: 'rEmail');
    await _storage.delete(key: 'rPassword');
    await _storage.delete(key: 'rememberMe');
  }

  //## token status ##
  static Future<void> setTokenAquired() async {
    await _storage.write(key: 'tokenAquired', value: 'true');
  }

  static Future<bool> getTokenStatus() async {
    final tknSts = await _storage.read(key: 'tokenAquired') ?? '';
    return tknSts == 'true' ? true : false;
  }

  //## download path ##
  static Future<void> setDownloadPath(String path) async {
    if (path.isNotEmpty) {
      await _storage.write(key: 'dPath', value: path);
    }
  }

  static Future<String> getDownloadPath() async {
    final path = await _storage.read(key: 'dPath') ?? '';
    return path;
  }

  static Future<void> deleteDownloadPath(String path) async {
    await _storage.delete(key: 'dPath');
  }
}
