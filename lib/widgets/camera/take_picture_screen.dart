import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:ensobox/models/photo_side.dart';
import 'package:ensobox/models/photo_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../models/enso_user.dart';
import 'display_picture_screen.dart';

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  final PhotoType photoType;
  final PhotoSide photoSide;

  TakePictureScreen(
      {required this.camera, required this.photoType, required this.photoSide});

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  Future<void>? _initializeCameraControllerFuture;
  bool _isCameraInitialized = false;

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = _cameraController;
    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
        cameraDescription, ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg, enableAudio: false);

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        _cameraController = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = _cameraController!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _cameraController = CameraController(widget.camera, ResolutionPreset.max,
        imageFormatGroup: ImageFormatGroup.jpeg, enableAudio: false);

    _initializeCameraControllerFuture = _cameraController!.initialize();

    if (mounted) {
      setState(() {
        _isCameraInitialized = _cameraController!.value.isInitialized;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
      log("Disposed the camera to save memory, because the App Lifesycle was inactive");
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    log("Disposed the camera to save memory");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    EnsoUser currentUser = Provider.of<EnsoUser>(context, listen: false);

    return Stack(children: <Widget>[
      FutureBuilder(
        future: _initializeCameraControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_cameraController!);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      if (widget.photoType == PhotoType.id &&
          widget.photoSide == PhotoSide.front) ...[
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: const AssetImage('assets/img/perso-vs.png'),
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.1),
                      BlendMode.modulate,
                    ))),
          ),
        ),
      ],
      if (widget.photoType == PhotoType.id &&
          widget.photoSide == PhotoSide.back) ...[
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: const AssetImage('assets/img/perso-rs.png'),
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.1),
                      BlendMode.modulate,
                    ))),
          ),
        ),
      ],
      Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FloatingActionButton(
            // Provide an onPressed callback.
            onPressed: () async {
              // Take the Picture in a try / catch block. If anything goes wrong,
              // catch the error.
              try {
                // Ensure that the camera is initialized.
                await _initializeCameraControllerFuture;
                XFile image;
                // Attempt to take a picture and then get the location
                // where the image file is saved.
                if (_cameraController != null) {
                  image = await _cameraController!.takePicture();
                } else {
                  log("Tried to takePicture before _cameraController was initialized - _initializeCameraControllerFuture was wrongly true");
                  return;
                }

                if (!mounted) return;

                // If the picture was taken, display it on a new screen.
                // _cameraController!.resumePreview();
                // _cameraController!.dispose();

                if (currentUser != null) {
                  if (widget.photoType == PhotoType.id &&
                      widget.photoSide == PhotoSide.front) {
                    currentUser.frontIdPhotoPath = image.path;
                  } else if (widget.photoType == PhotoType.id &&
                      widget.photoSide == PhotoSide.back) {
                    currentUser.backIdPhotoPath = image.path;
                  } else if (widget.photoType == PhotoType.selfie) {
                    currentUser.selfiePhotoPath = image.path;
                  } else {
                    log("WARN: photo was neither a selfie nor an id photo");
                  }
                } else {
                  log("WARN: Can't add the photo to the currentUser, currentUser was null");
                }

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                      // Pass the automatically generated path to
                      // the DisplayPictureScreen widget.
                      imagePath: image.path,
                      photoType: widget.photoType,
                      photoSide: widget.photoSide,
                    ),
                  ),
                );
              } catch (e) {
                // If an error occurs, log the error to the console.
                print(e);
              }
            },
            child: const Icon(Icons.camera_alt),
          ),
        ),
      )
    ]);
  }

  void _takePicture(BuildContext context) async {
    try {
      await _initializeCameraControllerFuture;

      final path =
          join((await getTemporaryDirectory()).path, '${DateTime.now()}.png');

      await _cameraController!.takePicture();

      Navigator.pop(context, path);
    } catch (e) {
      print(e);
    }
  }
}
