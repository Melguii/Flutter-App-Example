import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mapingu_app/models/story_model.dart';
import 'models/user_model.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({Key key, @required this.stories});

  final List<Story> stories;

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> with SingleTickerProviderStateMixin {
  PageController _pageController;
  AnimationController _animationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(vsync: this);

    final Story firstStory = widget.stories.first;
    _loadStory(story: firstStory, animateToPage: false);

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.stop();
        _animationController.reset();
        setState(() {
          if (_currentIndex + 1 < widget.stories.length) {
            _currentIndex += 1;
            _loadStory(story: widget.stories[_currentIndex]);
          } else {
            _currentIndex = 0;
            _loadStory(story: widget.stories[_currentIndex]);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Story story = widget.stories[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) => _onTapDown(details, story),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.stories.length,
              itemBuilder: (context, i) {
                final Story story = widget.stories[i];
                return CachedNetworkImage(
                  imageUrl: story.url,
                  fit: BoxFit.cover,
                );
              },
            ),
            Positioned(
              top: 40,
              right: 10,
              left: 10,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: UserInfo(user: story.user, animationController: _animationController),
              ),
            ),
          ],
        ),
      ),
    );
  }
/*
  _onPanDown() {
    Navigator.pop(context);
  }
*/
  _onTapDown(TapDownDetails details, Story story) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      //Anem enrere una foto
      if (_currentIndex - 1 >= 0) {
        _currentIndex -= 1;
        _loadStory(story: widget.stories[_currentIndex]);
      }
    } else if (dx > 2 * screenWidth / 3) {
      setState(() {
        //Passem a la següent fotom, sempre que es pugui avançar
        if (_currentIndex + 1 < widget.stories.length) {
          _currentIndex += 1;
          _loadStory(story: widget.stories[_currentIndex]);
        } else {
          _currentIndex = 0;
          _loadStory(story: widget.stories[_currentIndex]);
        }
      });
    }
  }

  void _loadStory({Story story, bool animateToPage = true}) {
    _animationController.stop();
    _animationController.reset();
    _animationController.duration = story.duration;
    _animationController.forward();
    
    if (animateToPage) {
      _pageController.animateToPage(_currentIndex, duration: const Duration(milliseconds: 200), curve: Curves.easeInOut);
    }
  }
}

class UserInfo extends StatelessWidget {
  final User user;
  final AnimationController animationController;

  const UserInfo({Key key, this.user, this.animationController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.grey[300],
          backgroundImage: CachedNetworkImageProvider(
            user.profileImageUrl,
          ),
        ),
        const SizedBox(width: 10.0),
        Expanded(
          child: Text(
            user.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.close,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: () {
            animationController.stop();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}




