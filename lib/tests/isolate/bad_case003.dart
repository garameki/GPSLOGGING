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

printPos(int ii, Position pos, SendPort port) {
  print(ii);
  Future(() {
    port.send(
        '-----------------${ii.toString()},${pos.timestamp},${pos.altitude},${pos.longitude}-----------------');
  });
}

int base = 15;

// Top level function
void isolateEntry(List<dynamic> message) async {
  var sendPort = message[0];
  int count = 0;
  void onTime(timer) {
    getPos().then((pos) {
      printPos(count++, pos, sendPort); //このifで余分なevent queueの実行結果をignoreする。
    });
  }

  RootIsolateToken rootToken = message[1];
  BackgroundIsolateBinaryMessenger.ensureInitialized(rootToken);
  while (true) {
    onTime(null);
    await Future.delayed(const Duration(seconds: 1));
  }
}

void otherFunction() async {
  //isolateEntryよりも、こっちのMainのほうがkillされる可能性のほうが高い。
  ReceivePort receivePort = ReceivePort();

  RootIsolateToken rootToken = RootIsolateToken.instance!;
  Isolate isolate = await Isolate.spawn<List<dynamic>>(
      isolateEntry, [receivePort.sendPort, rootToken],
      paused: false);
  isolate.addOnExitListener(receivePort.sendPort, response: 'killed');
  Isolate.current.addOnExitListener(receivePort.sendPort, response: 'finish');
  receivePort.listen((message) {
    print(message);
    if (message == 'finish') isolate.kill();
  });
}
