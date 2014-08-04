import 'dart:mirrors';
import 'orel.dart';
import 'managed.dart';

Map<Symbol, String> DART_TO_SQL_TYPES = {
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
  
  String selectSQL;
  String insertSQL;
  String updateSQL;
  String deleteSQL;

  SQLBuilder(this.manager) {
    cm = manager.modelMirror;
    tableName = MirrorSystem.getName(cm.simpleName).toLowerCase();
    fields = cm.declarations.values.where((m) => m is VariableMirror).map((dm) => dm as VariableMirror);
    createTableSQL = _createTableSQL();
    createForeignKeySQL = _createForeignKeySQL();
    selectSQL = _selectSQL();
    insertSQL = _insertSQL();
    updateSQL = _updateSQL();
    deleteSQL = _deleteSQL();
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
    return "CREATE TABLE $tableName (\n" +
           names.join(",\n") +
           "\n);";
  }

  String _createForeignKeySQL() {
    var keys = [];
    fields.forEach((vm) {
      if (vm.type.isSubtypeOf(reflectType(Managed))) {
        var columnName = MirrorSystem.getName(vm.simpleName).toLowerCase();
        var columnTypeName = MirrorSystem.getName(vm.type.simpleName).toLowerCase();
        keys.add("ALTER TABLE $tableName ADD FOREIGN KEY (${columnName}_id) REFERENCES $columnTypeName;\n");
      }
    });
    return keys.join();
  }

  String _selectSQL() {
    var cols = [];
    fields.forEach((vm) {
      var columnName = MirrorSystem.getName(vm.simpleName);
      if (vm.type.isSubtypeOf(reflectType(Managed))) {
        // Foreign Key
        cols.add("${columnName}_id");
      } else {
        cols.add("$columnName");
      }
    });
    return "SELECT ${cols.join(', ')} FROM $tableName;";
  }

  String _insertSQL() {
    var cols = [];
    fields.forEach((vm) {
      var columnName = MirrorSystem.getName(vm.simpleName);
      if (vm.type.isSubtypeOf(reflectType(Managed))) {
        // Foreign Key
        cols.add("${columnName}_id");
      } else if (columnName == "id") {
        
      } else {
        cols.add("$columnName");
      }
    });
    var colNames = cols.join(', ');
    var valNames = cols.map((e) => "@"+e).join(', ');
    return "INSERT INTO $tableName ($colNames) VALUES ($valNames) RETURNING id;";
  }

  String _updateSQL() {
    var cols = [];
    fields.forEach((vm) {
      var columnName = MirrorSystem.getName(vm.simpleName);
      if (vm.type.isSubtypeOf(reflectType(Managed))) {
        // Foreign Key
        cols.add("${columnName}_id");
      } else if (columnName == "id") {
        
      } else {
        cols.add("$columnName");
      }
    });
    var colSetters = cols.map((e) => e+" = @"+e).join(', ');
    return "UPDATE $tableName SET $colSetters WHERE id = @id;";
  }

  String _deleteSQL() {
    return "DELETE FROM $tableName WHERE id = @id;";
  }

}