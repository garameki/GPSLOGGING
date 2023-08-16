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

///https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html

class _TopWidgetState extends State<TopWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Timer _timer;
  int _count = 0;

  final List<AppLifecycleState> _stateHistoryList = <AppLifecycleState>[];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 2), onTime);

    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState != null) {
      _stateHistoryList.add(WidgetsBinding.instance.lifecycleState!);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _stateHistoryList.add(state);
    });
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

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(_stateHistoryList.length.toString());
    late ListView observer;
    if (_stateHistoryList.isNotEmpty) {
      observer = ListView.builder(
        shrinkWrap: true, //絶対必要!!!
        reverse: true,
        key: UniqueKey(),
        itemCount: _stateHistoryList.length,
        itemBuilder: (BuildContext context, int index) {
          return Text('state is: ${_stateHistoryList[index]}');
        },
      );
    } else {
      observer = ListView();
    }
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(
            '$_count',
            style: Theme.of(context).textTheme.headlineMedium,
          )),
      body: observer,
    );
  }
}

///drawer menu を実装してみた。

