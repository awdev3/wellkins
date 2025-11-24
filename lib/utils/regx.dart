class Regx {
  static final nameRegExp = RegExp(r'^\s*[a-zA-Z]+\s*$');
  static final fullNameRegExp = RegExp(r'^[A-Za-z\s]+$');
  static final emailRegExp = RegExp(r'\S+@\S+\.\S+');
  static final phoneRegExp = RegExp(r'^[0-9]+$');
  static final addressRegExp = RegExp(r'^[a-zA-Z0-9\s.,-]*$');
  // ensures 0 can be added at front
  static final nineDigitRegExp = RegExp(r'^(?:[1-9]\d{8}|0\d{9})$');
  static final oldEmailRegExp =
      RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  static final passwordRegExp = RegExp(r'.{8,}');
  static final doubleRegExp = RegExp(r'^\d+(\.\d+)?$');
  static final double2RegExp = RegExp(r'^\d+\.?\d{0,2}');

  // static final nameRegExp = RegExp(r'^[a-zA-Z]+$');
  // static final nineDigitRegExp = RegExp(r'^\d{9}$');
  // static final nineDigitRegExp = RegExp(r'^\d{9,}$'); // min 9 digit
  // static final passwordRegExp =  RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$');
}
