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
        body: Center(
          child: MyParent2(child: MyChild(MyParent2.keyChild)),
        ));
  }
}

class MyParent2 extends StatefulWidget {
  const MyParent2({super.key, required this.child});

  final Widget child;
  static final GlobalKey<MyChildState> keyChild = GlobalKey<MyChildState>();

  @override
  State<MyParent2> createState() => MyParent2State();
}

class MyParent2State extends State<MyParent2> {

  getText() => MyParent2.keyChild.currentState?.getTextForParent();
  setText(value) => MyParent2.keyChild.currentState?.setTextForParent(value);


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class MyChild extends StatefulWidget implements {
  const MyChild(Key? key) : super(key: key);

  @override
  State<MyChild> createState() => MyChildState();
}

///Childウィジェットには[MyParent2Implements]を[implements]すること
class MyChildState extends State<MyChild> implements MyParent2Implements{
  @override
  getTextForParent() => 'gagaga';
  @override
  setTextForParent(value) => 'gugugu';

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

abstract class MyParent2Implements {
  String getTextForParent();

  setTextForParent(value);
}
