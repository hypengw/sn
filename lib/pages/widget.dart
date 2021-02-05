
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/single_child_widget.dart';
import 'package:snc/model/monitors.dart';
import 'package:video_player/video_player.dart';
import 'package:snc/common/global.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

class SnDrawer extends StatelessWidget{
  final String selectPage;
  final void Function() doWhenSwitch;
  final void Function() doAfterSwitch;
  final void Function() doAfterSwitchOff;
  final bool doForReplace;
  SnDrawer({
    this.selectPage,
    this.doWhenSwitch,
    this.doAfterSwitch,
    this.doAfterSwitchOff,
    doForReplace,
  }):doForReplace = doForReplace??false;

  void Function() get _doWhenSwitch => this.doWhenSwitch??(){};
  void Function() get _doAfterSwitch => this.doAfterSwitch??(){};
  void Function() get _doAfterSwitchOff => this.doAfterSwitchOff??(){};

  void push(BuildContext context,String routeName,{bool replace=true}){
    Navigator.pop(context);
    if(this.selectPage == routeName) return;
    if(replace) {
      if (this.doForReplace){
        this._doWhenSwitch();Navigator.pushReplacementNamed(context, routeName).then((value) => _doAfterSwitchOff());
        this._doAfterSwitch();
      } else Navigator.pushReplacementNamed(context, routeName);
    }
    else {
      this._doWhenSwitch();Navigator.pushNamed(context, routeName).then((value) => _doAfterSwitchOff());
      this._doAfterSwitch();
    }
  }
  bool isSelect(String page){
    if(this.selectPage == page) return true;
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return new Drawer(
      child: new MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                child: Container(
                  color: Theme.of(context).primaryColor,
                  width: double.maxFinite,
                  padding: EdgeInsets.only(top:40, bottom: 10, left: 20),
                  child: new Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Text((Global.profile.user.mail.split('@')[0]),
                        style: TextStyle(fontSize: 17),
                      ),
                      new Padding(padding: EdgeInsets.only(top: 15)),
                      new Text(Global.profile.user.url,
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  )
                ),
                flex: 1,
              ),
              new Expanded(
                child: new Container(
                  color: Theme.of(context).primaryColorLight,
                  child: new Column(
                    children: <Widget>[
                      new ListTile(
                        leading: new Icon(Icons.live_tv),
                        title: new Text('实时预览'),
                        onTap: ()=>this.push(context, 'home_page'),
                        selected: this.isSelect('home_page'),
                      ),
                      new Divider(),
                      new ListTile(
                        leading: new Icon(Icons.fiber_smart_record),
                        title: new Text('录像回放'),
                        onTap: ()=>this.push(context, 'record_page'),
                        selected: this.isSelect('record_page'),
                      ),
                      new Divider(),
                      new ListTile(
                        leading: new Icon(Icons.cloud),
                        title: new Text('我的设备'),
                        onTap: ()=>this.push(context,  'login_page'),
                        selected: this.isSelect('login_page'),
                      ),
                      new Container(
                        width: double.maxFinite,
                        decoration:BoxDecoration(
                            border:new Border(
                              bottom: BorderSide(width: 3.0,color: Theme.of(context).dividerColor)
                            )
                        ),
                      ),
                      new ListTile(
                        title: new Text('关于'),
                        onTap: ()=>this.push(context,  'about_page', replace: false),
                        selected: false,
                      )
                    ],
                  ),
                ),
                flex: 3,
              ),
            ],
          )
      ),
    );
  }
}

class Filter{
  DateTime startTime;
  DateTime endTime;
  Monitor monitor;
  int limit;
  Filter({
    this.startTime,
    this.endTime,
    this.monitor,
    this.limit
  });
}

class FilterWidget extends StatefulWidget {
  final Filter filter;
  final void Function() refresh;
  FilterWidget({
    @required this.filter,
    this.refresh,
  }) :assert(filter != null);

  @override
  State<StatefulWidget> createState() => new _FilterWidget();
}

class _FilterWidget extends State<FilterWidget> {

  final DateFormat dayFormat = new DateFormat('yyyy-MM-dd');
  final DateFormat timeFormat = new DateFormat('HH-mm');
  DateTime startDate;
  DateTime startTime;
  DateTime endDate;
  DateTime endTime;
  @override
  void initState() {
    super.initState();
    startDate = widget.filter.startTime;
    startTime = widget.filter.startTime;
    endDate = widget.filter.endTime;
    endTime = widget.filter.endTime;
  }

  void refreshFilter(){
    if(startDate==null || endDate==null) return;
    widget.filter.startTime = startTime==null?startDate:startDate.add(Duration(
        hours: startTime.hour,
        minutes: startTime.minute
    ));
    widget.filter.endTime = endTime==null?endDate:endDate.add(Duration(
        hours: endTime.hour,
        minutes: endTime.minute
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new FlatButton.icon(
            onPressed: ()=>(widget.refresh??(){})(),
            icon: Icon(Icons.refresh,size: 30,),
            label: new Text('刷新'),
            padding: EdgeInsets.only(left: 20),
        ),
        new Divider(),
        new Text('   开始时间'),
        new Padding(padding: EdgeInsets.only(top: 10)),
        new Row(
          children: <Widget>[
            FlatButton(
              onPressed: ()=> DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(2000, 1, 1), maxTime: DateTime.now(),
                  onConfirm: (date) {
                    startDate = DateTime(date.year,date.month,date.day);
                    refreshFilter();
                    this.setState(() { });
                  }, currentTime: startDate??DateTime.now(), locale: LocaleType.zh
              ),
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.calendar_today),
                  new Text(startDate==null?'0000-00-00':dayFormat.format(startDate))
                ],
              ),
              padding: EdgeInsets.only(left:20,right: 40),
            ),
            FlatButton(
              onPressed: ()=> DatePicker.showTimePicker(context,
                  showTitleActions: true, showSecondsColumn: false,
                  onConfirm: (date) {
                    startTime = DateTime(2000,1,1,date.hour,date.minute);
                    refreshFilter();
                    this.setState(() { });
                  }, currentTime: startTime??DateTime.now(), locale: LocaleType.zh
              ),
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.access_time),
                  new Text(startTime==null?'00:00':timeFormat.format(startTime))
                ],
              ),
            ),
          ],
        ),
        new Divider(),
        new Text('   结束时间'),
        new Padding(padding: EdgeInsets.only(top: 10)),
        new Row(
          children: <Widget>[
            FlatButton(
              onPressed: ()=> DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(2000, 1, 1), maxTime: DateTime.now(),
                  onConfirm: (date) {
                    endDate = DateTime(date.year,date.month,date.day);
                    refreshFilter();
                    this.setState(() { });
                  }, currentTime: endDate??DateTime.now(), locale: LocaleType.zh
              ),
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.calendar_today),
                  new Text(endDate==null?'0000-00-00':dayFormat.format(endDate))
                ],
              ),
              padding: EdgeInsets.only(left:20,right: 40),
            ),
            FlatButton(
              onPressed: ()=> DatePicker.showTimePicker(context,
                  showTitleActions: true, showSecondsColumn: false,
                  onConfirm: (date) {
                    endTime = DateTime(2000,1,1,date.hour,date.minute);
                    refreshFilter();
                    this.setState(() { });
                  }, currentTime: endTime??DateTime.now(), locale: LocaleType.zh
              ),
              child: new Row(
                children: <Widget>[
                  new Icon(Icons.access_time),
                  new Text(endTime==null?'00:00':timeFormat.format(endTime))
                ],
              ),
            ),

          ],
        ),
        new Divider(),
        new Text('   条目限制'),
        new Container(
          margin: EdgeInsets.only(top: 10),
          padding: EdgeInsets.only(left: 30),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColorDark,
            borderRadius: BorderRadius.circular(30)
          ),
          child: new TextField(
            decoration: InputDecoration(
                //labelText: "条目限制",
                hintText: widget.filter.limit.toString(),
                //prefixIcon: Icon(Icons.list),
                border: InputBorder.none
            ),
            inputFormatters: [
              WhitelistingTextInputFormatter(RegExp('[0-9]')),
            ],
            onChanged: (value){widget.filter.limit = int.parse(value);},
          ),
        )
      ]
    );
  }
}
class ItemContainer extends SingleChildStatelessWidget {
  final double height;
  final Color color;

  ItemContainer({
    this.height,
    this.color,
    child,
  }):super(child:child);

  @override
  Widget buildWithChild(BuildContext context, Widget child) {
    return new Container(
        height: this.height,
        margin: EdgeInsets.only(top: 20, left: 20, right: 20),
        padding: EdgeInsets.only(top:10, bottom: 10, left: 20 ,right: 20),
        decoration: new BoxDecoration(
          //border: new Border.all(color: this.color??Theme.of(context).primaryColorDark.withAlpha(70),width: 1.2),
          borderRadius: new BorderRadius.circular(5.0),
          color: this.color??Theme.of(context).primaryColorDark.withAlpha(70),
        ),
        child: child
    );
  }
}

class ShowErr extends StatelessWidget{
  final String errMsg;
  final void Function() onTap;
  const ShowErr({this.onTap,this.errMsg});

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> textList = new List<InlineSpan>();
    if(this.onTap!=null){
      textList.insert(0, new TextSpan(
          text: ', ',
      ));
      textList.insert(1, new TextSpan(
          text: '重试',
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()..onTap = this.onTap
      ));
    }
    return new Align(
        child: new RichText(
          text: new TextSpan(
            text: this.errMsg,
            children: textList,
          ),
        )
    );
  }
}

class BufferBody<T> extends StatefulWidget{
  final Widget Function(BuildContext,T) builder;
  final Future<T> future;
  final void Function(BuildContext context) reTry;
  final Widget Function(BuildContext,Object) showErr;
  final Widget waitWidget;
  final bool showDirect;
  final T initialData;
  const BufferBody({
    @required this.builder,
    @required this.future,
    this.reTry,
    this.showErr,
    this.waitWidget,
    this.initialData,
    showDirect
  }):showDirect = showDirect??false;

  static String getErrMsg(Object error) {
    if(error is DioError) return '网络错误';
    return '未知错误';
  }

  @override
  State<StatefulWidget> createState() => new _BufferBody<T>();
}
class _BufferBody<T> extends State<BufferBody<T>>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showDirect)
      return widget.builder(context, widget.initialData);

    return new FutureBuilder<T>(
        future: widget.future,
        builder: (BuildContext context, AsyncSnapshot<T> snapshot){
          Widget result;
          if(snapshot.hasError){
            result = widget.showErr == null
                ?new ShowErr(
                errMsg: BufferBody.getErrMsg(snapshot.error),
                onTap: widget.reTry==null?null:(){widget.reTry(context);})
                :widget.showErr(context,snapshot.error);
          }else if(snapshot.connectionState == ConnectionState.done) {
            result = widget.builder(context,snapshot.data);

          }else if(snapshot.connectionState == ConnectionState.waiting){
            result = new Align(
              child: widget.waitWidget == null
                  ?new CircularProgressIndicator()
                  :widget.waitWidget,
            );
          }else if(snapshot.connectionState == ConnectionState.none){
            result = new Container();
          }
          return result;
        });
  }
}

class UINotification extends Notification{}
class SetStateNotification extends UINotification{}

class NotificationUI extends StatefulWidget{
  final Widget Function(BuildContext) builder;

  const NotificationUI({
    @required this.builder
  });
  @override
  State<StatefulWidget> createState() => new _NotificationUI();
}
class _NotificationUI extends State<NotificationUI>{

  @override
  Widget build(BuildContext context) {
    return new NotificationListener<UINotification>(
      onNotification: (notification){
        switch(notification.runtimeType){
          case SetStateNotification:
            print('setState');
            this.setState(() { });
            break;
        }
        return true;
      },
      child: new Builder(builder: widget.builder),
    );
  }
}

class VideoControlPanel extends StatefulWidget {
  final VideoPlayerController controller;
  final double height;
  final List<Widget> children;
  final List<bool> itemVisible;
  const VideoControlPanel({
    @required this.controller,
    this.height,
    children,
    itemVisible
  }):assert(controller != null),
        children = children??const <Widget>[],
        itemVisible = itemVisible??const <bool>[true,true,true];

  @override
  State<StatefulWidget> createState() => new _VideoControlPanel();
}
class _VideoControlPanel extends State<VideoControlPanel>{
  bool isPlaying;
  
  _VideoControlPanel(){
    listener = (){
      if (!mounted) {
        return;
      }
      if(this.controller.value.isPlaying != this.isPlaying){
        this.isPlaying = this.controller.value.isPlaying;
        setState(() {});
      }
    };
  }
  VoidCallback listener;
  VideoPlayerController get controller => widget.controller;
  List<Widget> get children => widget.children;
  double get height => widget.height==null?30.0:widget.height;
  List<bool> get itemVisible => widget.itemVisible;

  @override
  void initState() {
    super.initState();
    this.controller.addListener(this.listener);
  }

  void togglePlay(){
    if(this.controller.value.isPlaying)
      this.controller.pause();
    else
      this.controller.play();
  }

  List<Widget> buildItem(){
    List<Widget> result = <Widget>[];
    if(this.itemVisible[0]){
      result.add(new Padding(
        padding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: this.togglePlay,
          child: this.controller.value.isPlaying
              ?new Icon(Icons.pause,color: Theme.of(context).buttonColor,
                  size: this.height==null?null:this.height*0.75,
                )
              :new Icon(Icons.play_arrow,color: Theme.of(context).buttonColor,
                  size: this.height==null?null:this.height*0.75,
                ),
        ),
      ));
    }
    if(this.itemVisible[1]){
      result.add(new Expanded(
        flex: 1,
        child: new VideoProgressIndicator(
          widget.controller,
          allowScrubbing: true,
          padding: EdgeInsets.symmetric(vertical: 3),
        ),
      ));
    }
    if(this.itemVisible[2]){
      result.add(new VideoTime(controller: this.controller,
          height: this.height*0.5,
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        height: this.height,
        decoration: new BoxDecoration(
          color: Colors.black54,
        ),
        alignment: Alignment.center,
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: this.buildItem()..addAll(this.children),
        )
    );
  }
}

class WaitCalender extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio: 1.0,
      child: new Container(
        child: new Align(child: new CircularProgressIndicator(),),
        width: double.infinity,
      ),
    );
  }
}

class WaitVideo extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return new AspectRatio(
      aspectRatio:16.0/9.0,
      child: new Container(
        child:new Align(child: new CircularProgressIndicator(),),
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
      ),
    );
  }

  static Widget showErr(BuildContext context,Object error){
    return new AspectRatio(
      aspectRatio:16.0/9.0,
      child: new Container(
        child:new Align(child: new ShowErr(onTap: (){},errMsg: BufferBody.getErrMsg(error),),),
        width: double.infinity,
        color: Colors.black,
      ),
    );
  }
}

class VideoTime extends StatefulWidget{
  final VideoPlayerController controller;
  final bool showHour;
  final bool showSec;
  final TextStyle textStyle;
  final double height;
  const VideoTime({
    @required this.controller,
    this.textStyle,
    this.height,
    this.showHour,
    showSec,
  }):assert(controller != null),
        showSec = showSec??true;

  static String getDuration(Duration duration, bool showHour, bool showSec, Duration totle){
    String result = '';
    if(duration == null || totle == null ) return '--';
    List<String> listDuration = duration.toString().split('.')[0].split(':');
    if(showHour==true || showHour==null && totle.inHours>0) result += listDuration[0] + ':';
    result += listDuration[1] + ':';
    if(showSec == true) result += listDuration[2];
    return result;
  }


  @override
  State<StatefulWidget> createState() => new _VideoTime();
}
class _VideoTime extends State<VideoTime>{

  VoidCallback listener;

  String _getDuration(Duration duration,Duration totle){
    return VideoTime.getDuration(duration, widget.showHour, widget.showSec, totle);
  }

  VideoPlayerController get controller => widget.controller;
  TextStyle get textStyle => widget.textStyle;
  String get position => this._getDuration(this.controller.value.position,this.controller.value.duration);
  String get duration => this._getDuration(this.controller.value.duration,this.controller.value.duration);
  double get height => widget.height;


  _VideoTime(){
    listener = (){
      if (!mounted) {
        return;
      }
      if(this.controller.value.initialized){
        if(this.controller.value.isPlaying){
          setState(() {});
        }
      }
    };
  }

  @override
  void initState() {
    super.initState();
    this.controller.addListener(this.listener);
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
        padding: EdgeInsets.symmetric(horizontal: 3),
        child: new SizedBox(
          height: this.height,
          child: new FittedBox(child: new Text(
            this.position+'/'+this.duration,
            style: this.textStyle??TextStyle( color: Theme.of(context).buttonColor),
          )),
        )
    );
  }
}