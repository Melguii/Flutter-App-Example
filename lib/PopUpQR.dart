import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'flutterFireUtils/DBUtils.dart';

class PopUpQR extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          height: 260,
          width: 200,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          alignment: Alignment.center,
          child: QrImage(
            data: DBUtils.getState().user.email,
            embeddedImage: AssetImage('assets/pingu.png'),
            version: QrVersions.auto,
            size: 250,
            gapless: false,
            foregroundColor: Colors.black,
          ),
        ),
      ),
    );
  }
}