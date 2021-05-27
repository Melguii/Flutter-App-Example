import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapingu_app/flutterFireUtils/DBUtils.dart';

import 'StoryScreen.dart';
import 'flutterFireUtils/DBUtils.dart';
import 'flutterFireUtils/StorageUtils.dart';
import 'models/UserDB.dart';
import 'models/story_model.dart';
import 'models/user_model.dart';

class StoriesList extends StatelessWidget {
  List<Users> namesList = List<Users>();
  List<Image> profilePics;
  List<String> urls;
  List<List<Story>> stories;
  int currentIndex = 0;

  Stream<List<Image>> imageStream;

  StoriesList(List<Users> friendsList) {
    Users user = DBUtils.getState().user;
    user.name = 'Your Story';
    namesList.add(user);
    namesList.addAll(friendsList);
    profilePics = List<Image>();
    stories = List<List<Story>>();
  }

  Future<List<Image>> getImageProfile() async {
    urls = await StorageUtils.getState().getListProfilePics(namesList);
    profilePics = List<Image>();
    for (int i = 0; i < urls.length; i++) {
      profilePics.add(Image.network(urls[i], fit: BoxFit.cover));
      List<Story> userStories = await getStoriesUser(i);
      stories.add(userStories);
    }
    return profilePics;
  }

  Future<List<Story>> getStoriesUser(int iUser) async {
    List<Story> stories = List<Story>();
    List<String> urls =
        await StorageUtils.getState().getListStories(namesList[iUser]);
    String profilePic =
        await StorageUtils.getState().getFriendProfilePic(namesList[iUser]);
    User user = User(name: namesList[iUser].name, profileImageUrl: profilePic);
    urls.forEach((url) {
      Story story =
          new Story(url: url, duration: const Duration(seconds: 3), user: user);
      stories.add(story);
    });
    return stories;
  }

  Image getProfilePic() {
    return profilePics[currentIndex];
  }

  String getFriendName() {
    return namesList[currentIndex++].name;
  }

  //Si tarda en cargar la imagen o se pierda la connexión, se carga una foto de stock
  Image getStockImage() {
    return Image.asset('assets/white.jpg', fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getImageProfile(),
      builder:
          (BuildContext context, AsyncSnapshot<List<Image>> imageProfileList) {
        if (imageProfileList.hasData) {
          return storyIcons(context, imageProfileList.data);
        } else {
          return storyIconsBlank(context);
        }
      },
    );
  }

  ListView storyIcons(BuildContext context, List<Image> imageProfileList) {
    return ListView.builder(
      itemCount: namesList.length,
      itemExtent: 90,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
          child: Column(
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                            Positioned?.fill(
                              child: Image.asset("assets/storyborder.png"),
                            ),
                            Positioned?.fill(
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40)),
                                  child: imageProfileList[index] ??
                                      getStockImage(),
                                ),
                              ),
                            ),
                          ] ??
                          [],
                    ),
                    onTap: () {
                      if (stories[index].isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StoryScreen(stories: stories[index]),
                          ),
                        );
                      }
                    }),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                namesList[index].name ?? "",
                maxLines: 1,
                style: TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  ListView storyIconsBlank(BuildContext context) {
    return ListView?.builder(
        itemExtent: 90,
        itemCount: namesList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                          Positioned?.fill(
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(40)),
                                child: getStockImage(),
                              ),
                            ),
                          ),
                        ] ??
                        [],
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  "",
                  maxLines: 1,
                  style: TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        });
  }
}
