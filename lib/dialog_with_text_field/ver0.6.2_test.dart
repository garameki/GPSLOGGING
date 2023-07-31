import 'dart:ui';

import 'package:flutter/material.dart';
import 'ver0.6.2.dart';

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
        body: const Center(
          child: MyWrapperTextfieldDialog(),
        ));
  }
}

///子Widget
///キーを渡すWidgetはStatefulWidgetでなくてはならない。
///コンストラクタはリダイレクトコンストラクタの形をとらなくてはならない。
class MyGPS extends StatefulWidget {
  const MyGPS({Key? key}) : super(key: key);

  @override
  State<MyGPS> createState() => MyGPSState();
}

///[key]を使ってアクセスを受ける場合にはクラス名はprivateではいけません。
/////////////////////////////
///ここにimplementsします。///
/////////////////////////////
class MyGPSState extends State<MyGPS>
    implements MyWrapperTextfieldDialogImplements {
  String _filename = 'PAROPARO_SAN';

  bool _flagStarted = false;

  _callbackSTOP() {
    setState(() {
      _flagStarted = false;
    });
  }

  ////////////////////////////////////////////////
  ///implementsされたクラスのメソッドを装備する//////
  ////////////////////////////////////////////////
  @override
  String getTextForMyWrapperTextfieldDialog() => _filename;
  @override
  void setTextForMyWrapperTextfieldDialog(value) {
    setState(() {
      _filename = value;
      _flagStarted = true;
    });
  }

  @override
  void canceledForMyWrapperTextfieldDialog() {
    setState(() {
      _flagStarted = false;
    });
  }

  //////////////////////////////////////////////////////////////////////
  ///statefulwidgetの子にキーを渡す場合には[initState]の中でキーを取得する//
  ///statelesswidgetの場合にはコンストラクタの初期化時点でやる?/////////////
  //////////////////////////////////////////////////////////////////////
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    ///取得例
    ///GlobalKey keey = MyWrapperTextfieldDialog.ofElement(context).keyChild;
  }

  @override
  Widget build(BuildContext context) {
    if (_flagStarted) {
      return Column(children: <Widget>[
        Text(_filename),
        OutlinedButton(
            onPressed: _callbackSTOP, child: const Text('STOP LOGGING'))
      ]);
    } else {
      return Column(
          //        children: <Widget>[Text(_filename), const Text('RENAME FILE')]);
          children: <Widget>[
            Text(_filename),
            OutlinedButton(
                onPressed: () => textfieldDialog(context),
                child: const Text('START LOGGING'))
          ]);
    }
  }
}


///ver0.6.2のtest用です
///START/STOP ボタンをtest側に実装しました。
///WrappingするウィジェットのStateにはMyWrapperTextfieldDialogImplementsを
///implementsしてもらいます。