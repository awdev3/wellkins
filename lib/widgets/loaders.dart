import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';

// import '../providers/auth_provider.dart';
import 'wave.dart';

Widget showLoader({
  double size = 30,
  Color color = Colors.red,
  bool centered = false,
}) {
  return centered ? Center(child: _loader(color, size)) : _loader(color, size);
}

Widget _loader(Color color, double size) {
  return SpinKitWave(color: color, size: size.w);
}

Widget fullLoaderWhite = Container(
  color: Colors.white38,
  height: double.infinity,
  width: double.infinity,
  child: showLoader(),
);

Widget fullLoaderblack = Container(
  color: Colors.black38,
  height: double.infinity,
  width: double.infinity,
  child: showLoader(),
);

// Widget authLoader(context) {
//   return Selector<AuthProvider, bool>(
//     selector: (_, snapshot) => snapshot.authLoad,
//     builder: buildLoader,
//   );
// } //TODO uncommend when integrating provider

Widget buildLoader(context, loading, child) {
  return loading ? fullLoaderWhite : const SizedBox();
}
