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
  const _MyOkButton({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
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
  late ElevatedButton buttonOk;

  void isNotBlank() {
    if (textfieldIsBlank) {
      setState(() {
        textfieldIsBlank = false;
      });
    }
  }

  void isBlank() {
    setState(() {
      textfieldIsBlank = true;
    });
  }

  dynamic _callbackNull() => null;
  dynamic _callbackPop() {
    Navigator.pop(context);
  }

  dynamic callbackOfOkButton;

  Future<void> inputDialog(
      BuildContext context, MyDialogInherited widgetInherited) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return widgetInherited;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print('MyDialogState build() $textfieldIsBlank');
    callbackOfOkButton = textfieldIsBlank ? _callbackNull : _callbackPop;

    ///OKButtonのインスタンスをここで作り直す。
    buttonOk = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        foregroundColor: MaterialStateProperty.all(Colors.blue),
      ),
      onPressed: () => callbackOfOkButton(),
      child: const Text('OK'),
    );

    ///MyDialogInherited(ダイアログのツリーのトップ)のインスタンスをここで新たに作り直す。
    MyDialogInherited widgetInherited = MyDialogInherited(
        state: this,
        child: AlertDialog(
          actions: <Widget>[
            const _MyCancelButton(),
            _MyOkButton(
              child: buttonOk,
            )
          ],
          title: const Text('カスタムファイル名'),
          content: const _MyTextField(),
        ));

    /////////ここの部分はExportできるようにしないといけないなぁ。//////////////
    ///DialogBox出現用のボタンのインスタンスを作成する。
    return OutlinedButton(
        onPressed: () => inputDialog(context, widgetInherited),
        child: const Text('Open Dialog'));
  }
}


//ofElementとかを使って、全部作り直しているのをやめたい。
///出現用ボタンをMixInできるか試したい。