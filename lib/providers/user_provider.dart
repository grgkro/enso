import 'package:flutter/widgets.dart';

import '../models/enso_user.dart';

class UserProvider with ChangeNotifier {
  final EnsoUser _user = EnsoUser(EnsoUserBuilder());

  EnsoUser get user {
    // if we directly returned _user, we'd pass the pointer. Then anywhere in the code we could edit the user.
    return _user;
  }
}
