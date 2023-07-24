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
  final TextEditingController controller =
      TextEditingController(text: 'example');
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  con() => context;

  String textTest = 'INIT';

  ///OKボタンのためのインスタンス
  bool textfieldIsBlank = true;
  dynamic _callbackNotOk() => null;
  dynamic _callbackOk() {
    Navigator.pop(context);
  }

  dynamic callbackOfOkButton;

  @override
  void initState() {
    super.initState();
  }

  ///OKボタンの文字色
  Text textNotOk = const Text('NOT', style: TextStyle(color: Colors.grey));
  Text textOk = const Text('OK', style: TextStyle(color: Colors.black));
  late Text textOfOkButton;

  //OKボタンの色
  TextStyle styleNotOk = const TextStyle(color: Colors.grey);
  TextStyle styleOk = const TextStyle(color: Colors.black);
  late TextStyle styleOfOkButton;

  Future<void> inputDialog(BuildContext context) async {
    return await showDialog<void>(
        context: context,
        builder: (context) {
          ///[StatefulBuilder]を使います
          ///
          ///
          ///
          ///
          return StatefulBuilder(
              builder: ((BuildContext context, StateSetter setState) {
            void isNotBlank() {
              if (textfieldIsBlank) MyDialog.of(context).setState(() {});
              textfieldIsBlank = false;
              callbackOfOkButton = _callbackOk;
              textTest = 'false';
            }

            void isBlank() {
              MyDialog.of(context).setState(() {});
              textfieldIsBlank = true;
              callbackOfOkButton = _callbackNotOk;
              textTest = 'true';
            }

            controller.addListener(() {
              if (controller.text.isEmpty) {
                isBlank();
              } else {
                isNotBlank();
              }
            });

            //isNotBlank();

            return MyDialogInherited(
                state: this,
                child: AlertDialog(
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
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.blue),
                        ),
                        onPressed: callbackOfOkButton,
                        //これだと[AlertDialog]が表示されなくなる.
                        // onPressed: textfieldIsBlank
                        //     ? _callbackNotOk()
                        //     : _callbackOk(), //callbackOfOkButton,
                        child: Text(textfieldIsBlank ? 'NOT' : 'OK')),
                  ],
                  title: const Text('カスタムファイル名'),
                ));
          }));
        });
  }

  @override
  Widget build(BuildContext context) {
    print('MyDialogState build() $textfieldIsBlank');

    /////////ここの部分はExportできるようにしないといけないなぁ。//////////////
    ///DialogBox出現用のボタンのインスタンスを作成する。
    ///このなかでもインスタンス作って見たけどダメだった。
    return OutlinedButton(
        onPressed: () => inputDialog(context), child: Text(textTest));
  }
}

///説明
///TextFieldを有するDialogBoxです。
///TextFieldの中身がEmptyになると[OK]ボタンが薄くなります。
///なりません。
///

///参考記事
///https://note.com/hatchoutschool/n/nda33cfa5f2d4
///

///とりあえず、[StatefulBuilder]をつかって、その[builder()]の中に
///[Widget]を使わずに全部突っ込んだらできました。
///
///しかし、
///FlutterError (setState() called after dispose(): _StatefulBuilderState#21f92(lifecycle state: defunct, not mounted)
/// This error happens if you call setState() on a State object for a widget that no longer appears in the widget tree (e.g., whose parent widget no longer includes the widget in its build). This error can occur when code calls setState() from a timer or an animation callback.
/// The preferred solution is to cancel the timer or stop listening to the animation in the dispose() callback. Another solution is to check the "mounted" property of this object before calling setState() to ensure the object is still in the tree.
/// This error might indicate a memory leak if setState() is being called because another object is retaining a reference to this State object after it has been removed from the tree. To avoid memory leaks, consider breaking the reference to this object during dispose().)
///というエラーを食らった


///新たな疑問
///Widgetにする意味は何なのだろうか？
///
///

///ver0.2.2
///InheritedWidgetを[AlertDialog]の上層にかませてみたが、[of()]が[null]なのであきらめ


