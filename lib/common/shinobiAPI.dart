import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snc/common/global.dart';

import 'package:snc/model/login.dart';
import 'package:snc/model/monitors.dart';
import 'package:snc/model/user.dart';
import 'package:snc/model/videos.dart';

class ShinobiAPI {
   User get user => Global.profile.user;
   Login get login => Global.profile.login;
   bool get isLogin => (Global.profile.login?.user?.auth_token != null);
   //set user(User value) => Global.profile.user = value;
   set login(Login value) => Global.profile.login = value;
   Dio dio;
   DateFormat dateFormat;

   ShinobiAPI() {
      this.dio = new Dio();
      this.dio.options.responseType = ResponseType.plain;
      this.dio.options.receiveTimeout = 5000;
      this.dio.options.connectTimeout = 5000;
      this.dateFormat = new DateFormat("yyyy-MM-ddTHH:mm:ss");
   }

   Future<void> init() async {

   }
   Future<bool> _checkSocketPort(String host, int port, {int timout=3}) async {
      Socket connection;
      connection = await Socket.connect(host, port, timeout: new Duration(seconds: timout)).catchError((e)=> false);
      if (connection != null) {
         connection.destroy();
         return true;
      }
      return false;
   }

   Future<bool> loginSn() async {
      Response rep;
      rep = await this.dio.post(this.user.url+'/?json=true',data: {
         "machineID":this.user.machineID,
         "mail":this.user.mail,
         "pass":this.user.pass,
         "function":"dash"
      });
      this.login = Login.fromjson(
          json.decode(rep.data.toString())
      );
      return this.login.ok;
   }

   Future<List<Monitor>> getMonitors() async {
      Response rep;
      rep = await this.dio.get(this.user.url +'/'+ this.login.user.auth_token +'/monitor/'+ this.login.user.ke);
      return Monitors.fromjson(json.decode(rep.data.toString()));
   }

   Future<bool> checkMonitorDirect(Monitor monitor) async {
      return await _checkSocketPort(monitor.host, monitor.port);
   }

   Future<bool> deleteVideo(SnVideo snVideo) async {
      Response rep;
      rep = await this.dio.get(this.user.url + snVideo.links.deleteVideo);
      return json.decode(rep.data.toString())['ok'];
   }

   Future<bool> videoChangeToRead(SnVideo snVideo) async {
      Response rep;
      rep = await this.dio.get(this.user.url + snVideo.links.changeToRead);
      return json.decode(rep.data.toString())['ok'];
   }

   Future<SnVideos> getAllVideos() async {
      return this.getVideos(null, null, null, null);
   }
   //Get video files between start time and end time
   Future<SnVideos> getVideos(Monitor monitor, DateTime startTime, DateTime endTime, int limit) async {
      Response rep;
      String url = this.user.url +'/'+ this.login.user.auth_token +'/videos/'+ this.login.user.ke;
      if(monitor!=null)url = url + '/'+monitor.mid;
      url = url + '?';
      if(startTime!=null)url = url + '&start='+this.dateFormat.format(startTime);
      if(endTime!=null)url = url + '&end='+this.dateFormat.format(endTime);
      if(limit!=null)url = url + '&limit='+limit.toString();
      rep = await this.dio.get(url);
      return SnVideos.fromjson(json.decode(rep.data.toString()));
   }

   Future<bool> isDayHaveVideo(DateTime day, Monitor monitor) async {
      SnVideos snVideos = await getVideos(monitor, day, day.add(new Duration(days: 1)), 1);
      return snVideos.total > 0;
   }

   List<Future<bool>> getDaysHaveVideoInMonth(DateTime month, Monitor monitor) {
      List<Future<bool>> days = new List<Future<bool>>(32);
      DateTime dayTime = new DateTime(month.year,month.month);
      for(var i = 1;i<32;i++){
         days[i] = this.isDayHaveVideo(dayTime, monitor);
         dayTime = dayTime.add(new Duration(days: 1));
      }
      return days;
   }

   String getFirstStreamUrl(Monitor monitor) {
      String url;
      monitor.streamByType.streams.forEach((key, value) {
         url = this.user.url + value[0];
         return;
      });
      return url;
   }

   String getVideoFileUrl(SnVideo snVideo) {
      String url = this.user.url +'/'+ this.login.user.auth_token +'/videos/'+ this.login.user.ke +'/'+ snVideo.mid +'/'+ snVideo.filename;
      return url;
   }

}