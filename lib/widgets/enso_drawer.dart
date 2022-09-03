import 'dart:developer';

import 'package:ensobox/widgets/auth/login_screen.dart';
import 'package:ensobox/widgets/provider/current_user_provider.dart';
import 'package:ensobox/widgets/service_locator.dart';
import 'package:ensobox/widgets/services/authentication_service.dart';
import 'package:ensobox/widgets/services/global_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/enso_user.dart';
import 'firebase_repository/auth_repo.dart';

FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
GlobalService _globalService = getIt<GlobalService>();
AuthRepo _authRepo = getIt<AuthRepo>();

bool isSignedIn = _globalService.isSignedIn;

class EnsoDrawer extends StatefulWidget {
  const EnsoDrawer({Key? key}) : super(key: key);

  @override
  State<EnsoDrawer> createState() => _EnsoDrawerState();
}

class _EnsoDrawerState extends State<EnsoDrawer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentUserProvider>(
      builder: (context, currentUserProvider, child) {
        return Drawer(
          child: ListView(
            // Remove padding
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(
                    isSignedIn && currentUserProvider.currentEnsoUser.email != null
                        ? currentUserProvider.currentEnsoUser.email!.split('@')[0]
                        : "Gast"),
                accountEmail: Text(
                    isSignedIn && currentUserProvider.currentEnsoUser.email != null
                        ? currentUserProvider.currentEnsoUser.email!
                        : ""),
                currentAccountPicture: CircleAvatar(
                  child: ClipOval(
                    child: Image.network(
                      'https://firebasestorage.googleapis.com/v0/b/enso-fairleih.appspot.com/o/grid_0.png?alt=media&token=e9a37dbf-aa3a-4391-81b3-e59116139a26',
                      fit: BoxFit.cover,
                      width: 90,
                      height: 90,
                    ),
                  ),
                ),
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
                leading: Icon(Icons.list_rounded),
                title: Text('Bisherige Ausleihen'),
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
              !isSignedIn
                  ? ListTile(
                      title: Text('Einloggen'),
                      leading: Icon(Icons.exit_to_app),
                      onTap: () async {
                        log("Trying to log in from prefs.");

                        _authRepo.signInAuthUserIfPossible().then((authCredentials) {
                          if (authCredentials != null && authCredentials.user != null) {
                            log("logged in from prefs");
                            setState(() {
                              isSignedIn = true;
                            });
                          } else {
                            log("Couldn't log in from prefs, Going to log-in screen");

                          }
                        })
                        .catchError((e) {
                          log("Error while trying to log in from prefs: ${e}");
                          log("Going to log-in screen");
                          _globalService.showScreen(context, const LoginScreen());
                        });
                      })
                  : ListTile(
                      title: Text('Ausloggen'),
                      leading: Icon(Icons.exit_to_app),
                      onTap: () async {
                        log("Trying to log out");
                        _firebaseAuth.signOut().then((res) {
                          setState(() {
                            isSignedIn = false;
                          });
                          log("Successfully logged out: isloggedIn: ${isSignedIn}");
                        });
                      }),
            ],
          ),
        );
      },
    );
  }
}
