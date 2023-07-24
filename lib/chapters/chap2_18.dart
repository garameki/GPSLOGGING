import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher.dart';
//import 'package:flutter/src/rendering/box.dart';

void main() {
  runApp(const MyApp());
}

/**
 * Widget bind()内で自作オブジェクトクラスのインスタンスを作成して使ってる！
 * だから、StatelessWidgetやStatefullWidgetを継承して自作のidgetクラスを
 * 作ってるんだ！！
 * だから、クラスとして自作オブジェクトを作るんだ。
 */

/// list 2.18
Widget getProgressBar(double remainingDays) {
  //ウィジェット重ねるウィジェットStackを返します
  return Stack(children: [
    SizedBox(
      child: LinearProgressIndicator(
        minHeight: 30.0,
        backgroundColor: Colors.blue,
        value: remainingDays,
      ),
    ),
    Align(
        alignment: Alignment.center,
        child: Text("残り${(1 - remainingDays).toStringAsFixed(1)}%",
            style: const TextStyle(fontSize: 20, color: Colors.white)))
  ]);
}

/// list 2.19
/// ただのWidget
/// Stateとか関係ない
Widget getNowLoading() {
  //ウィジェットを返します
  return Column(children: [
    Center(
        child: Container(
            padding: const EdgeInsets.all(10.0),
            child: const SizedBox(
                width: 100,
                height: 100,
                child: CircularProgressIndicator(
                  strokeWidth: 10.0,
                ))))
  ]);
}

//list2.20
//StatefulWidgetはStateと対で使う！
///list2.20 StatefulWidget class
class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key, required this.title}) : super(key: key);

  final String title;

  //StatefulWidgetクラスはStateクラスを作る機能を持つ
  @override
  State<MyDrawer> createState() => _MyDrawer();
}

///list2.20 State class
class _MyDrawer extends State<MyDrawer> {
  bool _flag = false;
  @override
  Widget build(BuildContext context) {
//    return getNowLoading()
    return Expanded(
        child: Drawer(
      child: ListView(padding: EdgeInsets.zero, children: <Widget>[
        SwitchListTile(
            title: const Text("記念日"),
            value: _flag,
            onChanged: (bool value) {
              setState(() {
                _flag = value;
              });
            }),
      ]),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      if (_counter >= 10) _counter = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            //if (_counter == 0) getNowLoading(),
            if (_counter > 0) getProgressBar(_counter / 10.0),
            getProgressBar(_counter / 100.0),
            const MyDrawer(title: "mattene"),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
