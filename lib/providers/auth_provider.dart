import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../constants/strings.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';
import '../screens/authScrn/auth_screen.dart';
import '../screens/authScrn/components/sign_in.dart';
import '../screens/bottomNav/bottom_nav_bar.dart';
import '../screens/forogotPass/otp_screen.dart';
import '../screens/forogotPass/reset_pass_screen.dart';
import '../services/api_service.dart';
import '../services/helpers.dart';
import '../services/session_timeout.dart';
import '../utils/console_util.dart';
import '../utils/transitions_util.dart';
import '../widgets/toasts.dart';

class AuthProvider extends ChangeNotifier {
  String otpId = '';
  String otpCode = '';
  String otpEmail = '';

  bool authLoad = false;
  bool resendOff = false;

  void setAuthLoad(bool cndn) {
    authLoad = cndn;
    notifyListeners();
  }

  void setRecendLoad(bool cndn) {
    resendOff = cndn;
    notifyListeners();
  }

  Map<String, String> get headers => {"Content-type": "application/json"};

  String decodeToken(dynamic token) {
    final dToken = JwtDecoder.decode(token);
    final exp = dToken['exp'];
    final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    // final tknExp = Frmtr.frmtDate(
    //   dateTime: expDate,
    //   inForm: 'yyyy-MM-dd HH:mm:ss.SSS',
    //   outForm: 'yyyy-MM-dd HH:mm:ss',
    // );
    printData(title: '---->', data: 'session ends at $expDate');
    return '$expDate';
  }

  void setOtpCode(String otp) {
    otpCode = otp;
    notifyListeners();
  }

  Future<void> registerUser({
    required Register userData,
    required BuildContext ctx,
  }) async {
    setAuthLoad(true);
    delayedCallback(milliseconds: 200, () async {
      try {
        final userProvider = getUserProvider(ctx);

        final body = registerToJson(userData);
        logData(title: 'register body : ', data: body);

        final data = await ApiService().postDataToApi(
          api: 'client/create-client?',
          headers: headers,
          payload: body,
        );

        final msg = data["message"] ?? data['error'];

        if (msg == 'Client register successful') {
          final tknExp = decodeToken(data["accessToken"]);
          final user = userFromJson(data, tknExp);
          await userProvider.setUserData(user);
          await userProvider.getUserData();
          if (!ctx.mounted) return;
          SessionTimeout.startUserSession(ctx);
          _navToHome(ctx);
        } else {
          showToast(message: msg);
        }
      } catch (e) {
        showToast(message: AppConstants.error);
        printData(title: 'from registerUser', data: '$e', e: true);
      } finally {
        setAuthLoad(false);
      }
    });
  }

  Future<void> loginUser({
    required Login userData,
    required BuildContext ctx,
  }) async {
    setAuthLoad(true);
    delayedCallback(milliseconds: 200, () async {
      try {
        final userProvider = getUserProvider(ctx);

        final body = loginToJson(userData);
        logData(title: 'login body : ', data: body);

        final data = await ApiService().postDataToApi(
          api: 'client/client-login-mobile?',
          headers: headers,
          payload: body,
        );

        final msg = data["message"] ?? data['error'];

        if (msg == 'User login successful') {
          final tknExp = decodeToken(data["accessToken"]);
          final user = userFromJson(data, tknExp);
          await userProvider.setUserData(user);
          await userProvider.getUserData();
          if (!ctx.mounted) return;
          SessionTimeout.startUserSession(ctx);
          _navToHome(ctx);
        } else {
          showToast(message: msg);
        }
      } catch (e, st) {
        showToast(message: AppConstants.error);
        printData(title: 'from loginUser', data: '$e,$st', e: true);
      } finally {
        setAuthLoad(false);
      }
    });
  }

  Future<void> logoutUser(BuildContext ctx) async {
    setAuthLoad(true);
    delayedCallback(milliseconds: 1000, () async {
      final userProvider = getUserProvider(ctx);
      _navToAuth(ctx: ctx);
      await userProvider.deleteUserData().whenComplete(() {
        setAuthLoad(false);
      });
    });
  }

  Future<void> sendOtp({
    String email = '',
    bool isResend = false,
    required dynamic ctx,
  }) async {
    setAuthLoad(true);
    delayedCallback(milliseconds: 200, () async {
      try {
        if (isResend) {
          otpId = '';
          otpCode = '';
        } else {
          otpId = '';
          otpCode = '';
          otpEmail = '';
          otpEmail = email;
        }

        final body = forgotPassToJson(ForgotPass(email: otpEmail));

        logData(title: 'forgotPass body : ', data: body);

        final data = await ApiService().postDataToApi(
          api: 'client/send-otp?',
          headers: headers,
          payload: body,
        );

        final msg = data["message"] ?? data['error'];

        if (msg == 'OTP sent on your email') {
          otpId = '${data["id"]}';
          isResend
              ? showToast(message: AppConstants.otpResend)
              : _navToOtp(ctx);
        } else {
          showToast(message: msg);
        }
      } catch (e) {
        showToast(message: AppConstants.error);
        printData(title: 'from sendOtp', data: '$e', e: true);
      } finally {
        setAuthLoad(false);
      }
    });
  }

  Future<void> verifyOtp(dynamic ctx) async {
    setAuthLoad(true);
    delayedCallback(milliseconds: 1000, () async {
      try {
        final body = verifyOtpToJson(VerifyOtp(id: otpId, otp: otpCode));
        logData(title: 'verifyOtp body : ', data: body);

        final data = await ApiService().postDataToApi(
          api: 'client/verify-otp?',
          headers: headers,
          payload: body,
        );

        final msg = data['message'] ?? data['error'];
        final isExpired = '${data['isExpired']}' != 'false';

        if (msg == 'OTP is Verified' && !isExpired) {
          otpId = '';
          otpCode = '';
          _navToResetPass(ctx);
        } else {
          showToast(message: msg);
        }
      } catch (e) {
        printData(title: 'from verifyOtp', data: '$e', e: true);
        showToast(message: AppConstants.error);
      } finally {
        setAuthLoad(false);
      }
    });
  }

  Future<void> resetPassword({
    required String pass,
    required dynamic ctx,
  }) async {
    setAuthLoad(true);
    delayedCallback(milliseconds: 1000, () async {
      try {
        final body = resetPassToJson(
          ResetPass(
            resetPassData: ResetPassData(email: otpEmail, password: pass),
          ),
        );
        logData(title: 'resetPassword body : ', data: body);

        final data = await ApiService().postDataToApi(
          api: 'client/forgot-password?',
          headers: headers,
          payload: body,
        );

        final msg = data['message'] ?? data['error'];

        if (msg == 'update password') {
          otpEmail = '';
          showToast(message: AppConstants.success);
          _navToAuth(replace: true, ctx: ctx);
        } else {
          showToast(message: msg);
        }
      } catch (e) {
        printData(title: 'from resetPassword', data: '$e', e: true);
        showToast(message: AppConstants.error);
      } finally {
        setAuthLoad(false);
      }
    });
  }

  void _navToHome(BuildContext ctx) => Navigator.pushAndRemoveUntil(
    ctx,
    FadeRoute(page: const BottomNavBar(pageNum: 0)),
    (route) => false,
  );

  void _navToAuth({bool replace = false, required BuildContext ctx}) => replace
      ? Navigator.pushReplacement(
          ctx,
          SlideLeftRoute(page: const LoginScreen()),
        )
      : Navigator.pushAndRemoveUntil(
          ctx,
          FadeRoute(page: const AuthScreen()),
          (route) => false,
        );

  void _navToOtp(BuildContext ctx) {
    Navigator.pushReplacement(ctx, FadeRoute(page: const OtpScreen()));
  }

  void _navToResetPass(BuildContext ctx) {
    Navigator.pushReplacement(
      ctx,
      SlideLeftRoute(page: const ResetPassScreen()),
    );
  }
}
