import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:ensobox/models/photo_side.dart';
import 'package:ensobox/models/photo_type.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeCameraControllerFuture;

  @override
  void initState() {
    super.initState();

    _cameraController = CameraController(widget.camera, ResolutionPreset.max);

    _initializeCameraControllerFuture = _cameraController!.initialize();
  }

  @override
  Widget build(BuildContext context) {
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
      if (widget.photoType == PhotoType.id) ...[
        Center(
          child: Container(
            height: 600,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: const AssetImage('assets/img/perso.png'),
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.4),
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
                _cameraController!.resumePreview();
                // _cameraController!.dispose();
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
