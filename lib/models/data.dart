import 'package:mapingu_app/models/story_model.dart';
import 'package:mapingu_app/models/user_model.dart';

//STORIES DE PRUEBA
final User user = User(
  name: 'Pepe Jr Real',
  profileImageUrl: 'https://wallpapercave.com/wp/AYWg3iu.jpg',
);

final List<Story> stories = [
  Story(
    url:
    'https://images.unsplash.com/photo-1534103362078-d07e750bd0c4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=634&q=80',
    duration: const Duration(seconds: 3),
    user: user,
  ),
  Story(
    url: 'https://images.unsplash.com/reserve/LJIZlzHgQ7WPSh5KVTCB_Typewriter.jpg?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=2141&q=80',
    user: User(
      name: 'John Doe',
      profileImageUrl: 'https://wallpapercave.com/wp/AYWg3iu.jpg',
    ),
    duration: const Duration(seconds: 3),
  ),
  Story(
    url:
    'https://images.unsplash.com/photo-1531694611353-d4758f86fa6d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=564&q=80',
    duration: const Duration(seconds: 3),
    user: user,
  ),
  Story(
    url: 'https://images.unsplash.com/photo-1612203067056-736633c23d00?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=619&q=80',
    duration: const Duration(seconds: 3),
    user: user,
  ),
  Story(
    url: 'https://images.unsplash.com/photo-1612225365568-20ac6dadde31?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=675&q=80',
    duration: const Duration(seconds: 3),
    user: user,
  ),
  Story(
    url: 'https://images.unsplash.com/photo-1612221119152-311beb1f9354?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80',
    duration: const Duration(seconds: 3),
    user: user,
  ),
  Story(
    url: 'https://images.unsplash.com/photo-1612223365722-c7ec40ba6993?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80',
    duration: const Duration(seconds: 3),
    user: user,
  ),
  Story(
    url: 'https://images.unsplash.com/photo-1611616327200-f7da5dbebf91?ixlib=rb-1.2.1&ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&auto=format&fit=crop&w=2134&q=80',
    duration: const Duration(seconds: 3),
    user: user,
  ),
  Story(
    url: 'https://images.unsplash.com/photo-1612229616525-925a57d1173c?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80',
    duration: const Duration(seconds: 3),
    user: user,
  ),
  Story(
    url: 'https://images.unsplash.com/photo-1612207149044-231306f00e17?ixid=MXwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80',
    duration: const Duration(seconds: 3),
    user: user,
  ),
];