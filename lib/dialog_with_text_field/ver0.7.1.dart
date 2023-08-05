import 'package:flutter/material.dart';
import '../gps/ver0.4.1.dart';

///これをどこからでも呼び出せばtextfield入りのDialogが開きます。
Future<void> textfieldDialog(BuildContext context) async {
  return await showDialog<void>(
      context: context,
      builder: (context) {
        return const _MyTextfieldDialog();
      });
}

///textfieldDialog()の挙動を記述してあるWidgetStatefulWidgetです。
class _MyTextfieldDialog extends StatefulWidget {
  const _MyTextfieldDialog();

  @override
  State<_MyTextfieldDialog> createState() => _MyTextfieldDialogState();
}

class _MyTextfieldDialogState extends State<_MyTextfieldDialog> {
  late final TextEditingController controller;

  ///OKボタンのためのmemberとcallbackたち
  bool textfieldIsBlank = true;
  dynamic _callbackNotOk() => null;
  dynamic _callbackOk() {
    MyWrapperTextfieldDialogState.stateForDialog._setText(controller.text);
    //////////////
    ///カスタム///
    /////////////
    MyWrapperTextfieldDialogState.stateForDialog._startGPS();

    Navigator.pop(context);
  }

  ///CANCELボタンのためのcallback
  dynamic _callbackCANCEL() {
    MyWrapperTextfieldDialogState.stateForDialog._canceled();
    Navigator.pop(context);
  }

  dynamic callbackOfOkButton;

  void isNotBlank() {
    if (textfieldIsBlank) setState(() {});
    textfieldIsBlank = false;
    callbackOfOkButton = _callbackOk;
  }

  void isBlank() {
    setState(() {});
    textfieldIsBlank = true;
    callbackOfOkButton = _callbackNotOk;
  }

  final reg = RegExp(r'[\\\/:\*\?\"<>\|]');

  @override
  void initState() {
    super.initState();

    ///////////////////////////////////////
    ///Textfieldに初めに出したい文字を取得する
    ///////////////////////////////////////
    //String value = 'example.csv';
    String? value = MyWrapperTextfieldDialogState.stateForDialog._getText();

    controller = TextEditingController(text: value);
    if (controller.text.isEmpty) {
      isBlank();
    } else {
      isNotBlank();
    }
    controller.addListener(() {
      if (reg.hasMatch(controller.text)) {
        int len = controller.text.length;
        String stringNew = controller.text.substring(0, len - 1);
        controller.text = stringNew;
        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length));
        print(stringNew);
      }

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
          onPressed: _callbackCANCEL,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.white),
              foregroundColor: MaterialStateProperty.all(Colors.blue),
            ),
            onPressed: callbackOfOkButton,
            //これだと[AlertDialog]が表示されなくなるので注意.
            // onPressed: textfieldIsBlank
            //     ? _callbackNotOk()
            //     : _callbackOk(), //callbackOfOkButton,
            child: Text(textfieldIsBlank ? 'Inabled' : 'OK')),
      ],
      title: const Text('カスタムファイル名'),
    );
  }
}

///Dialog側からはofを使ってもこの[InheritedWidget]にはアクセスできません。
class _MyWrapperTextfieldDialogInherited extends InheritedWidget {
  const _MyWrapperTextfieldDialogInherited(
      {required super.child, required this.state});
  final MyWrapperTextfieldDialogState state;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

///textFieldを伴ったDialogを持つラッパーです。
///textfieldの内容をこのWidgetを通して子孫と共有することができます。
///共有には、
///[GlobalKey]と[stateForDialog]を使います。
///子孫へのkeyの継承は[ofElement]を使って[MyWrapperTextfieldDialog]に保存してある
///keyを取得してもらい、子孫に渡します。

/////////////////////////////////////////
///ここで子クラスのジェネリクスを宣言して///
/////////////////////////////////////////
typedef GenericsInMyWrapperTextfieldDialog = MyGPSState;

class MyWrapperTextfieldDialog extends StatefulWidget {
  const MyWrapperTextfieldDialog(
      {super.key, required this.keyChild, required this.child});

  final Widget child;
  final GlobalKey<GenericsInMyWrapperTextfieldDialog> keyChild;

  @override
  State<MyWrapperTextfieldDialog> createState() =>
      MyWrapperTextfieldDialogState();

  ///Dialog側からはInheritedWidgetは使えない。

  ///一方、同じツリーの子孫からは[of]で[state]が参照可能である。
  ///以下の[ofWidget]と[ofElement]とwidgetのlifecycleについても学ぶ必要がある。
  static ofWidget(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_MyWrapperTextfieldDialogInherited>()!
      .state;

  static ofElement(BuildContext context) => (context
          .getElementForInheritedWidgetOfExactType<
              _MyWrapperTextfieldDialogInherited>()!
          .widget as _MyWrapperTextfieldDialogInherited)
      .state;
}

///[build]関数を見てもらえばわかるが、このMyWrapperTextfieldDialog関連のwidget
///たちはMyGPSとMyDialogButtonを繋いて、textをやり取りするのに使われている。
class MyWrapperTextfieldDialogState extends State<MyWrapperTextfieldDialog> {
  ///以下[stateForDialog]と[key***]の二つのメンバはとても重要です。
  ///Dialogからのアクセス用です。変更不可です。
  static late MyWrapperTextfieldDialogState stateForDialog; //build()の中でthisを入れる

  ///DialogからstateForDialogを通してこの二つの関数を呼び出すことで、
  ///間接的にMyGPSのメソッドをよび出して文字列をやりとりしている。

  ///子からtextを得る
  String _getText() {
    return widget.keyChild.currentState!.getTextForMyWrapperTextfieldDialog();
  }

  ///textを子に送信する
  void _setText(fname) {
    widget.keyChild.currentState!.setTextForMyWrapperTextfieldDialog(fname);
  }

  ///CANCELボタンが押されたことを子に通知
  void _canceled() {
    widget.keyChild.currentState!.canceledForMyWrapperTextfieldDialog();
  }

  ///追加のメソッド
  void _startGPS() {
    widget.keyChild.currentState!.startGPS();
    TopWidget.ofElement(context).rebuildActionButtonGPS();
  }
  ////////////////////////注意////////////////////////////////////////
  ///[key]を通して操作する子孫は[StatefulWidget]でなくてはならない///////
  ///その[State]はprivateではダメです//////////////////////////////////
  ///その[State]の中に操作したいインスタンスメソッドを盛り込んでおきます///
  ////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    stateForDialog = this;
    return _MyWrapperTextfieldDialogInherited(state: this, child: widget.child);
  }
}

///wrappingする子ウィジェットのStateウィジェットにはこれをimplementsしてもらう。
abstract class MyWrapperTextfieldDialogImplements {
  ///TEXTのやり取りに関するメソッド
  String getTextForMyWrapperTextfieldDialog();
  void setTextForMyWrapperTextfieldDialog(value);

  ///CANCELボタンが押された時のメソッド
  void canceledForMyWrapperTextfieldDialog();

  ///実装の例
  ///String _filename;
  ///
  ///String getTextForMyWrapperTextfieldDialog() => _filename;
  ///void setTextForMyWrapperTextfieldDialog(value) {
  ///setState((){
  ///   _filename = value;
  /// });
  ///}
}

///ver0.7.0
///gps/ver0.4.1に実装するためのバージョンです。
///gps/ver0.4.1とは強結合です。
