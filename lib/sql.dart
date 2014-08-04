import 'dart:mirrors';
import 'orel.dart';
import 'managed.dart';

final Map<Symbol, String>  DART_TO_SQL_TYPES = {
  new Symbol("String"): "text",
  new Symbol("int"): "integer"
};

class SQLBuilder {
  Manager manager;
  ClassMirror cm;
  String tableName;
  Iterable<VariableMirror> fields;

  String createTableSQL;
  String createForeignKeySQL;

  SQLBuilder(this.manager) {
    cm = manager.modelMirror;
    tableName = MirrorSystem.getName(cm.simpleName);
    fields = cm.declarations.values.where((m) => m is VariableMirror).map((dm) => dm as VariableMirror);
    createTableSQL = _createTableSQL();
    createForeignKeySQL = _createForeignKeySQL();
  }

  String _createTableSQL() {
    var names = [];
    fields.forEach((vm) {
      var columnName = MirrorSystem.getName(vm.simpleName);
      var columnType = DART_TO_SQL_TYPES[vm.type.simpleName];
      if (vm.type.isSubtypeOf(reflectType(Managed))) {
        // Foreign Key
        names.add("  ${columnName}_id integer NOT NULL");
      } else if (columnName == "id" && columnType == "integer") {
        names.add("  $columnName serial PRIMARY KEY");
      } else if (columnType != null) {
        names.add("  $columnName $columnType");
      }
    });
    return "CREATE TABLE ${tableName.toLowerCase()} (\n" +
           names.join(",\n") +
           "\n);";
  }

  String _createForeignKeySQL() {
    var keys = [];
    fields.forEach((vm) {
      if (vm.type.isSubtypeOf(reflectType(Managed))) {
        var columnName = MirrorSystem.getName(vm.simpleName);
        var columnTypeName = MirrorSystem.getName(vm.type.simpleName);
        keys.add("ALTER TABLE ${tableName.toLowerCase()} ADD FOREIGN KEY (${columnName}_id) REFERENCES ${columnTypeName.toLowerCase()};\n");
      }
    });
    return keys.join();
  }
}