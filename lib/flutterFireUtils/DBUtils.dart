import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mapingu_app/googleMapsUtils/APICalls.dart';
import '../models/UserDB.dart';

class DBUtils {
  static DBUtils _instance;
  final FirebaseFirestore database = FirebaseFirestore.instance;
  CollectionReference ref;
  UserDB userList;
  Users user;

  DBUtils._internal() {
    ref = database.collection('users');
  }

  static DBUtils getState() {
    if (_instance == null) {
      _instance = DBUtils._internal();
    }
    return _instance;
  }

  saveUser(email, emailName){
    getCoordenades().then((value) {
      user = Users(amigos: [], fotos: [], pfp: "pingu.png", email: email, name: emailName, location: userLocation(lat: value.latitude, long: value.longitude));
      ref.doc(email).set(user.toJson());
    });
  }

  addFriendToUser(friendEmail) {
    user.amigos.add(friendEmail);
    ref.doc(user.email).update({
      'amigos': FieldValue.arrayUnion([friendEmail])
    });
    ref.doc(friendEmail).update({
      'amigos': FieldValue.arrayUnion([user.email])
    });
  }

  updateUser(email, name) async {
    user = await getCoordenades().then((value) {
      //Amigos, fotos y pfp se  actualiza más adelante
      return Users(amigos: [], fotos: [], pfp: "pingu.png", email: email, name: name, location: userLocation(lat: value.latitude, long: value.longitude));
    });
  }

  updatePFPUserPath(imageName) {
    user.pfp = imageName;
    ref.doc(user.email).update({
      'pfp': imageName,
    });
  }

  addStoryUser(nameStory, timestamp) {
    Fotos foto = new Fotos();
    foto.nombre = nameStory;
    foto.timestamp = timestamp;
    user.fotos.add(foto);
    ref.doc(user.email).update({
      'fotos': FieldValue.arrayUnion([foto.toJson()])
    });
  }

  void updateLocationUserPath(userLocation location) {
    ref.doc(user.email).update({
      'location': location.toJson(),
    });
  }
}