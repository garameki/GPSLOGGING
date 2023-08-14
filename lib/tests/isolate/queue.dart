//https://qiita.com/takyam/items/6ad155678c95bba4047f#microtask_queue_schedule

import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

Future<Position> getPos() async {
  return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
}

void main2() {
  WidgetsFlutterBinding.ensureInitialized();

  ///queueは2種類
  ///1.event queue 2.microtask queue
  ///
  ///優先順位
  /// 1 < 2

  ///イベントqueueでの管理をなるべく行う-->イベントqueueの枯渇を減らせる
  getPos() //getPos()のFutureを完了後にthenはすぐに実行されていく
      .then((value) => print(value.timestamp))
      .then((value) => Future.delayed(const Duration(seconds: 5), () {
            print('new future');
          }).then((value) => print('second')))
      .whenComplete(() => print('complete'));

  scheduleMicrotask(() {
    //優先順位が高いmicrotask queueにpush
    print('microtask');
  });

  print('end of main isolate'); //１回、すべてを最後まで実行

  ///イベントqueueにpushする方法
  ///1.new Future()を使う
  ///2.new Future.delayed()を使う

  ///1秒後にevent queueにタスクをpush
  Future.delayed(const Duration(seconds: 1), getPos); //遅延可能性あり

  ///緊急性のあるtaskはscheduleMicrotask()を用いてmicrotask queueにpushする
}
