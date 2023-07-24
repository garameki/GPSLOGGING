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

class _MyTextField extends StatefulWidget {
  const _MyTextField();
  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<_MyTextField> {
  String name = '';
  final TextEditingController controller =
      TextEditingController(text: 'example');

  //https://api.flutter.dev/flutter/widgets/TextEditingController-class.html
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.text.isEmpty) {
        MyDialog.ofElement(context).isBlank();
      } else {
        MyDialog.ofElement(context).isNotBlank();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (text) {
        name = text;
      },
    );
  }
}

class _MyCancelButton extends StatelessWidget {
  const _MyCancelButton();
  @override
  build(BuildContext context) => ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Cancel'),
      );
}

class _MyOkButton extends StatelessWidget {
  const _MyOkButton();

  @override
  Widget build(BuildContext context) {
    print('OK-BUTTON////////////////////////////////');
    return ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.white),
          foregroundColor: MaterialStateProperty.all(Colors.blue),
        ),
        onPressed: MyDialog.ofWidget(context).callbackOfOkButton,
        child: MyDialog.ofWidget(context).textOfOkButton);
  }
}

///[MyDialogInherited]は外で変数の型として使われているのでprivateにできません。
class MyDialogInherited extends InheritedWidget {
  const MyDialogInherited(
      {super.key, required super.child, required this.state});

  final MyDialogState state;

  @override
  bool updateShouldNotify(MyDialogInherited oldWidget) => true;
}

///ダイアログ出現ボタンなので、privateにはできませ。。
class MyDialog extends StatefulWidget {
  const MyDialog({super.key});

  static MyDialogState ofWidget(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MyDialogInherited>()!.state;

  static MyDialogState ofElement(BuildContext context) => (context
          .getElementForInheritedWidgetOfExactType<MyDialogInherited>()!
          .widget as MyDialogInherited)
      .state;

  @override
  MyDialogState createState() => MyDialogState();
}

///of関数がstaticなので[State]はprivateにできません。
class MyDialogState extends State<MyDialog> {
  bool textfieldIsBlank = true;
  late Widget buttonOk;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    textfieldIsBlank = false;
    textOfOkButton = textOk;
    mojiOfOkButton = mojiOk;
  }

  void isNotBlank() {
    if (textfieldIsBlank) {
      ///むやみに[setState()]を呼ばない。
      setState(() {
        textfieldIsBlank = false;
        textOfOkButton = textOk;
        mojiOfOkButton = mojiOk;
        callbackOfOkButton = _callbackOk;
      });
    }
  }

  void isBlank() {
    setState(() {
      textfieldIsBlank = true;
      textOfOkButton = textNotOk;
      mojiOfOkButton = mojiNotOk;
      callbackOfOkButton = _callbackNotOk;
    });
  }

  ///OKボタンのonPressed:
  dynamic _callbackNotOk() => null;
  dynamic _callbackOk() {
    Navigator.pop(context);
  }

  dynamic callbackOfOkButton;

  ///OKボタンの文字色
  Text textNotOk = const Text('NOT', style: TextStyle(color: Colors.grey));
  Text textOk = const Text('OK', style: TextStyle(color: Colors.black));
  late Text textOfOkButton;

  ///OKボタンの文字
  String mojiNotOk = 'NOT';
  String mojiOk = 'OK';
  late String mojiOfOkButton;

  //OKボタンの色
  TextStyle styleNotOk = const TextStyle(color: Colors.grey);
  TextStyle styleOk = const TextStyle(color: Colors.black);
  late TextStyle styleOfOkButton;

  Future<void> inputDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        /////////このなかでなにかやらなきゃOKの文字は変化しない？////////
        ///===>このなかでインスタンス作ってみたけどダメだった。
        ///OKButtonのインスタンスをbuild()で作り直す。
        buttonOk = const _MyOkButton();

        AlertDialog alertDialog = AlertDialog(
          content: const _MyTextField(),
          actions: <Widget>[
            const _MyCancelButton(),
            buttonOk,
          ],
          title: const Text('カスタムファイル名'),
        );

        ///MyDialogInherited(ダイアログのツリーのトップ)のインスタンスをbuild()で新たに作り直す。
        MyDialogInherited widgetInherited = MyDialogInherited(
          state: this,
          child: alertDialog,
        );

        return widgetInherited;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('MyDialogState build() $textfieldIsBlank');

    /////////ここの部分はExportできるようにしないといけないなぁ。//////////////
    ///DialogBox出現用のボタンのインスタンスを作成する。
    ///このなかでもインスタンス作って見たけどダメだった。
    return OutlinedButton(
        onPressed: () => inputDialog(context),
        child: const Text('Open Dialog'));
  }
}

///説明
///TextFieldを有するDialogBoxです。
///TextFieldの中身がEmptyになると[OK]ボタンが薄くなります。
///なりません。

///問題点
///1.一回TextFieldをクリックするとかしないとOKボタンのonPressed:がnullのままになってしまう。
///2.８４行目、_MyOkButton()でリビルドされてないことが発覚！！！

///
///ver0.1.2
///2...ベータ番号
///1...動く番号
///0...リリース番号(パッケージとして[@override]すれば動くこと)
///
///What's up?
///ver0.2.0重くなるのをsetState()を呼ぶ回数を減らすことで回避した。
///
///問題はtextFieldとの連携なんだよな。
///addListenerのなかでインスタンスとかつくれないかな？