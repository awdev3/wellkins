import 'dart:convert';

String loginToJson(Login data) => json.encode(data.toJson());
String registerToJson(Register data) => json.encode(data.toJson());
String forgotPassToJson(ForgotPass data) => json.encode(data.toJson());
String verifyOtpToJson(VerifyOtp data) => json.encode(data.toJson());
String resetPassToJson(ResetPass data) => json.encode(data.toJson());

class Login {
  LoginData loginData;
  Login({required this.loginData});

  Map<String, dynamic> toJson() => {"login": loginData.toJson()};
}

class LoginData {
  String userEmail;
  String password;

  LoginData({required this.userEmail, required this.password});

  Map<String, dynamic> toJson() => {
    "client_email": userEmail,
    "password": password,
  };
}

class Register {
  RegisterData registerData;

  Register({required this.registerData});

  Map<String, dynamic> toJson() => {"client": registerData.toJson()};
}

class RegisterData {
  String fullName;
  String email;
  String contactNo;
  String state;
  String invAmount;
  String password;

  RegisterData({
    required this.fullName,
    required this.email,
    required this.contactNo,
    required this.state,
    required this.invAmount,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    "full_name": fullName,
    "client_email": email,
    "contact_no": contactNo,
    "state": state,
    "investment_amount": invAmount,
    "password": password,
    "active": 0,
  };
}

class RememberMe {
  bool rememberMe;
  String rEmail;
  String rPassword;
  RememberMe({
    required this.rememberMe,
    required this.rEmail,
    required this.rPassword,
  });
}

class ForgotPass {
  String email;

  ForgotPass({required this.email});

  Map<String, dynamic> toJson() => {"email": email};
}

class VerifyOtp {
  String id;
  String otp;

  VerifyOtp({required this.id, required this.otp});

  Map<String, dynamic> toJson() => {"id": id, "otp": otp};
}

class ResetPass {
  ResetPassData resetPassData;

  ResetPass({required this.resetPassData});

  Map<String, dynamic> toJson() => {"client": resetPassData.toJson()};
}

class ResetPassData {
  String email;
  String password;

  ResetPassData({required this.email, required this.password});

  Map<String, dynamic> toJson() => {"email": email, "password": password};
}
