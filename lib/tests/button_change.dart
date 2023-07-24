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
      body: const Center(child: MyButtonTest()),

      ///ここにwidgetを入れる
    );
  }
}

////////////////////////////////////////////////////////////

class MyButtonTestInherited extends InheritedWidget {
  const MyButtonTestInherited(
      {super.key, required super.child, required this.state});
  final MyButtonTestState state;

  @override
  bool updateShouldNotify(MyButtonTestInherited oldWidget) {
    return true;
  }
}

class MyButtonTest extends StatefulWidget {
  const MyButtonTest({super.key});

  static MyButtonTestState ofWidget(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<MyButtonTestInherited>()!
      .state;

  static MyButtonTestState ofElement(BuildContext context) => (context
          .getElementForInheritedWidgetOfExactType<MyButtonTestInherited>()!
          .widget as MyButtonTestInherited)
      .state;

  @override
  State<MyButtonTest> createState() => MyButtonTestState();
}

class MyButtonTestState extends State<MyButtonTest> {
  bool flag = true;
  String moji = 'NULL';
  Function? callback;
  String text = '';
  void setFlag() {
    if (flag) {
      flag = false;
      moji = 'false';
      callback = null;
      text = 'Don\'t';
    } else {
      flag = true;
      moji = 'true';
      callback = () {
        print('me');
      };
      text = 'PUSH';
    }
    print(flag);
    setState(() {}); //???
  }

  @override
  Widget build(BuildContext context) {
    return MyButtonTestInherited(
        state: this,
        child: const Column(children: <Widget>[
          MyButtonA(),
          MyLCD(),
          MyButtonB(),
        ]));
  }
}

///////////////////////////////////////////////////////////

class MyButtonA extends StatelessWidget {
  const MyButtonA({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        MyButtonTest.ofElement(context).setFlag();
      },
      child: const Text('PUSH'),
    );
  }
}

class MyLCD extends StatelessWidget {
  const MyLCD({super.key});

  @override
  Widget build(BuildContext context) {
    print('LCD');
    return Text(MyButtonTest.ofWidget(context).moji);
  }
}

class MyButtonB extends StatelessWidget {
  const MyButtonB({super.key});

  @override
  Widget build(BuildContext context) {
    print('BUTTON-B');
    return ElevatedButton(
      onPressed: () => MyButtonTest.ofElement(context).callback!(),
      //child: const MyButtonB_LCD(),//変化しない
      child: Text(MyButtonTest.ofWidget(context).text), //変化する
    );
  }
}



///ボタンのTEXTも変化させてみた
