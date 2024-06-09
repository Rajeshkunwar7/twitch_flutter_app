import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_twitch/models/user.dart' as model;
import 'package:flutter_twitch/provider/user_provider.dart';
import 'package:flutter_twitch/resources/auth_methods.dart';
import 'package:flutter_twitch/screens/home_screen.dart';
import 'package:flutter_twitch/screens/login_screen.dart';
import 'package:flutter_twitch/screens/onboarding_screen.dart';
import 'package:flutter_twitch/screens/sign_up_screen.dart';
import 'package:flutter_twitch/utils/colors.dart';
import 'package:flutter_twitch/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Twitch Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme.of(context).copyWith(
            backgroundColor: backgroundColor,
            elevation: 0,
            titleTextStyle: const TextStyle(
              color: primaryColor,
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: const IconThemeData(
              color: primaryColor,
            )),
      ),
      routes: {
        OnBoardingScreen.routeName: (context) => const OnBoardingScreen(),
        LogInScreen.routeName: (context) => const LogInScreen(),
        SignUpScreen.routeName: (context) => const SignUpScreen(),
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
      home: FutureBuilder(
        future: AuthMethods()
            .getCurrentUser(
          FirebaseAuth.instance.currentUser != null
              ? FirebaseAuth.instance.currentUser!.uid
              : null,
        )
            .then((value) {
          if (value != null) {
            Provider.of<UserProvider>(context, listen: false)
                .setUser(model.User.fromMap(value));
          }
          return value;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const OnBoardingScreen();
        },
      ),
    );
  }
}
