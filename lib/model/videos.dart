import 'package:snc/common/global.dart';
import 'package:snc/model/monitors.dart';
class SnVideos {
  bool isUTC;
  int total;
  List<SnVideo> videos;

  SnVideos.fromjson(Map<String, dynamic> json){
    this.isUTC = json['isUTC'];
    List<dynamic> temp = json['videos'];
    this.total = temp.length;
    this.videos = List<SnVideo>.generate(temp.length, (index) => SnVideo.fromjson(temp[index]));
  }
}

class SnVideo {
  String mid;
  DateTime time;
  DateTime end;
  String ext;
  int size;
  int status;
  String filename;
  _Links links;

  //other
  String get monitorName {
    List<Monitor> mon = Monitors.findMonitor(Global.monitors, (monitor) => monitor.mid == this.mid, 1);
    if(mon.length>0) return mon[0].name;
    else return 'not find Monitor';
  }

  SnVideo.fromjson(Map<String, dynamic> json){
    this.mid = json['mid'];
    this.time = Global.sn.dateFormat.parse(json['time']);
    this.end = Global.sn.dateFormat.parse(json['end']);
    this.ext = json['ext'];
    this.size = json['size'];
    this.status = json['status'];
    this.filename = json['filename'];
    this.links = _Links.fromjson(json['links']);

  }
}

class _Links {
  String deleteVideo;
  String changeToUnread;
  String changeToRead;
  _Links.fromjson(Map<String, dynamic> json){
    this.deleteVideo = json['deleteVideo'];
    this.changeToUnread = json['changeToUnread'];
    this.changeToRead = json['changeToRead'];
  }
}

enum VideoStatus{
  none,
  unread,
  read,
}

/*
I/flutter (11940): {
I/flutter (11940):    "total": 14,
I/flutter (11940):    "limit": 100,
I/flutter (11940):    "skip": 0,
I/flutter (11940):    "videos": [
I/flutter (11940):       {
I/flutter (11940):          "mid": "UelJ2NdkJe",
I/flutter (11940):          "ke": "PTYqKF0sBE",
I/flutter (11940):          "ext": "mp4",
I/flutter (11940):          "time": "2020-07-06T09:48:13+08:00",
I/flutter (11940):          "duration": null,
I/flutter (11940):          "size": 133420000,
I/flutter (11940):          "frames": null,
I/flutter (11940):          "end": "2020-07-06T09:58:18+08:00",
I/flutter (11940):          "status": 1,
I/flutter (11940):          "details": {},
I/flutter (11940):          "filename": "2020-07-06T09-48-13.mp4",
I/flutter (11940):          "actionUrl": "/ec80a59accce7a12f56e8f0272dd2202/videos/PTYqKF0sBE/UelJ2NdkJe/2020-07-06T09-48-13.mp4",
I/flutter (11940):          "links": {
I/flutter (11940):             "deleteVideo": "/ec80a59accce7a12f56e8f0272dd2202/videos/PTYqKF0sBE/UelJ2NdkJe/2020-07-06T09-48-13.mp4/delete",
I/flutter (11940):             "changeToUnread": "/ec80a59accce7a12f56e8f0272dd2202/videos/PTYqKF0sBE/UelJ2NdkJe/2020-07-06T09-48-13.mp4/status/1",
I/flutter (11940):             "changeToRead": "/ec80a59accce7a12f56e8f0272dd2202/videos/PTYqKF0sBE/UelJ2NdkJe/2020-07-06T09-48-13.mp4/status/2"
I/flutter (11940):          },
I/flutter (11940):          "href": "/ec80a59accce7a12f56e8f0272dd2202/videos/PTYqKF0sBE/UelJ2NdkJe/

*/


