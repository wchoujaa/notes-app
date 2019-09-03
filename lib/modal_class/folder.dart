import 'leaf.dart';

class Folder extends Leaf{
  Folder(String title, int parentId) : super(title, parentId);

  Folder.fromFolderMap(Map<String, dynamic> map) : super(map['title']) {
    id = map['l_id'];
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toFolderMap() {
    var map = Map<String, dynamic>();
    if (id != null) {
      map['l_id'] = id;
    }
    map['title'] = title;
    return map;
  }
}
