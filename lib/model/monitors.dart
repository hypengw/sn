import 'dart:convert' as convert;

/*
      "type": "h264",
      "ext": "mp4",
      "protocol": "rtsp",
      "host": "192.168.13.130",
      "path": "/Streaming/Channels/101",
      "port": 554,
      "fps": 1,
      "mode": "start",
      "width": 640,
      "height": 480,
*/


class Monitors{
  static List<Monitor> fromjson(dynamic json) {
    if (json is List<dynamic>) {
      return new List.generate(json.length, (index) => Monitor.fromjson(json[index]));
    }else {
      return new List.generate(1, (index) => Monitor.fromjson(json));
    }
  }
  static List<dynamic> tojson(List<Monitor> m){
    return new List.generate(m.length, (index) => m[index].toString());
  }
  static List<Monitor> findMonitor(List<Monitor> monitors, bool filter(Monitor monitor), int limit){
    List<Monitor> result = new List<Monitor>();
    int i = 0;
    for(Monitor item in monitors??[]){
      if(i == limit) break;
      if(filter(item)){
        result.add(item);
        i++;
      }
    }
    return result;
  }
  static String GetDirectUrl(Monitor monitor){
    String url = monitor.protocol + '://' + monitor.details.muser + ':' + monitor.details.mpass + '@'
        + monitor.host+':'+monitor.port.toString() + monitor.path;
    return url;
  }
}

class Monitor{
  String mid;
  String name;
  String type;
  String ext;
  String protocol;
  String host;
  int port;
  String path;
  String mode;
  String status;
  _StreamByType streamByType;
  _Details details;

  Monitor.fromjson(Map<String, dynamic> json){
    this.mid = json['mid'];
    this.name = json['name'];
    this.ext = json['ext'];
    this.type = json['type'];
    this.protocol = json['protocol'];
    this.status = json['status'];
    this.mode = json['mode'];
    this.port = json['port'];
    this.host = json['host'];
    this.path = json['path'];
    this.streamByType = _StreamByType.fromjson(json['streamsSortedByType']);
    this.details = _Details.fromjson(convert.json.decode(json['details']));
  }
  Map<String, dynamic> tojson(){
    return <String, dynamic>{
      'mid': this.mid,
      'name': this.name,
      'ext': this.ext,
      'type': this.type,
      'protocol': this.protocol,
      'status': this.status,
      'host': this.host,
      'port': this.port,
      'path': this.path,
      'mode': this.mode,
      'streamByType': this.streamByType.tojson(),
      'details': this.details.tojson(),
    };
  }
}

class _StreamByType {
  Map<String, List<String>> streams;

  _StreamByType.fromjson(Map<String, dynamic> json){
    this.streams = new Map<String, List<String>>();
    json.forEach((key, value) {
      if(value is List<dynamic>){
        this.streams[key] = List<String>.from(value);
      }
    });
  }
  Map<String, dynamic> tojson(){
    return streams;
  }
}

class _Details{
  String stream_type;
  String muser;
  String mpass;
  _Details.fromjson(Map<String, dynamic> json){
    this.stream_type = json['stream_type'];
    this.muser = json['muser'];
    this.mpass = json['mpass'];
  }

  Map<String, dynamic> tojson(){
    return <String, dynamic>{
      'stream_type': this.stream_type,
      'muser': this.muser,
      'mpass': this.mpass
    };
  }
}