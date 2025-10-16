import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ludo_game/provider/authProvider.dart';
import 'package:ludo_game/provider/coinProvider.dart';
import 'package:ludo_game/provider/gameProvider.dart';
import 'package:ludo_game/provider/profileProvider.dart';
import 'package:ludo_game/provider/tournamentProvider.dart';
import 'package:ludo_game/services/route/route.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CoinProvider()),
      ],
      child: MaterialApp(
        title: 'Ludo Masters',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.light,
        initialRoute: '/splash',
        routes: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}