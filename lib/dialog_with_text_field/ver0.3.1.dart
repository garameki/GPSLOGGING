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
    print(MyWrapperForFilenameState.stateForDialog.tempFilename);
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
  final GlobalKey key = GlobalKey<MyGPSState>();

  String tempFilename = 'UGOUGO'; //本当はfilenameを保存するメンバなんていらない。

  static late MyWrapperForFilenameState stateForDialog;

  ///親が子のメソッドを呼ぶにはどうするのかな？
  ///具体的には
  ///MyGPSのget filenameをcallしたい
  ///

  @override
  void initState() {
    super.initState();
  }

//  String getFilename() => tempFilename;
//  void setFilename(fname) => tempFilename = fname;

  ///MyGPSのメソッドをよびたいのだけれど。
  String? getFilename() {
    print(
        'in MyWrapperForFilenameState.getFilename():${key.currentState.toString()}');
    return key.currentState!.hihi;//.getFilename();
        .toString(); //.toDiagnosticsNode().name.hashCode.toString();
//    hashCode.toString(); //間に何か入れるんだろ！！

    //return key.currentState.hashCode.toString(); //このstateはどのwidgetだ？？？
    //回答_MyGPSStateでした！！！！！！！！！！
  }

  void setFilename(fname) => tempFilename = fname;

  @override
  Widget build(BuildContext context) {
    stateForDialog = this;
//    key = GlobalKey<MyGPSState>();
    print('NEW:$key');
    return _MyWrapperForFilenameInherited(
        state: this,
        child: Column(
            children: <Widget>[MyGPS(key: key), const MyDialogButton()]));
  }
}

class MyGPS extends StatefulWidget {
  const MyGPS({super.key});

  @override
  State<MyGPS> createState() => MyGPSState();
}

class MyGPSState extends State<MyGPS> {
  String _filename = 'PAROPARO_SAN';

  static String hihi = 'hh';

  String getFilename() {
    return _filename;
  }

  void setFilename(fname) {
    setState(() {
      //staticメソッドの中では無理だかんね。
      _filename = fname;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('MyGPS:${context.widget.toString()}'); //widgetプロパティは[Key]そのもの！！！
    print('MyGPSState:${this.toString()}');
    print(this.hashCode == context.hashCode);
    return Text(_filename);
  }
}



///説明
///DialogとほかのWidgetとの通信




///ver0.3.0
///[Widget]を[Dialog]専用にすることで解決できた。
///InheritedWidgetも必要なかった。


///Git情報
///ブランチdevelopを切りました。
