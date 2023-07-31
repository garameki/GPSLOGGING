import 'ver0.6.2_test.dart';
import 'package:flutter/material.dart';

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
class MyWrapperTextfieldDialog extends StatefulWidget {
  const MyWrapperTextfieldDialog({super.key});

  @override
  State<MyWrapperTextfieldDialog> createState() =>
      MyWrapperTextfieldDialogState();

  ///Dialog側からはInheritedWidgetは使えない。
  ///なぜならば、Dialogのツリーが通常のWidgetのツリーとは別物ゆえに
  ///Dialogをさかのぼっても、InheritedWidgetにはたどり着かないから。

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
  //////////////////////////////////////////////////////////
  ///同一ツリーの子孫をアクセスため用のkeyのストック////////////////
  ///操作したいWigetの数だけ[GlobalKey]をここで定義してください/////
  //////////////////////////////////////////////////////////////
  late final GlobalKey<MyGPSState> keyChild; //子for exaple

  @override
  void initState() {
    super.initState();
    ///////////////////////////////////////////////////////////
    ///keyをここで生成してください。/////////////////////////////
    ///////////////////////////////////////////////////////////
    keyChild = GlobalKey<MyGPSState>();
  }

  ///DialogからstateForDialogを通してこの二つの関数を呼び出すことで、
  ///間接的にMyGPSのメソッドをよび出して文字列をやりとりしている。

  ///子からtextを得る
  String _getText() {
    return keyChild.currentState!.getTextForMyWrapperTextfieldDialog();
  }

  ///textを子に送信する
  void _setText(fname) {
    keyChild.currentState!.setTextForMyWrapperTextfieldDialog(fname);
  }

  ///CANCELボタンが押されたことを子に通知
  void _canceled() {
    keyChild.currentState!.canceledForMyWrapperTextfieldDialog();
  }
  ////////////////////////注意////////////////////////////////////////
  ///[key]を通して操作する子孫は[StatefulWidget]でなくてはならない///////
  ///その[State]はprivateではダメです//////////////////////////////////
  ///その[State]の中に操作したいインスタンスメソッドを盛り込んでおきます///
  ////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    stateForDialog = this;
    return _MyWrapperTextfieldDialogInherited(
        state: this,
        //////////////////////////////////////////////////////////////////////////////////
        ///WrapするWidgetをここに挿入する/////////////////////////////////////////////////
        ///keyを渡すならば、child:はStatefulWidgetかつリダイレクトコンストラクタがあること///
        //////////////////////////////////////////////////////////////////////////////////
        child: MyGPS(
          key: keyChild,
        ));
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
