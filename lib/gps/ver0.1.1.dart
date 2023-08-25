import 'dart:async';

import 'package:flutter/material.dart';

import 'package:geolocator/geolocator.dart';
//import 'package:intl/date_symbol_data_local.dart';
//import 'package:intl/date_time_patterns.dart';

import 'package:intl/intl.dart' show DateFormat;
import 'dart:io' show Directory, File;
import 'package:path_provider/path_provider.dart';
//GPSを操作する
//Storageに格納する

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

///やることはたくさんある
///storageを[StatefulWidget]に組み込んだり
///[_counter]を変えたり
///appendするようにしたり
///DialogBoxからファイル名をにゅうりょくするようにしたり
//[State]クラスの[widget]使ったり

///To Do
///[readFile]で引数が''の場合は再度ポップアップで入力してもらう
///
///ファイル名も保存する
class GPSStorage {
  GPSStorage();

  ///接頭辞の説明
  ///path...絶対パス
  ///folda...フォルダの名前(親フォルダは含まない)
  ///filename...ファイルの名前(フォルダは含まない)
  ///filepath...ファイル名まで含めた絶対パス
  ///foldapath...フォルダまでの絶対パス

  ///sync/awaitを使うような静的な定数を持たないようにする.

  static const String _foldaNameOfLocationFile = 'filenames/';
  static const String _filenameNameOfLocationFile = 'filenameLocationFile.txt';
  static const String _foldaLocationFiles = 'locations/';
  final String _filenameLocationFile = 'dummy.csv';

  ///このアプリの専用フォルダのルートパス
  Future<String> get _pathApplication async {
    //final Directory directory = await getApplicationDocumentsDirectory();
    final Directory directory = await getApplicationSupportDirectory();
    return '${directory.path}/'; //最後に/を入れて返却
  }

  ///生成します
  ///1.Locationファイルのファイルネームをしまうフォルダ
  ///2.Locationファイルをためるフォルダ
  ///3.Locationファイルの名前をしまうファイル
  createFolders() async {
    final String pathApp = await _pathApplication;

    //ディレクトリの生成
    Directory folda = Directory('$pathApp$_foldaNameOfLocationFile');
    await folda.create(recursive: true);

    //ディレクトリの生成
    folda = Directory('$pathApp$_foldaLocationFiles');
    await folda.create(recursive: true);

    //ファイルの生成
    File file =
        File('$pathApp$_foldaNameOfLocationFile$_filenameNameOfLocationFile');
    await file.create();
    var systemTempDir = Directory(pathApp);

    // List directory contents, recursing into sub-directories,
    // but not following symbolic links.
    await for (var entity
        in systemTempDir.list(recursive: true, followLinks: false)) {
      //await Directory(entity.path).delete(recursive: true);
      print(entity.path);
    }
  }

  String formatPositionToLine(Position position) {
    double lon = position.longitude;
    double lat = position.latitude;
    DateTime? timestamp =
        position.timestamp!.add(const Duration(hours: 9) * -1);
    String time = '${DateFormat('yyyy-MM-ddTHH:mm:ss.000').format(timestamp)}Z';
    return '$time,$lon,$lat';
  }

  ///現在、位置情報の保存に使っているファイルへの絶対パス
  Future<String> get _filepathLocationFile async {
    String filename = '';
    String pathApp = await _pathApplication;
    String filepath =
        '$pathApp$_foldaNameOfLocationFile$_filenameNameOfLocationFile';
    File file = File(filepath);

    try {
      bool isExist = await file.exists();
      if (!isExist) throw ('ファイルが存在しません。$filepath');
      //ファイルやフォルダが存在しない場合は読み込めません。
      filename = await file.readAsString();
      if (filename == '') throw ('ファイル名が格納されていません。');
    } catch (e) {
      print('in _filepathLocationFile');
      print(e);
      print('in _filepathLocationFile');
    }
    return '$pathApp$_foldaLocationFiles$filename';
  }

  ///現在使っている位置情報ファイルの内容の読み出し
  Future<String> readPositions() async {
    String contents = '';
    String filepath = await _filepathLocationFile;
    File file = File(filepath);
    bool isExist = await file.exists();
    if (!isExist) {
      //ファイルが存在しない
      contents = "";
    } else {
      contents = await file.readAsString();
    }
//    print(contents);
    return contents;
  }

  ///現在使っている位置情報ファイルへの書き込み
  void storePositions({required String contents}) async {
    String filepath = await _filepathLocationFile;
    File file = File(filepath);
    file.writeAsString(contents.toString());
  }

  ///現在使っている位置情報ファイルの最後に位置情報１行を追加する
  void appendPosition({required Position position}) async {
    String contentsBefore = await readPositions();
    String linePosition = formatPositionToLine(position);
    storePositions(contents: '$contentsBefore$linePosition\n');
  }

  void storeNameOfLocationFile(
      {String filename = _filenameNameOfLocationFile}) async {
    String pathApp = await _pathApplication;
    String filepath =
        '$pathApp$_foldaNameOfLocationFile$_filenameNameOfLocationFile';
    File file = File(filepath);

    try {
      bool isExist = await file.exists();
      if (!isExist) throw ('ファイルが存在しません。$filepath');
      //ファイルやフォルダが存在しない場合は読み込めません。
      await file.writeAsString(filename);
    } catch (e) {
      print('in _filepathLocationFile');
      print(e);
      print('in _filepathLocationFile');
    }
  }

  String _nameFromDialogBox() {
    return _filenameLocationFile;
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
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        storage: GPSStorage(),
      ),
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
  double lat = 0;
  double lon = 0;
  String ymd = '';
  String filenameOfLocations = '';
  bool started = false;

  String setFilename() {
    String filename = widget.storage._nameFromDialogBox();
    widget.storage.storeNameOfLocationFile(filename: filename);
    return filename;

    ///本来は
    //DialogBoxを表示して、ファイル名の入力を求める
    //参考記事
    //https://qiita.com/y_oshike_n/items/076b54f2e5084bb15dde
  }

  void setLocation({Position? position}) async {
    ymd =
        '${DateFormat('yyyy-MM-ddTHH:mm:ss.000').format(position!.timestamp!)}Z';
    //？？？setState()のブロックの中にymdが入ってないのにTextWidgetが更新されるのはなぜ？
    setState(() {
      lon = position.longitude;
    });
    lat = position.latitude;
    //ファイルに格納
    widget.storage.appendPosition(position: position);
  }

  Timer? timer;

  Timer? _onTime(timer) {
    _determinePosition()
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
    _determinePosition()
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
              filenameOfLocations,
              style: const TextStyle(fontSize: 15),
            ),
            Text(
              ymd,
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
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          started ? 'STOP' : 'START',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        onPressed: started ? _stopGPS : _startGPS,
        tooltip: 'Increment',
        //child: const Icon(Icons.add),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButtonLocation: CustomizedFloatingLocation(
          FloatingActionButtonLocation.centerFloat, 0, -200),
    );
  }
}
