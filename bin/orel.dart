import 'dart:io';

void main(List<String> arguments) {
  var currentDir = Directory.current.path;
  
  var f = new File("tmp_orel_migrate.dart").absolute;
  f.createSync();
  f.writeAsStringSync("""
  import 'package:orel/migrate.dart';
  import 'dart:mirrors';
  import 'app.dart';

  main() {
    print("migrate script:");
    var lib = currentMirrorSystem().libraries.values.where((u)=>u.uri.path.endsWith("app.dart")).first;
    migrate(lib);
  }
  """);

  Process.run(Platform.executable, [f.path])
    .then((ProcessResult pr) {
        print(pr.stdout);
    }).catchError((e) => print("$e error"))
    .whenComplete(() {
      //f.deleteSync();
    });
}