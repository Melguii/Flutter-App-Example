import 'package:firebase_auth/firebase_auth.dart';

class loginUtils{
  final FirebaseAuth auth;
  loginUtils(this.auth);

  Stream<User> get authStateChanges => auth.authStateChanges(); 

  String checkUser(){
  auth.authStateChanges().listen((User user) {
    if (user == null) {
      return('OK');
    } else {
      return('KO');
    }
  });
}

  Future<String> login ({String email, String pass}) async {
    try{
      await auth.signInWithEmailAndPassword(email: email, password: pass);
      return "Logged";
    }catch(e){
      print(e);
      return null;
      }
    }

  Future<String> register ({String email, String pass}) async {
    try{
      await auth.createUserWithEmailAndPassword(email: email, password: pass);
      return "Registered";
    }on FirebaseAuthException catch(e){
      return null;
    }
  }
}