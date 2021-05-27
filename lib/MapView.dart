import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mapingu_app/StoriesList.dart';
import 'package:mapingu_app/flutterFireUtils/DBUtils.dart';
import 'package:mapingu_app/googleMapsUtils/locations.dart';
import 'package:mapingu_app/musicUtils/musicUtils.dart';

import 'CircularButton.dart';
import 'PopUpProfile.dart';
import 'PopUpQR.dart';
import 'flutterFireUtils/DBUtils.dart';
import 'googleMapsUtils/APICalls.dart';
import 'googleMapsUtils/locations.dart';
import 'models/UserDB.dart';

class MapView extends StatefulWidget {
  MapView({Key key, this.controller}) : super(key: key);

  final PageController controller;

  @override
  createState() => _myMapView();
}

class _myMapView extends State<MapView> with SingleTickerProviderStateMixin {
  StreamSubscription listener;
  GoogleMapController mapController;
  final controller = PageController(initialPage: 1);
  final CameraPosition _center = CameraPosition(
      target: LatLng(39.56552062811425, 2.6299959440994383), zoom: 15);
  var userPlace = new locations();

  List<Users> friendList = List<Users>();
  Set<Marker> mapMarkers = Set<Marker>();

  AnimationController animationController;
  Animation animationObj, animationObj2, animationObj3;
  Animation animationRotation, animationColor;

  BitmapDescriptor placeIcon;
  BitmapDescriptor friendIcon;
  IconData _icon = Icons.fiber_manual_record_outlined;
  Color _colorIcon = Colors.white;

  getMarkerIcons() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5),
            "assets/relevantplace.png")
        .then((value) => setState(() {
              placeIcon = value;
            }));
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(devicePixelRatio: 2.5), "assets/pingufriend.png")
        .then((value) => setState(() {
              friendIcon = value;
            }));
  }

  getMarkers() {
    getLocations().then((value) {
      setState(() {
        mapMarkers.clear();
        for (int i = 0; i < value.results.length; i++) {
          mapMarkers.add(Marker(
            markerId: MarkerId(value.results[i].name),
            draggable: false,
            icon: placeIcon,
            position: LatLng(value.results[i].geometry.location.lat,
                value.results[i].geometry.location.lng),
            visible: true,
            infoWindow: InfoWindow(title: value.results[i].name),
          ));
        }
      });
    });
  }

  placeFriendsOnMap() {
    for (int i = 0; i < friendList.length; i++) {
      mapMarkers.add(Marker(
        markerId: MarkerId(friendList[i].name),
        draggable: false,
        icon: friendIcon,
        position:
            LatLng(friendList[i].location.lat, friendList[i].location.long),
        visible: true,
        infoWindow: InfoWindow(title: friendList[i].name),
      ));
    }
  }

  double degreeToRadians(double degree) {
    double unitRadian = 360 / (2 * pi);
    return degree / unitRadian;
  }

  AnimationController getAnimationController() {
    return animationController;
  }

  //Posició inicial
  getCameraPosition() async {
    var getLoc = Location();
    var location = await getLoc.getLocation();
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(location.latitude, location.longitude), zoom: 15)));
  }

  //Live location
  constantUserObservation() async {
    var getLoc = Location();
    var location = await getLoc.getLocation();

    Future.delayed(const Duration(milliseconds: 700), () {
      if (mapController != null) {
        mapController.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(location.latitude, location.longitude),
                zoom: 15)));
      }
    });

    if (listener != null) {
      listener.cancel();
    }

    listener = getLoc.onLocationChanged.listen((event) {
      if (mapController != null) {
        getMarkers();
        placeFriendsOnMap();
        DBUtils.getState().updateLocationUserPath(
            userLocation(lat: location.latitude, long: location.longitude));
      }
    });
  }

  @override
  void initState() {
    friendList = List<Users>();
    getMarkerIcons();

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 350));
    animationObj = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.2), weight: 75.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.2, end: 1.0), weight: 25.0),
    ]).animate(animationController);
    animationObj2 = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.4), weight: 55.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.4, end: 1.0), weight: 45.0),
    ]).animate(animationController);
    animationObj3 = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.0, end: 1.6), weight: 45.0),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 1.6, end: 1.0), weight: 55.0),
    ]).animate(animationController);
    animationRotation = Tween(begin: 360.0, end: 0.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeOut));
    animationColor = ColorTween(
      begin: Colors.black,
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Interval(0.00, 1.00, curve: Curves.easeOut),
    ));
    super.initState();
    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    constantUserObservation();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: DBUtils.getState().ref.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          retrieveInformationFirestoreDB(snapshot.data);
          return defaultView();
        } else {
          return defaultViewWithourStories();
        }
      },
    );
  }

  void retrieveInformationFirestoreDB(QuerySnapshot snapshot) {
    DBUtils.getState().userList = UserDB();
    DBUtils.getState().userList.users = List<Users>();
    friendList = List<Users>();
    List<DocumentSnapshot> docsList = snapshot.docs.toList(growable: false);

    //Obtenemos todos los usuarios y los guardamos en memoria. También actualizamos al usuario de la aplicación
    docsList.forEach((element) {
      Users user = Users.fromJson(element.data());
      if (user.email == DBUtils.getState().user.email) {
        DBUtils.getState().user = user;
      } else {
        DBUtils.getState().userList.users.add(user);
      }
    });

    //Buscamos para cada uno de los amigos
    for (int i = 0; i < DBUtils.getState().user.amigos.length; i++) {
      //Para cada uno de los amigos miramos toda la DB
      for (int j = 0; j < DBUtils.getState().userList.users.length; j++) {
        //Comprovamos si es amigo
        if (DBUtils.getState().user.amigos[i] ==
            DBUtils.getState().userList.users[j].email) {
          List<Fotos> fotosAux = List<Fotos>();

          //Si es amigo buscamos las últimas fotos
          DBUtils.getState().userList.users[j].fotos.forEach((foto) {
            //Si no han pasado 72h guardamos la story, sino la marcamos como caducada
            int time = DateTime.now().millisecondsSinceEpoch;
            print("Resta: " + (time - foto.timestamp).toString());
            //Si la foto ha caducado, no la añadimos a fotos a mostrar
            if ((time - foto.timestamp) < 259200000) {
              fotosAux.add(foto);
            }
          });

          //Guardamos el usuario en la lista de amigos
          Users user = Users(
              amigos: [],
              fotos: fotosAux,
              pfp: DBUtils.getState().userList.users[j].pfp,
              email: DBUtils.getState().userList.users[j].email,
              name: DBUtils.getState().userList.users[j].name,
              location: DBUtils.getState().userList.users[j].location);
          friendList.add(user);
        }
      }
    }
    placeFriendsOnMap();
  }

  Scaffold defaultView() {
    return Scaffold(
      //Indicamos al body que se extienda también por la navbar
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/pingu.png',
              fit: BoxFit.contain,
              height: 45,
            ),
          ],
        ),
      ),

      body: GestureDetector(
        child: Stack(
          children: <Widget>[
            Container(
              child: GoogleMap(
                onMapCreated: (GoogleMapController tempMapController) {
                  mapController = tempMapController;
                },
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                mapType: MapType.normal,
                zoomControlsEnabled: false,
                initialCameraPosition:
                    CameraPosition(target: LatLng(50, 50), zoom: 5),
                markers: mapMarkers,
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 120,
                child: StoriesList(friendList),
              ),
            ),
          ],
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    IgnorePointer(
                      child: Container(
                        color: Colors.transparent,
                        height: 150.0,
                        width: 200.0,
                      ),
                    ),
                    Transform.translate(
                      offset: Offset.fromDirection(
                          degreeToRadians(225), animationObj.value * 100),
                      child: Transform(
                        transform: Matrix4.rotationZ(
                            degreeToRadians(animationRotation.value))
                          ..scale(animationObj.value),
                        alignment: Alignment.center,
                        child: CircularButton(
                          color: Colors.white,
                          width: 50,
                          height: 50,
                          icon: Icon(
                            Icons.campaign_rounded,
                            size: 25,
                            color: Colors.black,
                          ),
                          onClick: () {
                            animationController.reverse();
                            musicUtils.getState().playMusic();
                            setState(() {
                              _icon = Icons.fiber_manual_record_outlined;
                              _colorIcon = Colors.white;
                            });
                          },
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset.fromDirection(
                          degreeToRadians(270), animationObj2.value * 100),
                      child: Transform(
                        transform: Matrix4.rotationZ(
                            degreeToRadians(animationRotation.value))
                          ..scale(animationObj2.value),
                        alignment: Alignment.center,
                        child: CircularButton(
                          color: Colors.white,
                          width: 50,
                          height: 50,
                          icon: Icon(
                            Icons.person_pin,
                            size: 25,
                            color: Colors.black,
                          ),
                          onClick: () {
                            animationController.reverse();
                            setState(() {
                              animationController.reverse();
                              setState(() {
                                _icon = Icons.fiber_manual_record_outlined;
                                _colorIcon = Colors.white;
                                getCameraPosition();
                              });
                            });
                          },
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset.fromDirection(
                          degreeToRadians(315), animationObj3.value * 100),
                      child: Transform(
                        transform: Matrix4.rotationZ(
                            degreeToRadians(animationRotation.value))
                          ..scale(animationObj3.value),
                        alignment: Alignment.center,
                        child: CircularButton(
                          color: Colors.white,
                          width: 50,
                          height: 50,
                          icon: Icon(
                            Icons.qr_code_rounded,
                            size: 25,
                            color: Colors.black,
                          ),
                          onClick: () async {
                            _icon = Icons.fiber_manual_record_outlined;
                            animationController.reverse();
                            setState(() {
                              _colorIcon = Colors.white;
                            });
                            await showDialog(
                                context: context, builder: (_) => PopUpQR());
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      height: 75,
                      child: Transform(
                        transform: Matrix4.rotationZ(
                            degreeToRadians(animationRotation.value)
                        ),
                        alignment: Alignment.center,
                        child: CircularButton(
                          color: animationColor.value,
                          width: 45,
                          height: 45,
                          icon: Icon(_icon, size: 25, color: _colorIcon),
                          onClick: () {
                            if (animationController.isCompleted) {
                              animationController.reverse();
                              setState(() {
                                _icon = Icons.fiber_manual_record_outlined;
                                _colorIcon = Colors.white;
                              });
                            } else {
                              animationController.forward();
                              setState(() {
                                _icon = Icons.clear;
                                _colorIcon = Colors.black;
                              });
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: CurvedNavigationBar(
        index: 1,
        letIndexChange: ((_) => false),
        height: 50.0,
        color: Colors.white,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.transparent,
        items: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Icon(Icons.camera_alt_outlined, size: 30),
            onTap: () {
              widget.controller.animateToPage(
                0,
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            },
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Icon(Icons.check_box_outline_blank, size: 25),
          ),
          GestureDetector(
            //behavior: HitTestBehavior.translucent,
            child: Icon(Icons.account_circle_outlined, size: 30),
            onTap: () async {
              await showDialog(
                  context: context, builder: (_) => PopUpProfile());
              friendList = List<Users>();
            },
          )
        ],
      ),
    );
  }

  Scaffold defaultViewWithourStories() {
    return Scaffold(
      //Indicamos al body que se extienda también por la navbar
      extendBody: true,
      appBar: AppBar(
        toolbarHeight: 40,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/pingu.png',
              fit: BoxFit.contain,
              height: 45,
            ),
          ],
        ),
      ),

      body: GestureDetector(
        child: Stack(
          children: <Widget>[
            Container(
              child: GoogleMap(
                onMapCreated: (GoogleMapController tempMapController) {
                  mapController = tempMapController;
                },
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
                mapType: MapType.normal,
                zoomControlsEnabled: false,
                initialCameraPosition:
                    CameraPosition(target: LatLng(0, 0), zoom: 15),
                markers: mapMarkers,
              ),
            ),
          ],
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Stack(
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    IgnorePointer(
                      child: Container(
                        color: Colors.transparent,
                        height: 150.0,
                        width: 200.0,
                      ),
                    ),
                    Transform.translate(
                      offset: Offset.fromDirection(
                          degreeToRadians(225), animationObj.value * 100),
                      child: Transform(
                        transform: Matrix4.rotationZ(
                            degreeToRadians(animationRotation.value))
                          ..scale(animationObj.value),
                        alignment: Alignment.center,
                        child: CircularButton(
                          color: Colors.white,
                          width: 50,
                          height: 50,
                          icon: Icon(
                            Icons.campaign_rounded,
                            size: 25,
                            color: Colors.black,
                          ),
                          onClick: () {
                            animationController.reverse();
                            musicUtils.getState().playMusic();
                            setState(() {
                              _icon = Icons.fiber_manual_record_outlined;
                              _colorIcon = Colors.white;
                            });
                          },
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset.fromDirection(
                          degreeToRadians(270), animationObj2.value * 100),
                      child: Transform(
                        transform: Matrix4.rotationZ(
                            degreeToRadians(animationRotation.value))
                          ..scale(animationObj2.value),
                        alignment: Alignment.center,
                        child: CircularButton(
                          color: Colors.white,
                          width: 50,
                          height: 50,
                          icon: Icon(
                            Icons.group_outlined,
                            size: 25,
                            color: Colors.black,
                          ),
                          onClick: () {
                            animationController.reverse();
                            setState(() {
                              _icon = Icons.fiber_manual_record_outlined;
                              _colorIcon = Colors.white;
                              getCameraPosition();
                            });
                          },
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset.fromDirection(
                          degreeToRadians(315), animationObj3.value * 100),
                      child: Transform(
                        transform: Matrix4.rotationZ(
                            degreeToRadians(animationRotation.value))
                          ..scale(animationObj3.value),
                        alignment: Alignment.center,
                        child: CircularButton(
                          color: Colors.white,
                          width: 50,
                          height: 50,
                          icon: Icon(
                            Icons.qr_code_rounded,
                            size: 25,
                            color: Colors.black,
                          ),
                          onClick: () async {
                            _icon = Icons.fiber_manual_record_outlined;
                            animationController.reverse();
                            setState(() {
                              _colorIcon = Colors.white;
                            });
                            await showDialog(
                                context: context, builder: (_) => PopUpQR());
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      height: 75,
                      child: Transform(
                        transform: Matrix4.rotationZ(
                            degreeToRadians(animationRotation.value)),
                        alignment: Alignment.center,
                        child: CircularButton(
                          color: animationColor.value,
                          width: 45,
                          height: 45,
                          icon: Icon(_icon, size: 25, color: _colorIcon),
                          onClick: () {
                            if (animationController.isCompleted) {
                              animationController.reverse();
                              setState(() {
                                _icon = Icons.fiber_manual_record_outlined;
                                _colorIcon = Colors.white;
                              });
                            } else {
                              animationController.forward();
                              setState(() {
                                _icon = Icons.clear;
                                _colorIcon = Colors.black;
                              });
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar: CurvedNavigationBar(
        index: 1,
        letIndexChange: ((_) => false),
        height: 50.0,
        color: Colors.white,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.transparent,
        items: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Icon(Icons.camera_alt_outlined, size: 30),
            onTap: () {
              widget.controller.animateToPage(
                0,
                duration: Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            },
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Icon(Icons.check_box_outline_blank, size: 25),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            child: Icon(Icons.account_circle_outlined, size: 30),
            onTap: () async {
              await showDialog(
                  context: context, builder: (_) => PopUpProfile());
            },
          )
        ],
      ),
    );
  }
}
