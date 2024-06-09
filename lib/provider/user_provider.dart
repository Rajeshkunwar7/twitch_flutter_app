import 'package:flutter/cupertino.dart';
import 'package:flutter_twitch/models/user.dart';

class UserProvider extends ChangeNotifier {
  User _user = User(uid: "", username: "", email: "");

  User get user => _user;

  setUser(User user) {
    _user = user;
    notifyListeners();
  }
}
