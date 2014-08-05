library migrate;

import 'dart:mirrors';

migrate(LibraryMirror lib) {
  var claz = lib.declarations.values.where((m) => m is ClassMirror);
  claz.forEach((c)=>print(c));
}