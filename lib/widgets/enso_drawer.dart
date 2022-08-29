import 'dart:developer';

import 'package:ensobox/widgets/service_locator.dart';
import 'package:ensobox/widgets/services/global_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'firebase_repository/auth_repo.dart';

FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
GlobalService _globalService = getIt<GlobalService>();
AuthRepo _authRepo = getIt<AuthRepo>();

bool isLoggedIn = _globalService.isSignedIn;

class EnsoDrawer extends StatefulWidget {
  const EnsoDrawer({Key? key}) : super(key: key);

  @override
  State<EnsoDrawer> createState() => _EnsoDrawerState();
}

class _EnsoDrawerState extends State<EnsoDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
          padding: EdgeInsets.zero,
          children: [
      UserAccountsDrawerHeader(
        accountName: Text(isLoggedIn ? _globalService.currentEnsoUser.email!.split('@')[0] : "Gast"),
      accountEmail: Text(isLoggedIn ? _globalService.currentEnsoUser.email! : "Gast"),
      // currentAccountPicture: CircleAvatar(
      //   child: ClipOval(
      //     child: Image.network(
      //       'https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png',
      //       fit: BoxFit.cover,
      //       width: 90,
      //       height: 90,
      //     ),
      //   ),
      // ),
      decoration: BoxDecoration(
        color: Colors.blue,
        image: DecorationImage(
            fit: BoxFit.fill,
            image: NetworkImage(
                'https://oflutter.com/wp-content/uploads/2021/02/profile-bg3.jpg')),
      ),
    ),
    ListTile(
    leading: Icon(Icons.favorite),
    title: Text('Favoriten'),
    onTap: () => null,
    ),
    ListTile(
    leading: Icon(Icons.person),
    title: Text('Freunde'),
    onTap: () => null,
    ),
    ListTile(
    leading: Icon(Icons.share),
    title: Text('Weitersagen'),
    onTap: () => null,
    ),
    ListTile(
    leading: Icon(Icons.notifications),
    title: Text('Benachrichtigungen'),
    ),
    Divider(),
    ListTile(
    leading: Icon(Icons.settings),
    title: Text('Einstellungen'),
    onTap: () => null,
    ),
    ListTile(
    leading: Icon(Icons.description),
    title: Text('FAQ'),
    onTap: () => null,
    ),
    ListTile(
    leading: Icon(Icons.description),
    title: Text('AGB & Datenschutz'),
    onTap: () => null,
    ),
    ListTile(
    leading: Icon(Icons.description),
    title: Text('Impressum'),
    onTap: () => null,
    ),
    Divider(),
    !isLoggedIn ?
    ListTile(
    title: Text('Einloggen'),
    leading: Icon(Icons.exit_to_app),
    onTap: () async {
      await _authRepo.registerByEmailAndHiddenPW("grgkr.o@gmail.com");
      setState(() {
        isLoggedIn = true;
      });
      log("Successfully logged in: isloggedIn: ${isLoggedIn}");
    }
    ) :
    ListTile(
      title: Text('Ausloggen'),
      leading: Icon(Icons.exit_to_app),
      onTap: () async {
        log("Trying to log out");
        _firebaseAuth.signOut().then((res) {

          setState(() {
            isLoggedIn = false;
          });
          log("Successfully logged out: isloggedIn: ${isLoggedIn}");
        });

      }
    ),
    ]
    ,
    )
    ,
    );
  }
}
