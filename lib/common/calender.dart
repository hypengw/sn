
import 'package:flutter/material.dart';


class CalenderTimeUnity {

  static const List<int> DaysOfMonth = const <int>[
    31,
    -1,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31
  ];

  static const List<int> numOfWeekday = const <int>[
    2,
    3,
    4,
    5,
    6,
    7,
    1,
  ];

  static int getDaysOfMonth(int year, int month) {
    if(month == DateTime.february){
      if(year % 400 == 0 || (year % 100 !=0 && year % 4 == 0))
        return 29;
      else
        return 28;
    }
    return CalenderTimeUnity.DaysOfMonth[month-1];
  }

  static int getWeekday(int year, int month, int day){
    return (new DateTime.utc(year,month,day)).weekday;
  }

  static int getFirstDayPosition(int year,int month){
    return CalenderTimeUnity.numOfWeekday[CalenderTimeUnity.getWeekday(year, month, 1)-1];
  }

  static int getColumns(int year, int month){
    int sumDays = getDaysOfMonth(year, month)+getFirstDayPosition(year, month)-1;
    return sumDays ~/ 7 + (sumDays % 7 == 0?0:1);
  }

}

class Calender extends StatelessWidget{

  final int year;
  final int month;
  final int firstDayPosition;
  final int days;
  final int columns;
  final List<bool> isHighlight;
  final void Function(DateTime day) tapCallBack;

  Calender({
    @required this.year,
    @required this.month,
    isHighlight,
    this.tapCallBack,
  }):firstDayPosition = CalenderTimeUnity.getFirstDayPosition(year, month),
        days = CalenderTimeUnity.getDaysOfMonth(year, month),
        columns = CalenderTimeUnity.getColumns(year, month),
        isHighlight = isHighlight??new List<bool>.filled(32, false);

  final week = const [
    '日', '一', '二','三','四','五','六'
  ];

  Widget showWeek(int index){
   return new Expanded(flex: 1,child: new Align(child: new Text(this.week[index]),));
  }

  Widget buildItem(BuildContext context, int column, int index){
    int num = index + 2 - this.firstDayPosition + column*7;
    num = num < 1?0:num;
    num = num > this.days?0:num;
    return new Expanded(
        flex: 1,
        child:new GestureDetector(
          onTap: num>0?()=>this.tapCallBack(new DateTime(year,month,num)):null,
          child: new Container(
            padding: EdgeInsets.only(top: 8),
            decoration: new BoxDecoration(
                border: new Border(
                    bottom: this.isHighlight[num]??false
                        ?new BorderSide(
                        color: Theme.of(context).accentColor,
                        width: 2.0
                    )
                        :BorderSide.none
                )
            ),
            child: new Align(
              child:new Text(num==0?'':num.toString()),
            ),
          ),
        )
    );
  }
  
  Widget buildColumn(BuildContext context, int column){
    return new Expanded(
        flex: 1,
        child: new Row(
          children: <Widget>[
          ]..addAll(List<Widget>.generate(7, (index) => this.buildItem(context, column, index))),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
      height: (MediaQuery.of(context).size.width/7)*(this.columns+1),
      child: new Column(
        children: <Widget>[
          new Row(
            children: List.generate(7, this.showWeek),
          ),
        ]..addAll(List<Widget>.generate(this.columns, (index) => this.buildColumn(context, index))),
      ),
    );
  }
}