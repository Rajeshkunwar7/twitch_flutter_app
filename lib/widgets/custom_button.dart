import 'package:flutter/material.dart';
import 'package:flutter_twitch/utils/colors.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CustomButton({Key? key, required this.title, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      child: Text(title),
      style: ElevatedButton.styleFrom(
          primary: buttonColor, minimumSize: const Size(double.infinity, 40)),
    );
  }
}
