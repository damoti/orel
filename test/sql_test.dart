import 'package:unittest/unittest.dart';
import 'package:orel/orel.dart';
import 'package:orel/managed.dart';

class Address extends Managed {
  int id;
  String street;
}

class Person extends Managed {
  int id;
  String name;
  Address addr;
}

void main() {
  Manager m = new Manager<Person>();

  group("DDL", () {

    test("create table", () {
        expect(m.sql.createTableSQL,
            equals("CREATE TABLE person (\n"
                   "  id serial PRIMARY KEY,\n"
                   "  name text,\n"
                   "  addr_id integer NOT NULL\n"
                   ");"));
    });

    test("create foreign key", () {
      expect(m.sql.createForeignKeySQL,
          equals("ALTER TABLE person ADD FOREIGN KEY (addr_id) REFERENCES address;\n"));
    });

  });
  
  group("SQL", () {

    test("select", () {
      expect(m.sql.selectSQL,
          equals("SELECT id, name, addr_id FROM person;"));
    });
    
    test("insert", () {
      expect(m.sql.insertSQL,
          equals("INSERT INTO person (name, addr_id) VALUES (@name, @addr_id) RETURNING id;"));
    });
    
    test("update", () {
      expect(m.sql.updateSQL,
          equals("UPDATE person SET name = @name, addr_id = @addr_id WHERE id = @id;"));
    });

    test("delete", () {
      expect(m.sql.deleteSQL,
          equals("DELETE FROM person WHERE id = @id;"));
    });

  });
  /*m.get(9).then((Person p) {
    p.save().then((bool success) {
      
    });
  });*/

}