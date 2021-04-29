import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:localstorage/localstorage.dart';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:audiofileplayer/audio_system.dart';

class Jump extends StatefulWidget {
  Jump({Key? key}) : super(key: key);

  @override
  _JumpState createState() => _JumpState();
}

class _JumpState extends State<Jump> {
  int startTime = 0;
  List recorders = [];
  String state = "stop", movement = "";
  var timer1, timer2;
  final methodChannel =
      const MethodChannel('jump/MethodChannel');
  static const EventChannel eventChannel =
      const EventChannel('jump/EventChannel');
  NumberFormat formatCount = NumberFormat("#,##0", "en_US"),
    formatSecond =  NumberFormat("#,##0", "en_US");
  // static const messageChannel = const BasicMessageChannel(
  //     'jump/MessageChannel', StandardMessageCodec());
  final LocalStorage storage = new LocalStorage('history');
  Map<String, dynamic> history = {};
  String fmtDate = "yyyyMMdd";
  DateTime today =  DateTime.now();

  @override
  void initState() {
    super.initState();
    eventChannel.receiveBroadcastStream().listen(_onEvent);
    initial();      
  }

  void initial() async {
    
  }

  _onEvent(dynamic event) {
    if(movement == "上" && "$event".indexOf("下") > -1) {
      if(startTime == 0) {
        add();
      } else {
        recorders[0]["count"]++;
        recorders[0]["second"] = (DateTime.now().millisecondsSinceEpoch - startTime) / 1000;
        this.setState(() {});
      }
      int count = recorders[0]["count"] % 10;
      Audio.load('assets/mp3/${count == 0 ? "10" : count}.mp3')..play()..dispose();

      if(timer1 != null) timer1.cancel();
      timer1 = Timer(Duration(seconds: 5), (){
        startTime = 0;
        timer1.cancel();
        timer1 = null;
        timer2 = Timer(Duration(seconds: 5), (){
          action("stop");
          Audio.load('assets/mp3/beep.mp3')..play()..dispose();
          setState(() { });
        });
      });
    }
    movement = "$event";
  }

  @override
  dispose() { //
    super.dispose();
    action("stop");
  }

  void action(String mode) {
    state = mode;
    methodChannel.invokeMethod('sensor', { "action": state});
    if(timer1 != null) {
      timer1.cancel();
      timer1 = null;
    }
      
    if(timer2 != null) {
      timer2.cancel();
      timer2 = null;
    }
  }

  void add() {
    String fmtTime = "HH:mm";
    DateTime dt = DateTime.now();//
    startTime = DateTime.now().millisecondsSinceEpoch;
    recorders.insert(0, {"count": 1, "second": 0.0, "time": DateFormat(fmtTime).format(dt)});
    this.setState(() {}); // 
  }

  @override
  void reassemble() async {
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async { onBack(); return false; },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => onBack(),
          ), 
          title: Text("jump"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(flex: 1, child: list()),
              if(state == "start") sum(),
              state == "stop" ? bntStart() : btnStop()
            ],
          ),
        ),
      )
    );
  }
  Widget sum() {
    int count = 0;
    double second = 0;
    for(int i = 0; i < recorders.length; i++) {
      count += recorders[i]["count"] as int;
      second += recorders[i]["second"] as double;
    }

    String s2 = "";
    NumberFormat format1 = NumberFormat("#,##0", "en_US");
    NumberFormat format2 = NumberFormat("#0", "en_US");
    double min = second / 60; second = second % 60;
    if(min >= 1)
      s2 = format1.format(min.floor()) + '分';
    if(second >= 1) {
      s2 += (s2.length > 0 ? " " : "") + format2.format(second) + '秒';
    }

    return Container(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      decoration: BoxDecoration(
        color: Colors.blue[40],
        border:  new Border.all(color: Colors.blue, width: 1), 
      ),
      child: Row(
        children: [
          Expanded( 
            flex: 1,
            child: Align(
              alignment: Alignment.center,
              child: Text("${formatCount.format(count) + '次'}",
              // Text("$count 次",
                style: new TextStyle(
                  fontSize: 20.0,
                  // color: i >= 5 ? Colors.orange[900] : Colors.black
                ),
              )
            )
          ),
          Expanded( 
            flex: 1,
            child: Align(
              alignment: Alignment.center,
              child: Text("${s2.length == 0 ? '0秒' : s2}",
                style: new TextStyle(
                  fontSize: 20.0,
                  // color: i >= 5 ? Colors.orange[900] : Colors.black
                ),
              )
            )
          ),
        ],
      )
    );
  }
  Widget list() {
    Widget divider1=Divider(color: Colors.blue,);
    Widget divider2=Divider(color: Colors.green);
    return ListView.separated(
        itemCount: recorders.length,
        //列表项构造器
        itemBuilder: (BuildContext context, int index) {
          return rowRender(index);
        },
        //分割器构造器
        separatorBuilder: (BuildContext context, int index) {
          return index%2==0?divider1:divider2;
        },
    );
  }

  Widget rowRender(int index) {
    return Container(
      child: Row(
        // mainAxisAlignment: MainAxisAlignment.start,
        // crossAxisAlignment: CrossAxisAlignment.start, 
        children: [
          Container(
            child: Text("${recorders.length - index}", 
              textAlign: TextAlign.center,
              style: new TextStyle(
                fontSize: 18.0,
              ),
            ),
            width: 40,
            padding: EdgeInsets.all(5),
            // decoration: BoxDecoration(
            //   border:  new Border.all(color: Color(0xFFFF0000), width: 1), 
            // )
          ),
          Expanded( 
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Container( child: Text("${'時間：' + recorders[index]['time']}",
                    style: new TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  padding: const EdgeInsets.only(bottom: 5),
                ),
                Row(children: [
                  Expanded(
                      flex: 1,
                      child: Container(
                        child: Text("${formatCount.format(recorders[index]['count']) + '次'}", 
                          textAlign: TextAlign.right,
                          style: new TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        // decoration: BoxDecoration(
                        //   border: new Border.all(color: Color(0xFF000000), width: 1), 
                        // ),
                      ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                        child: Text("${formatSecond.format(recorders[index]['second']) + '秒'}",
                          textAlign: TextAlign.right,
                          style: new TextStyle(
                            fontSize: 18.0,
                          ),
                        ),
                        // decoration: BoxDecoration(
                        //   border: new Border.all(color: Color(0xFF000000), width: 1), 
                        // ),
                      )
                  ),
                ])
            ],)
          )
        ],
      ),
      // decoration: BoxDecoration(
      //   border: new Border.all(color: Color(0xFF000000), width: 1), 
      // ),
      // padding: const EdgeInsets.only(right: 5, top: 5, bottom: 5),
      padding: EdgeInsets.all(5),
    );
  }

  Widget bntStart() {
    Widget child = Material(
      color: Color(0XFFC01921),
      child: InkWell(
        onTap: () {
          state = "start";
          setState(() { });
          Timer(Duration(seconds: 10), (){
            Audio.load('assets/mp3/countdown.mp3')..play()..dispose();
            Timer(Duration(seconds: 5), (){
              action("start");
            });
          });
        },
        child: Align(
          alignment: Alignment.center,
          child: Text("開始",
            textAlign: TextAlign.center,
            style: new TextStyle(
              fontSize: 20.0,
              color: Colors.white
            ),
          ),
        )
      )
    );

    return Container(
      height: 45.0,
      width: double.infinity,
      child: child
    );
  }

  Widget btnStop() {
    Widget child = Material(
      color: Colors.blue,
      child: InkWell(
        onTap: () {
          action("stop");
          setState(() { });
        } ,
        child: Align(
          alignment: Alignment.center,
          child: Text("停止",
            textAlign: TextAlign.center,
            style: new TextStyle(
              fontSize: 20.0,
              color: Colors.white
            ),
          ),
        )
      )
    );

    return Container(
      height: 45.0,
      width: double.infinity,
      child: child
    );
  }

  void onBack() {
    var count = 0, second = 0.0;
    if(recorders.length > 0){
      String yymm = DateFormat("yyyyMM").format(DateTime.now());
      String dd = DateFormat("dd").format(DateTime.now());
      history = storage.getItem(yymm) ?? {};
      
      for(int i = 0; i < recorders.length; i++) {
        count += recorders[i]["count"] as int;
        second += recorders[i]["second"] as double;
      }
      if(count > 0) {
        List record = history[dd] == null ? [] : history[dd];
        record.add({"count": count, "second": second, "time": recorders[0]["time"]});
        history[dd] = record;
        storage.setItem(yymm, history);
      }
    }
    state = "back";
    Navigator.of(context).pop(count > 0 ? "OK" : "");
  }
}
