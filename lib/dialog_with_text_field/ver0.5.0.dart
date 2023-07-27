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

Future<void> inputDialog(BuildContext context) async {
  return await showDialog<void>(
      context: context,
      builder: (context) {
        return const _MyInputDialog();
      });
}

class _MyInputDialog extends StatefulWidget {
  const _MyInputDialog();

  @override
  State<_MyInputDialog> createState() => _MyInputDialogState();
}

class _MyInputDialogState extends State<_MyInputDialog> {
  late final TextEditingController controller;

  ///OKボタンのためのmemberとcallbackたち
  bool textfieldIsBlank = true;
  dynamic _callbackNotOk() => null;
  dynamic _callbackOk() {
    ////////////////////////////////////////////////////
    ///ここにMyWrapperを通して操作をしたい命令を書き込む///
    ////////////////////////////////////////////////////
    MyWrapperForInteractionState.stateForDialog.setFilename(controller.text);

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
    ////////////////////////////////////////////////////
    ///ここにMyWrapperを通して操作をしたい命令を書き込む(初期化する)///
    ////////////////////////////////////////////////////
    String? value = MyWrapperForInteractionState.stateForDialog.getFilename();

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

///Dialog側からはアクセスできません。
class _MyWrapperForInteractionInherited extends InheritedWidget {
  const _MyWrapperForInteractionInherited(
      {required super.child, required this.state});
  final MyWrapperForInteractionState state;
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return true;
  }
}

///TextFieldを伴ったDialogをも使えるラッパーです。
///Textfieldの内容を子孫と共有することができます。
///[GlobalKey]と[stateForDialog]を使います。
///子孫へのkeyの継承は[ofElement]を使って[MyWrapperForInteraction]に保存してある
///keyにアクセスしてもらいます。
class MyWrapperForInteraction extends StatefulWidget {
  const MyWrapperForInteraction({super.key});

  @override
  State<MyWrapperForInteraction> createState() =>
      MyWrapperForInteractionState();

  ///Dialog側からはInheritedWidgetは使えない。
  ///なぜならば、Dialogのツリーが通常のWidgetのツリーとは別物だから、
  ///Dialogからさかのぼっても、InheritedWidgetにはたどり着かないから。

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
///たちはMyGPSとMyDialogButtonを繋いて、Filenameをやり取りするのに使われている。
class MyWrapperForInteractionState extends State<MyWrapperForInteraction>
    implements MyWrapperBetweenDialogAndWidget {
  ///以下の二つのメンバはとても重要です。
  ///Dialogからのアクセス用
  static late MyWrapperForInteractionState stateForDialog; //build()の中でthisを入れる
  //////////////////////////////////////////////////////////
  ///同一ツリーの子孫をアクセスため用のkeyのストック
  ///////////////////////////////////////////////////////////
  final keyMyGPS = GlobalKey<MyGPSState>();
  final keySonOfMyGPS = GlobalKey<_MySonOfMyGPSState>();

  static String hi = '';

  @override
  void initState() {
    super.initState();
    print('$keySonOfMyGPS////////////////////////////');
  }

  ////////////////////////////////////////////////////
  ///ここにMyWrapperを通して操作をしたい命令を書き込む///
  ////////////////////////////////////////////////////
  ///DialogからstateForDialogを通してこの二つの関数を呼び出すことで、
  ///間接的にMyGPSのメソッドをよび出してFilenameをやりとりしている。
  String? getFilename() => keyMyGPS.currentState!.getFilename();

  void setFilename(fname) {
    keyMyGPS.currentState!.setFilename(fname);
    keySonOfMyGPS.currentState!.setFilename(fname);
  }
  ////////////////////////注意//////////////////////////////////
  ///[key]を通して操作する子孫は[StatefulWidget]でなくてはならない。
  ///その[State]の方に操作したいインスタンスメソッドを盛り込んでおく。
//////////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    stateForDialog = this;
    return _MyWrapperForInteractionInherited(
        state: this,
        child: MyGPS(
          key: keyMyGPS,
        ));
  }
}

class MyGPS extends StatefulWidget {
  const MyGPS({Key? key}) : super(key: key);

  ///リダイレクトコンストラクタ（Redirecting Constructor）。この形で親のコンストラクタを呼び出す必要がある。
  //「const MyGPS({super.key});」の形ではダメです！！！

  ///Stack Overflow
  ///https://stackoverflow.com/questions/73767079/whats-the-difference-between-using-super-key-and-key-key-superkey-key-i/73767149#73767149
  ///Question
  ///I want to know what's the main difference between using super.key and (Key? key) : super(key: key) in a flutter app, I mean I know they both set key from the super widgets, but why there is 2 types of them, and which is preferred to use.
  ///Answer
  ///super.key is the new syntax, made available in Dart 2.17, which first came with Flutter 3.0. Details are at the release notes: https://dart.dev/guides/whats-new#may-11-2022-217-release
  ///The new syntax is much shorter and cleaner, [but you'll need to understand both forms for years to come.]

  ///上記の違いはある！！！
  ///ということですな。

  @override
  State<MyGPS> createState() => MyGPSState();
}

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
    key = MyWrapperForInteraction.ofElement(context).keySonOfMyGPS;
    print('$key////////////////////////////');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
//        children: <Widget>[Text(_filename), const Text('RENAME FILE')]);
        children: <Widget>[
          Text(_filename),
          OutlinedButton(
              onPressed: () => inputDialog(context),
              child:
                  const Text('Open Dialog-with-textfield to rename filename')),
          MySonOfMyGPS(key),
        ]);
  }
}

class MySonOfMyGPS extends StatefulWidget {
  const MySonOfMyGPS(Key? key) : super(key: key);

  @override
  State<MySonOfMyGPS> createState() => _MySonOfMyGPSState();
}

class _MySonOfMyGPSState extends State<MySonOfMyGPS> {
  String _filename = 'Son_Son_SOn';

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


///ver0.5.0
///ついに子孫WidgetからinputDialog()を開いて、子孫とTextfieldのString dataのやり取りに成功した。


///ver0.4.1
///どうやって本物のGPSと通信するかを考えるdevelopブランチです。
///
///今回のdevelopでは、
///MyGPSのボタンからinputDialog()を呼び出せるようにdevelopします。
///いや
///孫からもinputDialog()を呼び出すことに成功しました。
///
///なので、ver0.4.1=>ver0.5.0に書き換えます。

///abstruct classを作ろうと思うのだが、
///良記事
///https://zenn.dev/iwaku/articles/2020-12-16-iwaku
///今回はやめておく

///よくよく考えると、
///Dialogが必要になるtreeには[MyWrapper]を上層部にかませておけば安心
///だから、ここで考えなければならないことは、ただ一つ。
///子孫から[inputDialog()]を呼べるようにすること！
///
///それは問題ありません。[inputDialog]はグローバルに定義されているので、
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