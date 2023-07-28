import 'package:flutter/material.dart';
import 'my_wrapper_textfield_dialog_ver0.6.0.dart';

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
class MyGPSState extends State<MyGPS> {
  String _filename = 'PAROPARO_SAN';

  late GlobalKey key;
  String getFilename() {
    return _filename;
  }

  void setFilename(fname) {
    ///[setState()]は[staticメソッド]の中には入れられない
    setState(() {
      _filename = fname;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //////////////////////////////////////////////////////////////////////
    ///statefulwidgetの子にキーを渡す場合には[initState]の中でキーを取得する//
    ///statelesswidgetの場合にはコンストラクタの初期化時点でやる?/////////////
    //////////////////////////////////////////////////////////////////////
    ///
  }

  @override
  Widget build(BuildContext context) {
    return Column(
//        children: <Widget>[Text(_filename), const Text('RENAME FILE')]);
        children: <Widget>[
          Text(_filename),
          OutlinedButton(
              onPressed: () => textfieldDialog(context),
              child:
                  const Text('Open Dialog-with-textfield to rename filename')),
        ]);
  }
}

///test用です
///./lib/my_wrapper_textfield_dialog_ver0.6.0.dart
///を別ファイル化テストするためのものです。
