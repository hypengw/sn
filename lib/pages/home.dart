

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:video_player/video_player.dart';
import 'package:fijkplayer/fijkplayer.dart';


import 'package:snc/model/monitors.dart';
import 'package:snc/common/global.dart';
import 'package:snc/pages/widget.dart';
import 'package:snc/pages/videoList.dart';



class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => new _HomePageState();
}

String statusCN(String status){
  if(status != 'Idle') return '在线';
  return '离线';
}

class _HomePageState extends State<HomePage> {
  ScrollController _scrollController;
  Future _gettingMonitors;
  // index =>
  Map<int,FijkPlayer> _mapConVideo;
  Map<int,bool> _mapIsDirect;


  @override
  void initState() {
    super.initState();
    this._mapConVideo = new Map<int,FijkPlayer>();
    this._scrollController = new ScrollController();
    if(!Global.sn.isLogin) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        Navigator.of(context).pushReplacementNamed("login_page");
      });
    } else{
      this._gettingMonitors = this.getMonitors();
    }
    this._mapIsDirect = new Map();
  }


  Future<List<Monitor>> getMonitors() {
    return Global.sn.getMonitors()..then((value){
      Global.monitors = value;
    });
  }


  @override
  void dispose() {
    super.dispose();
    this._scrollController.dispose();
    this.disposeVideoController(this._mapConVideo, null);
  }

  void disposeVideoController(Map<int,FijkPlayer> mapConVideo, int index) {
    Map<int,FijkPlayer> temp = new Map.of(mapConVideo);
    if(index!=null) mapConVideo.remove(index);
    else mapConVideo.clear();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      temp.forEach((key, value) {
        if(index == null || key == index)
          value.release();
      });
      //temp.clear();
    });
  }
/*
  Widget buildVideoPage(BuildContext context, int index) {
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.landscapeRight,DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIOverlays([]);
    Navigator.push(context,
        new MaterialPageRoute(builder: (context) {
          return new Stack(
            children: <Widget>[
              new AspectRatio(
                aspectRatio: this._mapConVideo[index].value.size.aspectRatio,
                child: new FijkView(
                    player: this._mapConVideo[index],
                ),
              ),
              /*
              new Positioned(bottom: 0, left: 0, right: 0,
                child: new VideoControlPanel(controller: this._mapConVideo[index],
                  itemVisible: [true,false,false],
                  height: 40,
                  children: <Widget>[
                    new Expanded(child: new Padding(padding: EdgeInsets.zero),),
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
              )*/
            ],
          );
        },
          maintainState: true
        )
    ).whenComplete((){
      SystemChrome.setPreferredOrientations([]);
      SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom,SystemUiOverlay.top]);
    });
  }
*/

  Future<void> setPlayer(int index, List<Monitor> monitors) async{
    String url;
    if (this._mapIsDirect.containsKey(index))
      url = Monitors.GetDirectUrl(monitors[index]);
    else
      url = Global.sn.getFirstStreamUrl(monitors[index]);
    await this._mapConVideo[index].setOption(FijkOption.playerCategory, "fast", 1);//不额外优化
    //pause output until enough packets have been read after stalling
    await this._mapConVideo[index].setOption(FijkOption.playerCategory, "packet-buffering", 0);//是否开启缓冲
    //automatically start playing on prepared
    await this._mapConVideo[index].setOption(FijkOption.playerCategory, "mediacodec", 1);//开启硬解
    await this._mapConVideo[index].setOption(FijkOption.playerCategory, "mediacodec-auto-rotate", 0);//自动旋屏
    await this._mapConVideo[index].setOption(FijkOption.playerCategory, "mediacodec-handle-resolution-change", 0);//处理分辨率变化
    //max buffer size should be pre-read：默认为15*1024*1024
    await this._mapConVideo[index].setOption(FijkOption.playerCategory, "max-buffer-size", 0);//最大缓存数
    await this._mapConVideo[index].setOption(FijkOption.playerCategory, "min-frames", 2);//默认最小帧数2
    await this._mapConVideo[index].setOption(FijkOption.playerCategory, "max_cached_duration", 30);//最大缓存时长
    await this._mapConVideo[index].setOption(FijkOption.formatCategory, "fflags", "nobuffer");
    await this._mapConVideo[index].setOption(FijkOption.formatCategory, "flush_packets", 1);
    await this._mapConVideo[index].setOption(FijkOption.formatCategory, "probesize", 200);//10240
    await this._mapConVideo[index].setOption(FijkOption.formatCategory, "rtsp_transport", "tcp");
    await this._mapConVideo[index].setOption(FijkOption.formatCategory, "analyzedmaxduration", 100);//分析码流时长:默认1024*1000

    await this._mapConVideo[index].setDataSource(url, autoPlay: true);
  }

  Widget buildList(BuildContext context, int index,List<Monitor> monitors){
    return new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new ItemContainer(
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Padding(
                              padding: EdgeInsets.only(right:15),
                              child: new Icon(Icons.videocam,size: 32,),
                          ),
                        ]
                    ),
                    new Expanded(
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Row(
                            children: <Widget>[
                              new Expanded(
                                child: new Text(
                                  monitors[index].name,
                                  textScaleFactor: 1.5,
                                  maxLines: 1,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                              new Container(
                                padding: EdgeInsets.only(top: 3,bottom: 3,left: 5,right: 5),
                                child: new Text(monitors[index].details.stream_type.toUpperCase()),
                                decoration: new BoxDecoration(
                                  color: Theme.of(context).hintColor,
                                  borderRadius: BorderRadius.circular(4.0),
                                  boxShadow: [ //阴影
                                    BoxShadow(
                                        color:Colors.black54,
                                        offset: Offset(1.0,1.0),
                                        blurRadius: 4.0
                                    )
                                  ]
                                ),
                              )
                            ],
                          ),
                          new Padding(padding: EdgeInsets.only(top:10)),
                          new Row(
                            children: <Widget>[
                              new Text(statusCN(monitors[index].status),maxLines: 1,textAlign: TextAlign.left),
                              new Padding(padding: EdgeInsets.only(right: 10)),
                              new BufferBody<bool>(
                                  builder: (BuildContext context, bool data){
                                    this._mapIsDirect[index] = data;
                                    if(data)
                                      return Text('直连', textAlign: TextAlign.left);
                                    else
                                      return new Container();
                                  },
                                  initialData: true,
                                  showDirect: this._mapIsDirect.containsKey(index) && this._mapIsDirect[index],
                                  future: this._mapIsDirect.containsKey(index) && this._mapIsDirect[index]
                                      ? Future.value(true)
                                      : Global.sn.checkMonitorDirect(monitors[index])
                              ),
                              new Expanded(
                                child: new Padding(padding: EdgeInsets.zero),
                              ),
                              new GestureDetector(
                                child: Icon(this._mapConVideo.containsKey(index)?Icons.stop:Icons.play_arrow),
                                onTap: () {
                                  if(! this._mapConVideo.containsKey(index)) {
                                    this._mapConVideo[index] = new FijkPlayer();
                                    this.setState(() { });
                                  }else{
                                    this.disposeVideoController(this._mapConVideo, index);
                                    this.setState(() { });
                                  }
                                },
                              ),
                              new Padding(padding: EdgeInsets.only(right: 30)),
                              new GestureDetector(
                                child: Icon(Icons.video_library),
                                onTap: () {
                                  this.disposeVideoController(this._mapConVideo, null);
                                  this.setState(() { });
                                  Navigator.push(context,
                                    new MaterialPageRoute(
                                        builder:(context){
                                          return new VideoListPage(title: '录像回放',
                                            filter: new Filter(monitor:monitors[index],limit: 15),
                                          );
                                        }
                                    )
                                  );
                                },
                              ),
                              new Padding(padding: EdgeInsets.only(right: 10)),
                            ],
                          )
                          ]
                      ),
                      flex: 3,
                    ),
                  ],
                )
              ),
              this._mapConVideo.containsKey(index)?new Padding(padding: EdgeInsets.only(top: 5)):new Padding(padding: EdgeInsets.zero),
              this._mapConVideo.containsKey(index)
                ? new GestureDetector(
                    child: new BufferBody(
                        builder: (context,data){
                          return new AspectRatio(
                            aspectRatio: (this._mapConVideo[index].value.size?.aspectRatio)??16/9,
                            child: new FijkView(
                              player: this._mapConVideo[index],
                              fit: FijkFit.fill
                            ),
                          );
                        },
                        showErr: WaitVideo.showErr,
                        waitWidget: new WaitVideo(),
                        future: this._mapConVideo[index].value.videoRenderStart
                            ? Future.value()
                            : this.setPlayer(index, monitors)
                    ),
                    //onTap: () => buildVideoPage(context, index)
                  )
               : new Padding(padding: EdgeInsets.zero),
            ],
        );
  }

  Widget buildBody(BuildContext context, List<Monitor> monitors){
    return new Scrollbar(
        controller: this._scrollController,
        child: new ListView.builder(itemCount: monitors.length,itemBuilder: (context,index)=>buildList(context,index,monitors),
          controller: this._scrollController,
          physics: AlwaysScrollableScrollPhysics(),
        ),
    );

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("实时预览"),
      ),
      drawer: new SnDrawer(selectPage: "home_page",
        doWhenSwitch: (){
          this.disposeVideoController(this._mapConVideo, null);
          this.setState(() { });
          },
      ),
      body: Global.sn.isLogin
          ? new BufferBody<List<Monitor>>(
              builder: (context,data){
                return RefreshIndicator(
                  onRefresh: () async {
                    this._mapIsDirect.clear();
                    this._gettingMonitors =  this.getMonitors();
                    await this._gettingMonitors.catchError((e){});
                    this.setState(() { });
                  },
                  child: this.buildBody(context,data),
                );
              },
              future: this._gettingMonitors,
              reTry: (context){this._gettingMonitors=this.getMonitors();this.setState(() { });},
            )
          :null,
    );
  }
}
/*

 */
