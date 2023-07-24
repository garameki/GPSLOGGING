import 'package:flutter/material.dart';
import 'dart:async';

//https://qiita.com/agajo/items/375d5415cb79689a925c

//Tips
//stf+TABでstatefullwidgetのデフォルトが出てくる
//stl+TABでstatelesswidgetのデフォルトが出てくる

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
      home: MainWidget(),
    );
  }
}

///いまのところ、[InheritedWidget]を使う理由は、TREEの下層Widgetから、
///「[context.dependOnInheritedWidgetOfWxactType<T>()]が使える」
///ということである！
class CountData extends InheritedWidget {
  const CountData({Key? key, required Widget child, required this.count})
      : assert(child != null),
        super(key: key, child: child);

  ///[InheritedElement]が保持している何らかのデータ（この場合[count]）に
  ///変更が入ったときにこのWidgetを参照しようとしている子孫に[_dirty]フラグを
  ///立てる（再buildさせる）という役割がある
  final int count;
  @override
  bool updateShouldNotify(CountData oldWidget) {
    return oldWidget.count % 2 == 0;
  }

  ///staticを使うことで、インスタンスに関係なくクラスの関数として
  ///コールすることができる！！つまりこれが
  ///クラスメソッド！！！
  static CountData? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CountData>();
}

class MainWidget extends StatefulWidget {
  MainWidget({super.key});

  final Widget child = Scaffold(
    appBar: AppBar(),
    body: WidgetA(UniqueKey()),
  );

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

///STATEのライフサイクル
///https://tech-rise.net/what-is-lifecycle-of-state/

class _MainWidgetState extends State<MainWidget> {
  ///デフォルトコンストラクタ

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeCount++;
        print(timeCount);
      });
    });
  }

  int timeCount = 0;
  Timer? timer;

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CountData(
        //timeCountが更新されるたびにsetStateされ、[build()]が呼ばれ、ここで[CountData]インスタンスが作り直される！！！
        count: timeCount,
        child: widget.child); //inheritedwidgetのインスタンスを改めてを作り直している
  }
}

class WidgetA_B extends StatelessWidget {
//A,Bは子を表す
  const WidgetA_B(Key? key) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WidgetA(UniqueKey()),
        WidgetB(UniqueKey()),
      ],
    );
  }
}

class WidgetA extends StatelessWidget {
  const WidgetA(Key? key) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print('A build');

    final count = CountData.of(context)!.count;
    return Text('count: $count');
  }
}

class WidgetB extends StatelessWidget {
  const WidgetB(Key? key) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const Text("B");
  }
}
