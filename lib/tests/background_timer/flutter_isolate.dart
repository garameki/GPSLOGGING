import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:path_provider/path_provider.dart';

//import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

import 'dart:isolate';

// Future<Position> getPos() {
//   return Geolocator.getCurrentPosition();
// }

@pragma('vm:entry-point')
void isolate2(String arg) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  Location location = Location();
  location.enableBackgroundMode(enable: true);
  bool serviceEnabled;
  PermissionStatus permissionGranted;
  // while (true) {
  //   await Future.delayed(Duration(seconds: 1));
  //   try {
  //     serviceEnabled = await location.serviceEnabled();
  //     if (serviceEnabled) break;
  //   } catch (e) {
  //     print('waiting');
  //   }
  // }
  // if (!serviceEnabled) {
  //   serviceEnabled = await location.requestService();
  //   if (!serviceEnabled) {
  //     return null;
  //   }
  // }

  // permissionGranted = await location.hasPermission();
  // if (permissionGranted == PermissionStatus.denied) {
  //   permissionGranted = await location.requestPermission();
  //   if (permissionGranted != PermissionStatus.granted) {
  //     return null;
  //   }
  // }

  Timer.periodic(const Duration(seconds: 1), (timer) {
    print("Timer Running From Isolate 2");

    ///thenなら70個
    ///microtaskなら15個
    ///ぐらい溜まるとtaskが止まる
    ///
    ///thenを実行していても止まる
    ///
    ///nativeコードでcomputeを通してやってみますかね。
    ///引数が問題だから、それをクリアするためにnativeコードに
    ///挑戦しますかー

    ///そもそも、1秒ごとにgetPosしているのに、なんで同じ時刻が連続で続いてしまうの？？
    ///それを解明するのが先だ！！
    ///UIが表示されているとそうなる。
    ///UIを隠すときちんと1秒ごとに位置が計測される。
    ///
    ///printをコメントアウトすると、止まらない！！！！
    ///止まるときと止まらないときがある！！！
    ///
    ///かくじつに言えることはqueueではなく、
    ///時間で止まる！！
    ///間隔を250msにしたら、240ぐらいで止まった。
    ///
    ///
    ///時間になったらpopしてpushしてみよう
    ///
    ///
    ///
    ///
    ///

    scheduleMicrotask(() {
      location.getLocation().then((value) {
        print(value.time.toString());
      }).catchError((e) {
        print(e);
      });
//       getPos().then((value) {
//         /////////thenを使うとどうしてもqueueがいっぱいで止まる？？？
//         print(value.timestamp.toString());
// //        value.timestamp.toString();
//       });
    });
  });
}

@pragma('vm:entry-point')
void isolate1(String arg) async {
  await FlutterIsolate.spawn(isolate2, "hello2");
  print('${Isolate.current.debugName} in isolate1');

  getTemporaryDirectory().then((dir) {
    print("isolate1 temporary directory: $dir");
  });
  Timer.periodic(
      const Duration(seconds: 1), (timer) => print("Timer Running From Isolate 1"));
}

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    print('------------------------------');
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: const AppWidget()));
  }
}

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  Future<void> _run() async {
    print(
        "Temp directory in main isolate : ${(await getTemporaryDirectory()).path}");
    final isolate = await FlutterIsolate.spawn(isolate1, "hello");
    Timer(const Duration(seconds: 5), () {
      print("Pausing Isolate 1");
      isolate.pause();
    });
    Timer(const Duration(seconds: 5), () {
      print("Killing Isolate 1");
      isolate.kill();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('**********************************');
    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
      ElevatedButton(
        onPressed: _run,
        child: const Text('Spawn isolates'),
      ),
      ElevatedButton(
        child: const Text('Kill all running isolates'),
        onPressed: () async {
          await FlutterIsolate.killAll();
        },
      ),
    ]);
  }
}
