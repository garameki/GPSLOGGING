import 'package:flutter/material.dart';

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
          child: MyWrapperForFilename(),
        ));
  }
}

///ダイアログ出現ボタンなので、privateにはできませ。。
class MyDialogButton extends StatefulWidget {
  const MyDialogButton({super.key});
  @override
  MyDialogButtonState createState() => MyDialogButtonState();
}

///of関数がstaticなので[State]はprivateにできません。
class MyDialogButtonState extends State<MyDialogButton> {
  Future<void> inputDialog(BuildContext context) async {
    return await showDialog<void>(
        context: context,
        builder: (context) {
          return const MyInputDialog();
        });
  }

  @override
  Widget build(BuildContext context) {
    ///DialogBox出現用のボタンのインスタンスを作成する。
    ///このなかでもインスタンス作って見たけどダメだった。
    return OutlinedButton(
        onPressed: () => inputDialog(context), child: const Text('PUSH'));
  }
}

class MyInputDialog extends StatefulWidget {
  const MyInputDialog({super.key});

  @override
  State<MyInputDialog> createState() => _MyInputDialogState();
}

class _MyInputDialogState extends State<MyInputDialog> {
  late final TextEditingController controller;
  String textTest = 'INIT';

  ///OKボタンの文字色
  Text textNotOk = const Text('NOT', style: TextStyle(color: Colors.grey));
  Text textOk = const Text('OK', style: TextStyle(color: Colors.black));
  late Text textOfOkButton;

  //OKボタンの色
  TextStyle styleNotOk = const TextStyle(color: Colors.grey);
  TextStyle styleOk = const TextStyle(color: Colors.black);
  late TextStyle styleOfOkButton;

  ///OKボタンのためのmemberとcallbackたち
  bool textfieldIsBlank = true;
  dynamic _callbackNotOk() => null;
  dynamic _callbackOk() {
    MyWrapperForFilenameState.stateForDialog.setFilename(controller.text);
    //MyGPS.filename = controller.text;
    Navigator.pop(context);
  }

  dynamic callbackOfOkButton;

  void isNotBlank() {
    if (textfieldIsBlank) setState(() {});
    textfieldIsBlank = false;
    callbackOfOkButton = _callbackOk;
    textTest = 'false';
  }

  void isBlank() {
    setState(() {});
    textfieldIsBlank = true;
    callbackOfOkButton = _callbackNotOk;
    textTest = 'true';
  }

  @override
  void initState() {
    super.initState();
    String? value = MyWrapperForFilenameState.stateForDialog.getFilename();
    controller = TextEditingController(text: value);
    isNotBlank();
    controller.addListener(() {
      if (controller.text.isEmpty) {
        isBlank();
      } else {
        isNotBlank();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        controller: controller,
        onChanged: (text) {},
      ),
      actions: <Widget>[
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              foregroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: callbackOfOkButton,
            //これだと[AlertDialog]が表示されなくなる.
            // onPressed: textfieldIsBlank
            //     ? _callbackNotOk()
            //     : _callbackOk(), //callbackOfOkButton,
            child: Text(textfieldIsBlank ? 'Inabled' : 'OK')),
      ],
      title: const Text('カスタムファイル名'),
    );
  }
}

class _MyWrapperForFilenameInherited extends InheritedWidget {
  const _MyWrapperForFilenameInherited(
      {required super.child, required this.state});
  final MyWrapperForFilenameState state;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

class MyWrapperForFilename extends StatefulWidget {
  const MyWrapperForFilename({super.key});

  @override
  State<MyWrapperForFilename> createState() => MyWrapperForFilenameState();

  static getFilenameFromMyGPS() {}

  ///使わなくてもお約束のofメソッドを用意してみた。
  static ofWidget(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_MyWrapperForFilenameInherited>()!
      .state;

  static ofElement(BuildContext context) => (context
          .getElementForInheritedWidgetOfExactType<
              _MyWrapperForFilenameInherited>()!
          .widget as _MyWrapperForFilenameInherited)
      .state;
}

class MyWrapperForFilenameState extends State<MyWrapperForFilename> {
  final key = GlobalKey<MyGPSState>();

  static late MyWrapperForFilenameState stateForDialog;

  @override
  void initState() {
    super.initState();
  }

  ///MyGPSのメソッドをよび出す。
  String? getFilename() => key.currentState!.getFilename();

  void setFilename(fname) => key.currentState!.setFilename(fname);

  @override
  Widget build(BuildContext context) {
    stateForDialog = this;
    return _MyWrapperForFilenameInherited(
        state: this,
        child: Column(
            children: <Widget>[MyGPS(key: key), const MyDialogButton()]));
  }
}

class MyGPS extends StatefulWidget {
  const MyGPS({Key? key}) : super(key: key);

  ///リダイレクトコンストラクタ（Redirecting Constructor）。この形で親のコンストラクタを呼び出す必要がある。
  //const MyGPS({super.key});の形ではダメです！！！

  ///Stack Overflow
  ///https://stackoverflow.com/questions/73767079/whats-the-difference-between-using-super-key-and-key-key-superkey-key-i/73767149#73767149
  ///Question
  ///I want to know what's the main difference between using super.key and (Key? key) : super(key: key) in a flutter app, I mean I know they both set key from the super widgets, but why there is 2 types of them, and which is preferred to use.
  ///Answer
  ///super.key is the new syntax, made available in Dart 2.17, which first came with Flutter 3.0. Details are at the release notes: https://dart.dev/guides/whats-new#may-11-2022-217-release
  ///The new syntax is much shorter and cleaner, [but you'll need to understand both forms for years to come.]

  ///上記の違いはある！！！
  ///ということですな。

  @override
  State<MyGPS> createState() => MyGPSState();
}

class MyGPSState extends State<MyGPS> {
  String _filename = 'PAROPARO_SAN';

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
  Widget build(BuildContext context) {
    return Text(_filename);
  }
}



///説明
///DialogとほかのWidgetとの通信

///なんちゃってGPS Widgetをつくって、それとの通信をしました。
///具体的にはファイル名のやりとりです。

///ポイント
///親から子のメソッド呼び出しはGlobalkeyを使いました。
///直接の子ではないAlertDialogからは[staticメンバ]を使って、
///   [build()]の際に[this]をそのメンバに入れて、直接[State]にある
///   インスタンスメソッドにアクセスするようにしました。

///Ridirecting Constructorや、Initializing list等については以下に詳しいです。
///https://dev.classmethod.jp/articles/about_dart_constructors/#item_01-03

///Keyについては以下を参考にしました。ありがとうございます。
///https://zenn.dev/flutteruniv_dev/articles/908d4069197e0c