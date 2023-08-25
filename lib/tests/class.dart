import 'package:flutter/material.dart';

//https://qiita.com/agajo/items/375d5415cb79689a925c

//Tips
//stf+TABでstatefullwidgetのデフォルトが出てくる
//stl+TABでstatelesswidgetのデフォルトが出てくる

///[StatefulWidget]のメンバ[widget]や
///[State]クラスのメンバ[_widget]はどこからくるのかの確認

void main() {
//  runApp(const MyApp());

  MainWidget bob = MainWidget(UniqueKey(), "Bob");
  MainWidget sary = MainWidget(UniqueKey(), "Sary");
  print(bob.name2);
  print(sary.name2);
}

/** 
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
      home: MainWidget(
        'BBB',
        name1: 'HeloHelo',
      ),
    );
  }
}
*/
class CountData extends InheritedWidget {
  const CountData({Key? key, required Widget child, required this.count})
      : super(key: key, child: child);

  final int count;
  @override
  bool updateShouldNotify(CountData oldWidget) {
    return true;
  }
}

class MainWidget extends StatefulWidget {
  MainWidget(Key? key, this.name, {super.key});

  String name2 = name;
  String name;
  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  ///デフォルトコンストラクタ

  @override
  Widget build(BuildContext context) {
    return Text(widget.name);

//    CountData(
  }
}

class MyMessageData extends InheritedWidget {
  const MyMessageData(
      {required Key key, required Widget child, required this.message})
      : super(key: key, child: child);

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
