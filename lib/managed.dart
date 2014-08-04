import 'dart:async';

class Managed {
  var manager;

  Future<bool> save() {
    return manager.save(this);
  }

  Future<bool> delete() {
    return manager.delete(this);
  }
}