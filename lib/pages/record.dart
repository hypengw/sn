import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snc/common/global.dart';
import 'package:snc/pages/widget.dart';
import 'package:snc/common/calender.dart';
import 'package:snc/pages/videoList.dart';
import 'package:intl/intl.dart';

class RecordPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => new _RecordPage();
}

class _RecordPage extends State<RecordPage>{
  DateTime _calender;
  Future _gettingIsHighlight;


  @override
  void initState() {
    super.initState();
    this._calender = DateTime.now();
    this._gettingIsHighlight = this.getDaysHaveVideos();
  }

  Future<List<bool>> getDaysHaveVideos() async {
    List<bool> isHighlight = new List<bool>(32);
    List<Future<bool>> days = Global.sn.getDaysHaveVideoInMonth(this._calender, null);
    for(var i = 1;i<32;i++){
      await days[i].then((value){isHighlight[i] = value;});
    }
    return isHighlight;
  }

  void NavigatorVideosListPage(BuildContext context, DateTime day) {
    Navigator.push(context,
        new MaterialPageRoute(builder: (context) {
          return new VideoListPage(
            filter: new Filter(
              startTime:  day,
              endTime: day.add(new Duration(days: 1)),
              limit: 300,
            ),
            title: '录像回放',);
    }));
  }


  Widget buildbody(BuildContext context){
    return new Column(
      children: <Widget>[
            new Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new GestureDetector(
                  onTap: (){
                    this._calender = new DateTime(this._calender.year,this._calender.month-1);
                    this._gettingIsHighlight =  this.getDaysHaveVideos();
                    SetStateNotification().dispatch(context);
                  },
                  child: new Padding(padding: EdgeInsets.only(top: 5),child: new Icon(Icons.arrow_left,size: 45),),
                ),
                new Text(this._calender.year.toString()+'年'+this._calender.month.toString()+'月',
                  style: new TextStyle(fontSize: 25),
                ),
                new GestureDetector(
                  onTap: (){
                    this._calender = new DateTime(this._calender.year,this._calender.month+1);
                    this._gettingIsHighlight =   this.getDaysHaveVideos();
                    SetStateNotification().dispatch(context);
                  },
                  child: new Padding(padding: EdgeInsets.only(top: 5),child:new Icon(Icons.arrow_right,size: 45,)),
                ),
              ],
            ),
          new BufferBody(
            reTry: (context){
              this._gettingIsHighlight = this.getDaysHaveVideos();
              SetStateNotification().dispatch(context);
            },
            builder: (context,data){
              return new Column(
                children: <Widget>[
                  new Padding(padding: EdgeInsets.only(top: 10)),
                  new Calender(year:this._calender.year, month: this._calender.month,
                    isHighlight: data,
                    tapCallBack: (day)=>data[day.day]?this.NavigatorVideosListPage(context, day):null,
                  ),
                ],
              );
            },
            future: this._gettingIsHighlight,
            waitWidget: new WaitCalender(),
            //showErr: (context,err){return new Text(err.toString());},
          )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: new Text('录像回放'),
        actions: <Widget>[
          new IconButton(
              icon: Icon(Icons.refresh),
              onPressed: (){
                this._gettingIsHighlight = this.getDaysHaveVideos();
                this.setState(() { });
              }
          )
        ],
      ),
      drawer: new SnDrawer(selectPage: "record_page"),
      body: new NotificationUI(builder: this.buildbody)
    );
  }
}