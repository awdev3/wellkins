// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import 'firebase_options.dart';
// import 'providers/auth_provider.dart';
// import 'providers/dash_provider.dart';
// import 'providers/inv_provider.dart';
// import 'providers/noti_provider.dart';
// import 'providers/user_provider.dart';
// import 'providers/woo_provider.dart';
import 'root.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(
    const MyApp(),

    // multiProviders()
  );
}

// MultiProvider multiProviders() {
//   final providers = [
//     ChangeNotifierProvider(create: (_) => AuthProvider()),
//     ChangeNotifierProvider(create: (_) => UserProvider()),
//     ChangeNotifierProvider(create: (_) => DashProvider()),
//     ChangeNotifierProvider(create: (_) => InvProvider()),
//     ChangeNotifierProvider(create: (_) => WooProvider()),
//     ChangeNotifierProvider(create: (_) => NotiProvider()),
//   ];
//   return MultiProvider(providers: [], child: const MyApp());
// }
