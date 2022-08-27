import 'dart:developer';

import 'package:ensobox/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../globals/enso_divider.dart';
import '../service_locator.dart';
import '../services/global_service.dart';

GlobalService _globalService = getIt<GlobalService>();

class WaitForApprovalScreen extends StatelessWidget {
  const WaitForApprovalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Auf Bestätigung warten"),
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.blue),
      ),
      // backgroundColor: Constants.kPrimaryColor,
      body: Center(
        child: Column(
          children: [
            const Text(
                'Wir müssen deine Angaben prüfen, bevor du etwas ausleihen kannst. Das dauert in der Regel ca. 1-2 Tage.'
                    'Du erhälst von uns dann eine Email, sobald du ausleihen kannst. Sieh dazu auch im Spam Ordner nach.'
            ),
            const EnsoDivider(),
            Text(
                'Und vergiss nicht deine Emailadresse zu bestätigen, falls du das noch nicht getan hast. '
                    'Die Email mit dem Bestätigungslink könnte auch im Spam Ordner gelandet sein.'
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.done_all,
                color: Colors.blue,
              ),
              label: "Alles klaro"),
        ],
        onTap: (int itemIndex) {
          log("Pressed" + itemIndex.toString());
          switch (itemIndex) {
            case 0:
              _globalService.showScreen(
                  context, const Home());
              break;

          }
        },
      ),
    );
  }
}
