import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:snc/pages/widget.dart';


class SnVideoPlayer extends StatelessWidget{
  final VideoPlayerController controller;
  final bool noBuffering;

  SnVideoPlayer({
    @required this.controller,
    noBuffering
  }):assert(controller != null),
        noBuffering = noBuffering??false;

  static void disposeVideoController(Map<int,VideoPlayerController> mapConVideo, int index) {
    Map<int,VideoPlayerController> temp = new Map.of(mapConVideo);
    if(index!=null) mapConVideo.remove(index);
    else mapConVideo.clear();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      temp.forEach((key, value) {
        if(index == null || key == index)
          value.dispose();
      });
      //temp.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if(noBuffering) {
      return new AspectRatio(
        aspectRatio: this.controller.value.aspectRatio,
        child: new VideoPlayer(this.controller),
      );
    }
    return new BufferBody(
        builder: (context,data){
          return new AspectRatio(
            aspectRatio: this.controller.value.aspectRatio,
            child: new VideoPlayer(this.controller),
          );
        },
        waitWidget: new WaitVideo(),
        showErr: WaitVideo.showErr,
        future: this.controller.initialize()..then((value) => this.controller.play())
    );
  }
}
