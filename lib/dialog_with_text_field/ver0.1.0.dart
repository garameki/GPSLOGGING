import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyDialog(),
    );
  }
}

class MyTextField extends StatefulWidget {
  const MyTextField({super.key});
  @override
  MyTextFieldState createState() => MyTextFieldState();
}

class MyTextFieldState extends State<MyTextField> {
  String name = '';
  final TextEditingController controller =
      TextEditingController(text: 'example');

  //https://api.flutter.dev/flutter/widgets/TextEditingController-class.html
  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (controller.text == '') {
        MyDialog.ofWidget(context).isBlank();
      } else {
        MyDialog.ofWidget(context).isNotBlank(); //ここのWidgetはInheritの子ではない
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

class MyCancelButton extends StatelessWidget {
  const MyCancelButton({super.key});
  @override
  build(BuildContext context) => ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Cancel'),
      );
}

class MyOkButton extends StatelessWidget {
  const MyOkButton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

class MyDialogInherited extends InheritedWidget {
  const MyDialogInherited(
      {super.key, required super.child, required this.state});

  final MyDialogState state;

  @override
  bool updateShouldNotify(MyDialogInherited oldWidget) => true;
}

class MyDialog extends StatefulWidget {
  const MyDialog({super.key});

  static MyDialogState ofWidget(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MyDialogInherited>()!.state;

  @override
  MyDialogState createState() => MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  bool textfieldIsBlank = true;
  late ElevatedButton buttonOk;

  void isNotBlank() {
    setState(() {
      textfieldIsBlank = false;
    });
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
    buttonOk = ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(Colors.white),
        foregroundColor: MaterialStateProperty.all(Colors.blue),
      ),
      onPressed: () => callbackOfOkButton(),
      child: const Text('OK'),
    );
    MyDialogInherited widgetInherited = MyDialogInherited(
        state: this,
        child: AlertDialog(
          actions: <Widget>[
            const MyCancelButton(),
            MyOkButton(
              child: buttonOk,
            )
          ],
          title: const Text('カスタムファイル名'),
          content: const MyTextField(),
        ));
    return Scaffold(
      appBar: AppBar(title: const Text('Show Dialog Sample')),
      body: Center(
        child: OutlinedButton(
            onPressed: () => inputDialog(context, widgetInherited),
            child: const Text('Open Dialog')),
      ),
    );
  }
}
