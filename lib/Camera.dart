import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapingu_app/PhotoPreview.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'QRReader.dart';

class Camera extends StatefulWidget {
  Camera({Key key, this.controller}) : super(key: key);

  final PageController controller;

  @override
  createState() => _myCamera();
}

class _myCamera extends State<Camera> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  List cameras;
  int selectedCameraIdx;
  bool _cameraDelanteraisOn = false;

  Future<CameraDescription> getCamera() async {
    cameras = await availableCameras();
    return cameras.first;
  }

  @override
  void initState() {
    super.initState();
    getCamera().then((camera) async {
      selectedCameraIdx = 0;
      await initCameraController(camera);
      setState(() {});
    });
  }

  Future initCameraController(CameraDescription camera) async {
    _controller = CameraController(camera, ResolutionPreset.veryHigh);
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (_controller.value.hasError) {
        print('Camera error ${_controller.value.errorDescription}');
      }
    });

    try {
      _initializeControllerFuture = _controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: FutureBuilder(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Transform.scale(
                    scale: _controller.value.aspectRatio / deviceRatio,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: CameraPreview(_controller),
                      ),
                    ));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        Positioned.fill(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              shadowColor: Colors.transparent,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              //Go back button
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: GestureDetector(
                    onTap: () {
                      widget.controller.animateToPage(
                        1,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                    child: Icon(Icons.arrow_forward),
                  ),
                ),
              ],
            ),
            body: Container(
              child: Stack(
                children: [
                  Positioned(
                    bottom: 70,
                    right: 20,
                    left: 20,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //QR Detector
                        IconButton(
                            icon: Icon(
                              Icons.qr_code_scanner,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              if (_cameraDelanteraisOn) {
                                await initCameraController(cameras[0]);
                              }
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QRPreview(),
                                ),
                              );
                            }),
                        Container(
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(25),
                                )),
                            child: GestureDetector(onTap: () async {
                              try {
                                await _initializeControllerFuture;
                                final path = join(
                                  (await getTemporaryDirectory()).path,
                                  '${DateTime.now()}.png',
                                );
                                await _controller.takePicture(path);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PhotoPreview(imagePath: path),
                                  ),
                                );
                              } catch (Error) {
                                print(Error);
                              }
                            }),
                          ),
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                              border: Border.all(
                                width: 5,
                                color: Colors.white.withOpacity(.5),
                              )),
                        ),
                        //Change Camera
                        Container(
                          height: 40,
                          child: GestureDetector(
                            child: Icon(
                              Icons.cached,
                              color: Colors.white,
                            ),
                            onTap: () async {
                              selectedCameraIdx =
                                  (selectedCameraIdx == 0) ? 1 : 0;
                              await initCameraController(
                                  cameras[selectedCameraIdx]);
                              _cameraDelanteraisOn = true;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
