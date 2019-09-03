import 'package:flutter/cupertino.dart';

class Leaf {
  int _id;
  int _fId;
  String _title;

  int get id => _id;

  int get folderId => _fId;

  String get title => _title;

  Leaf(this._title, [ this._fId]);

  // Extract a Note object from a Map object
  Leaf.fromLeafMap(Map<String, dynamic> map) {
    this._id = map['l_id'];
    this._fId = map['f_id'];
    this._title = map['title'];
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toLeafMap() {
    var map = Map<String, dynamic>();
    map['l_id'] = _id;
    map['f_id'] = _fId;
    map['title'] = _title;
    return map;
  }

  set title(String newTitle) {
    if (newTitle.length <= 255) {
      this._title = newTitle;
    }
  }

  set id(int id) {
    this._id = id;
  }

  set folderId(int fId) {
    this._fId = fId;
  }
}
