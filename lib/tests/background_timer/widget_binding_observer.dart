import 'dart:ui';

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
  void didChangeMetrics() {}

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    print('GOOD-BYE');
    Future.delayed(Duration(seconds: 5));
    return AppExitResponse.exit;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _timer = Timer.periodic(const Duration(seconds: 2), onTime);

    ///mixin WidgetsBinding on BindingBase, ServicesBinding, SchedulerBinding, GestureBinding, RendererBinding, SemanticsBinding {
    ///この意味はonの後ろにあるクラスを継承したクラスでないとmixinできませんよ！ということ。
    ///
    ///参考記事
    ///https://zenn.dev/iwaku/articles/2020-12-16-iwaku#mixin%EF%BC%88with%EF%BC%89
    ///...「on」で検索してみて
    ///
    ///「abstract mixin class」の意味は
    ///https://dart.dev/language/mixins
    ///で、「abstract mixin class」で検索してみて
    ///
    ///https://zenn.dev/iwaku/articles/2020-12-16-iwaku#factory%E3%81%A8abstract
    ///...factoryの使い方が出てる
    WidgetsBinding.instance.addObserver(this); //こいつmixin class?
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
      print('${_count.toString()}++++');
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
//    print(_stateHistoryList.length.toString());
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
///
///
// D/EGL_emulation(18428): app_time_stats: avg=2004.63ms min=2004.63ms max=2004.63ms count=1
// I/flutter (18428): 27++++
// D/EGL_emulation(18428): app_time_stats: avg=1969.91ms min=1969.91ms max=1969.91ms count=1
// I/flutter (18428): 28++++
// D/EGL_emulation(18428): app_time_stats: avg=1998.16ms min=1998.16ms max=1998.16ms count=1
// I/flutter (18428): 29++++
// D/EGL_emulation(18428): app_time_stats: avg=1994.25ms min=1994.25ms max=1994.25ms count=1
// I/flutter (18428): 30++++
// D/EGL_emulation(18428): app_time_stats: avg=2033.01ms min=2033.01ms max=2033.01ms count=1
// I/flutter (18428): 31++++
// D/EGL_emulation(18428): app_time_stats: avg=2002.55ms min=2002.55ms max=2002.55ms count=1
// I/flutter (18428): 32++++
// D/EGL_emulation(18428): app_time_stats: avg=1971.94ms min=1971.94ms max=1971.94ms count=1
// I/flutter (18428): 33++++
// D/EGL_emulation(18428): app_time_stats: avg=2020.15ms min=2020.15ms max=2020.15ms count=1
// I/flutter (18428): 34++++
// D/EGL_emulation(18428): app_time_stats: avg=1997.48ms min=1997.48ms max=1997.48ms count=1
// I/flutter (18428): 35++++
// D/EGL_emulation(18428): app_time_stats: avg=1994.99ms min=1994.99ms max=1994.99ms count=1
// I/flutter (18428): 36++++
// D/EGL_emulation(18428): app_time_stats: avg=2010.88ms min=2010.88ms max=2010.88ms count=1
// I/flutter (18428): 37++++
// D/EGL_emulation(18428): app_time_stats: avg=1980.28ms min=1980.28ms max=1980.28ms count=1
// I/flutter (18428): 38++++
// D/EGL_emulation(18428): app_time_stats: avg=2016.65ms min=2016.65ms max=2016.65ms count=1
// I/flutter (18428): 39++++
// D/EGL_emulation(18428): app_time_stats: avg=1982.38ms min=1982.38ms max=1982.38ms count=1
// I/flutter (18428): 40++++
// D/EGL_emulation(18428): app_time_stats: avg=2002.34ms min=2002.34ms max=2002.34ms count=1
// I/flutter (18428): 41++++
// D/EGL_emulation(18428): app_time_stats: avg=1993.82ms min=1993.82ms max=1993.82ms count=1
// I/flutter (18428): 42++++
// D/EGL_emulation(18428): app_time_stats: avg=2023.19ms min=2023.19ms max=2023.19ms count=1
// I/flutter (18428): 43++++
// D/EGL_emulation(18428): app_time_stats: avg=1978.81ms min=1978.81ms max=1978.81ms count=1
// I/flutter (18428): 44++++
// D/EGL_emulation(18428): app_time_stats: avg=2004.74ms min=2004.74ms max=2004.74ms count=1
// I/flutter (18428): 45++++
// D/EGL_emulation(18428): app_time_stats: avg=1988.83ms min=1988.83ms max=1988.83ms count=1
// I/flutter (18428): 46++++
// D/EGL_emulation(18428): app_time_stats: avg=2005.42ms min=2005.42ms max=2005.42ms count=1
// I/flutter (18428): 47++++
// D/EGL_emulation(18428): app_time_stats: avg=2007.20ms min=2007.20ms max=2007.20ms count=1
// I/flutter (18428): 48++++
// D/EGL_emulation(18428): app_time_stats: avg=1990.12ms min=1990.12ms max=1990.12ms count=1
// I/flutter (18428): 49++++
// D/EGL_emulation(18428): app_time_stats: avg=2008.64ms min=2008.64ms max=2008.64ms count=1
// I/flutter (18428): 50++++
// D/EGL_emulation(18428): app_time_stats: avg=2004.48ms min=2004.48ms max=2004.48ms count=1
// I/flutter (18428): 51++++
// D/EGL_emulation(18428): app_time_stats: avg=1984.28ms min=1984.28ms max=1984.28ms count=1
// I/flutter (18428): 52++++
// D/EGL_emulation(18428): app_time_stats: avg=1998.18ms min=1998.18ms max=1998.18ms count=1
// I/flutter (18428): 53++++
// D/EGL_emulation(18428): app_time_stats: avg=2004.15ms min=2004.15ms max=2004.15ms count=1
// I/flutter (18428): 54++++
// D/EGL_emulation(18428): app_time_stats: avg=2013.31ms min=2013.31ms max=2013.31ms count=1
// I/flutter (18428): 55++++
// D/EGL_emulation(18428): app_time_stats: avg=2003.46ms min=2003.46ms max=2003.46ms count=1
// I/flutter (18428): 56++++
// D/EGL_emulation(18428): app_time_stats: avg=1985.98ms min=1985.98ms max=1985.98ms count=1
// I/flutter (18428): 57++++
// D/EGL_emulation(18428): app_time_stats: avg=2015.94ms min=2015.94ms max=2015.94ms count=1
// I/flutter (18428): 58++++
// D/EGL_emulation(18428): app_time_stats: avg=2002.72ms min=2002.72ms max=2002.72ms count=1
// I/flutter (18428): 59++++
// D/EGL_emulation(18428): app_time_stats: avg=2000.54ms min=2000.54ms max=2000.54ms count=1
// I/flutter (18428): 60++++
// D/EGL_emulation(18428): app_time_stats: avg=1975.99ms min=1975.99ms max=1975.99ms count=1
// I/flutter (18428): 61++++
// D/EGL_emulation(18428): app_time_stats: avg=2020.33ms min=2020.33ms max=2020.33ms count=1
// I/flutter (18428): 62++++
// D/EGL_emulation(18428): app_time_stats: avg=1976.47ms min=1976.47ms max=1976.47ms count=1
// I/flutter (18428): 63++++
// D/EGL_emulation(18428): app_time_stats: avg=2026.58ms min=2026.58ms max=2026.58ms count=1
// I/flutter (18428): 64++++
// D/EGL_emulation(18428): app_time_stats: avg=1988.72ms min=1988.72ms max=1988.72ms count=1
// I/flutter (18428): 65++++
// D/EGL_emulation(18428): app_time_stats: avg=1951.57ms min=1951.57ms max=1951.57ms count=1
// I/flutter (18428): 66++++
// D/EGL_emulation(18428): app_time_stats: avg=2012.72ms min=2012.72ms max=2012.72ms count=1
// I/flutter (18428): 67++++
// D/EGL_emulation(18428): app_time_stats: avg=1978.85ms min=1978.85ms max=1978.85ms count=1
// I/flutter (18428): 68++++
// D/EGL_emulation(18428): app_time_stats: avg=2000.37ms min=2000.37ms max=2000.37ms count=1
// I/flutter (18428): 69++++
// D/EGL_emulation(18428): app_time_stats: avg=2000.07ms min=2000.07ms max=2000.07ms count=1
// I/flutter (18428): 70++++
// D/EGL_emulation(18428): app_time_stats: avg=1999.80ms min=1999.80ms max=1999.80ms count=1
// I/flutter (18428): 71++++
// I/flutter (18428): 72++++
// I/flutter (18428): 73++++
// I/flutter (18428): 74++++
// I/flutter (18428): 75++++
// I/flutter (18428): 76++++
// I/flutter (18428): 77++++
// E/OpenGLRenderer(18428): Unable to match the desired swap behavior.
// I/flutter (18428): 78++++
// D/EGL_emulation(18428): app_time_stats: avg=563.85ms min=5.32ms max=1122.39ms count=2
// I/flutter (18428): 79++++
// D/EGL_emulation(18428): app_time_stats: avg=1998.83ms min=1998.83ms max=1998.83ms count=1
// I/flutter (18428): 80++++
// D/EGL_emulation(18428): app_time_stats: avg=2001.09ms min=2001.09ms max=2001.09ms count=1
// I/flutter (18428): 81++++
// D/EGL_emulation(18428): app_time_stats: avg=1999.35ms min=1999.35ms max=1999.35ms count=1
// I/flutter (18428): 82++++
// I/flutter (18428): 83++++
// I/flutter (18428): 84++++
// I/flutter (18428): 85++++
// I/flutter (18428): 86++++
// I/flutter (18428): 87++++
// I/flutter (18428): 88++++
// I/flutter (18428): 89++++
// I/flutter (18428): 90++++
// I/flutter (18428): 91++++
// I/flutter (18428): 92++++
// I/flutter (18428): 93++++
// I/flutter (18428): 94++++
// W/OpenGLRenderer(18428): Failed to choose config with EGL_SWAP_BEHAVIOR_PRESERVED, retrying without...
// W/OpenGLRenderer(18428): Failed to initialize 101010-2 format, error = EGL_SUCCESS
// E/OpenGLRenderer(18428): Unable to match the desired swap behavior.
// I/flutter (18428): 95++++
// D/EGL_emulation(18428): app_time_stats: avg=509.27ms min=16.26ms max=1002.27ms count=2
// I/flutter (18428): 96++++
// D/EGL_emulation(18428): app_time_stats: avg=2000.27ms min=2000.27ms max=2000.27ms count=1
// I/flutter (18428): 97++++
// D/EGL_emulation(18428): app_time_stats: avg=1999.99ms min=1999.99ms max=1999.99ms count=1
// I/flutter (18428): 98++++
// D/EGL_emulation(18428): app_time_stats: avg=1999.22ms min=1999.22ms max=1999.22ms count=1
// I/flutter (18428): 99++++
// D/EGL_emulation(18428): app_time_stats: avg=2000.77ms min=2000.77ms max=2000.77ms count=1
// I/flutter (18428): 100++++
// D/EGL_emulation(18428): app_time_stats: avg=2001.15ms min=2001.15ms max=2001.15ms count=1
// I/flutter (18428): 101++++
// D/EGL_emulation(18428): app_time_stats: avg=1997.29ms min=1997.29ms max=1997.29ms count=1
// I/flutter (18428): 102++++
// D/EGL_emulation(18428): app_time_stats: avg=2002.23ms min=2002.23ms max=2002.23ms count=1
// D/FlutterGeolocator(18428): Detaching Geolocator from activity
// D/FlutterGeolocator(18428): Flutter engine disconnected. Connected engine count 0
// D/FlutterGeolocator(18428): Disposing Geolocator services
// E/FlutterGeolocator(18428): Geolocator position updates stopped
// D/FlutterGeolocator(18428): Stopping location service.
// I/flutter (18428): 103++++
// D/FlutterLocationService(18428): Unbinding from location service.
// D/FlutterLocationService(18428): Destroying service.
// D/FlutterGeolocator(18428): Unbinding from location service.
// D/FlutterGeolocator(18428): Destroying location service.
// D/FlutterGeolocator(18428): Stopping location service.
// D/FlutterGeolocator(18428): Destroyed location service.
// Lost connection to device.
// Exited (sigterm)
