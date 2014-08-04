library orel;

import 'dart:mirrors';
import 'dart:async';
import 'sql.dart';

class Manager<M> {

  ClassMirror modelMirror;
  SQLBuilder sql;

  Manager() {
    modelMirror = reflectClass(M);
    sql = new SQLBuilder(this);
  }

  M _newInstance() {
    var im = modelMirror.newInstance(new Symbol(""), []);
    M model = im.reflectee;
    model.manager = this;
    return model;
  }

  Future<M> get(int id) {
    return new Future<M>(() {
      return _newInstance();
    });
  }

  Future<M> create() {
    return new Future<M>(() {
      return _newInstance();
    });
  }

  Future<bool> save(Object o) {
    return new Future<bool>(() => true);
  }

}

main() {

/*  p.addr = new Address();
  
  MirrorSystem mirrors = currentMirrorSystem();
  Map<Uri, LibraryMirror> libraries = mirrors.libraries;
  var uri = Uri.parse('file:///home/lex/dart/orel/lib/orel.dart');
  LibraryMirror lm = mirrors.libraries[uri];
  lm.declarations.forEach((s, dm) {
    print(s);
  });*/
}