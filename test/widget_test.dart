// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/db_helper/db_helper.dart';

import 'package:notes_app/main.dart';
import 'package:notes_app/modal_class/folder.dart';

void main() {


  test("Database insert Folder", () async {
    DatabaseHelper helper = DatabaseHelper();
    Folder root = await helper.getRoot();

    Folder folderTest = new Folder("test", 1);
    helper.insertFolder(folderTest);

    List<Folder> folderList = await helper.getFolderList();

    expect(folderList.length, 1);
    expect(folderList[0].title, "test");
  });
}
