import 'package:flutter/material.dart';
import 'dart:async';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _TopWidget(),
    );
  }
}

class _TopWidget extends StatelessWidget {
  _TopWidget();

  /////////////////////////////////////
  ///一つ上の階層でキーを作成する/////////
  /////////////////////////////////////
  final GlobalKey<MyReceiverState> keyChild = GlobalKey<MyReceiverState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Show Dialog Sample')),
        body: Center(
          //////////////////////////////////
          ///キーとキーを入れたWidgetを渡す///
          ///Receiverにはキーを付与//////////
          //////////////////////////////////
          child: MyParent2(
              keyChildReceiver: keyChild,
              childReceiver: MyReceiver(keyChild),
              childTransmitter: const MyTransmitter()),
        ));
  }
}

class MyParent2Inherited extends InheritedWidget {
  const MyParent2Inherited(
      {super.key, required super.child, required this.state});
  final MyParent2State state;

  @override
  bool updateShouldNotify(MyParent2Inherited oldWidget) => true;
}

class MyParent2 extends StatefulWidget {
  const MyParent2(
      {super.key,
      required this.keyChildReceiver,
      required this.childReceiver,
      required this.childTransmitter});
  final StatefulWidget childReceiver;
  final StatefulWidget childTransmitter;

  ////////////////////////////////////////////////////////////////
  ///[GlobakKey]のジェネリクスに子の[State]のウィジェット名を入れる///
  ////////////////////////////////////////////////////////////////
  final GlobalKey<MyReceiverState> keyChildReceiver;

  ///このmethodを呼び出したWidgetをリビルドします
  static MyParent2State ofWidget(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MyParent2Inherited>()!.state;

  ///このmethodを呼び出して[MyParent2Inherited]にアクセスしても
  ///呼び出し元のWidgetはリビルドされません。
  static MyParent2State ofElement(BuildContext context) => (context
          .getElementForInheritedWidgetOfExactType<MyParent2Inherited>()!
          .widget as MyParent2Inherited)
      .state;

  @override
  State<MyParent2> createState() => MyParent2State();
}

// キーを外部で作って渡してもらえばいいのだ。！！！
// キーを作ってそれを使ってinstanciateしたものをchildに迎えればいいのだ。
// こんな感じ
// key = GlobalKey<MyGPSState>();
// MyParent2(keyChildReceiver: key,child:MyGPS(key: key));
// ジェネリクスいらねーな
class MyParent2State extends State<MyParent2> {
  getText() => widget.keyChildReceiver.currentState?.getTextForParent();

  ///必ずStringにcastしてください
  setText(String value) =>
      widget.keyChildReceiver.currentState?.setTextForParent(value.toString());

  @override
  Widget build(BuildContext context) {
    ///////////////////////////////////
    ///Column、Row、等に変更可能です。///
    ///////////////////////////////////
    return MyParent2Inherited(
        state: this,
        child: Column(
            children: <Widget>[widget.childReceiver, widget.childTransmitter]));
  }
}

///受信側の子
class MyReceiver extends StatefulWidget {
  const MyReceiver(Key? key) : super(key: key);

  @override
  State<MyReceiver> createState() => MyReceiverState();
}

///Childウィジェットには[MyParent2ImplementForReceiver]を[implements]すること
class MyReceiverState extends State<MyReceiver>
    implements MyParent2ImplementForReceiver {
  String _filename = 'HELLO WORLD';

  ///implementsのoverride
  @override
  getTextForParent() => _filename;
  @override
  setTextForParent(value) {
    setState(() {
      _filename = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_filename);
  }
}

///送信側のchild
class MyTransmitter extends StatefulWidget {
  const MyTransmitter({super.key});

  @override
  State<MyTransmitter> createState() => _MyTransmitterState();
}

class _MyTransmitterState extends State<MyTransmitter> {
  int _counter = 0;
  void _onTime(value) {
    _counter++;
    MyParent2.ofElement(context).setText(_counter.toString());
    print(_counter);
  }

  late Timer _timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), _onTime);
  }

  @override
  void dispose() {
    // TODO: implement dispose

    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

abstract class MyParent2ImplementForReceiver {
  String getTextForParent();

  setTextForParent(value);
}


//test version0.1.1

//今回はdialogではなくて、同じツリーの子同士の通信をやってみる

//MyReceiverとMyTransmitterが子です

//MyParent2Inheritedをつくる
//ofメソッドを実装する

///子に渡す値は必ずtoString()する