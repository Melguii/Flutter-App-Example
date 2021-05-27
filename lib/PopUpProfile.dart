import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'Login.dart';
import 'flutterFireUtils/DBUtils.dart';
import 'flutterFireUtils/StorageUtils.dart';

class PopUpProfile extends StatelessWidget {
  final controller = PageController(initialPage: 1);

  Future<Image> getImageProfile() async {
    return Image.network(await StorageUtils.getState().getProfilePic(),
        fit: BoxFit.cover);
  }

  //Si tarda en cargar la imagen o se pierda la connexión, se carga una foto de stock
  Image getStockImage() {
    return Image.asset('assets/white.jpg', fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getImageProfile(),
      builder: (BuildContext context, AsyncSnapshot<Image> image) {
        if (image.hasData) {
          return popUp(context, image.data);
        } else {
          return popUp(context, getStockImage());
        }
      },
    );
  }

  Dialog popUp(BuildContext context, Image image) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(color: Colors.grey, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          height: 230,
          width: 100,
          child: Column(
            children: [
              GestureDetector(
                onTapDown: (details) async {
                  final picker = ImagePicker();
                  final imagePicked =
                  await picker.getImage(source: ImageSource.gallery);
                  if (imagePicked != null) {
                    //Subimos foto
                    await StorageUtils.getState()
                        .uploadFoto(imagePicked.path, 'ProfilePic');
                  }
                  Navigator.pop(context);
                  await showDialog(
                      context: context, builder: (_) => PopUpProfile());
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 18.0),
                  height: 125,
                  width: 125,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(60)),
                            child: image,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white),
                            color: Colors.white,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black),
                            ),
                            child: Icon(Icons.mode_outlined),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Text(
                DBUtils.getState().user.name,
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                            (Route<dynamic> route) => false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}