import 'package:firebase_storage/firebase_storage.dart';
import 'package:mapingu_app/models/UserDB.dart';
import 'dart:io';
import 'DBUtils.dart';

class StorageUtils {
  static StorageUtils _instance;
  FirebaseStorage storage;
  Reference rootRef;
  String userPath = DBUtils.getState().user.email + '/';

  StorageUtils._internal() {
    storage = FirebaseStorage.instance;
    rootRef = FirebaseStorage.instance.ref('/');
  }

  static StorageUtils getState() {
    if (_instance == null) {
      _instance = StorageUtils._internal();
    }
    return _instance;
  }

  Future<String> getImageUrl(imageName) async {
    print(imageName);
    return await storage.ref(imageName).getDownloadURL();
  }

  Future<String> getProfilePic() async {
    if (DBUtils.getState().user.pfp == 'pingu.png') {
      return await getImageUrl('System.Images/3.jpg');
    }
    return await getImageUrl (
        userPath + 'ProfilePic' + '/' + DBUtils.getState().user.pfp);
  }

  Future<String> getFriendProfilePic(Users user) async {
    if (user.pfp == 'pingu.png') {
      return await getImageUrl('System.Images/3.jpg');
    } else {
      return await getImageUrl (
          user.email + '/ProfilePic/' + user.pfp);
    }
  }

  Future<List<String>> getListProfilePics(List<Users> friends) async {
    List<String> photosURLPath = List();
    for (int i = 0; i < friends.length; i++) {
      if (friends[i].pfp == 'pingu.png') {
        photosURLPath.add(await getImageUrl('System.Images/3.jpg'));
      } else {
        photosURLPath.add(await getImageUrl(
            friends[i].email + '/ProfilePic/' + friends[i].pfp));
      }
    }
    return photosURLPath;
  }

  Future<List<String>> getListStories(Users user) async {
    List<String> photosURLPath = List<String>();
    for (int i = 0; i < user.fotos.length; i++) {
      photosURLPath.add(await getImageUrl(user.email + '/' + 'Friends' + '/' + user.fotos[i].nombre));
    }
    return photosURLPath;
  }

  Future<void> uploadFoto(localPath, privacity) async {
    int timestamp = DateTime.now().millisecondsSinceEpoch;
    String imageName = DBUtils.getState().user.name + timestamp.toString();
    String remotePath = userPath + privacity + '/' + imageName;
    if (privacity == 'ProfilePic') {
      DBUtils.getState().updatePFPUserPath(imageName);
    } else {
      DBUtils.getState().addStoryUser(imageName, timestamp);
    }
    await uploadFile(localPath, remotePath);
  }

  Future<void> uploadFile(localPath, remotePath) async {
    File file = File(localPath);
    try {
      await FirebaseStorage.instance.ref(remotePath).putFile(file);
    } on FirebaseException catch (e) {
      return e.message;
    }
  }
}
