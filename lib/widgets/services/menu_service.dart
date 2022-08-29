import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

class MenuService {

  getMenuButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.menu_rounded),
      onSelected: handleClick,
      itemBuilder: (BuildContext context) {
        return {'Logout', 'Einstellungen'}.map((String choice) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(choice),
          );
        }).toList();
      },
    );
  }

  void handleClick(String value) {
    switch (value) {
      case 'Logout':
        log("Trying to log out");
        _firebaseAuth.signOut().then((res) {
          log("Successfully logged out");
        });
        break;
      case 'Einstellungen':
        break;
    }
  }
}