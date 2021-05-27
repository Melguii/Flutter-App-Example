import 'dart:collection';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapingu_app/flutterFireUtils/DBUtils.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:toast/toast.dart';
import 'Camera.dart';
import 'MapView.dart';

class QRPreview extends StatefulWidget {
  const QRPreview({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRView();
}

class _QRView extends State<QRPreview> {
  final pageController = PageController(initialPage: 1);

  Barcode result;
  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_back),
        backgroundColor: Colors.red,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PageView(
                physics: new NeverScrollableScrollPhysics(),
                controller: pageController,
                children: [
                  Camera(controller: this.pageController),
                  MapView(controller: this.pageController),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    return QRView(
      key: qrKey,
      cameraFacing: CameraFacing.front,
      onQRViewCreated: _onQRViewCreated,
      formatsAllowed: [BarcodeFormat.qrcode],
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        //
        if (result.code.contains('@')) {
          DBUtils.getState().addFriendToUser(result.code);
          Toast.show('You have a new friend!', context,
              duration: 1, gravity: Toast.BOTTOM);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PageView(
                physics: new NeverScrollableScrollPhysics(),
                controller: pageController,
                children: [
                  Camera(controller: this.pageController),
                  MapView(controller: this.pageController),
                ],
              ),
            ),
          );
        }
      });
    });
  }
}
