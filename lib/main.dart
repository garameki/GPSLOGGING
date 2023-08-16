import 'package:flutter/material.dart';
//import 'gps/ver0.4.1.dart' show MyApp;
//import 'tests/location.dart' show MyApp;

// void main() {
//   runApp(const MyApp());
// }

//import 'tests/app_lifecycle.dart';
//void main() => runApp(const WidgetBindingObserverExampleApp());

//import 'tests/workmanager/case002.dart' show MyApp;
//void main() => runApp(MyApp());

//import 'tests/isolate/bad_case004.dart';
//void main() => runApp(const MyApp());

//import 'tests/background_location/example.dart' show MyApp;
//void main() => runApp(MyApp());

import 'tests/background_timer/widget_binding_observer.dart' show MyApp;

void main() => runApp(const MyApp());

///theme color builder
///https://zenn.dev/10_tofu_01/articles/adopt_material_color_generotor
///https://m3.material.io/theme-builder#/custom


//import '../colorScheme/color_schemes.g.dart';

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
//       darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
//       home: const Home(),
//     );
//   }
// }

// class Home extends StatelessWidget {
//   const Home({Key? key}) : super(key: key);

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           elevation: 2,
//           title: Text("Material Theme Builder"),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Update with your UI',
//               ),
//             ],
//           ),
//         ),
//         floatingActionButton:
//             FloatingActionButton(onPressed: () => {}, tooltip: 'Increment'));
//   }
// }
