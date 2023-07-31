import 'dart:async';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
//import 'package:intl/date_symbol_data_local.dart';
//import 'package:intl/date_time_patterns.dart';

import '../gps_storage/ver0.1.0.dart';

//GPSを操作する
//Storageに格納する
//version0.1.1ではfloatingButtonが点滅してしまう。これを解消する。

void main() {
  runApp(const MyApp());
}

///やることはたくさんある
///storageを[StatefulWidget]に組み込んだり
///DialogBoxからファイル名をにゅうりょくするようにしたり
//[State]クラスの[widget]使ったり

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
      home: MyHomePage(
        title: 'Global Positioning Storager',
        storage: GPSStorage(),
      ),
    );
  }
}

class _Propagation extends InheritedWidget {
  const _Propagation({required super.child, required this.state});

  ///[StatefulWidget]クラスと対になっている[State]クラスのインスタンス
  final MyHomePageState state;

  @override
  bool updateShouldNotify(_Propagation oldWidget) {
    //イベント(状態変化)リスナー
    return true;
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.storage});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final GPSStorage storage;

  @override
  State<MyHomePage> createState() => MyHomePageState();

  ///このmethodを呼び出したWidgetをリビルドします
  static MyHomePageState ofWidget(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_Propagation>()!.state;

  ///このmethodを呼び出して[_Propagation]にアクセスしても
  ///呼び出し元のWidgetはリビルドされません。
  static MyHomePageState ofElement(BuildContext context) =>
      (context.getElementForInheritedWidgetOfExactType<_Propagation>()!.widget
              as _Propagation)
          .state;
}

class MyHomePageState extends State<MyHomePage> {
  double lat = 0.0;
  double lon = 0.0;
  String ymd = 'GMT';
  String filenameOfLocations = 'File name will be shown here.';
  bool started = false;

  String setFilename() {
    String filename = widget.storage.nameFromDialogBox();
    widget.storage.storeNameOfLocationFile(filename: filename);
    return filename;

    ///本来は
    //DialogBoxを表示して、ファイル名の入力を求める
    //参考記事
    //https://qiita.com/y_oshike_n/items/076b54f2e5084bb15dde
  }

  void setLocation({Position? position}) async {
    ymd = GPSStorage.formatTimestamp(timestampJST: position!.timestamp);
    setState(() {
      lon = position.longitude;
    });
    lat = position.latitude;
    //ファイルに格納
    widget.storage.appendPosition(position: position);
  }

  Timer? timer;

  Timer? _onTime(timer) {
    GPSStorage.determinePosition()
        .then((value) => {setLocation(position: value)})
        .catchError((value) => print(value));
    return timer;
  }

  Future<Timer?> _startGPS() async {
    setState(() {
      started = true;
    });
    await widget.storage.createFolders();
    filenameOfLocations = setFilename();
    GPSStorage.determinePosition()
        .then((value) => {setLocation(position: value)})
        .catchError((value) => print(value));
    timer = Timer.periodic(const Duration(seconds: 10), _onTime);
    return timer;
  }

  void _stopGPS() {
    setState(() {
      started = false;
    });
    if (timer == null) return;
    timer!.cancel();
  }

  Widget kodomoIndication = const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: <Widget>[
      WidgetFilename(),
      WidgetYMD(),
      WidgetLon(),
      WidgetLat(),
    ],
  );

  Widget buttonStartStop = const FloatingActionButtonGPS();

  FloatingActionButtonLocation locationStartStop = CustomizedFloatingLocation(
      FloatingActionButtonLocation.centerFloat, 0, -200);

  @override
  Widget build(BuildContext context) {
    ///とりあえず[build]の中にいれてみた.
    Widget kodomoOfPropagation = Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: kodomoIndication,
      ),
      floatingActionButton: buttonStartStop,
      // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButtonLocation: locationStartStop,
    );

    return _Propagation(state: this, child: kodomoOfPropagation);
  }
}

/// ここから、各構成部品

class WidgetFilename extends StatelessWidget {
  const WidgetFilename({super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      MyHomePage.ofWidget(context).filenameOfLocations.toString(),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class WidgetYMD extends StatelessWidget {
  const WidgetYMD({super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      MyHomePage.ofWidget(context).ymd.toString(),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class WidgetLon extends StatelessWidget {
  const WidgetLon({super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      MyHomePage.ofWidget(context).lon.toString(),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class WidgetLat extends StatelessWidget {
  const WidgetLat({super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      MyHomePage.ofWidget(context).lat.toString(),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class DummyButton extends StatelessWidget {
  const DummyButton({super.key});
  @override
  Widget build(BuildContext context) {
    return const Text('Wait a moment....');
  }
}

class FloatingActionButtonGPS extends StatelessWidget {
  const FloatingActionButtonGPS({super.key});

  @override
  Widget build(BuildContext context) {
    final VoidCallback start = MyHomePage.ofElement(context)._startGPS;
    final VoidCallback stop = MyHomePage.ofElement(context)._stopGPS;
    final bool started = MyHomePage.ofWidget(context).started;

    return FloatingActionButton.extended(
      label: Text(started ? 'STOP' : 'START',
          style: Theme.of(context).textTheme.headlineMedium),
      onPressed: started ? stop : start,
    );
  }
}

class CustomizedFloatingLocation extends FloatingActionButtonLocation {
  FloatingActionButtonLocation location;
  double offsetX;
  double offsetY;
  CustomizedFloatingLocation(this.location, this.offsetX, this.offsetY);
  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    Offset offset = location.getOffset(scaffoldGeometry);
    return Offset(offset.dx + offsetX, offset.dy + offsetY);
  }
}
