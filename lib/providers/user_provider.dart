import 'package:flutter/widgets.dart';

import '../models/user.dart';

class UserProvider with ChangeNotifier {
  final User _user = new User.empty();

  User get user {
    // if we directly returned _users, we'd pass the pointer. Then anywhere in the code we could edit the list.
    return _user;
  }
}
