import 'dart:async';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
//import 'package:intl/date_symbol_data_local.dart';
//import 'package:intl/date_time_patterns.dart';

import 'gps_storage.dart';

String _version = 'ver.0.2.3';

///version0.2.2では、スタートボタンを押した後にダイアログボックスが出てくるが、
///  そのキャンセルボタンを押しても、ログがスタートしたままになってしまう。
///  この[develop][pull request]バージョンではそれを解消します。

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
      home: MyHomePage(
        title: '💛  $_version  💛',
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
  const MyHomePage({
    super.key,
    required this.title,
    required this.storage,
  });

  final String title;
  final GPSStorage storage; //Stateで使う機能をこのウィジェットに格納する

  @override
  State<MyHomePage> createState() => MyHomePageState();

  ///どれもインスタンスを遡る命令群です。

  ///このmethodを呼び出したWidgetをリビルドします
  static MyHomePageState ofWidget(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_Propagation>()!.state;
  }

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

  ///Dialog Boxのためのmenber
  String filenameInDialog = '';
  bool canceled = false;

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
    //inputDialog()の中でstatic filenameInDialogが呼ばれます
    filenameInDialog = await widget.storage.filenameLocationFile;

    try {
      await Future.delayed(const Duration(
          milliseconds:
              100)); //https://dart.dev/tools/linter-rules/use_build_context_synchronously
      if (!context.mounted) throw ('contextがmountされていません');
    } catch (e) {
      print(e);
      return timer;
    }
    TitleDialogState.inputDialog(context).then((value) async {
      ///このstatic methodで
      ///直接MyHomePageのstatic memberであるfilenameDialogに
      ///ファイル名を格納してしまう。

      await widget.storage.createFolders();

      ///filenameOfLocationsを決定する
      widget.storage.storeNameOfLocationFile(filename: filenameInDialog);

      print(canceled);
      print(filenameInDialog);
      if (!canceled) {
        ///GPSをタイマーで定期に起動
        GPSStorage.determinePosition()
            .then((value) => {setLocation(position: value)})
            .catchError((value) => print(value));
        timer = Timer.periodic(const Duration(seconds: 10), _onTime);
        setState(() {
          started = true;
          filenameOfLocations = filenameInDialog ?? 'temporary.csv';
        });
      }
    });

    return timer;
  }

  void _stopGPS() {
    setState(() {
      started = false;
    });
    if (timer == null) return;
    timer!.cancel();
  }

  Widget buttonStartStop = const FloatingActionButtonGPS();

  FloatingActionButtonLocation locationStartStop = CustomizedFloatingLocation(
      FloatingActionButtonLocation.centerFloat, 0, -200);

  @override
  Widget build(BuildContext context) {
    ///とりあえず[build]の中にいれてみた.
    Widget kodomoIndication = const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          WidgetFilename(),
          WidgetYMD(),
          WidgetLon(),
          WidgetLat(),
          TitleDialog(),
        ]);

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


///問題点
///3.読み出されたファイル名が表示されない
///     a.ファイル名が格納されているのか常時表示するwidgetを作成する

/// コンストラクタの後ろの : は initializer list と呼ばれるもので、
// 1. assert
// 2. fieldの初期化
// 3. 他のコンストラクタ(super含む)
// がサポートされており、,でつなげて表現できる。
//最後は ; で締めくくる

/// クロージャーの例
/// func(x)は関数を返します。
///
/// func(x) {
///  return (y){
///   return x+y;
///  }
/// }
///
/// main() {
///  Button entity = new Button(onPressed: func(x))
/// }
///
