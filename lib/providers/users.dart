import 'package:flutter/widgets.dart';

import '../models/user.dart';

class Users with ChangeNotifier {
  List<User> _users = [];

  List<User> get users {
    // if we directly returned _users, we'd pass the pointer. Then anywhere in the code we could edit the list.
    return [..._users];
  }

  void addUser(User user) {
    // _users.add(user);
    notifyListeners();
  }
}
