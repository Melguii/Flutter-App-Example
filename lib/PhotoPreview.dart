import 'dart:collection';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapingu_app/flutterFireUtils/StorageUtils.dart';
import 'dart:io';
import 'Camera.dart';
import 'MapView.dart';

class PhotoPreview extends StatefulWidget {
  PhotoPreview({Key key, this.imagePath}) : super(key: key);
  final String imagePath;

  @override
  createState() => _photoPreview();
}

class _photoPreview extends State<PhotoPreview>
    with SingleTickerProviderStateMixin {
  final controller = PageController(initialPage: 1);

  AnimationController animationController;
  Animation<Color> animationColor;
  int times_tapped = 0;
  int color = 0;

  double degreeToRadians(double degree) {
    double unitRadian = 360 / (2 * pi);
    return degree / unitRadian;
  }

  AnimationController getAnimationController() {
    return animationController;
  }

  loadMenu() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PageView(
          physics: new NeverScrollableScrollPhysics(),
          controller: controller,
          children: [
            Camera(controller: this.controller),
            MapView(controller: this.controller),
          ],
        ),
      ),
    );
  }

  _changeColorTween() {
    animationColor = ColorTween(
      begin: Colors.grey.withOpacity(.55),
      end: Colors.red.withOpacity(.55),
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.00, 1.00, curve: Curves.easeOut),
    ));
  }

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _changeColorTween();
    super.initState();
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        centerTitle: true,
        toolbarHeight: 40,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Image.asset(
              'assets/pingu.png',
              fit: BoxFit.contain,
              height: 45,
            ),
            GestureDetector(
              child: Icon(
                Icons.arrow_back,
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Container(
              alignment: Alignment.bottomCenter,
              child: Image.file(File(widget.imagePath))
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 18.0),
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                  color: animationColor.value,
                  borderRadius: BorderRadius.all(
                    Radius.circular(35),
                  ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(
                            Radius.circular(35),
                          )),
                      child: Center(
                        child: GestureDetector(
                            child: Icon(
                              Icons.account_circle,
                              size: 30,
                              color: Colors.white,
                            ),
                            onTap: () async {
                              animationController.forward();
                              if (color == 1) {
                                color = 0;
                                times_tapped = 0;
                              }
                              if (times_tapped == 1) {
                                //Subimos foto
                                await StorageUtils.getState().uploadFoto(widget.imagePath, 'Friends');
                                loadMenu();
                              }
                              times_tapped++;
                            }),
                      ),
                    ),
                    height: 70,
                    width: 70,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.all(
                          Radius.circular(40),
                        ),
                        border: Border.all(
                          width: 5,
                          color: Colors.red.withOpacity(.5),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
