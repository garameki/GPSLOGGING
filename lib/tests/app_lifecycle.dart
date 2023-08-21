import 'package:flutter/material.dart';

///参考サイト
///https://api.flutter.dev/flutter/widgets/WidgetsBindingObserver-class.html

/// Flutter code sample for [WidgetBindingsObserver].

void main() => runApp(const WidgetBindingObserverExampleApp());

class WidgetBindingObserverExampleApp extends StatelessWidget {
  const WidgetBindingObserverExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('WidgetBindingsObserver Sample')),
        body: const WidgetBindingsObserverSample(),
      ),
    );
  }
}

class WidgetBindingsObserverSample extends StatefulWidget {
  const WidgetBindingsObserverSample({super.key});

  @override
  State<WidgetBindingsObserverSample> createState() =>
      _WidgetBindingsObserverSampleState();
}

class _WidgetBindingsObserverSampleState
    extends State<WidgetBindingsObserverSample> with WidgetsBindingObserver {
  final List<AppLifecycleState> _stateHistoryList = <AppLifecycleState>[];

  @override
  void initState() {
    super.initState();

    ///''this'' is Instance of WidgetsBindingObserver!
    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState != null) {
      _stateHistoryList.add(WidgetsBinding.instance.lifecycleState!);
    }
    print('initState()');
  }

  ///WidgetsBindingObserverのメソッド
  @override
  void didChangeAccessibilityFeatures() {
    print('didChangeAccessibilityFeatures()');
  }

  ///WidgetsBindingObserverのメソッド
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _stateHistoryList.add(state);
    });
    print('didChangeAppLifecycleState($state)');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    print('dispose()');
  }

  @override
  Widget build(BuildContext context) {
    print('build()');
    if (_stateHistoryList.isNotEmpty) {
      return ListView.builder(
        key: const ValueKey<String>('stateHistoryList'),
        itemCount: _stateHistoryList.length,
        itemBuilder: (BuildContext context, int index) {
          return Text('state is: ${_stateHistoryList[index]}');
        },
      );
    }

    return const Center(
        child: Text('There are no AppLifecycleStates to show.'));
  }
}


///inactive
///↓
///pause
///↓
///resume
///を繰り返すだけでしたー