import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

const simpleTaskKey = "be.tramckrijte.workmanagerExample.simpleTask";
const rescheduledTaskKey = "be.tramckrijte.workmanagerExample.rescheduledTask";
const failedTaskKey = "be.tramckrijte.workmanagerExample.failedTask";
const simpleDelayedTask = "be.tramckrijte.workmanagerExample.simpleDelayedTask";
const simplePeriodicTask =
    "be.tramckrijte.workmanagerExample.simplePeriodicTask";
const simplePeriodic1HourTask =
    "be.tramckrijte.workmanagerExample.simplePeriodic1HourTask";
@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
Future<void> wait({int seconds = 0}) async {
  await Future.delayed(Duration(seconds: seconds));
}

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
Future<void> getPos({String thread = 'any', int number = 999}) async {
  ///https://stackoverflow.com/questions/54783316/flutter-geolocator-package-not-retrieving-location
  Position pos = await Geolocator.getCurrentPosition(
      forceAndroidLocationManager: true,
      desiredAccuracy: LocationAccuracy.high);
  print(
      '-----------------$thread,${number.toString()},${pos.timestamp},${pos.altitude},${pos.longitude}-----------------');
}

@pragma(
    'vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('${task.toString()}+++++++++++++++++++++++++++++');
    print('${inputData.toString()}+++++++++++++++++++++++++++');
    switch (task) {
      case simpleTaskKey:
        print(
            "$simpleTaskKey was executed. inputData = $inputData///////////////");
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("test", true);
        print("Bool from prefs: ${prefs.getBool("test")}///////////////");
        final String key = inputData!['key']!;
        int ii = 0;
        while (true) {
          await getPos(thread: key, number: ii++);
          await wait(seconds: 60);
        }
        break;
    }

    return Future.value(true);
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Flutter WorkManager Example"),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  "Plugin initialization",
                  style: Theme.of(context).textTheme.headline5,
                ),
                ElevatedButton(
                  child: Text("Start the Flutter background service"),
                  onPressed: () {
                    Workmanager().initialize(
                      callbackDispatcher,
                      isInDebugMode: true,
                    );
                  },
                ),
                SizedBox(height: 16),

                //This task runs once.
                //Most likely this will trigger immediately
                ElevatedButton(
                  child: Text("Register OneOff Task"),
                  onPressed: () {
                    String key = UniqueKey().toString();
                    Workmanager().registerOneOffTask(
                      'Name:$key',
                      simpleTaskKey,
                      tag: 'Tag:$key',
                      inputData: <String, dynamic>{
                        'key': 'Inp:$key',
                      },
                    );
                  },
                ),
                SizedBox(height: 16),
                Text(
                  "Task cancellation",
                  style: Theme.of(context).textTheme.headline5,
                ),
                ElevatedButton(
                  child: Text("Cancel All"),
                  onPressed: () async {
                    await Workmanager().cancelAll();
                    print('Cancel all tasks completed///////////////');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

///2023.8.16
///リリースモードで、アプリを閉じて、バックグラウンドを試したが、やっぱり途中で止まる。

///sleep時間25分
///電源off時間25分
///に設定した場合
// connecting to VM Service at ws://127.0.0.1:54536/qMamfB9tem0=/ws
// D/EGL_emulation(31658): app_time_stats: avg=2049.64ms min=96.11ms max=4003.17ms count=2
// D/EGL_emulation(31658): app_time_stats: avg=77.91ms min=14.16ms max=1289.90ms count=21
// D/CompatibilityChangeReporter(31658): Compat change id reported: 194532703; UID 10183; state: ENABLED
// D/CompatibilityChangeReporter(31658): Compat change id reported: 253665015; UID 10183; state: DISABLED
// D/CompatibilityChangeReporter(31658): Compat change id reported: 263076149; UID 10183; state: DISABLED
// D/FlutterGeolocator(31658): Geolocator foreground service connected
// D/FlutterGeolocator(31658): Initializing Geolocator services
// D/FlutterGeolocator(31658): Flutter engine connected. Connected engine count 2
// W/FlutterJNI(31658): FlutterJNI.loadLibrary called more than once
// I/ResourceExtractor(31658): Found extracted resources res_timestamp-1-1691483507935
// W/FlutterJNI(31658): FlutterJNI.prefetchDefaultFontManager called more than once
// W/FlutterJNI(31658): FlutterJNI.init called more than once
// I/flutter (31658): be.tramckrijte.workmanagerExample.simpleTask+++++++++++++++++++++++++++++
// I/flutter (31658): {key: Inp:[#00e03]}+++++++++++++++++++++++++++
// I/flutter (31658): be.tramckrijte.workmanagerExample.simpleTask was executed. inputData = {key: Inp:[#00e03]}///////////////
// I/flutter (31658): Bool from prefs: true///////////////
// I/flutter (31658): -----------------Inp:[#00e03],0,2023-08-08 08:32:02.561Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],1,2023-08-08 08:33:06.564Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],2,2023-08-08 08:34:10.565Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],3,2023-08-08 08:35:14.568Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],4,2023-08-08 08:36:18.569Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],5,2023-08-08 08:37:18.688Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],6,2023-08-08 08:38:19.654Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],7,2023-08-08 08:39:20.507Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],8,2023-08-08 08:40:21.377Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],9,2023-08-08 08:41:22.387Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],10,2023-08-08 08:42:23.235Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],11,2023-08-08 08:43:24.126Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],12,2023-08-08 08:44:24.957Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],13,2023-08-08 08:45:25.802Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],14,2023-08-08 08:46:26.633Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],15,2023-08-08 08:47:27.472Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],16,2023-08-08 08:48:28.304Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],17,2023-08-08 08:49:29.213Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],18,2023-08-08 08:50:30.145Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],19,2023-08-08 08:51:31.016Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],20,2023-08-08 08:52:31.861Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],21,2023-08-08 08:53:32.688Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],22,2023-08-08 08:54:33.526Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],23,2023-08-08 08:55:34.419Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],24,2023-08-08 08:56:35.261Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],25,2023-08-08 08:57:36.175Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],26,2023-08-08 08:58:37.018Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],27,2023-08-08 08:59:37.858Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],28,2023-08-08 09:00:38.693Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],29,2023-08-08 09:01:39.584Z,104.5,139.383-----------------
// D/FlutterGeolocator(31658): Flutter engine disconnected. Connected engine count 1
// D/FlutterGeolocator(31658): Disposing Geolocator services
// E/FlutterGeolocator(31658): Geolocator position updates stopped
// E/FlutterGeolocator(31658): There is still another flutter engine connected, not stopping location service
// I/WM-WorkerWrapper(31658): Work [ id=b03e4c4c-66de-46d5-8e72-26039261af2c, tags={ be.tramckrijte.workmanager.BackgroundWorker, Tag:[#00e03] } ] was cancelled
// I/WM-WorkerWrapper(31658): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(31658): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(31658): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(31658): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(31658): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(31658): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(31658): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(31658): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(31658): 	at java.lang.Thread.run(Thread.java:1012)
// D/FlutterGeolocator(31658): Geolocator foreground service connected
// D/FlutterGeolocator(31658): Initializing Geolocator services
// D/FlutterGeolocator(31658): Flutter engine connected. Connected engine count 2
// I/flutter (31658): be.tramckrijte.workmanagerExample.simpleTask+++++++++++++++++++++++++++++
// I/flutter (31658): {key: Inp:[#00e03]}+++++++++++++++++++++++++++
// I/flutter (31658): be.tramckrijte.workmanagerExample.simpleTask was executed. inputData = {key: Inp:[#00e03]}///////////////
// I/flutter (31658): Bool from prefs: true///////////////
// I/flutter (31658): -----------------Inp:[#00e03],0,2023-08-08 09:01:58.764Z,104.5,139.383-----------------
// I/flutter (31658): -----------------Inp:[#00e03],1,2023-08-08 09:02:59.717Z,104.5,139.383-----------------
// W/OpenGLRenderer(31658): Failed to choose config with EGL_SWAP_BEHAVIOR_PRESERVED, retrying without...
// W/OpenGLRenderer(31658): Failed to initialize 101010-2 format, error = EGL_SUCCESS
// E/OpenGLRenderer(31658): Unable to match the desired swap behavior.
// D/EGL_emulation(31658): app_time_stats: avg=3490.33ms min=20.41ms max=6960.26ms count=2
// I/flutter (31658): Cancel all tasks completed///////////////
// D/FlutterGeolocator(31658): Flutter engine disconnected. Connected engine count 1
// D/FlutterGeolocator(31658): Disposing Geolocator services
// E/FlutterGeolocator(31658): Geolocator position updates stopped
// E/FlutterGeolocator(31658): There is still another flutter engine connected, not stopping location service
// I/WM-WorkerWrapper(31658): Work [ id=b03e4c4c-66de-46d5-8e72-26039261af2c, tags={ be.tramckrijte.workmanager.BackgroundWorker, Tag:[#00e03] } ] was cancelled
// I/WM-WorkerWrapper(31658): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(31658): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(31658): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(31658): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(31658): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(31658): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(31658): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(31658): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(31658): 	at java.lang.Thread.run(Thread.java:1012)
// Application finished.



///sleep時間3時間
///電源off時間3時間
///に設定した場合
///
///多分30分で1クールなんだと思う
///
///この場合も上記と全く同じように止まっているorz
// connecting to VM Service at ws://127.0.0.1:56408/KiEJsQWhqZc=/ws
// D/FlutterGeolocator(32407): Geolocator foreground service connected
// D/FlutterGeolocator(32407): Initializing Geolocator services
// D/FlutterGeolocator(32407): Flutter engine connected. Connected engine count 1
// D/LocationPlugin(32407): Service connected: ComponentInfo{com.example.flutter_application_1/com.lyokone.location.FlutterLocationService}
// D/EGL_emulation(32407): app_time_stats: avg=1325.96ms min=54.78ms max=2597.13ms count=2
// D/EGL_emulation(32407): app_time_stats: avg=117.37ms min=14.79ms max=1284.48ms count=13
// D/CompatibilityChangeReporter(32407): Compat change id reported: 194532703; UID 10183; state: ENABLED
// D/CompatibilityChangeReporter(32407): Compat change id reported: 253665015; UID 10183; state: DISABLED
// D/CompatibilityChangeReporter(32407): Compat change id reported: 263076149; UID 10183; state: DISABLED
// W/FlutterJNI(32407): FlutterJNI.loadLibrary called more than once
// D/FlutterGeolocator(32407): Geolocator foreground service connected
// D/FlutterGeolocator(32407): Initializing Geolocator services
// D/FlutterGeolocator(32407): Flutter engine connected. Connected engine count 2
// W/FlutterJNI(32407): FlutterJNI.prefetchDefaultFontManager called more than once
// I/ResourceExtractor(32407): Found extracted resources res_timestamp-1-1691486366153
// W/FlutterJNI(32407): FlutterJNI.init called more than once
// I/flutter (32407): be.tramckrijte.workmanagerExample.simpleTask+++++++++++++++++++++++++++++
// I/flutter (32407): {key: Inp:[#4c516]}+++++++++++++++++++++++++++
// I/flutter (32407): be.tramckrijte.workmanagerExample.simpleTask was executed. inputData = {key: Inp:[#4c516]}///////////////
// I/flutter (32407): Bool from prefs: true///////////////
// I/flutter (32407): -----------------Inp:[#4c516],0,2023-08-08 09:19:40.263Z,104.5,139.383-----------------
// Reloaded 1 of 1057 libraries in 515ms (compile: 40 ms, reload: 147 ms, reassemble: 190 ms).
// D/EGL_emulation(32407): app_time_stats: avg=2142.71ms min=6.65ms max=63988.11ms count=30
// I/flutter (32407): -----------------Inp:[#4c516],1,2023-08-08 09:20:44.265Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],2,2023-08-08 09:21:44.353Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],3,2023-08-08 09:22:45.240Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],4,2023-08-08 09:23:46.071Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],5,2023-08-08 09:24:46.918Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],6,2023-08-08 09:25:47.752Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],7,2023-08-08 09:26:48.633Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],8,2023-08-08 09:27:49.465Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],9,2023-08-08 09:28:50.368Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],10,2023-08-08 09:29:51.203Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],11,2023-08-08 09:30:52.067Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],12,2023-08-08 09:31:52.907Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],13,2023-08-08 09:32:53.799Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],14,2023-08-08 09:33:54.627Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],15,2023-08-08 09:34:55.528Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],16,2023-08-08 09:35:56.358Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],17,2023-08-08 09:36:57.250Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],18,2023-08-08 09:37:58.081Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],19,2023-08-08 09:38:58.934Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],20,2023-08-08 09:39:59.770Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],21,2023-08-08 09:41:00.598Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],22,2023-08-08 09:42:01.428Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],23,2023-08-08 09:43:02.263Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],24,2023-08-08 09:44:03.109Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],25,2023-08-08 09:45:03.970Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],26,2023-08-08 09:46:04.795Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],27,2023-08-08 09:47:05.630Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],28,2023-08-08 09:48:06.462Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],29,2023-08-08 09:49:07.290Z,104.5,139.383-----------------
// D/FlutterGeolocator(32407): Flutter engine disconnected. Connected engine count 1
// D/FlutterGeolocator(32407): Disposing Geolocator services
// E/FlutterGeolocator(32407): Geolocator position updates stopped
// E/FlutterGeolocator(32407): There is still another flutter engine connected, not stopping location service
// I/WM-WorkerWrapper(32407): Work [ id=17aa8f21-3df3-4beb-89c6-6184356ad1f9, tags={ Tag:[#4c516], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(32407): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(32407): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(32407): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(32407): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(32407): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(32407): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(32407): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(32407): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(32407): 	at java.lang.Thread.run(Thread.java:1012)
// D/FlutterGeolocator(32407): Geolocator foreground service connected
// D/FlutterGeolocator(32407): Initializing Geolocator services
// D/FlutterGeolocator(32407): Flutter engine connected. Connected engine count 2
// I/flutter (32407): be.tramckrijte.workmanagerExample.simpleTask+++++++++++++++++++++++++++++
// I/flutter (32407): {key: Inp:[#4c516]}+++++++++++++++++++++++++++
// I/flutter (32407): be.tramckrijte.workmanagerExample.simpleTask was executed. inputData = {key: Inp:[#4c516]}///////////////
// I/flutter (32407): Bool from prefs: true///////////////
// I/flutter (32407): -----------------Inp:[#4c516],0,2023-08-08 09:49:35.653Z,104.5,139.383-----------------
// I/flutter (32407): -----------------Inp:[#4c516],1,2023-08-08 09:50:36.516Z,104.5,139.383-----------------
