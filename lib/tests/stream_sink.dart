import 'package:flutter/material.dart';
import 'dart:async';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: _TopWidget(),
    );
  }
}

class _TopWidget extends StatelessWidget {
  const _TopWidget();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Show Dialog Sample')),
      body: const Center(child: _My()), ////////////このクラス(ツリーのトップ)を変更する///////
    );
  }
}

////////////////////ここまではお約束///////////////////////////////////////

class _MyInherited extends InheritedWidget {
  const _MyInherited({required super.child, required this.state});
  final MyState state;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

class _My extends StatefulWidget {
  const _My();

  static MyState ofWidget(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_MyInherited>()!.state;
  }

  ///このmethodを呼び出して[_Propagation]にアクセスしても
  ///呼び出し元のWidgetはリビルドされません。
  static MyState ofElement(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<_MyInherited>()!.widget
              as _MyInherited)
          .state;

  @override
  MyState createState() => MyState();
}

class MyState extends State<_My> {
  String filename = 'HELL';

  late final button = ElevatedButton(
      onPressed: () {
        streamFilename.sink.add('Help me!');
      },
      child: const Text('PUSH HERE!'));

  final streamFilename = StreamController();

  @override
  void dispose() {
    streamFilename.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    streamFilename.stream.listen((string) {
      setState(() {
        filename = string;
      });
    });
  }

  ///呼びません。
  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return _MyInherited(
        state: this,
        child: const Column(
          children: <Widget>[_MyLCD(), _MyButton()],
        )); //いつでも同じインスタンスを返す。
  }
}

class _MyLCD extends StatelessWidget {
  const _MyLCD();

  @override
  Widget build(BuildContext context) {
    return Text(_My.ofWidget(context).filename);
  }
}

class _MyButton extends StatelessWidget {
  const _MyButton();
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          _My.ofElement(context).streamFilename.sink.add('HELLO!!');
        },
        child: const Text('push'));
  }
}

/// ver0.1.0


///説明
///ボタンを押すと「HELL」が「HELLO!!」に変化します。
///[MyState]にある[StreamController]と
///あれれ？？
///わざわざInherited Widget作って、Stateも作って、oｆ()を使ってるのならば、
///ストリーム使ってでStringを流さなくても、changeFilename()とか作って
///その中にsetState()入れればいい話じゃんか！！！
///
///しかし、ものごとはそう簡単ではないことに気づいた。
///ファイルを別にしたShowDialog()内のTextFieldクラスのインスタンスのTextEditingControllerのaddListener()
///からストリームを介してファイルアクセスをしたいわけ。
///で、そこで、InheritedWidgetとか使いたくないわけ。構造作るの面倒くさいから。