import 'dart:async';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/date_time_patterns.dart';

import 'package:intl/intl.dart';
//GPSを操作する

//参考ドキュメント
//1.geolocator 9.0.2
//https://pub.dev/packages/geolocator
//2.【Flutter】スマホの位置情報を取得するやり方
//https://zenn.dev/namioto/articles/3abb0ccf8d8fb6

//android/src/main/AndroidManifest.xmlに以下の３行を<manifest>タグの後ろに加える
//<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
//<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
//<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

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

///権限の様子を見てエラーを返す
///しかし、「常に許可」等の確認画面は出ませんので
///実装がまた必要になります。
Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.222');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    return Future.error('Location permissions denied.333');
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied.We can not request permissions.444');
  }

  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

class _MyHomePageState extends State<MyHomePage> {
  Position? _counter;
  double? lat;
  double? lon;

  String? ymd;

  void setLocation(value) {
    final now = DateTime.now().add(const Duration(hours: 9) * -1);
    ymd = '${DateFormat('yyyy-MM-ddTHH:mm:ss.000').format(now)}Z';
    setState(() {
      _counter = value;
      lon = _counter!.longitude;
      lat = _counter!.latitude;
    });
  }

  Timer? _onTime(time) {
    _determinePosition()
        .then((value) => {setLocation(value)})
        .catchError((value) => print(value));
    return time;
  }

  Timer? timer;

  Timer? _startGPS() {
    timer = Timer.periodic(const Duration(seconds: 10), _onTime);
    return timer;
  }

  void _stopGPS() {
    if (timer == null) return;
    timer!.cancel();
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
              Text(
                '$ymd',
                style: const TextStyle(fontSize: 15),
              ),
              Text(
                '$lat',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Text(
                '$lon',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          children: [
            FloatingActionButton(
              onPressed: _stopGPS,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
            FloatingActionButton(
              onPressed: _startGPS,
              tooltip: 'Increment',
              child: const Icon(Icons.add),
            ),
          ], // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}
