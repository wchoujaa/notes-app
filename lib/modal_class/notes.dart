import 'leaf.dart';

class Note extends Leaf {

  String _description;
  String _date;
  int _priority, _color;
  String get description => _description;
  int get priority => _priority;
  int get color => _color;
  String get date => _date;

  Note(title, this._date, this._priority, this._color,
      [this._description]) : super(title);

  Note.withId(id, title, this._date, this._priority, this._color,
      [this._description]) : super(id, title);

  // Extract a Note object from a Map object
  Note.fromNoteMap(Map<String, dynamic> map) : super(map['title']) {
    this.id = map['l_id'];
    this._description = map['description'];
    this._priority = map['priority'];
    this._color = map['color'];
    this._date = map['date'];
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toNoteMap() {
    var map = Map<String, dynamic>();

    map['l_id'] = id;
    map['title'] = title;
    map['description'] = _description;
    map['priority'] = _priority;
    map['color'] = _color;
    map['date'] = _date;

    return map;
  }


  set description(String newDescription) {
    if (newDescription.length <= 255) {
      this._description = newDescription;
    }
  }

  set priority(int newPriority) {
    if (newPriority >= 1 && newPriority <= 3) {
      this._priority = newPriority;
    }
  }

  set color(int newColor) {
    if (newColor >= 0 && newColor <= 9) {
      this._color = newColor;
    }
  }

  set date(String newDate) {
    this._date = newDate;
  }



}
