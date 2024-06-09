import 'package:flutter/material.dart';
import 'package:flutter_twitch/resources/auth_methods.dart';
import 'package:flutter_twitch/screens/home_screen.dart';
import 'package:flutter_twitch/widgets/custom_button.dart';
import 'package:flutter_twitch/widgets/custom_text_field.dart';
import 'package:flutter_twitch/widgets/loading_indicator.dart';

class LogInScreen extends StatefulWidget {
  static const routeName = "/logInScreen";

  const LogInScreen({Key? key}) : super(key: key);

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  final AuthMethods authMethods = AuthMethods();

  logInUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      bool res = await authMethods.logInUser(
        email: emailController.text,
        password: passwordController.text,
        context: context,
      );
      setState(() {
        isLoading = false;
      });
      if (res) {
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Log In"),
      ),
      body: isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: size.height * 0.1),
                    const Text(
                      "Email",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CustomTextField(controller: emailController),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      "Password",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CustomTextField(controller: passwordController),
                    ),
                    const SizedBox(height: 22),
                    CustomButton(
                        title: "Log In",
                        onTap: () {
                          logInUser();
                        })
                  ],
                ),
              ),
            ),
    );
  }
}
