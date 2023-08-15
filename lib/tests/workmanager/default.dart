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

                //This task runs once.
                //Most likely this will trigger immediately
                ElevatedButton(
                  child: Text("Register OneOff Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      simpleTaskKey,
                      simpleTaskKey,
                      inputData: <String, dynamic>{
                        'int': 1,
                        'bool': true,
                        'double': 1.0,
                        'string': 'string',
                        'array': [1, 2, 3],
                      },
                    );
                  },
                ),
                ElevatedButton(
                  child: Text("Register rescheduled Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      rescheduledTaskKey,
                      rescheduledTaskKey,
                      inputData: <String, dynamic>{
                        'key': Random().nextInt(64000),
                      },
                    );
                  },
                ),
                ElevatedButton(
                  child: Text("Register failed Task"),
                  onPressed: () {
                    Workmanager().registerOneOffTask(
                      failedTaskKey,
                      failedTaskKey,
                    );
                  },
                ),
                //This task runs once
                //This wait at least 10 seconds before running
                ElevatedButton(
                    child: Text("Register Delayed OneOff Task"),
                    onPressed: () {
                      Workmanager().registerOneOffTask(
                        simpleDelayedTask,
                        simpleDelayedTask,
                        initialDelay: const Duration(seconds: 0),
                      );
                    }),
                SizedBox(height: 8),

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
                            await wait(seconds: 10);
                            key = UniqueKey().toString();
                            Workmanager().registerPeriodicTask(
                              key,
                              simplePeriodicTask,
                              tag: key,
                              initialDelay:
                                  const Duration(microseconds: 900000),
                              frequency: const Duration(milliseconds: 900000),
                              inputData: {'key': key},
                            );
                            await wait(seconds: 10);
                            key = UniqueKey().toString();
                            Workmanager().registerPeriodicTask(
                              key,
                              simplePeriodicTask,
                              tag: key,
                              initialDelay:
                                  const Duration(microseconds: 900000),
                              frequency: const Duration(milliseconds: 900000),
                              inputData: {'key': key},
                            );
                          }
                        : null,
                    child: const Text("Register 3 Periodic Task (Android)")),
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
