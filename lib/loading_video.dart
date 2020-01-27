import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class LoadingVideo extends StatefulWidget {
  final VideoPlayerController controller;
  final Future<void> future;

  LoadingVideo({Key key, this.controller, this.future}) : super(key: key);

  @override
  LoadingVideoState createState() => LoadingVideoState();
}

class LoadingVideoState extends State<LoadingVideo> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            child: AspectRatio(
              aspectRatio: widget.controller.value.aspectRatio,
              child: VideoPlayer(widget.controller),
            ),
            height: 300,
            width: 300,
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
