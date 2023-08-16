import 'package:flutter/material.dart';
import '../../colorScheme/color_schemes.g.dart';
import 'dart:async';
//import 'package:flutter/services.dart';
//import 'dart:isolate';

void main() {
  runApp(const MyApp());
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
      home: const Scaffold(
        body: TopWidget(),
      ),
    );
  }
}

class TopWidget extends StatefulWidget {
  const TopWidget({super.key});
  final title = 'counter isolate & background test';

  @override
  State<TopWidget> createState() => _TopWidgetState();
}

class _TopWidgetState extends State<TopWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;
  int _count = 0;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 2), onTime);
  }

  Timer? onTime(timer) {
    setState(() {
      print(_count.toString());
      _count++;
    });
    return timer;
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_count',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: const <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('ヘッダー'),
            ),
            ListTile(
              title: Text('Hello'),
              subtitle: Text('あいさつ'),
              leading: Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.search),
              ),
              trailing: Icon(Icons.arrow_forward),
            )
          ],
        ),
      ),
    );
  }
}

///drawer menu を実装してみた。

