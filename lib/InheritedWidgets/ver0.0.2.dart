import 'package:flutter/material.dart';
import 'dart:async';

//https://qiita.com/agajo/items/375d5415cb79689a925c

//Tips
//stf+TABでstatefullwidgetのデフォルトが出てくる
//stl+TABでstatelesswidgetのデフォルトが出てくる

///CountDataのcountと
///_MainWidgetのtimeCountの関係性？？？？

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

class CountData extends InheritedWidget {
  const CountData({Key? key, required Widget child, required this.count})
      : assert(child != null),
        super(key: key, child: child);

  final int count;
  @override
  bool updateShouldNotify(CountData oldWidget) {
    return true;
  }
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
    return CountData(count: timeCount, child: widget.child);
  }
}

class MyMessageData extends InheritedWidget {
  const MyMessageData(
      {required Key key, required Widget child, required this.message})
      : assert(child != null),
        super(key: key, child: child);

  final String? message;

  @override
  bool updateShouldNotify(MyMessageData oldWidget) {
    return true;
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
    final count =
        context.dependOnInheritedWidgetOfExactType<CountData>()!.count;
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
