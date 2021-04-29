import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:localstorage/localstorage.dart';
import 'package:jump/jump.dart';
import 'package:jump/detail.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class Calendar extends StatefulWidget {
  Calendar({Key? key}) : super(key: key);

  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  int year = 2021, month = 1, hh = 21, mm = 30, mode = 0;
  var today = DateTime.now();
  final LocalStorage storage = new LocalStorage('history');
  bool permission = false;
  final methodChannel = const MethodChannel('jump/MethodChannel');

  @override
  void initState() {
    super.initState();
    new Future.delayed(const Duration(milliseconds: 100), () {
      _requestPermissions().then((permission) async {
        this.permission = permission;
        year = today.year;
        month = today.month;
        storage.ready.then((b) async { 
          retrieve();
        });
        methodChannel.invokeMethod('initial');
      });
    });
   
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();

    // 測試用
    // String yymm = DateFormat("yyyyMM").format(DateTime.now());
    // String dd = "01"; // DateFormat("dd").format(DateTime.now());
    // Map<String, dynamic> history = storage.getItem(yymm) ?? {};
    // List record = [];
    // record.add({"count": 120, "second": 112.0, "time": "18:00"});
    // record.add({"count": 500, "second": 100.0, "time": "20:00"});
    // history[dd] = record;
    // storage.setItem(yymm, history);
    // retrieve();
  }
  void didChangeAppLifecycleState(AppLifecycleState state) { // App 生命週期
    switch (state) {
      case AppLifecycleState.resumed:
        today = DateTime.now();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.inactive:
        break;
      default:
        break;
    }
  }
  void retrieve(){
    setState(() {});
  }
  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      // Permission.location,
      Permission.storage,
    ].request();
    print(statuses[Permission.storage]);
    return true;
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> child;
    if(permission == true){
      child = [
        header(),
        week(),
        Expanded(flex: 1, child: calendar()),
      ];
    } else {
      child = [
        Text("跳繩訓練",
          style: new TextStyle(
            // fontSize: 18.0,
            color: Colors.black
          )
        ),

        Text("2021-04-29 09:00",
          style: new TextStyle(
            fontSize: 18.0,
            color: Colors.black
          )
        ),
      ];
    }

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: child,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:  () async {
          var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => Jump()));
          if(result == "OK") {
            retrieve();
          }
        },
        child: Icon(Icons.add),
      ), 
    );
  }

  Widget header(){
    return Container(child: 
      Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20, 
              color:  Colors.white
            ),
            onPressed: () { 
              month--;
              if(month <= 0){
                month = 12;
                year--;
              }
              today = DateTime.now();
              retrieve();
            },
          ),
          Expanded( 
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onTap: () {
                  // setup();
                }, 
                child: Text( "$year 年 $month 月",
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, size: 20, 
              color:  Colors.white
            ),
            onPressed: () { 
              month++;
              if(month > 12){
                month = 1;
                year++;
              }
              today = DateTime.now();
              retrieve();
            },
          ),
        ]
      ),
      decoration: ShapeDecoration(
        color: Colors.blue,
        shape: RoundedRectangleBorder(
          // borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
  Widget week(){
    var weeks = ["一", "二", "三", "四", "五", "六", "日"];
    List<Widget> rows = [];
    for(var i = 0; i < weeks.length; i++) {
      rows.add(
        Expanded( 
          flex: 1,
          child: Align(
            alignment: Alignment.center,
            child: Text("星期"+weeks[i],
              style: new TextStyle(
                // fontSize: 18.0,
                color: i >= 5 ? Colors.orange[900] : Colors.black
              ),
            )
          )
        )
      );
    }
    return Container(child: 
      Row( children: rows ),
      padding: const EdgeInsets.only(top: 5, bottom: 5),
    );
  }

  Widget calendar() {
    DateTime firstDay = new DateTime(year, month, 1);//
    DateTime startDay = firstDay;
    Map<String, dynamic> history = {};

    var span = Duration(days: (startDay.weekday * -1) + 1);
    startDay = startDay.add(span);
    List<Widget> cols = [];
    for(var i = 0; i < 6; i++) {
      List<Widget> rows = [];
      for(var j = 0; j < 7; j++) {
        if(startDay.month != firstDay.month || startDay.day == 1) {
          String yymm = DateFormat("yyyyMM").format(startDay);
          history = storage.getItem(yymm) ?? {};
        }
        List recorders = history[DateFormat("dd").format(startDay)] ?? [];
        rows.add(cell(startDay, i, j, recorders));
        span = Duration(days: 1);
        startDay = startDay.add(span);
      }
      cols.add(Expanded( flex: 1,
          child: Row(children: rows, mainAxisAlignment: MainAxisAlignment.spaceAround,)
        )
      );
      if(startDay.month != month) {
        break;
      }
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: cols
    );
  }

  Widget cell(DateTime day, int top, int left, List recorders){
    Text text1 = Text(DateFormat('d').format(day),
      style: TextStyle(
        fontSize: 16.0,
        color: year == day.year && month == day.month ? 
          (day.weekday > 5 ? Colors.orange[900] : Colors.black) : 
          Colors.grey
      )
    );
    var s3 = "", count = 0, second = 0.0;
    for(int i = 0; i < recorders.length; i++) {
      count += recorders[i]["count"] as int;
      second += recorders[i]["second"] as double;
    }
    if(count > 0) {
      NumberFormat format1 = NumberFormat("#,##0", "en_US");
      NumberFormat format2 = NumberFormat("#0", "en_US");
      double min = second / 60;
      second = second % 60;
      String s2 = "";
      if(min >= 1)
        s2 = format1.format(min.floor()) + '分';
      if(second >= 1) {
        s2 += (s2.length > 0 ? "\n" : "") + format2.format(second) + '秒';
      }
      s3 = "${format1.format(count) + '次'}\n$s2";
    }

    Text text2 = Text(s3,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12.0,
        color: count > 500 ? Color(0XFFC01921) : Colors.blue,
          // year == day.year && month == day.month 
          // ? Colors.blue 
          // : Colors.grey
      )
    );

    Widget stock = Stack(
      children: <Widget>[
        Align(child: text1, alignment: Alignment.topCenter),
        Align(child: text2, alignment: Alignment.bottomCenter)
      ],
      alignment: Alignment.center,
    );
    if(count > 0) {
      stock =  Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            var result = await Navigator.push(context,
              MaterialPageRoute(builder: (context) => Detail(recorders: recorders)),
            );
            if(result == "OK") {
              String yymm = DateFormat("yyyyMM").format(day);
              String dd = DateFormat("dd").format(day);
              Map<String, dynamic> history = storage.getItem(yymm) ?? {};
              history[dd] = recorders;
              storage.setItem(yymm, history);
              retrieve();
            }
          },
          child: stock
        )
      );
    }
    BorderSide bs1 = BorderSide(width: 1.0, color: Colors.black12);
    BorderSide bs2 = BorderSide(width: 0, color: Colors.transparent);
  
    return Expanded(
      flex: 1,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: stock,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: today.year == day.year && today.month == day.month && today.day == day.day 
            ? Colors.blue[50] : Colors.transparent,
          border: Border(top: top == 0 ? bs1 : bs2, left: left == 0 ? bs2 : bs1, bottom: bs1) ,
        )
      )
    );
  }
}
