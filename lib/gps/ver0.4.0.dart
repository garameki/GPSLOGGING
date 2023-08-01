import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../gps_storage/ver0.2.0.dart';
import '../dialog_with_text_field/ver0.7.0.dart';

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
      home: const TopWidget(),
    );
  }
}

class TopWidgetInherited extends InheritedWidget {
  const TopWidgetInherited(
      {super.key, required super.child, required this.state});
  final TopWidgetState state;
  @override
  bool updateShouldNotify(TopWidgetInherited oldWidget) => true;
}

class TopWidget extends StatefulWidget {
  const TopWidget({super.key});

  @override
  State<TopWidget> createState() => TopWidgetState();

  static TopWidgetState ofWidget(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TopWidgetInherited>()!
        .state;
  }

  static TopWidgetState ofElement(BuildContext context) => (context
          .getElementForInheritedWidgetOfExactType<TopWidgetInherited>()!
          .widget as TopWidgetInherited)
      .state;
}

class TopWidgetState extends State<TopWidget> {
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  //ここに各Widgetを取り持つKEYやメソッドを入れる
  //@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

  //between floatingActionButton and MYGPSState
  final _keyActionButtonGPS = GlobalKey<FloatingActionButtonGPSState>();
  final _keyMyGPS = GlobalKey<MyGPSState>();
  get flagStarted => _keyMyGPS.currentState?.flagStarted;
  startGPS() => _keyMyGPS.currentState?._openDialog(); //ここでDialogを開く
  stopGPS() => _keyMyGPS.currentState?._stopGPS();
  rebuildActionButtonGPS() =>
      _keyActionButtonGPS.currentState?.rebuild(); //ボタンの再描画

  @override
  Widget build(BuildContext context) {
    Scaffold scaffold = Scaffold(
      appBar: AppBar(title: const Text('💛  GPS  💛')),
      body: MyWrapperTextfieldDialog(
          keyChild: _keyMyGPS, child: MyGPS(_keyMyGPS)),
      floatingActionButton: FloatingActionButtonGPS(_keyActionButtonGPS),
      floatingActionButtonLocation: CustomizedFloatingLocation(
          FloatingActionButtonLocation.centerFloat, 0, 0),
    );
    return TopWidgetInherited(state: this, child: scaffold);
  }
}

class _MyGPSInherited extends InheritedWidget {
  const _MyGPSInherited({required super.child, required this.state});

  ///[StatefulWidget]クラスと対になっている[State]クラスのインスタンス
  final MyGPSState state;

  @override
  bool updateShouldNotify(_MyGPSInherited oldWidget) {
    //イベント(状態変化)リスナー
    return true;
  }
}

class MyGPS extends StatefulWidget {
  const MyGPS(Key? key) : super(key: key);

  @override
  State<MyGPS> createState() => MyGPSState();

  static MyGPSState ofWidget(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_MyGPSInherited>()!.state;
  }

  static MyGPSState ofElement(BuildContext context) => (context
          .getElementForInheritedWidgetOfExactType<_MyGPSInherited>()!
          .widget as _MyGPSInherited)
      .state;
}

class MyGPSState extends State<MyGPS>
    with MyGPSStorage
    implements MyWrapperTextfieldDialogImplements {
  double lat = 0.0;
  double lon = 0.0;
  String ymd = 'GMT';
  String filename = 'hello.csv';

  bool flagStarted = false;

  ////////////////////////////////////////////////
  ///implementsされたクラスのメソッドを装備する//////
  ////////////////////////////////////////////////
  @override
  String getTextForMyWrapperTextfieldDialog() => filename;
  @override
  void setTextForMyWrapperTextfieldDialog(value) {
    setState(() {
      filename = value;
      flagStarted = true;
    });
  }

  @override
  void canceledForMyWrapperTextfieldDialog() {
    setState(() {
      flagStarted = false;
    });
  }

  @override
  void initState() {
    super.initState();

    createFolders();
    filenameLocationFile.then((value) {
      filename = value;
    });
  }

  void setLocation({required Position position}) async {
    setState(() {
      ymd = formatTimestamp(timestampJST: position.timestamp);
      lon = position.longitude;
      lat = position.latitude;
    });
    //ファイルに格納
    appendPosition(position: position);
  }

  Timer? timer;

  Timer? _onTime(timer) {
    determinePosition()
        .then((value) => {setLocation(position: value)})
        .catchError((value) => print(value));
    return timer;
  }

  void _openDialog() {
    textfieldDialog(context);
  }

  Future<Timer?> startGPS() async {
    ///初回のdetect
    determinePosition()
        .then((value) => {setLocation(position: value)})
        .catchError((value) => print(value));

    ///定期にpositionをdetect
    timer = Timer.periodic(const Duration(seconds: 10), _onTime);
    setState(() {
      flagStarted = true;
    });

    return timer;
  }

  void _stopGPS() {
    setState(() {
      flagStarted = false;
      if (timer == null) return;
      timer!.cancel();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _MyGPSInherited(
        state: this,
        child: const Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              WidgetFilename(),
              WidgetYMD(),
              WidgetLon(),
              WidgetLat(),
            ])));
  }
}

/// ここから、各構成部品

class WidgetFilename extends StatelessWidget {
  const WidgetFilename({super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      MyGPS.ofWidget(context).filename.toString(),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class WidgetYMD extends StatelessWidget {
  const WidgetYMD({super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      MyGPS.ofWidget(context).ymd.toString(),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class WidgetLon extends StatelessWidget {
  const WidgetLon({super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      MyGPS.ofWidget(context).lon.toString(),
      style: Theme.of(context).textTheme.headlineMedium,
    );
  }
}

class WidgetLat extends StatelessWidget {
  const WidgetLat({super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      MyGPS.ofWidget(context).lat.toString(),
      style: Theme.of(context).textTheme.headlineMedium,
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

class FloatingActionButtonGPS extends StatefulWidget {
  const FloatingActionButtonGPS(Key? key) : super(key: key);

  @override
  State<FloatingActionButtonGPS> createState() =>
      FloatingActionButtonGPSState();
}

class FloatingActionButtonGPSState extends State<FloatingActionButtonGPS> {
  late final VoidCallback start;
  late final VoidCallback stop;
  bool _flagStarted = false;

  ///dialogによるファイル名の取得も含めた
  ///ログの開始準備
  startGPS() {
    setState(() {
      TopWidget.ofWidget(context).startGPS();
    });
  }

  ///ログを止める
  stopGPS() {
    setState(() {
      TopWidget.ofWidget(context).stopGPS();
    });
  }

  ///再描画のために他からcallされる。
  rebuild() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _flagStarted = TopWidget.ofElement(context).flagStarted;
    return FloatingActionButton.extended(
      label: Text(_flagStarted ? 'STOP LOGGING' : 'START LOGGING',
          style: Theme.of(context).textTheme.headlineMedium),
      onPressed: _flagStarted ? stopGPS : startGPS,
    );
  }
}

///ver0.4.0
///ここからはtextfieldDialogはコールしません。
///
///主に状態をやり取りするメソッドを導入しました。

///課題
///1.ログをやめたら表示部を表示しないようにする。
///2.ボタンの色を赤と緑のペアにする。


