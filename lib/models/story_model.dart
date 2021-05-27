import 'package:flutter/cupertino.dart';
import 'package:mapingu_app/models/user_model.dart';

enum MediaType {
  image,
  video
}

class Story {
  final String url;
  final Duration duration;
  final User user;

  const Story({
    @required this.url,
    @required this.duration,
    @required this.user,
  });
}