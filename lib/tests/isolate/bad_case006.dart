///isolateとevent queueとmicrotask queueの見直し

import 'dart:async';

import 'package:flutter/material.dart';

import 'dart:isolate';

import 'package:geolocator/geolocator.dart';

import 'dart:io' show Directory, File;
import 'package:path_provider/path_provider.dart';


import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

main() => runApp(const MyApp());

///バックグラウンドでは動作しない

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
Future<void> wait({int seconds = 0}) async {
  await Future.delayed(Duration(seconds: seconds));
}

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
Future<Position> getPos() {
  return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

@pragma('vm:entry-point')
writePos(int ii, Position pos) async {
  Directory directory = await getApplicationSupportDirectory();
  File filePath = File('${directory.path}/location.csv');
  if (filePath.existsSync()) {
    await filePath.create();
  }
  filePath.writeAsString('');
  String before = await filePath.readAsString();
  String line = '${ii.toString()},${pos.timestamp}';
  await filePath.writeAsString('$before$line\n');
//  print(await filePath.readAsString());
}

@pragma('vm:entry-point')
Future<String> readPos() async {
  Directory directory = await getApplicationSupportDirectory();
  File filePath = File('${directory.path}/location.csv');
  if (filePath.existsSync()) {
    await filePath.create();
  }
  return filePath.readAsString();
}

@pragma('vm:entry-point')
void downloaderCallback(
    //String id, DownloadTaskStatus status, int progress) {
    String id,
    dynamic status,
    int progress) {
  print("progress: $progress");
}

@pragma('vm:entry-point')
int base = 5; //最低15秒は必要.そうでないとevent queueに溜まったFuture<Position>の解凍で同時刻に吐く

@pragma('vm:entry-point')
void isolateEntry2(List<dynamic> message) async {
  Timer timer = Timer.periodic(const Duration(seconds: 5), (timer) {
    print('isolate2');
  });
}

// Top level function
@pragma('vm:entry-point')
void isolateEntry(List<dynamic> message) async {
  ///from flutter_isolate example

  print('+++++++++++++++++++++++++++++');
  getTemporaryDirectory().then((dir) async {
    print("isolate2 temporary directory: $dir");

    // await FlutterDownloader.initialize(debug: true);
    // FlutterDownloader.registerCallback(downloaderCallback);

    // final taskId = await FlutterDownloader.enqueue(
    //     url:
    //         "https://raw.githubusercontent.com/rmawatson/flutter_isolate/master/README.md",
    //     savedDir: dir.path);
  });

  bool flagStarted = false;
  bool flagPaused = false;
  int count = 0;
  late Timer timer;

  late SendPort sendPort;
  Timer? onTime(timer) {
    getPos().then((pos) {
      if (flagStarted) {
        writePos(count, pos); //このifで余分なevent queueの実行結果をignoreする。
        if (!flagPaused) {
          sendPort.send(['measured', '']);
        }
        print('isolate : measured! $count');
      }
    }).onError((error, stackTrace) {
      print('$error $stackTrace');
    });
    count++;
    return timer;
  }

  void start() {
    if (flagStarted) {
      timer.cancel();
      throw ('logic conflict');
    }
    //first get position
    onTime(null);
    timer = Timer.periodic(Duration(seconds: base), onTime);
    flagStarted = true;
  }

  void stop() {
    Future(() {
      if (flagStarted) {
        timer.cancel();
        print('canceled');
      } else {
        throw ('logic conflict');
      }
      flagStarted = false;
    });
  }

  const name = 'isolate';

  ReceivePort receivePort = ReceivePort();
  sendPort = message[0];
//  RootIsolateToken rootToken = message[1];
//  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  sendPort.send(['handshake', receivePort.sendPort]);
  receivePort.listen((messageListened) {
    dynamic command = messageListened[0];
    dynamic arg = messageListened[1];
    print('$name : received [0] : $command');
    print('$name : received [1] : $arg');
    switch (command) {
      case 'print':
        print('$name : received message : $arg');
        break;
      case 'start':
        count = 0;
        start();
        break;
      case 'stop':
        stop();
        break;
      case 'exit':
        FlutterIsolate.killAll();
      case 'inactive':
      case 'paused':
        flagPaused = true;
        break;
      case 'resumed':
        flagPaused = false;
        break;
      default:
        print('$name : not available command : $command');
        break;
    }
  });
}

//shake hands

//関連を知りたい
//Isolate.current.
//Capability
//isolate.pause()
//isolate.resume()
//SendPort controlPort_____どういう使い方をするの？
/// Control port used to send control messages to the isolate.
///
/// The control port identifies the isolate.
///
/// An `Isolate` object allows sending control messages
/// through the control port.
///
/// Some control messages require a specific capability to be passed along
/// with the message (see [pauseCapability] and [terminateCapability]),
/// otherwise the message is ignored by the isolate.
/// final SendPort controlPort;
//capabilityの設定はどうするのかな？main側からいじれるのかな？entry側からはisolateインスタンスを自身が持たないから当然いじれないよねぇ。
///
//static run method

//Isolateはspawnされたときにcontrol port とpauseCapabilityとterminateCapabilityを持っている。
//IsolateからpauseCapabilityを発行されてないpause callは無視される
//Isolateは作られたときはcapabilityを有していなくてもよい。必要ならばIsolate.Isolateを使う。
//Isolate ObjectはSendPortでは送ることができない。
//SendPortで送ることができるのはcontrolPortとcapabilityである。
//current isolateはほかのisolateをコントロールする
// controlPortはidentifyのほかに使い道がない！！！
// 内部的に使われるのではないだろうか？
// あるページによれば、eventListerに関連しているらしい。

//getPosの停止再開方法
// その１
// isolate.pauseとisolate.resumeとwhile(true)とawait Durationを使う方法
//  キューにたまっちゃうらしくて時間間隔が０なんてことになってる
// その２
// Timerを回し続けて、aloowGetPos==true の時だけ計測
//  時間間隔はしっかりしているが、再開時にすぐに計測してくれない。
// その３
// spawnとkillを使う
//
// その４
// isolate.puaseとisolate.resumeとTimerを回し続ける
//  わりといけるが、pauseしたあとに1回計測されてしまうのはなぜ？
//
//
//
@pragma('vm:entry-point')
Future<SendPort> mainIsolate(TopWidgetState state) async {
  //isolateEntryよりも、こっちのMainのほうがkillされる可能性のほうが高い。
  const String name = 'main';
  bool flagHandshaked = false;
  late SendPort sendPort;
  ReceivePort receivePort = ReceivePort();
  RawReceivePort rawReceivePort = RawReceivePort((event) {});

//  RootIsolateToken rootToken = RootIsolateToken.instance!;
  FlutterIsolate isolate = await FlutterIsolate.spawn<List<dynamic>>(
      isolateEntry, [receivePort.sendPort, '']);

  await Future.delayed(const Duration(milliseconds: 500)); //handshakeに数秒かかる
  receivePort.listen((messageReceived) {
    dynamic command = messageReceived[0];
    dynamic arg = messageReceived[1];
    print('$name : received [0] : $command');
    print('$name : received [1] : $arg');

    if (!flagHandshaked && command != 'handshake') {
      throw ('Be sure to handshake first!');
    }
    switch (command) {
      case 'handshake':
        sendPort = arg;
        flagHandshaked = true;
        break;
      case 'print':
        print('$name : received message : $arg ');
        break;
      case 'start': //must be sent from widget
        sendPort.send(['start', '']);
        break;
      case 'exit': //must be sent from widget
        sendPort.send(['exit', '']);
        break;
      case 'measured':
//        state.onMeasured();
        break;
      case 'stateChanged':
        sendPort.send([arg, '']);
        break;
      default:
        print('$name : error : $command');
        print('$name : error : $arg');
        break;
    }
  });

  return receivePort.sendPort;
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
//       theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
//       darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const TopWidget(),
    );
  }
}

class TopWidget extends StatefulWidget {
  const TopWidget({super.key});

  @override
  State<TopWidget> createState() => TopWidgetState();
}

class TopWidgetState extends State<TopWidget> with WidgetsBindingObserver {
  TopWidgetState();
  String text = '';
  late SendPort sendPortToMain;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    mainIsolate(this).then((SendPort sendport) {
      sendPortToMain = sendport;
      sendPortToMain.send(['start', '']);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    sendPortToMain.send(['stateChanged', state.name]);
  }

  @override
  void dispose() {
    sendPortToMain.send(['exit', '']);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TopWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    print('*************didUpdateWidget********************************');
    //呼び出されない
  }

  void onMeasured() {
    readPos().then((value) {
      setState(() {
        text = value;
        print('main : read!');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          title: const Text("Material Theme Builder"),
        ),
        body: Center(child: Text(text)));
  }
}



///やっていること
///isolate内で位置情報を計測してファイルに書き込む(Timer使用)
///portを使用してmainに更新を伝える
///mainはそれを受けてファイルを読み出し、画面を更新する
///
///つまり、mainとisolateを同期してみた。

//完全なバックグラウンドでうごきません。