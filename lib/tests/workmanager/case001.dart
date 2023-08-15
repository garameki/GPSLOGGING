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
  Position pos = await Geolocator.getCurrentPosition(
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
        break;
      case rescheduledTaskKey:
        final key = inputData!['key']!;
        final prefs = await SharedPreferences.getInstance();
        if (prefs.containsKey('unique-$key')) {
          print('has been running before, task is successful///////////////');
          return true;
        } else {
          await prefs.setBool('unique-$key', true);
          print('reschedule task///////////////');
          return false;
        }
      case failedTaskKey:
        print('failed task///////////////');
        return Future.error('failed');
      case simpleDelayedTask:
        print("$simpleDelayedTask was executed///////////////");
        for (int ii = 0; ii < 15; ii++) {
          await getPos(thread: '1', number: ii);
          await wait(seconds: 60);
        }
        break;
      case simplePeriodicTask:
        print("$simplePeriodicTask was executed///////////////");
        final key = inputData!['key']!;

        for (int ii = 0; ii < 15; ii++) {
          await getPos(thread: key, number: ii);
          await wait(seconds: 60);
        }
        break;
      case simplePeriodic1HourTask:
        print("$simplePeriodic1HourTask was executed///////////////");
        break;
      case Workmanager.iOSBackgroundTask:
        print("The iOS background fetch was triggered///////////////");
        Directory? tempDir = await getTemporaryDirectory();
        String? tempPath = tempDir.path;
        print(
            "You can access other plugins in the background, for example Directory.getTemporaryDirectory(): $tempPath///////////////");
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

                //This task runs periodically
                //It will wait at least 10 seconds before its first launch
                //Since we have not provided a frequency it will be the default 15 minutes
                ElevatedButton(
                    onPressed: Platform.isAndroid
                        ? () async {
                            late String key;
                            key = UniqueKey().toString();
                            Workmanager().registerPeriodicTask(
                              key,
                              simplePeriodicTask,
                              tag: key,
                              initialDelay: const Duration(seconds: 0),
                              frequency: const Duration(milliseconds: 900000),
                              inputData: {'key': key},
                            );
                            await wait(seconds: 900);
                            key = UniqueKey().toString();
                            Workmanager().registerPeriodicTask(
                              key,
                              simplePeriodicTask,
                              tag: key,
                              initialDelay: const Duration(seconds: 0),
                              frequency: const Duration(milliseconds: 900000),
                              inputData: {'key': key},
                            );
                          }
                        : null,
                    child:
                        const Text("CLICK Register 2 Periodic Task (Android)")),
                //This task runs periodically
                //It will run about every hour
                ElevatedButton(
                    child: Text("Register 15min later Periodic Task (Android)"),
                    onPressed: Platform.isAndroid
                        ? () {
                            late String key;
                            key = UniqueKey().toString();
                            Workmanager().registerPeriodicTask(
                              key,
                              simplePeriodicTask,
                              tag: key,
                              initialDelay: const Duration(seconds: 900000),
                              frequency: const Duration(milliseconds: 900000),
                              inputData: {'key': key},
                            );
                            // Workmanager().registerPeriodicTask(
                            //   simplePeriodicTask,
                            //   simplePeriodic1HourTask,
                            //   frequency: Duration(hours: 1),
                            // );
                          }
                        : null),
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


///
///タスクが終わってない場合は別のスレッドを立ち上げるのかもしれないぞ。
///ということで、15minぎりぎりまでタスクを実行していないで、
///早めに切り上げてみた。
///
///
///keyで分けたら2本とも何もせずに同時に終了した。
                            // late String key;
                            // key = UniqueKey().toString();
                            // Workmanager().registerPeriodicTask(
                            //   key,
                            //   simplePeriodicTask,
                            //   tag: key,
                            //   initialDelay: const Duration(seconds: 0),
                            //   frequency: const Duration(milliseconds: 900000),
                            //   inputData: {'key': key},
                            // );
                            // await wait(seconds: 900);
                            // key = UniqueKey().toString();
                            // Workmanager().registerPeriodicTask(
                            //   key,
                            //   simplePeriodicTask,
                            //   tag: key,
                            //   initialDelay: const Duration(seconds: 0),
                            //   frequency: const Duration(milliseconds: 900000),
                            //   inputData: {'key': key},
                            // );



// D/EGL_emulation(28963): app_time_stats: avg=3678.41ms min=62.30ms max=7294.51ms count=2
// D/EGL_emulation(28963): app_time_stats: avg=113.96ms min=6.23ms max=2207.17ms count=21
// D/CompatibilityChangeReporter(28963): Compat change id reported: 194532703; UID 10183; state: ENABLED
// D/CompatibilityChangeReporter(28963): Compat change id reported: 253665015; UID 10183; state: DISABLED
// D/CompatibilityChangeReporter(28963): Compat change id reported: 263076149; UID 10183; state: DISABLED
// W/FlutterJNI(28963): FlutterJNI.loadLibrary called more than once
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 2
// W/FlutterJNI(28963): FlutterJNI.prefetchDefaultFontManager called more than once
// I/ResourceExtractor(28963): Found extracted resources res_timestamp-1-1691459602770
// W/FlutterJNI(28963): FlutterJNI.init called more than once
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#6c34f]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// I/flutter (28963): -----------------[#6c34f],0,2023-08-08 01:53:42.220Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],1,2023-08-08 01:54:41.220Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],2,2023-08-08 01:55:36.329Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],3,2023-08-08 01:56:32.204Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],4,2023-08-08 01:57:28.038Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],5,2023-08-08 01:58:23.915Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],6,2023-08-08 01:59:19.742Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],7,2023-08-08 02:00:15.579Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],8,2023-08-08 02:01:11.514Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],9,2023-08-08 02:02:07.382Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],10,2023-08-08 02:03:03.214Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],11,2023-08-08 02:03:59.042Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],12,2023-08-08 02:04:54.918Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],13,2023-08-08 02:05:50.762Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],14,2023-08-08 02:06:46.647Z,104.5,139.383-----------------
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 1
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// I/WM-WorkerWrapper(28963): Worker result SUCCESS for Work [ id=6113346d-5bf5-4e4d-9402-1d54b02d0e36, tags={ [#6c34f], be.tramckrijte.workmanager.BackgroundWorker } ]
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 2
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#444f4]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// I/flutter (28963): -----------------[#444f4],0,2023-08-08 02:08:37.985Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],1,2023-08-08 02:09:33.880Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],2,2023-08-08 02:10:29.710Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],3,2023-08-08 02:11:25.541Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],4,2023-08-08 02:12:21.365Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],5,2023-08-08 02:13:17.212Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],6,2023-08-08 02:14:13.067Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],7,2023-08-08 02:15:08.908Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],8,2023-08-08 02:16:04.742Z,104.5,139.383-----------------
// Reloaded 1 of 1057 libraries in 512ms (compile: 44 ms, reload: 147 ms, reassemble: 185 ms).
// I/flutter (28963): -----------------[#444f4],9,2023-08-08 02:17:00.577Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],10,2023-08-08 02:17:56.431Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],11,2023-08-08 02:18:52.260Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],12,2023-08-08 02:19:48.167Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],13,2023-08-08 02:20:44.048Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],14,2023-08-08 02:21:39.895Z,104.5,139.383-----------------
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 1
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// I/WM-WorkerWrapper(28963): Worker result SUCCESS for Work [ id=7b135cae-3d29-435b-b897-7963cd7db363, tags={ [#444f4], be.tramckrijte.workmanager.BackgroundWorker } ]
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 2
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#6c34f]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// I/flutter (28963): -----------------[#6c34f],0,2023-08-08 02:22:43.341Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],1,2023-08-08 02:23:39.192Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],2,2023-08-08 02:25:54.129Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],3,2023-08-08 02:26:49.965Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],4,2023-08-08 02:27:45.797Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],5,2023-08-08 02:28:41.626Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],6,2023-08-08 02:29:37.456Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],7,2023-08-08 02:30:33.327Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],8,2023-08-08 02:31:29.153Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],9,2023-08-08 02:32:25.045Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],10,2023-08-08 02:33:20.891Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],11,2023-08-08 02:34:16.722Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],12,2023-08-08 02:35:12.549Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],13,2023-08-08 02:36:08.423Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],14,2023-08-08 02:37:06.373Z,104.5,139.383-----------------
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 3
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#444f4]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// I/flutter (28963): -----------------[#444f4],0,2023-08-08 02:37:37.222Z,104.5,139.383-----------------
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 2
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// I/WM-WorkerWrapper(28963): Worker result SUCCESS for Work [ id=6113346d-5bf5-4e4d-9402-1d54b02d0e36, tags={ [#6c34f], be.tramckrijte.workmanager.BackgroundWorker } ]
// I/flutter (28963): -----------------[#444f4],1,2023-08-08 02:38:35.070Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],2,2023-08-08 02:39:33.138Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],3,2023-08-08 02:42:24.499Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],4,2023-08-08 02:43:22.536Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],5,2023-08-08 02:44:20.596Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],6,2023-08-08 02:45:18.588Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],7,2023-08-08 02:46:16.701Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],8,2023-08-08 02:47:14.747Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],9,2023-08-08 02:48:12.809Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],10,2023-08-08 02:49:10.920Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#444f4],11,2023-08-08 02:50:08.211Z,104.5,139.383-----------------
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 3
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#6c34f]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 2
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// I/WM-WorkerWrapper(28963): Work [ id=7b135cae-3d29-435b-b897-7963cd7db363, tags={ [#444f4], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(28963): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(28963): 	at java.lang.Thread.run(Thread.java:1012)
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 3
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#444f4]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// I/WM-WorkerWrapper(28963): Work [ id=6113346d-5bf5-4e4d-9402-1d54b02d0e36, tags={ [#6c34f], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(28963): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(28963): 	at java.lang.Thread.run(Thread.java:1012)
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 2
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 3
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#6c34f]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 2
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// I/WM-WorkerWrapper(28963): Work [ id=6113346d-5bf5-4e4d-9402-1d54b02d0e36, tags={ [#6c34f], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(28963): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(28963): 	at java.lang.Thread.run(Thread.java:1012)
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// lutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 3
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#6c34f]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// I/WM-WorkerWrapper(28963): Work [ id=7b135cae-3d29-435b-b897-7963cd7db363, tags={ [#444f4], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(28963): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(28963): 	at java.lang.Thread.run(Thread.java:1012)
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 2
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 3
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#444f4]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 2
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// I/WM-WorkerWrapper(28963): Work [ id=7b135cae-3d29-435b-b897-7963cd7db363, tags={ [#444f4], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(28963): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(28963): 	at java.lang.Thread.run(Thread.java:1012)
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 3
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#444f4]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 2
// I/WM-WorkerWrapper(28963): Work [ id=6113346d-5bf5-4e4d-9402-1d54b02d0e36, tags={ [#6c34f], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(28963): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(28963): 	at java.lang.Thread.run(Thread.java:1012)
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 3
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#6c34f]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 2
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// I/WM-WorkerWrapper(28963): Work [ id=6113346d-5bf5-4e4d-9402-1d54b02d0e36, tags={ [#6c34f], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(28963): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(28963): 	at java.lang.Thread.run(Thread.java:1012)
// W/r_application_1(28963): Reducing the number of considered missed Gc histogram windows from 1020 to 100
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 3
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#6c34f]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// I/WM-WorkerWrapper(28963): Work [ id=7b135cae-3d29-435b-b897-7963cd7db363, tags={ [#444f4], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(28963): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(28963): 	at java.lang.Thread.run(Thread.java:1012)
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 2
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 3
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#444f4]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 2
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// I/WM-WorkerWrapper(28963): Work [ id=7b135cae-3d29-435b-b897-7963cd7db363, tags={ [#444f4], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(28963): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(28963): 	at java.lang.Thread.run(Thread.java:1012)
// I/WM-WorkerWrapper(28963): Work [ id=6113346d-5bf5-4e4d-9402-1d54b02d0e36, tags={ [#6c34f], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(28963): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(28963): 	at java.lang.Thread.run(Thread.java:1012)
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 1
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 2
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 3
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#444f4]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#6c34f]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 2
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// I/WM-WorkerWrapper(28963): Work [ id=7b135cae-3d29-435b-b897-7963cd7db363, tags={ [#444f4], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(28963): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(28963): 	at java.lang.Thread.run(Thread.java:1012)
// I/WM-WorkerWrapper(28963): Work [ id=6113346d-5bf5-4e4d-9402-1d54b02d0e36, tags={ [#6c34f], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(28963): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(28963): 	at java.lang.Thread.run(Thread.java:1012)
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 1
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 2
// D/FlutterGeolocator(28963): Geolocator foreground service connected
// D/FlutterGeolocator(28963): Initializing Geolocator services
// D/FlutterGeolocator(28963): Flutter engine connected. Connected engine count 3
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#6c34f]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask+++++++++++++++++++++++++++++
// I/flutter (28963): {key: [#444f4]}+++++++++++++++++++++++++++
// I/flutter (28963): be.tramckrijte.workmanagerExample.simplePeriodicTask was executed///////////////
// Reloaded 1 of 1057 libraries in 567ms (compile: 44 ms, reload: 223 ms, reassemble: 224 ms).
// W/r_application_1(28963): Reducing the number of considered missed Gc histogram windows from 211 to 100
// W/OpenGLRenderer(28963): Failed to choose config with EGL_SWAP_BEHAVIOR_PRESERVED, retrying without...
// W/OpenGLRenderer(28963): Failed to initialize 101010-2 format, error = EGL_SUCCESS
// E/OpenGLRenderer(28963): Unable to match the desired swap behavior.
// I/flutter (28963): Cancel all tasks completed///////////////

///！！！！！！！！！！！！ここでキャンセルボタン押してるんだけど！！！！！！！！！！！！！！

// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 2
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// I/WM-WorkerWrapper(28963): Work [ id=7b135cae-3d29-435b-b897-7963cd7db363, tags={ [#444f4], be.tramckrijte.workmanager.BackgroundWorker } ] was cancelled
// I/WM-WorkerWrapper(28963): java.util.concurrent.CancellationException: Task was cancelled.
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.cancellationExceptionWithCause(AbstractFuture.java:1184)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.getDoneValue(AbstractFuture.java:514)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.futures.AbstractFuture.get(AbstractFuture.java:475)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.WorkerWrapper$2.run(WorkerWrapper.java:311)
// I/WM-WorkerWrapper(28963): 	at androidx.work.impl.utils.SerialExecutor$Task.run(SerialExecutor.java:91)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1145)
// I/WM-WorkerWrapper(28963): 	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:644)
// I/WM-WorkerWrapper(28963): 	at java.lang.Thread.run(Thread.java:1012)
// 3回同じ表示
// W/FlutterJNI(28963): Tried to send a platform message response, but FlutterJNI was detached from native C++. Could not send. Response ID: 3
// W/FlutterJNI(28963): Tried to send a platform message response, but FlutterJNI was detached from native C++. Could not send. Response ID: 15
// 9回同じ表示
// W/FlutterJNI(28963): Tried to send a platform message response, but FlutterJNI was detached from native C++. Could not send. Response ID: 3
// I/flutter (28963): -----------------[#6c34f],0,2023-08-08 07:52:37.491Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],1,2023-08-08 07:53:36.477Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],2,2023-08-08 07:54:35.479Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],3,2023-08-08 07:55:34.483Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],4,2023-08-08 07:56:33.483Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],5,2023-08-08 07:57:32.485Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],6,2023-08-08 07:58:31.485Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],7,2023-08-08 07:59:30.486Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],8,2023-08-08 08:00:29.489Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],9,2023-08-08 08:01:28.493Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],10,2023-08-08 08:02:27.494Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],11,2023-08-08 08:03:26.498Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],12,2023-08-08 08:04:25.499Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],13,2023-08-08 08:05:24.501Z,104.5,139.383-----------------
// I/flutter (28963): -----------------[#6c34f],14,2023-08-08 08:06:23.505Z,104.5,139.383-----------------
// D/FlutterGeolocator(28963): Flutter engine disconnected. Connected engine count 1
// D/FlutterGeolocator(28963): Disposing Geolocator services
// E/FlutterGeolocator(28963): Geolocator position updates stopped
// E/FlutterGeolocator(28963): There is still another flutter engine connected, not stopping location service
// Reloaded 0 libraries in 140ms (compile: 15 ms, reload: 0 ms, reassemble: 66 ms).
// D/EGL_emulation(28963): app_time_stats: avg=38552.84ms min=1.93ms max=962543.88ms count=25

/// 勝手にcancelされるわけを調査する
/// 
/// パソコンの電源が5時間後に切れた
/// 
/// キャンセルボタンを押した
/// 
/// 再開したら再びスレッドが動き出した！！！
