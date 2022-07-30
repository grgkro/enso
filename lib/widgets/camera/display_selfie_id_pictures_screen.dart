import 'dart:developer';
import 'dart:io';

import 'package:ensobox/widgets/globals/enso_divider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/enso_user.dart';
import '../auth/verification_overview_screen.dart';
import '../auth/wait_for_approval_screen.dart';
import '../service_locator.dart';
import '../services/global_service.dart';

GlobalService _globalVariablesService = getIt<GlobalService>();

class DisplaySelfieIdPicturesScreen extends StatefulWidget {
  const DisplaySelfieIdPicturesScreen({Key? key}) : super(key: key);

  @override
  State<DisplaySelfieIdPicturesScreen> createState() =>
      _DisplaySelfieIdPicturesScreenState();
}

class _DisplaySelfieIdPicturesScreenState
    extends State<DisplaySelfieIdPicturesScreen> {
  bool agree = false;

  void _showWaitForApprovalScreen(BuildContext ctx) {
    log("User accepted terms and condition");
    _globalVariablesService.showScreen(ctx, const WaitForApprovalScreen());
    // Do something
  }

  @override
  Widget build(BuildContext context) {
    EnsoUser currentUser = Provider.of<EnsoUser>(context, listen: false);
    final Uri _url_data_privacy =
        Uri.parse('https://fairleihbox.de/privacy-policy/');
    final Uri _url_agb = Uri.parse('https://fairleihbox.de');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Datenschutz akzeptieren'),
        backgroundColor: Colors.green[700],
      ),
      resizeToAvoidBottomInset: false,
      body:
          // SingleChildScrollView(
          //   child:
          Column(
        children: [
          Text(
              'Bitte prüfe nochmal, ob alles passt und akzeptiere dann die Datenschutzbestimmungen und die AGB.'),
          EnsoDivider(),
          Text('Vorderseite:'),
          Expanded(
            child: Container(
              width: MediaQuery.of(context)
                  .size
                  .width, // or use fixed size like 200
              // height: MediaQuery.of(context).size.height / 2 - 100,
              child: Image.file(File(currentUser.frontIdPhotoPath!)),
            ),
          ),
          EnsoDivider(),
          Text('Rückseite:'),
          Expanded(
            child: Container(
              width: MediaQuery.of(context)
                  .size
                  .width, // or use fixed size like 200
              // height: MediaQuery.of(context).size.height / 2 - 100,
              child: Image.file(File(currentUser.backIdPhotoPath!)),
            ),
          ),
          EnsoDivider(),
          Text('Selfie:'),
          Expanded(
            child: Container(
              width: MediaQuery.of(context)
                  .size
                  .width, // or use fixed size like 200
              // height: MediaQuery.of(context).size.height / 2 - 100,
              child: Image.file(File(currentUser.selfiePhotoPath!)),
            ),
          ),
          EnsoDivider(),
          Row(
            children: [
              Material(
                child: Checkbox(
                  value: agree,
                  onChanged: (value) {
                    setState(() {
                      agree = value ?? false;
                    });
                  },
                ),
              ),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'Ich akzeptiere die ',
                    ),
                    TextSpan(
                        style: TextStyle(color: Colors.blue),
                        //make link blue and underline
                        text: "Datenschutzrichtlinien",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            //on tap code here, you can navigate to other page or URL
                            var urllaunchable = await canLaunchUrl(
                                _url_data_privacy); //canLaunch is from url_launcher package
                            if (urllaunchable) {
                              // TODO: think of a fallback url
                              await launchUrl(
                                  _url_data_privacy); //launch is from url_launcher package to launch URL
                            } else {
                              print("URL can't be launched.");
                            }
                          }),
                    TextSpan(
                      text: ' und die ',
                    ),
                    TextSpan(
                        style: TextStyle(color: Colors.blue),
                        //make link blue and underline
                        text: "AGB",
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            //on tap code here, you can navigate to other page or URL
                            var urllaunchable = await canLaunchUrl(
                                _url_agb); //canLaunch is from url_launcher package
                            if (urllaunchable) {
                              // TODO: think of a fallback url
                              await launchUrl(
                                  _url_agb); //launch is from url_launcher package to launch URL
                            } else {
                              print("URL can't be launched.");
                            }
                          }),
                    TextSpan(
                      text: '.',
                    ),
                    //more text paragraph, sentences here.
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.blue,
              ),
              label: "Abbrechen"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.done_all,
                color: Colors.blue,
              ),
              label: "Fertig"),
        ],
        onTap: (int itemIndex) {
          log("Pressed" + itemIndex.toString());
          switch (itemIndex) {
            case 0:
              _globalVariablesService.showScreen(
                  context, VerificationOverviewScreen());
              break;
            case 1:
              agree ? _showWaitForApprovalScreen(context) : null;
          }
        },
      ),
    );
  }
}
