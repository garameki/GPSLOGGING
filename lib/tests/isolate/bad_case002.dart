import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:isolate';

import 'package:geolocator/geolocator.dart';

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

printPos(int ii, Position pos) {
  print(
      '-----------------${ii.toString()},${pos.timestamp},${pos.altitude},${pos.longitude}-----------------');
}

int base = 15;

// Top level function
void isolateEntry(List<dynamic> message) async {
  bool flagStarted = false;
  int count = 0;
  late Timer timer;
  Timer? onTime(timer) {
    getPos().then((pos) {
      if (flagStarted) {
        printPos(count++, pos); //このifで余分なevent queueの実行結果をignoreする。
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
      } else {
        throw ('logic conflict');
      }
      flagStarted = false;
    });
  }

  final name = Isolate.current.debugName;

  ReceivePort receivePort = ReceivePort();
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
  SendPort sendPort = message[0];
  RootIsolateToken rootToken = message[1];
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  sendPort.send(['handshake', receivePort.sendPort]);

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
// isolate.pauseとisolate.resumeとwhile(true)とawait Durationを使う
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
void otherFunction() async {
  //isolateEntryよりも、こっちのMainのほうがkillされる可能性のほうが高い。
  final String? name = Isolate.current.debugName;
  bool handshaked = false;
  late SendPort sendPort;
  ReceivePort receivePort = ReceivePort();
  RawReceivePort rawReceivePort = RawReceivePort((event) {});

  RootIsolateToken rootToken = RootIsolateToken.instance!;
  Isolate isolate = await Isolate.spawn<List<dynamic>>(
      isolateEntry, [receivePort.sendPort, rootToken],
      paused: true);

  await Future.delayed(const Duration(seconds: 1)); //handshakeに数秒かかる
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
          handshaked = true;
          isolate.addOnExitListener(
              receivePort.sendPort, //entryの挙動。entryがmainに対してsendする。
              response: ['print', 'EXITED']);
          isolate.addErrorListener(receivePort.sendPort);
          break;
        case 'print':
          print('$name : received message : $arg ');
          break;
        default:
          print('$name : error : $command');
          print('$name : error : $arg');
          break;
      }
    });
  });
  await Future.delayed(const Duration(seconds: 1)); //handshakeに数秒かかる
  if (handshaked) {
    sendPort.send(['print', 'Hello']);
  } else {
    throw ('$name : can not Hello because of not having handshaked');
  }
  int PAUSE = base * 3;
  int PLAY = base * 3;

  Future(() async {
    print('start');
    sendPort.send(['start', '']);
    await Future.delayed(Duration(seconds: PLAY));
    print('stop');
    sendPort.send(['stop', '']);
    await Future.delayed(Duration(seconds: PAUSE));
    print('start');
    sendPort.send(['start', '']);
    await Future.delayed(Duration(seconds: PLAY));
    print('stop');
    sendPort.send(['stop', '']);
    await Future.delayed(Duration(seconds: PLAY));
    print('start');
    sendPort.send(['start', '']);
    await Future.delayed(Duration(seconds: PLAY));
    print('stop');
    sendPort.send(['stop', '']);
  });
}
