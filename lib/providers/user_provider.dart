import 'package:flutter/widgets.dart';
import 'package:instagram_clone_flutter/models/user.dart';
import 'package:instagram_clone_flutter/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  AppUser? _appUser;
  final AuthMethods _authMethods = AuthMethods();

  AppUser? get getUser => _appUser;

  Future<void> refreshUser() async {
    AppUser user = await _authMethods.getUserDetails();
    _appUser = user;
    notifyListeners();
  }
}
