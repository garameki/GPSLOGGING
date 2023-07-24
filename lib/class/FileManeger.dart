///dartのクラスの練習用
class FileManager {
  ///とにかくメンバ変数は[this]を付けてコンストラクタの()の中に入れる！
  ///宣言はその下に書く.
  ///[{}]を付けるとインスタンス作成時に名前付きの引数になる
  FileManager({required this.filename, this.path = ''}) {
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
