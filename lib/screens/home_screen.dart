import 'package:flutter/material.dart';
import 'package:flutter_twitch/screens/feed_screen.dart';
import 'package:flutter_twitch/screens/go_live-screen.dart';
import 'package:flutter_twitch/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const routeName = "/homeScreen";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int page = 0;

  onPageChange(int selectedPage) {
    setState(() {
      page = selectedPage;
    });
  }

  List<Widget> pages = [
    const FeedScreen(),
    const GoLiveScreen(),
    const Center(child: Text("Browse")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[page],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: buttonColor,
        unselectedItemColor: primaryColor,
        backgroundColor: backgroundColor,
        unselectedFontSize: 12,
        onTap: onPageChange,
        currentIndex: page,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border), label: "Favorite"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_rounded), label: "Go Live"),
          BottomNavigationBarItem(icon: Icon(Icons.copy), label: "Browse"),
        ],
      ),
    );
  }
}
