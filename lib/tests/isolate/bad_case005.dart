///isolateとevent queueとmicrotask queueの見直し

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'dart:isolate';

import 'package:geolocator/geolocator.dart';

import 'dart:io' show Directory, File;
import 'package:path_provider/path_provider.dart';

import '../../colorScheme/color_schemes.g.dart';

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
  await filePath.create();
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
  await filePath.create();
  return filePath.readAsString();
}

@pragma('vm:entry-point')
int base = 3; //最低15秒は必要.そうでないとevent queueに溜まったFuture<Position>の解凍で同時刻に吐く

// Top level function
@pragma('vm:entry-point')
void isolateEntry(List<dynamic> message) async {
  bool flagStarted = false;
  int count = 0;
  late Timer timer;
  Timer? onTime(timer) {
    getPos().then((pos) {
      if (flagStarted) {
        writePos(count++, pos); //このifで余分なevent queueの実行結果をignoreする。
        print('isolate : measured!');
      }
    }).onError((error, stackTrace) {
      print('$error $stackTrace');
    });
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
      } else
        throw ('logic conflict');
      flagStarted = false;
    });
  }

  final name = Isolate.current.debugName;

  ReceivePort receivePort = ReceivePort();
  SendPort sendPort = message[0];
  RootIsolateToken rootToken = message[1];
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  sendPort.send(['handshake', receivePort.sendPort]);
  receivePort.listen((messageListened) {
    scheduleMicrotask(() {
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
        default:
          print('$name : not available command : $command');
          break;
      }
    });
  });

  //throw ('ooooooooooooo error oooooooooooo');
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
Future<Isolate> mainIsolate() async {
  //isolateEntryよりも、こっちのMainのほうがkillされる可能性のほうが高い。
  final String? name = Isolate.current.debugName;
  bool flagHandshaked = false;
  late SendPort sendPort;
  ReceivePort receivePort = ReceivePort();
  RawReceivePort rawReceivePort = RawReceivePort((event) {});

  RootIsolateToken rootToken = RootIsolateToken.instance!;
  Isolate isolate = await Isolate.spawn<List<dynamic>>(
      isolateEntry, [receivePort.sendPort, rootToken],
      paused: true);

  await Future.delayed(const Duration(seconds: 2)); //handshakeに数秒かかる
  isolate.resume(isolate.pauseCapability as Capability);
  receivePort.listen((messageReceived) {
    Future(() {
      dynamic command = messageReceived[0];
      dynamic arg = messageReceived[1];
      print('$name : received [0] : $command');
      print('$name : received [1] : $arg');

      switch (command) {
        case 'handshake':
          sendPort = arg;
          flagHandshaked = true;
          isolate.addOnExitListener(
              receivePort.sendPort, //entryの挙動。entryがmainに対してsendする。
              response: ['print', '${isolate.debugName} is EXITED']);
          isolate.addErrorListener(receivePort.sendPort);
          Isolate.current
              .addOnExitListener(receivePort.sendPort, response: ['exit', '']);
          break;
        case 'print':
          print('$name : received message : $arg ');
          break;
        case 'exit':
          isolate.kill();
          break;
        default:
          print('$name : error : $command');
          print('$name : error : $arg');
          break;
      }
    });
  });
  await Future.delayed(const Duration(milliseconds: 500)); //handshakeに数秒かかる
  if (flagHandshaked) {
    sendPort.send(['print', 'Hello']);
  } else {
    throw ('$name : can not Hello because of not having handshaked');
  }
  int PAUSE = base * 3;
  int PLAY = base * 3;

  Future(() async {
    print('start');
    sendPort.send(['start', '']);
    // await Future.delayed(Duration(seconds: PLAY));
    // print('stop');
    // sendPort.send(['stop', '']);
    // await Future.delayed(Duration(seconds: PAUSE));
    // print('start');
    // sendPort.send(['start', '']);
    // await Future.delayed(Duration(seconds: PLAY));
    // print('stop');
    // sendPort.send(['stop', '']);
    // await Future.delayed(Duration(seconds: PLAY));
    // print('start');
    // sendPort.send(['start', '']);
    // await Future.delayed(Duration(seconds: PLAY));
    // print('stop');
    // sendPort.send(['stop', '']);
  });

  return isolate;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
      home: const TopWidget(),
    );
  }
}

class TopWidget extends StatefulWidget {
  const TopWidget({super.key});

  @override
  State<TopWidget> createState() => _TopWidgetState();
}

class _TopWidgetState extends State<TopWidget> {
  _TopWidgetState();
  String text = '';
  late Timer timer;
  late Isolate isolate;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mainIsolate().then((value) {
      isolate = value;
    });
    timer = Timer.periodic(const Duration(seconds: 1), onTime);
  }

  @override
  void dispose() {
    timer.cancel();
    isolate.kill(priority: Isolate.beforeNextEvent);
    super.dispose();
  }

  Timer? onTime(Timer? timer) {
    setState(() {
      readPos().then((value) {
        text = value;
        print('main : read!');
      });
    });
    return timer;
  }

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}



///やっていること
///isolate内で位置情報を計測してファイルに書き込む(Timer使用)
///それをmain isolateで読み出して画面に表示する(Timer使用)
///つまり、mainとisolateは同期してません。
///
///readするたびにsetStateしているので無駄です。

//完全なバックグラウンドでうごきません。
