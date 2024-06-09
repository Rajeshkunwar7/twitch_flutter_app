import 'package:flutter/material.dart';
import 'package:flutter_twitch/screens/login_screen.dart';
import 'package:flutter_twitch/screens/sign_up_screen.dart';
import 'package:flutter_twitch/widgets/custom_button.dart';

class OnBoardingScreen extends StatelessWidget {
  static const routeName = "/onBoarding";

  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to \n Twitch",
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            CustomButton(
                title: "Log In",
                onTap: () {
                  Navigator.pushNamed(context, LogInScreen.routeName);
                }),
            const SizedBox(height: 10),
            CustomButton(
                title: "Sign Up",
                onTap: () {
                  Navigator.pushNamed(context, SignUpScreen.routeName);
                }),
          ],
        ),
      ),
    );
  }
}
