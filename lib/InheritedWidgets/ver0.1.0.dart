import 'package:flutter/material.dart';

//https://qiita.com/agajo/items/375d5415cb79689a925c

///
///
///
///このコードではWidgetAはリビルドされません。
///すなわち[InheritedWidget.count]は増えても表示は変わらず0のままです。
///
///
///
///

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const TopWidget());
  }
}

///[_InheritT1T2B2]を管理する[StatefulWidget]です。
class TopWidget extends StatefulWidget {
  const TopWidget({super.key});

  @override
  State<TopWidget> createState() => StateTopWidget();

  ///このmethodを呼び出したWidgetをリビルドします
  static StateTopWidget ofWidget(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_InheritT1T2B1>()!.state;

  ///このmethodを呼び出して[_InheritT1T2B1]にアクセスしても
  ///呼び出し元のWidgetはリビルドされません。
  static StateTopWidget ofElement(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<_InheritT1T2B1>()!.widget
              as _InheritT1T2B1)
          .state;
}

///[InheritT1T2B1]を管理する[State]クラスです。
class StateTopWidget extends State<TopWidget> {
  ///作り直したいWidgetをreturnする
  @override
  Widget build(BuildContext context) {
    Widget kodomo = const Column(
      children: [WidgetA(), WidgetB(), ButtonA()],
    );
    return _InheritT1T2B1(state: this, child: kodomo);
  }

  ///[initState]や[setState]を置けるのは[State]クラスの中だけ
  @override
  void initState() {
    super.initState();
  }

  int count = 0;

  ///[setState]を使えるのは[State]の中だけです。
  ///   [countup]を外部から呼ぶ仕組みが必要です。
  ///staticメソッドの中にsetState()を入れることはできません。
  ///   インスタンスメソッドの中に しか setState()を入れることはできません。

  void countup() {
    setState(() {
      count++;
    });
  }
}

///[Javascript]的にとらえると
///[InheritedWidget]は状態変化をイベントとするイベントリスナーである！！！

///[InheritedWidget]
///setState()置けない
class _InheritT1T2B1 extends InheritedWidget {
  const _InheritT1T2B1({required super.child, required this.state});

  ///[StatefulWidget]クラスと対になっている[State]クラスのインスタンス
  final StateTopWidget state;

  @override
  bool updateShouldNotify(_InheritT1T2B1 oldWidget) {
    //イベント(状態変化)リスナー
    return true;
  }
}

///WidgetAの表示も変化させるためここにも[StatefulWidget]を組み込む！！！
class WidgetA extends StatelessWidget {
  const WidgetA({super.key});

  @override
  Widget build(BuildContext context) {
    print('WidgetA');
    return Text(TopWidget.ofWidget(context)!.count.toString());
  }

  ///ここに[setState()]を置きたいのだが、きっかけの関数がない
  ///イベントドリブンを検知できるとかあればいいのだが、Elementはいじれないし、
  ///やっぱり、[InheritedWidget]の[updateShouldNotify]を置く必要がある！
}

class WidgetB extends StatelessWidget {
  const WidgetB({super.key});
  @override
  Widget build(BuildContext context) {
    print('WidgetB');
    return const Text("B");
  }
}

class ButtonA extends StatefulWidget {
  const ButtonA({super.key});

  @override
  State<ButtonA> createState() => _ButtonA();
}

class _ButtonA extends State<ButtonA> {
  @override
  Widget build(BuildContext context) {
    print('ButtonA');
    return FloatingActionButton(
        onPressed: _pressFunc,
        tooltip: 'Incremernt',
        child: Icon(icons[count]));
  }

  ///[ButtonA]の初期状態を記録
  @override
  void initState() {
    super.initState();
  }

  VoidCallback? _pressFunc() {
    setState(() {
      if (++count > 2) count = 0;
      print(count);
    });

    //下のどちらを使ってもすぐ上のsetState()と一緒になって
    //１回のWidget書き換えで済んでしまう。
    TopWidget.ofWidget(context).countup();
//    TopWidget.ofElement(context).countup();

    return null;
  } //クラスメソッド

  int count = 0;

  static List<IconData> icons = <IconData>[
    Icons.add_sharp,
    Icons.thirteen_mp_sharp,
    Icons.settings_remote
  ];
}
