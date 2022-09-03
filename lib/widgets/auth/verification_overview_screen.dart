import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:ensobox/widgets/auth/email_auth_form.dart';
import 'package:ensobox/widgets/auth/phone_auth_form.dart';
import 'package:ensobox/widgets/auth/success_screen.dart';
import 'package:ensobox/widgets/auth/wait_for_approval_screen.dart';
import 'package:ensobox/widgets/services/global_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:open_mail_app/open_mail_app.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/constants.dart';
import '../../main.dart';
import '../../models/enso_user.dart';
import '../../models/photo_side.dart';
import '../../models/photo_type.dart';
import '../camera/take_picture_screen.dart';
import '../firestore_repository/database_repo.dart';
import '../provider/current_user_provider.dart';
import '../service_locator.dart';
import '../../constants/constants.dart' as Constants;

GlobalService _globalService = getIt<GlobalService>();
DatabaseRepo _databaseRepo = getIt<DatabaseRepo>();
final FirebaseAuth _auth = FirebaseAuth.instance;
late final SharedPreferences prefs;
bool hasTriggeredConfirmationSms = false;
bool hasTriggeredConfirmationEmail = false;

class VerificationOverviewScreen extends StatefulWidget {
  @override
  State<VerificationOverviewScreen> createState() =>
      _VerificationOverviewScreenState();
}

class _VerificationOverviewScreenState
    extends State<VerificationOverviewScreen> {
  late Future<dynamic> _futureEnsoUser;

  @override
  void initState() {
    super.initState();
    final currentUserProvider =
    Provider.of<CurrentUserProvider>(context, listen: false);
    EnsoUser currentEnsoUser = currentUserProvider.currentEnsoUser;

    if (currentEnsoUser.id != null) {
      debugPrint(
          'Step 1, fetch data for _globalService.currentEnsoUser.id: ${currentEnsoUser.id!}');
      _futureEnsoUser =
          _databaseRepo.getUserFromDB(currentEnsoUser.id!);
    } else {
      _futureEnsoUser = Future.value(EnsoUser(EnsoUserBuilder()));
    }
  }

  void _showCamera() async {
    final List<CameraDescription> cameras = await availableCameras();
    _globalService.cameras = cameras;
    final CameraDescription camera = cameras.first;

    PhotoSide idSide = PhotoSide.front;
    if (isIdFrontAdded()) {
      idSide = PhotoSide.back;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => TakePictureScreen(
            camera: camera,
            photoType: PhotoType.id,
            photoSide: idSide),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      initialData: false,
      future: _futureEnsoUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data.runtimeType == EnsoUser) { // hasData is wrong for null values
          EnsoUser ensoUser = snapshot.data! as EnsoUser;
          User? user = _globalService.currentAuthUser;
          if (ensoUser.idApproved && user != null && user.emailVerified) {
            log("user is already approved. -> success screen");
            return _buildSuccessScreen(ensoUser);
          } else if (ensoUser.hasTriggeredIdApprovement){
            log("user has triggered id Approval already, but is not approved yet. -> WaitForApprovalScreen");
            return const WaitForApprovalScreen();
          } else if (!ensoUser.hasTriggeredConfirmationEmail){
            log("user has not triggered id Approval or email yet. -> _buildVerificationScreen");
            return EmailAuthForm();
            // return _buildEmailAuthFormScreen(ensoUser);
          } else if (!ensoUser.hasTriggeredConfirmationSms) {
            log("user has triggered email, but not id Approval or sms yet -> _buildPhoneScreen");
            return PhoneAuthForm();
          } else {
            log("user has not triggered id Approval or sms yet, but email. -> _buildIdVerificationScreen");

            final List<CameraDescription>? cameras = _globalService.cameras;
            late CameraDescription camera;
            if (cameras != null) {
              camera = cameras.first;
            }


            PhotoSide idSide = PhotoSide.front;
            if (isIdFrontAdded()) {
              idSide = PhotoSide.back;
            }

            return TakePictureScreen(
                camera: camera,
                photoType: PhotoType.id,
                photoSide: idSide);
          }
        } else {
          //TODO: replace endless Spinner with Error Screen -> the loaded User was null or an error occured during loading
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildSuccessScreen(EnsoUser ensoUser) {
    debugPrint('Step 2, build widget success, $ensoUser');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account erfolgreich bestätigt 🐱‍🏍'),
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        child: Text("Du kannst jetzt ausleihen"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.done_all,
                color: Colors.blue,
              ),
              label: "Jetzt ausleihen"),
        ],
        onTap: (int itemIndex) {
          log("Pressed Jetzt ausleihen" + itemIndex.toString());
          switch (itemIndex) {
            case 0:
              _globalService.showScreen(
                  context, const Home());
              break;

          }
        },
      ),);
  }

  Widget _buildEmailAuthFormScreen(EnsoUser ensoUser) {
    debugPrint('Step 2, build overview widget, hasTriggeredConfirmationSms?: ${ensoUser.hasTriggeredConfirmationSms}'
        '\n hasTriggeredConfirmationEmail?: ${ensoUser.hasTriggeredConfirmationEmail}\n'
        'idApproved?: ${ensoUser.idApproved}\n');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Identität bestätigen:'),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          Text(
              "Bevor du die Bohrmaschine ausleihen kannst, benötigen wir folgende Infos von dir:"),
          !ensoUser.hasTriggeredConfirmationSms
              ? ElevatedButton(
                  onPressed:
                      // TODO: was wenn app geschlossen wird und neu angefangen wird? isEmailVerified muss auch in user oder sharedPref gespeichert werden
                      () => showAddPhoneScreen(context),
                  child: Text('Handynummer & Email hinzufügen'),
                )
              : ensoUser.hasTriggeredConfirmationSms &&
                      !ensoUser.hasTriggeredConfirmationEmail
                  ? ElevatedButton(
                      onPressed: () =>
                          _globalService.showScreen(context, EmailAuthForm()),
                      child: const Text('Email hinzufügen'),
                    )
                  : ElevatedButton(
                      onPressed: () => showAddPhoneScreen(context),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green, // background (button) color
                        onPrimary: Colors.white, // foreground (text) color
                      ),
                      child: const Text('Handynummer oder Email ändern'),
                    ),
          ElevatedButton(
            onPressed: !isIdFrontAdded()
                ? startAddingIdFront
                : !isIdFrontAdded()
                    ? startAddingIdBack
                    : null,
            child: const Text('Perso oder Pass fotografieren'),
          )
        ],
      ),
    );
  }

  void startAddingIdFront() {
    log("Respond to button perso foto press, going to take front photo");
    if (!mounted) return;
    _showCamera();
  }

  void startAddingIdBack() {
    log("Respond to button perso foto press");
    if (!mounted) return;
    _showCamera();
  }

  bool isPhoneAdded() {
    return true;
  }

  bool isEmailAdded() {
    return false;
  }

  bool isIdFrontAdded() {
    return false;
  }

  bool isIdBackAdded() {
    return false;
  }

  void showAddPhoneScreen(BuildContext context) {
    log("Respond to button Handynummer verifizieren press");
    // showMrzScannerScreen(context);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return PhoneAuthForm();
    }));
  }

  void showAddEmailScreen() {
    log("Respond to button Email verifizieren press");
    // showMrzScannerScreen(context);
  }

  Future<void> initPrefs() async {
    prefs = await SharedPreferences.getInstance();

    final bool? hasTriggeredConfirmationSmsTmp =
        prefs.getBool(Constants.hasTriggeredConfirmationSms);
    if (hasTriggeredConfirmationSmsTmp != null) {
      hasTriggeredConfirmationSms = hasTriggeredConfirmationSmsTmp;
    }
    final bool? hasTriggeredConfirmationEmailTmp =
        prefs.getBool(Constants.hasTriggeredConfirmationEmail);
    if (hasTriggeredConfirmationEmailTmp != null) {
      hasTriggeredConfirmationEmail = hasTriggeredConfirmationEmailTmp;
    }
  }
}
