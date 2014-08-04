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
  /*m.get(9).then((Person p) {
    p.save().then((bool success) {
      
    });
  });*/

}