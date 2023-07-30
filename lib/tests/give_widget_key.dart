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
  ///一つ上の改装でキーを作成する/////////
  /////////////////////////////////////
  final GlobalKey<MyChildState> keyChild = GlobalKey<MyChildState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Show Dialog Sample')),
        body: Center(
            //////////////////////////////////
            ///キーとキーを入れたWidgetを渡す///
            //////////////////////////////////
            child: MyParent2(
          keyChild: keyChild,
          child: MyChild(keyChild),
        )));
  }
}

class MyParent2 extends StatefulWidget {
  const MyParent2({super.key, required this.keyChild, required this.child});

  ////////////////////////////////////////////////////////////////
  ///[GlobakKey]のジェネリクスに子の[State]のウィジェット名を入れる///
  ////////////////////////////////////////////////////////////////
  final GlobalKey<MyChildState> keyChild;

  final StatefulWidget child;

  @override
  State<MyParent2> createState() => MyParent2State();
}

// キーを外部で作って渡してもらえばいいのだ。！！！
// キーを作ってそれを使ってinstanciateしたものをchildに迎えればいいのだ。
// こんな感じ
// key = GlobalKey<MyGPSState>();
// MyParent2(keyChild: key,child:MyGPS(key: key));
// ジェネリクスいらねーな

class MyParent2State extends State<MyParent2> {
  getText() => widget.keyChild.currentState?.getTextForParent();
  ////////////////////////////////
  ///必ずStringにcastしてください///
  ////////////////////////////////
  setText(value) =>
      widget.keyChild.currentState?.setTextForParent(value.toString());

  int _counter = 0;
  void _onTime(value) {
    _counter++;
    setText(_counter);
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
    return widget.child;
  }
}

class MyChild extends StatefulWidget {
  const MyChild(Key? key) : super(key: key);

  @override
  State<MyChild> createState() => MyChildState();
}

///Childウィジェットには[MyParent2Implements]を[implements]すること
class MyChildState extends State<MyChild> implements MyParent2Implements {
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

abstract class MyParent2Implements {
  String getTextForParent();

  setTextForParent(value);
}


//test version0.0.2


///counterが動かないぞ

///子に渡す値は必ずtoString()する