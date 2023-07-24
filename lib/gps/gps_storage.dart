import 'dart:async';

import 'package:geolocator/geolocator.dart';

import 'package:intl/intl.dart' show DateFormat;
import 'dart:io' show Directory, File;
import 'package:path_provider/path_provider.dart';

//参考ドキュメント
//1.geolocator 9.0.2
//https://pub.dev/packages/geolocator
//2.【Flutter】スマホの位置情報を取得するやり方
//https://zenn.dev/namioto/articles/3abb0ccf8d8fb6

//android/src/main/AndroidManifest.xmlに以下の３行を<manifest>タグの後ろに加える
//<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
//<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
//<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />

class GPSStorage {
  GPSStorage();

  ///接頭辞の説明
  ///path...絶対パス
  ///folda...フォルダの名前(親フォルダは含まない)
  ///filename...ファイルの名前(フォルダは含まない)
  ///filepath...ファイル名まで含めた絶対パス
  ///foldapath...フォルダまでの絶対パス

  ///sync/awaitを使うような静的な定数を持たないようにする.

  static const String _foldaNameOfLocationFile = 'filenames/';
  static const String _filenameNameOfLocationFile = 'filenameLocationFile.txt';
  static const String _foldaLocationFiles = 'locations/';

  ///このアプリの専用フォルダのルートパス
  Future<String> get _pathApplication async {
    //final Directory directory = await getApplicationDocumentsDirectory();
    final Directory directory = await getApplicationSupportDirectory();
    return '${directory.path}/'; //最後に/を入れて返却
  }

  ///生成します
  ///1.Locationファイルのファイルネームをしまうフォルダ
  ///2.Locationファイルをためるフォルダ
  ///3.Locationファイルの名前をしまうファイル
  createFolders() async {
    final String pathApp = await _pathApplication;

    //ディレクトリの生成
    Directory folda = Directory('$pathApp$_foldaNameOfLocationFile');
    await folda.create(recursive: true);

    //ディレクトリの生成
    folda = Directory('$pathApp$_foldaLocationFiles');
    await folda.create(recursive: true);

    //ファイルの生成
    File file =
        File('$pathApp$_foldaNameOfLocationFile$_filenameNameOfLocationFile');
    await file.create();
    var systemTempDir = Directory(pathApp);

    // List directory contents, recursing into sub-directories,
    // but not following symbolic links.
    await for (var entity
        in systemTempDir.list(recursive: true, followLinks: false)) {
      //await Directory(entity.path).delete(recursive: true);
      print(entity.path);
    }
  }

  //format JST timestamp to GMT ZZZformat
  static String formatTimestamp({DateTime? timestampJST}) {
    DateTime? timestampGMT = timestampJST!.add(const Duration(hours: 9) * -1);
    String time =
        '${DateFormat('yyyy-MM-ddTHH:mm:ss.000').format(timestampGMT)}Z';
    return time;
  }

  String formatPositionToLine(Position position) {
    double lon = position.longitude;
    double lat = position.latitude;
    String time = formatTimestamp(timestampJST: position.timestamp);
    return '$time,$lon,$lat';
  }

  ///Locationが格納されるファイルのファイル名を返す
  Future<String> get filenameLocationFile async {
    String filename = '';
    String pathApp = await _pathApplication;
    String filepath =
        '$pathApp$_foldaNameOfLocationFile$_filenameNameOfLocationFile';
    File file = File(filepath);

    try {
      bool isExist = await file.exists();
      if (!isExist) throw ('ファイルが存在しません。$filepath');
      //ファイルやフォルダが存在しない場合は読み込めません。
      filename = await file.readAsString();
      if (filename == '') throw ('ファイル名が格納されていません。');
    } catch (e) {
      print('in filenameLocationFile');
      print(e);
      print('in filenameLocationFile');
      return 'dummy.csv';
    }
    return filename;
  }

  ///現在、位置情報の保存に使っているファイルへの絶対パス
  Future<String> get _filepathLocationFile async {
    String pathApp = await _pathApplication;
    String filename = await filenameLocationFile;
    // String filename = '';
    // String pathApp = await _pathApplication;
    // String filepath =
    //     '$pathApp$_foldaNameOfLocationFile$_filenameNameOfLocationFile';
    // File file = File(filepath);

    // try {
    //   bool isExist = await file.exists();
    //   if (!isExist) throw ('ファイルが存在しません。$filepath');
    //   //ファイルやフォルダが存在しない場合は読み込めません。
    //   filename = await file.readAsString();
    //   if (filename == '') throw ('ファイル名が格納されていません。');
    // } catch (e) {
    //   print('in _filepathLocationFile');
    //   print(e);
    //   print('in _filepathLocationFile');
    // }
    return '$pathApp$_foldaLocationFiles$filename';
  }

  ///現在使っている位置情報ファイルの内容の読み出し
  Future<String> readPositions() async {
    String contents = '';
    String filepath = await _filepathLocationFile;
    File file = File(filepath);
    bool isExist = await file.exists();
    if (!isExist) {
      //ファイルが存在しない
      contents = "";
    } else {
      contents = await file.readAsString();
    }
//    print(contents);
    return contents;
  }

  ///現在使っている位置情報ファイルへの書き込み
  void storePositions({required String contents}) async {
    String filepath = await _filepathLocationFile;
    File file = File(filepath);
    file.writeAsString(contents.toString());
  }

  ///現在使っている位置情報ファイルの最後に位置情報１行を追加する
  void appendPosition({required Position position}) async {
    String contentsBefore = await readPositions();
    String linePosition = formatPositionToLine(position);
    storePositions(contents: '$contentsBefore$linePosition\n');
  }

  void storeNameOfLocationFile(
      {String filename = _filenameNameOfLocationFile}) async {
    String pathApp = await _pathApplication;
    String filepath =
        '$pathApp$_foldaNameOfLocationFile$_filenameNameOfLocationFile';
    File file = File(filepath);

    try {
      bool isExist = await file.exists();
      if (!isExist) throw ('ファイルが存在しません。$filepath');
      //ファイルやフォルダが存在しない場合は読み込めません。
      await file.writeAsString(filename);
    } catch (e) {
      print('in storeNameOfLocationFile');
      print(e);
      print('in storeNameOfLocationFile');
    }
  }

  ///権限の様子を見てエラーを返す
  ///しかし、「常に許可」等の確認画面は出ませんので
  ///実装がまた必要になります。
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.222');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions denied.333');
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied.We can not request permissions.444');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
