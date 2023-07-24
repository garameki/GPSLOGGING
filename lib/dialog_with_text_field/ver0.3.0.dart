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
      body: const Center(child: MyDialog()),
    );
  }
}

class MyDialogInherited extends InheritedWidget {
  const MyDialogInherited(
      {super.key, required super.child, required this.state});

  final MyDialogState state;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return true;
  }
}

///ダイアログ出現ボタンなので、privateにはできませ。。
class MyDialog extends StatefulWidget {
  const MyDialog({super.key});
  @override
  MyDialogState createState() => MyDialogState();

  static of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MyDialogInherited>()!.state;
}

///of関数がstaticなので[State]はprivateにできません。
class MyDialogState extends State<MyDialog> {
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

///説明
///TextFieldを有するDialogBoxです。
///TextFieldの中身がEmptyになると[OK]ボタンが無効になり、文字も変化します。

///参考記事:BAD
///https://note.com/hatchoutschool/n/nda33cfa5f2d4
///この記事のStatefulBuilderクラスは必要ありませんでした。
///そもそも、StatefulBuilderは一部分をsetState()するためのクラスです。

///参考記事:GOOD
///https://api.flutter.dev/flutter/widgets/StatefulBuilder-class.html
///動画が張り付けてあります。参考になります。
///本[package]とは関係なくなりましたけど。



///疑問
///Widgetにする意味は何なのだろうか？

///その答え
///[setState()]で更新する範囲を区切ることが目的です！！！
///この[Dialog]の場合は特に、[showDialog()]のある[MyDialog.context]と
///[AlertDialog.context]が別のものなので、
///[context](Element treeそのもの)を遡ったり、contextを更新[setState()]したりする場合には
///区切る必要があるのです。

///ver0.3.0
///[Widget]を[Dialog]専用にすることで解決できた。
///InheritedWidgetも必要なかった。

///追伸
///[Typedef]をみかけた。
