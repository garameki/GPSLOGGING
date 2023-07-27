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
          child: MyWrapperForInteraction(),
        ));
  }
}

///これをどこからでも呼び出せばtextfield入りのDialogが開きます。
Future<void> textfieldDialog(BuildContext context) async {
  return await showDialog<void>(
      context: context,
      builder: (context) {
        return const MyTextfieldDialog();
      });
}

///textfieldDialog()の挙動を記述してあるWidgetStatefulWidgetです。
class MyTextfieldDialog extends StatefulWidget {
  const MyTextfieldDialog({super.key});

  @override
  State<MyTextfieldDialog> createState() => _MyTextfieldDialogState();
}

class _MyTextfieldDialogState extends State<MyTextfieldDialog> {
  late final TextEditingController controller;

  ///OKボタンのためのmemberとcallbackたち
  bool textfieldIsBlank = true;
  dynamic _callbackNotOk() => null;
  dynamic _callbackOk() {
    MyWrapperForInteractionState.stateForDialog.setText(controller.text);

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
    String? value = MyWrapperForInteractionState.stateForDialog.getText();

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
class _MyWrapperForInteractionInherited extends InheritedWidget {
  const _MyWrapperForInteractionInherited(
      {required super.child, required this.state});
  final MyWrapperForInteractionState state;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

///textFieldを伴ったDialogを持つラッパーです。
///textfieldの内容をこのWidgetを通して子孫と共有することができます。
///共有には、
///[GlobalKey]と[stateForDialog]を使います。
///子孫へのkeyの継承は[ofElement]を使って[MyWrapperForInteraction]に保存してある
///keyを取得してもらい、子孫に渡します。
class MyWrapperForInteraction extends StatefulWidget {
  const MyWrapperForInteraction({super.key});

  @override
  State<MyWrapperForInteraction> createState() =>
      MyWrapperForInteractionState();

  ///Dialog側からはInheritedWidgetは使えない。
  ///なぜならば、Dialogのツリーが通常のWidgetのツリーとは別物ゆえに
  ///Dialogをさかのぼっても、InheritedWidgetにはたどり着かないから。

  ///一方、同じツリーの子孫からは[of]で[state]が参照可能である。
  ///以下の[ofWidget]と[ofElement]とwidgetのlifecycleについても学ぶ必要がある。
  static ofWidget(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_MyWrapperForInteractionInherited>()!
      .state;

  static ofElement(BuildContext context) => (context
          .getElementForInheritedWidgetOfExactType<
              _MyWrapperForInteractionInherited>()!
          .widget as _MyWrapperForInteractionInherited)
      .state;
}

///[build]関数を見てもらえばわかるが、このMyWrapperForInteraction関連のwidget
///たちはMyGPSとMyDialogButtonを繋いて、textをやり取りするのに使われている。
class MyWrapperForInteractionState extends State<MyWrapperForInteraction>
    implements MyWrapperBetweenDialogAndWidget {
  ///以下[stateForDialog]と[key***]の二つのメンバはとても重要です。
  ///Dialogからのアクセス用です。変更不可です。
  static late MyWrapperForInteractionState stateForDialog; //build()の中でthisを入れる
  //////////////////////////////////////////////////////////
  ///同一ツリーの子孫をアクセスため用のkeyのストック////////////////
  ///操作したいWigetの数だけ[GlobalKey]をここで定義してください/////
  //////////////////////////////////////////////////////////////
  late final GlobalKey<MyGPSState> keyMyGPS; //子for exaple
  late final GlobalKey<MySonOfMyGPSState> keySonOfMyGPS; //孫for example

  @override
  void initState() {
    super.initState();
    ///////////////////////////////////////////////////////////
    ///keyをここで生成してください。/////////////////////////////
    ///////////////////////////////////////////////////////////
    keyMyGPS = GlobalKey<MyGPSState>();
    keySonOfMyGPS = GlobalKey<MySonOfMyGPSState>();
  }

  ///DialogからstateForDialogを通してこの二つの関数を呼び出すことで、
  ///間接的にMyGPSのメソッドをよび出して文字列をやりとりしている。
  String getText() {
    ///////////////////////////////////////////////////////////////
    ///ここにMyWrapperを通して受信したいtextを得るメソッドを書き込む///
    //////////////////////////////////////////////////////////////
    return keyMyGPS.currentState!.getFilename();
  }

  void setText(fname) {
    //////////////////////////////////////////////////////////
    ///ここにMyWrapperを通してtextを送信するメソッドを書き込む///
    //////////////////////////////////////////////////////////

    keyMyGPS.currentState!.setFilename(fname);
    keySonOfMyGPS.currentState!.setFilename(fname);
  }
  ////////////////////////注意////////////////////////////////////////
  ///[key]を通して操作する子孫は[StatefulWidget]でなくてはならない///////
  ///その[State]はprivateではダメです//////////////////////////////////
  ///その[State]の中に操作したいインスタンスメソッドを盛り込んでおきます///
  ////////////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    stateForDialog = this;
    return _MyWrapperForInteractionInherited(
        state: this,
        //////////////////////////////////
        ///WrapするWidgetをここに挿入する///
        //////////////////////////////////
        child: MyGPS(
          key: keyMyGPS,
        ));
  }
}

///子Widget
///キーを渡すWidgetはStatefulWidgetでなくてはならない。
///コンストラクタはリダイレクトコンストラクタの形をとらなくてはならない。
class MyGPS extends StatefulWidget {
  const MyGPS({Key? key}) : super(key: key);

  @override
  State<MyGPS> createState() => MyGPSState();
}

///[key]を使ってアクセスを受ける場合にはクラス名はprivateではいけません。
class MyGPSState extends State<MyGPS> {
  String _filename = 'PAROPARO_SAN';

  late GlobalKey key;
  String getFilename() {
    return _filename;
  }

  void setFilename(fname) {
    ///[setState()]は[staticメソッド]の中には入れられない
    setState(() {
      _filename = fname;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //////////////////////////////////////////////////////////////////////
    ///statefulwidgetの子にキーを渡す場合には[initState]の中でキーを取得する//
    ///statelesswidgetの場合にはコンストラクタの初期化時点でやる?/////////////
    //////////////////////////////////////////////////////////////////////
    key = MyWrapperForInteraction.ofElement(context).keySonOfMyGPS;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
//        children: <Widget>[Text(_filename), const Text('RENAME FILE')]);
        children: <Widget>[
          Text(_filename),
          OutlinedButton(
              onPressed: () => textfieldDialog(context),
              child:
                  const Text('Open Dialog-with-textfield to rename filename')),
          MySonOfMyGPS(key),
        ]);
  }
}

///孫Widget
class MySonOfMyGPS extends StatefulWidget {
  const MySonOfMyGPS(Key? key) : super(key: key);

  @override
  State<MySonOfMyGPS> createState() => MySonOfMyGPSState();
}

///[key]を使ってアクセスを受ける場合にはクラス名はprivateではいけません。
class MySonOfMyGPSState extends State<MySonOfMyGPS> {
  String _filename = 'Son_Son_SOn';

  ///////////////////////////////////////////////////////////////////
  ///Wrapperで使われるインスタンスメソッドはStateの中に定義しておく///////
  ///////////////////////////////////////////////////////////////////

  String? getFilename() => _filename;
  setFilename(value) {
    setState(() {
      _filename = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_filename);
  }
}

abstract class MyWrapperBetweenDialogAndWidget {}//It's procrastinated to make abstract class.


///ver0.5.3
///ここではWrapperForInteractionをpackageとして切り離そうと思います。
///ウィジェットの名前も変えようと思います。
///Dialogの部分もWrapperの機能として、一緒に切り離します。
///なぜならば、このWrapperはTextfieldと子孫ウィジェットを繋ぐものだからです。

///ver0.5.2
///切りはなす前の注釈を充実させました。

///ver0.5.0
///ついに子孫WidgetからtextfieldDialog()を開いて、子孫とTextfieldのString dataのやり取りに成功した。


///ver0.4.1
///どうやって本物のGPSと通信するかを考えるdevelopブランチです。
///
///今回のdevelopでは、
///MyGPSのボタンからtextfieldDialog()を呼び出せるようにdevelopします。
///いや
///孫からもtextfieldDialog()を呼び出すことに成功しました。
///
///なので、ver0.4.1=>ver0.5.0に書き換えます。

///abstruct classを作ろうと思うのだが、
///良記事
///https://zenn.dev/iwaku/articles/2020-12-16-iwaku
///今回はやめておく

///よくよく考えると、
///Dialogが必要になるtreeには[MyWrapper]を上層部にかませておけば安心
///だから、ここで考えなければならないことは、ただ一つ。
///子孫から[textfieldDialog()]を呼べるようにすること！
///
///それは問題ありません。[textfieldDialog]はグローバルに定義されているので、
///importさえしておけば、どこからでも呼び出せます。

///次の問題は子ではなく子孫にキーをMyWrapperから渡す方法です。
///ためしに[of]を使ってみましょう。
///MySonOfMyGPSをstatefulWidgetで作って、ofでkeyを取得したら、
///MySonOfMyGPSState内のメソッドを実行できました。
///成功です。
///ただ、気になるのはMySonOfMyGPSのofの最後にある[keySonOfMyGPS]が「定義されていません」
///と、表示されてしまうことです。これは、VSCodeのバグなのでしょうか？
///でも、動くのでいいですけど、Bagfixに支障が出る恐れがあります。


///ver0.4.0
///説明
///DialogとほかのWidgetとの通信

///なんちゃってGPS Widgetをつくって、それとの通信をしました。
///具体的にはファイル名のやりとりです。

///ポイント
///親から子のメソッド呼び出しはGlobalkeyを使いました。
///直接の子ではないAlertDialogからは[staticメンバ]を使って、
///   [build()]の際に[this]をそのメンバに入れて、直接[State]にある
///   インスタンスメソッドにアクセスするようにしました。

///Ridirecting Constructorや、Initializing list等については以下に詳しいです。
///https://dev.classmethod.jp/articles/about_dart_constructors/#item_01-03

///Keyについては以下を参考にしました。ありがとうございます。
///https://zenn.dev/flutteruniv_dev/articles/908d4069197e0c