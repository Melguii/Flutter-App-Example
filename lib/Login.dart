import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapingu_app/flutterFireUtils/loginUtils.dart';
import 'Camera.dart';
import 'MapView.dart';
import 'flutterFireUtils/DBUtils.dart';

class LoginScreen extends StatelessWidget {
  final controller = PageController(initialPage: 1);

  final database = DBUtils.getState();

  // ignore: deprecated_member_use
  final smtpServer = gmail('mappinguservices@gmail.com', 'mappingu1999');

  _basicEmail(String destination) {
    return Message()
      ..from = Address('mappinguservices@gmail.com', 'Mapingu Team')
      ..recipients.add(destination)
      ..subject = 'You have been invitated to Mapingu App! 😀'
      ..html = '''<!DOCTYPE html>
              <html lang="en">
              <head>
                <meta charset="utf-8">
                <title>Pingu Invite</title>
                <link href="lib/bootstrap/css/bootstrap.min.css" rel="stylesheet">
              </head>
              <body id="page-top">
                <div class="jumbotron cover">
                <img src="https://i.pinimg.com/originals/26/11/36/2611362427dd6121fd2334e127b31492.jpg">
                <div class="container text-center">
                  <hr border-top="3px">
                  <h1 class="cover">You have been invited by the greatest Pingu to use the MapPingu App!</h1>
                </div>
              </div>
              <style>
                .jumbotron.cover {
                  position: relative;
                 }
                img {
                  position: absolute;
                  z-index: -1;
                  width: 100%;
                }
              </style>
              </body>
              </html>''';
  }

  Duration get loginTime => Duration(milliseconds: 2250);

  //Login
  Future<String> _authUser(LoginData data) {
    return Future.delayed(loginTime).then((_) {
      return loginUtils(FirebaseAuth.instance).login(
          email: data.name,
          pass:  data.password,
      ).then((value) async {
        if (value == null) {
          return 'Email not exists';
        }
        await database.updateUser(data.name, data.name.split('@')[0]);
        return null;
      });
    });
  }

  //Sign Up
  Future<String> _signUpUser(LoginData data) {
    return Future.delayed(loginTime).then((_) {
      return loginUtils(FirebaseAuth.instance).register(
          email: data.name,
          pass:  data.password,
      ).then((value){
        if (value == null){
          return "There has been an error :(";
        }
        //Guardamos usuario a la BBDD
        database.saveUser(data.name, data.name.split('@')[0]);
        return null;
      }
      );
    });
  }

  //Invite
  Future<String> _inviteFriend(String name) {
    return Future.delayed(loginTime).then((_) async {
      await send(_basicEmail(name), smtpServer);
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = BorderRadius.vertical(
      bottom: Radius.circular(10.0),
      top: Radius.circular(20.0),
    );

    return FlutterLogin(
      title: 'Mapingu',
      logo: 'assets/pingu.png',
      onLogin: _authUser,
      onSignup: _signUpUser,
      onRecoverPassword: _inviteFriend,
      onSubmitAnimationCompleted: () {
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
      },
      messages: LoginMessages(
          forgotPasswordButton: 'Invite a friend!',
          recoverPasswordDescription:
              'We will send an invitation to your friend!',
          recoverPasswordIntro: '',
          recoverPasswordButton: 'INVITE',
          recoverPasswordSuccess: 'Invitation sended'),
      theme: LoginTheme(
        primaryColor: Color.fromRGBO(240, 191, 146, 1.0),
        accentColor: Colors.red,
        errorColor: Colors.deepOrange,
        titleStyle: TextStyle(
          color: Colors.white,
          fontFamily: 'Quicksand',
          letterSpacing: 4,
        ),
        bodyStyle: TextStyle(
          decoration: TextDecoration.underline,
        ),
        buttonStyle: TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 5,
          margin: EdgeInsets.only(top: 15),
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(100.0)),
        ),
        inputTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.purple.withOpacity(.1),
          contentPadding: EdgeInsets.zero,
          errorStyle: TextStyle(
            backgroundColor: Color.fromRGBO(255, 131, 110, 1.0),
            color: Colors.white,
          ),
          labelStyle: TextStyle(fontSize: 12),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade700, width: 7),
            borderRadius: inputBorder,
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red.shade400, width: 8),
            borderRadius: inputBorder,
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 5),
            borderRadius: inputBorder,
          ),
        ),
        buttonTheme: LoginButtonTheme(
          splashColor: Colors.red,
          backgroundColor: Colors.red,
          elevation: 4.0,
          highlightElevation: 6.0,
        ),
      ),
    );
  }
}
