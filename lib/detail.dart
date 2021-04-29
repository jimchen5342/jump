import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Detail extends StatefulWidget {
  Detail({Key? key, required this.recorders}) : super(key: key);
  final List recorders;

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  NumberFormat formatCount = NumberFormat("#,##0", "en_US"),
    formatSecond =  NumberFormat("#,##0", "en_US");
  bool dirty = false;
  @override
  void initState() {
    super.initState();
    print("${widget.recorders}");
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();
  }

  void onBack(){
    Navigator.of(context).pop(dirty == true ? "OK" : "");
  }

  @override
  Widget build(BuildContext context) {
    return  WillPopScope(
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
              sum(),
              // state == "stop" ? bntStart() : bntOK()
            ],
          ),
        ),
      )
    );
  }
  
  Widget sum() {
    int count = 0;
    double second = 0;
    for(int i = 0; i < widget.recorders.length; i++) {
      count += widget.recorders[i]["count"] as int;
      second += widget.recorders[i]["second"] as double;
    }
    if(count == 0) return Container();
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
              child: Text("$s2",
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
        itemCount: widget.recorders.length,
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
    String item = widget.recorders[index]['time'];
    return Dismissible(
      key: Key(item),
      onDismissed: (direction) {
        dirty = true;
        setState(() {
          widget.recorders.removeAt(index);
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("$item 已刪除......")));
      },
      // Show a red background as the item is swiped away.
      background: Container(color: Colors.red),
      child: Container(
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Container(
              child: Text("${widget.recorders.length - index}", 
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
                  Container( child: Text("${'時間：' + widget.recorders[index]['time']}",
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
                          child: Text("${formatCount.format(widget.recorders[index]['count']) + '次'}", 
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
                          child: Text("${formatSecond.format(widget.recorders[index]['second']) + '秒'}",
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
      )
    );
  }
}
