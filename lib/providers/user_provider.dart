import 'package:flutter/widgets.dart';

import '../models/enso_user.dart';

class UserProvider with ChangeNotifier {
  final EnsoUser _user = new EnsoUser.empty();

  EnsoUser get user {
    // if we directly returned _users, we'd pass the pointer. Then anywhere in the code we could edit the list.
    return _user;
  }
}
