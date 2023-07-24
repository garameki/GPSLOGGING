
import 'FileManeger.dart';

void main() {
//  runApp(const MyApp());

  FileManager2 aaa = FileManager2(filename: 'aaa.csv');
  print(aaa.path);
  print(aaa._getAllPath());
  aaa._path = 'gdgdgd/'; //[_]で始まっているprivateメンバでも同じファイル内ならば参照・変更できてしまう.
  //なので、クラスごとにファイルに分けるべし！！
  print(aaa._getAllPath());



///[FileManager]はほかのファイルにあるので、[_]で始まるメンバ変数とメンバ関数が
///呼び出せなくなっていることがわかる.
  FileManager bbb = FileManager(filename: 'bbb.csv');
  print(bbb.path);
  print(bbb._getAllPath());
  bbb._path = 'gdgdgd/'; //[_]で始まっているprivateメンバでも同じファイル内ならば参照・変更できてしまう.
  //なので、クラスごとにファイルに分けるべし！！
  print(bbb._getAllPath());
  print(FileManager._getPath2())//staticなクラス関数でもプライベート関数は呼び出せない.
}

///dartのクラスの練習用
class FileManager2 {
  ///とにかくメンバ変数は[this]を付けてコンストラクタの()の中に入れる！
  ///宣言はその下に書く.
  ///[{}]を付けるとインスタンス作成時に名前付きの引数になる
  FileManager2({required this.filename, this.path = ''}) {
    if (filename == '') {
      _filename = 'test.csv';
    } else {
      _filename = filename;
    }
    if (path == '') _path = _getPath();
  }

  ///コンストラクタ用
  final String filename;
  String path;

  ///
  ///プライベートメンバ変数Non-Nullableにするために['']を代入しておく.
  ///このファイルの中では[_]で始まるメンバ変数はプライベートではない.
  ///あくまで、ほかのファイルからは参照できないというだけ.
  String _filename = '';
  String _path = '';

  ///ゲッターはほかのファイル内での参照に使われることに存在価値がある.
  String get getFilename => _filename;
  String get getPath => _path;

  String _getPath() {
    return 'lkdjflsdk/';
  }

  String _getAllPath() {
    return '$_path$_filename';
  }

  ///[static]なのでインスタンスからこの関数は参照できません.
  static String _getPath2() {
    return 'src/data/';
  }
}
