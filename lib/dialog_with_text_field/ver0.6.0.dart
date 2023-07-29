import 'ver0.6.0_test.dart';
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
    MyWrapperTextfieldDialogState.stateForDialog.setText(controller.text);

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
    String? value = MyWrapperTextfieldDialogState.stateForDialog.getText();

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
  String getText() {
    ///////////////////////////////////////////////////////////////
    ///ここにMyWrapperを通して受信したいtextを得るメソッドを書き込む///
    //////////////////////////////////////////////////////////////
    return keyChild.currentState!.getFilename();
  }

  void setText(fname) {
    //////////////////////////////////////////////////////////
    ///ここにMyWrapperを通してtextを送信するメソッドを書き込む///
    //////////////////////////////////////////////////////////

    keyChild.currentState!.setFilename(fname);
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

abstract class MyWrapperTextfieldDialogImplements {}

///ver0.5.3
///ここではWrapperTextfieldDialogをpackageとして切り離そうと思います。
///ウィジェットの名前も変えようと思います。
///Dialogの部分もWrapperの機能として、一緒に切り離します。
///なぜならば、このWrapperはTextfieldと子孫ウィジェットを繋ぐものだからです。
///
///このウィジェットの使用例はver0.5.2.dartを参考にしてください。
