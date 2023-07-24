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
  ///OKボタンの文字色
  Text textNotOk = const Text('NOT', style: TextStyle(color: Colors.grey));
  Text textOk = const Text('OK', style: TextStyle(color: Colors.black));
  late Text textOfOkButton;

  //OKボタンの色
  TextStyle styleNotOk = const TextStyle(color: Colors.grey);
  TextStyle styleOk = const TextStyle(color: Colors.black);
  late TextStyle styleOfOkButton;

  final TextEditingController controller =
      TextEditingController(text: 'example');
  String textTest = 'INIT';

  ///OKボタンのためのインスタンス
  bool textfieldIsBlank = true;
  dynamic _callbackNotOk() => null;
  dynamic _callbackOk() {
    MyGPS.filename = controller.text;
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
  _MyWrapperForFilenameInherited({required super.child, required this.state});
  _MyWrapperForFilenameState state;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

class MyWrapperForFilename extends StatefulWidget {
  const MyWrapperForFilename({super.key});

  @override
  State<MyWrapperForFilename> createState() => _MyWrapperForFilenameState();

  static of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_MyWrapperForFilenameInherited>()!
      .state;
}

class _MyWrapperForFilenameState extends State<MyWrapperForFilename> {
  String filename = 'any';

  ///親が子のメソッドを呼ぶにはどうするのかな？

  @override
  Widget build(BuildContext context) {
    return _MyWrapperForFilenameInherited(
        state: this,
        child: const Column(children: <Widget>[MyGPS(), MyDialogButton()]));
  }
}

class MyGPS extends StatefulWidget {
  const MyGPS({super.key});

  @override
  State<MyGPS> createState() => _MyGPSState();
}

class _MyGPSState extends State<MyGPS> {
  String _filename = '';

  get filename {
    return _filename;
  }

  set filename(fname) {
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




///ver0.3.0
///[Widget]を[Dialog]専用にすることで解決できた。
///InheritedWidgetも必要なかった。

