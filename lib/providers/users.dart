import 'package:flutter/widgets.dart';

import '../models/enso_user.dart';

class Users with ChangeNotifier {
  List<EnsoUser> _users = [];

  List<EnsoUser> get users {
    // if we directly returned _users, we'd pass the pointer. Then anywhere in the code we could edit the list.
    return [..._users];
  }

  void addUser(EnsoUser user) {
    // _users.add(user);
    notifyListeners();
  }
}
