

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:snc/common/video.dart';
import 'package:snc/model/monitors.dart';
import 'package:snc/model/videos.dart';
import 'package:video_player/video_player.dart';
import 'package:snc/common/global.dart';
import 'package:snc/pages/widget.dart';

enum _Mode{
  normal,
  select,
}

class VideoListPage extends StatefulWidget{
  final Filter filter;
  final String title;

  const VideoListPage({
    this.filter,
    title,
  }):title = title??'视频列表';

  @override
  State<StatefulWidget> createState() => new _VideoListPage();
}

class _VideoListPage extends State<VideoListPage> {
  Map<int, VideoPlayerController> _mapConVideo;
  ScrollController _scrollController;
  _Mode _mode;
  List<bool> checkList;
  Future _gettingVideos;
  String title;
  int _selectedNum;
  Filter _filter;

  @override
  void initState() {
    super.initState();
    this._scrollController = new ScrollController();
    this._mapConVideo = new Map();
    this._mode = _Mode.normal;
    this._filter = widget.filter;
    this._gettingVideos = this.getVideos();
    this.title = widget.title;
  }
  Future<SnVideos> getVideos(){
    return Global.sn.getVideos(this._filter.monitor, this._filter.startTime,this._filter.endTime, this._filter.limit);
  }

  @override
  void dispose() {
    super.dispose();
    SnVideoPlayer.disposeVideoController(this._mapConVideo, null);
    this._scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: new Scaffold(
          appBar: new AppBar(title: new Text(this.title),actions: <Widget>[
            new Builder(builder: (context){
              return new IconButton(
                  icon:new Icon(Icons.filter_list),
              onPressed: (){Scaffold.of(context).openEndDrawer();});
            }),
          ],),
          endDrawer: new Drawer(
            child: new Column(
              children: <Widget>[
                new Container(
                  color: Theme.of(context).primaryColor,
                  height: 80,
                ),
                new FilterWidget(filter: this._filter,
                  refresh: (){
                  this._gettingVideos = this.getVideos();
                  this.setState(() { });
                  },
                )
              ],
            ),

          ),
          body: new BufferBody<SnVideos>(
            builder: (context,data){
              return RefreshIndicator(
                child: new Scrollbar(
                  child: new ListView.builder(itemCount: data.videos.length,itemBuilder: (context,index)=>
                      buildItem(context,index,data),
                    controller: this._scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                  ),
                  controller: this._scrollController,
                ),
                onRefresh: ()async{
                  this._gettingVideos = this.getVideos();
                  await this._gettingVideos.catchError((e){});
                  this.setState(() { });
                },
              );
            },
            reTry: (context){
              this._gettingVideos = this.getVideos();
              this.setState(() { });
            },
            future: this._gettingVideos,
          ),
        ),
        onWillPop: () async{
          if(this._mode == _Mode.select){
            this._mode = _Mode.normal;
            this.title = widget.title;
            this.setState(() { });
            return false;
          }
          return true;
        }
    );
  }

  void buildVideoPage(BuildContext context, int index) {
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.landscapeRight,DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    Navigator.push(context,
        new MaterialPageRoute(builder: (context) {
          return new Stack(
            children: <Widget>[
              new AspectRatio(
                aspectRatio: this._mapConVideo[index].value.aspectRatio,
                child: new VideoPlayer(this._mapConVideo[index]),
              ),
              new Positioned(bottom: 0, left: 0, right: 0,
                child: new VideoControlPanel(controller: this._mapConVideo[index],
                  height: 40,
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      child: new GestureDetector(
                        child: new Icon(Icons.fullscreen_exit,color: Theme.of(context).buttonColor,size: 40*0.75,),
                        onTap: (){
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          );
        })
    ).whenComplete((){
      SystemChrome.setPreferredOrientations([]);
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom,SystemUiOverlay.top]);
    });
  }
  
  void playButton(int index,SnVideos snVideos){
    if(this._mode == _Mode.select) return;
    if(! this._mapConVideo.containsKey(index)) {
      SnVideoPlayer.disposeVideoController(this._mapConVideo, null);
      this._mapConVideo[index] =
      new VideoPlayerController.network(Global.sn.getVideoFileUrl(snVideos.videos[index]),formatHint: VideoFormat.other);
      if(snVideos.videos[index].status == VideoStatus.unread.index){
        snVideos.videos[index].status = VideoStatus.read.index;
        Global.sn.videoChangeToRead(snVideos.videos[index]);
      }
    }else{
      SnVideoPlayer.disposeVideoController(this._mapConVideo, index);
    }
    this.setState(() { });
  }
  void deleteTap(int index,SnVideos snVideos){
    if(this._mode == _Mode.select) return;
    if(! this._mapConVideo.containsKey(index)) {
      this.showDeleteConfirmDialog().then((value) {
        if(value==true) Global.sn.deleteVideo(snVideos.videos[index]).then((value){
          if(value==true){
            snVideos.videos.removeAt(index);
            this.setState(() { });
          }
        });
      });
    }
  }
  
  Widget buildItem(BuildContext context, int index, SnVideos snVideos){
    DateFormat itemFormat = new DateFormat('HH:mm yyyy-MM-dd ');
    SnVideo thisVideo = snVideos.videos[index];
    int size = (thisVideo.size~/1024~/1024);
    TextStyle textInfoStyle = new TextStyle(
        fontSize: 11,
        color: Theme.of(context).hintColor
    );
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        new GestureDetector(
          onTap: (){
            if(this._mode == _Mode.select) {
              this.checkList[index] = this.checkList[index]?false:true;
              if(this.checkList[index]) this._selectedNum++;
              else this._selectedNum--;
              this.title = "已选择 "+ this._selectedNum.toString();
              this.setState(() { });
            }
          },
          onLongPress: (){
            if(this._mode == _Mode.normal) {
              this._mode = _Mode.select;
              this.checkList = new List<bool>.generate(
                  snVideos.videos.length, (index) => false);
              this.checkList[index] = true;
              this._selectedNum = 1;
              this.title = "已选择 "+ this._selectedNum.toString();
              this.setState(() { });
            }else{
              this._mode = _Mode.normal;
              this.title = widget.title;
              this.setState(() {});
            }
          },
          child: new ItemContainer(
            height: 90,
            color: (this._mode == _Mode.select && this.checkList[index])
                ?Theme.of(context).primaryColorLight
                :null,
            child: new Row(
              children: <Widget>[
                new Expanded(
                  child:new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Expanded(
                        child:new Text(thisVideo.monitorName,
                          style: new TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                      new Expanded(
                          child: new Text(itemFormat.format(thisVideo.time)+ ' 到 '+ itemFormat.format(thisVideo.end),
                            style: new TextStyle(fontSize: 12),
                          ),
                      ),
                      //new Padding(padding: EdgeInsets.only(top: 10)),
                      new Expanded(
                          child:new Row(
                            children: <Widget>[
                              new Expanded(child: new Text(thisVideo.end.difference(thisVideo.time).inMinutes.toString()+'min',
                                style: textInfoStyle,
                              )),
                              new Expanded(child: new Text((size == 0?'<0':size.toString()) + 'MB',
                                style: textInfoStyle,
                              )),
                              new Expanded(child: new Text(thisVideo.ext,
                                style: textInfoStyle,
                              )),
                            ],
                            crossAxisAlignment: CrossAxisAlignment.center,
                          )
                      ),
                    ],
                  ),
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    snVideos.videos[index].status == VideoStatus.unread.index
                        ?new Container(
                          child: new Text('new'),
                          padding: EdgeInsets.only(top: 3,bottom: 3,left: 5,right: 5),
                          decoration: BoxDecoration(
                            color: Theme.of(context).hintColor,
                            borderRadius: BorderRadius.circular(3.0),
                            boxShadow: [
                              BoxShadow(
                              offset: Offset(1.0,1.0),
                              blurRadius: 3.0
                              )
                            ]
                          ),
                        )
                      :new Padding(padding: EdgeInsets.zero),
                    new Expanded(child: new Padding(padding:EdgeInsets.zero)),
                    new Row(
                      children: <Widget>[
                        new GestureDetector(
                          child: Icon(this._mapConVideo.containsKey(index)?Icons.stop:Icons.play_arrow),
                          onTap: this._mode==_Mode.select?null:()=>this.playButton(index,snVideos),
                        ),
                        new Padding(padding: EdgeInsets.only(right: 20)),
                        new GestureDetector(
                          child: Icon(Icons.delete),
                          onTap: this._mode==_Mode.select||this._mapConVideo.containsKey(index)?null:()=>this.deleteTap(index, snVideos),
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        this._mapConVideo.containsKey(index)?new Padding(padding: EdgeInsets.only(top: 5)):new Padding(padding: EdgeInsets.zero),
        this._mapConVideo.containsKey(index)
            ?new Stack(
          children: <Widget>[
            new BufferBody(
                builder: (context,data){
                  return new AspectRatio(
                    aspectRatio: this._mapConVideo[index].value.aspectRatio,
                    child: new VideoPlayer(this._mapConVideo[index]),
                  );
                },
                waitWidget: new WaitVideo(),
                showErr: WaitVideo.showErr,
                future: this._mapConVideo[index].value.initialized
                    ?Future.value()
                    :this._mapConVideo[index].initialize()..then((value) => this._mapConVideo[index].play())
            ),
            new Positioned(bottom: 0, left: 0, right: 0,
                child: new VideoControlPanel(controller: this._mapConVideo[index],
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3),
                      child: new GestureDetector(
                        child: new Icon(Icons.fullscreen,color: Theme.of(context).buttonColor,),
                        onTap: (){
                          this.buildVideoPage(context, index);
                        },
                      ),
                    )
                  ],
                )
            )
          ],
        )
            :new Padding(padding: EdgeInsets.zero),
      ],
    );
  }



  Future<bool> showDeleteConfirmDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text("您确定要删除当前文件吗?"),
          actions: <Widget>[
            FlatButton(
              child: Text("取消"),
              onPressed: () => Navigator.of(context).pop(), // 关闭对话框
            ),
            FlatButton(
              child: Text("删除"),
              onPressed: () {
                //关闭对话框并返回true
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

}


