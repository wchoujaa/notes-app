import 'dart:developer';
import 'dart:io';

import 'package:notes_app/modal_class/leaf.dart';
import 'package:notes_app/modal_class/folder.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:notes_app/modal_class/notes.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper; // Singleton DatabaseHelper
  static Database _database; // Singleton Database

  String _noteTable = 'note_table';
  String _folderTable = 'folder_table';
  String _leafTable = 'leaf_table';
  String _noteTitle = 'title';
  String _noteDescription = 'description';
  String _notePriority = 'priority';
  String _noteColor = 'color';
  String _noteDate = 'date';
  String _noteId = 'n_id';
  String _folderId = 'f_id';
  String _leafId = 'l_id';
  String _folderTitle = 'title';
  String _leafTitle = 'title';

  DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // This is executed only once, singleton object
      _databaseHelper.initializeDatabase();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    // Open/create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    log("Database created");

    await db.execute('CREATE TABLE $_leafTable('
        '$_leafId INTEGER PRIMARY KEY AUTOINCREMENT, '
        '$_leafTitle TEXT,'
        '$_folderId INTEGER)');

    await db.execute('CREATE TABLE $_noteTable('
        '$_leafId INTEGER PRIMARY KEY, '
        '$_noteTitle TEXT, '
        '$_noteDescription TEXT, '
        '$_notePriority INTEGER, '
        '$_noteColor INTEGER,'
        '$_noteDate TEXT)');

    await db.execute('CREATE TABLE $_folderTable'
        '($_leafId INTEGER PRIMARY KEY, '
        '$_folderTitle INTEGER)');

    log("Database instanciated");
  }

  ////////////////////////////////   Note table operations ////////////////////////////////

  // Get the 'Map List' [ List<Map> ] and convert it to 'Leaf List' [ List<Note> ]
  Future<List<Map<String, dynamic>>> getLeafMapList() async {
    Database db = await this.database;

    //var result = await db.rawQuery('SELECT * FROM $noteTable order by $notePriority ASC');
    var result = await db.query(_leafTable);
    return result;
  }

  Future<List<Leaf>> getLeafList() async {
    var leafMapList = await getLeafMapList(); // Get 'Map List' from database
    int count =
        leafMapList.length; // Count the number of map entries in db table

    List<Leaf> leafList = List();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      leafList.add(Leaf.fromLeafMap(leafMapList[i]));
    }

    return leafList;
  }

  // Fetch Operation: Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async {
    Database db = await this.database;

    //var result = await db.rawQuery('SELECT * FROM $noteTable order by $notePriority ASC');
    var result = await db.query(_noteTable, orderBy: '$_noteTitle ASC');

    return result;
  }

  // Insert Operation: Insert a Note object to database
  Future<int> insertNote(Note note) async {
    Database db = await this.database;
    // Insert in Leaf Table

    var result = await db.insert(_leafTable, note.toLeafMap());
    note.id = result;
    // Insert in Note Table
    await db.insert(_noteTable, note.toNoteMap());
    // Insert in Leaf in Folder Table
    Map<String, dynamic> map = new Map();

    return result;
  }

  // Update Operation: Update a Note object and save it to database
  Future<int> updateNote(Note note) async {
    var db = await this.database;
    var result = await db.update(_noteTable, note.toNoteMap(),
        where: '$_noteId = ?', whereArgs: [note.id]);
    return result;
  }

  // Delete Operation: Delete a Note object from database
  Future<int> deleteNote(int id, int folderId) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $_noteTable WHERE $_leafId = $id');
    int result2 =
        await db.rawDelete('DELETE FROM $_leafTable WHERE $_leafId = $id');
    return result;
  }

  // Get number of Note objects in database
  Future<int> getNotesCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $_noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'Note List' [ List<Note> ]
  Future<List<Note>> getNoteList() async {
    Database db = await this.database;

    var noteMapList = await getNoteMapList(); // Get 'Map List' from database
    int count =
        noteMapList.length; // Count the number of map entries in db table

    List<Note> noteList = List<Note>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      Note note = Note.fromNoteMap(noteMapList[i]);
      noteList.add(note);

      var result = await db.rawQuery('SELECT $_leafTable.$_folderId FROM '
          '$_leafTable WHERE $_leafId = ${note.id}');
      if (result.isNotEmpty) note.folderId = result[0]['$_folderId'] as int;
    }
    return noteList;
  }

  ////////////////////////////////  Folder table operations ////////////////////////////////
  Future<List<Map<String, dynamic>>> getFolderMapList() async {
    Database db = await this.database;

    //		var result = await db.rawQuery('SELECT * FROM $noteTable order by $colPriority ASC');
    var result = await db.query(_folderTable);
    return result;
  }

  Future<Folder> getRoot() async {
    Database db = await this.database;
    // insert ROOT if not exist
    await db.execute('INSERT INTO $_folderTable($_leafId, $_folderTitle)'
        'SELECT 1, "root" '
        'WHERE NOT EXISTS(SELECT 1 FROM $_folderTable WHERE $_leafId = 1 );');

    await db.execute('INSERT INTO $_leafTable($_leafId, $_folderTitle, $_folderId)'
        'SELECT 1, "root", 1 '
        'WHERE NOT EXISTS(SELECT 1 FROM $_leafTable WHERE $_leafId = 1 );');

    var result =
        await db.rawQuery('SELECT * FROM $_folderTable WHERE $_leafId = 1');

    if (result.isEmpty) return null;

    ///throw error

    Folder folder = Folder.fromFolderMap(result[0]);
    folder.folderId = 1 ;
    return folder;
  }

  // Insert Operation: Insert a Folder object to database
  Future<int> insertFolder(Folder folder) async {
    Database db = await this.database;
    // Insert in Leaf Table
    var result = await db.insert(_leafTable, folder.toLeafMap());
    folder.id = result;
    // Insert in Folder Table
    await db.insert(_folderTable, folder.toFolderMap());
    return result;
  }

  Future<List<Folder>> getFolderList() async {
    Database db = await this.database;

    var folderMapList =
        await getFolderMapList(); // Get 'Map List' from database
    int count =
        folderMapList.length; // Count the number of map entries in db table
    List<Folder> folderList = List<Folder>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      Folder folder = Folder.fromFolderMap(folderMapList[i]);
      folderList.add(folder);

      var result = await db.rawQuery('SELECT $_leafTable.$_folderId FROM '
          '$_leafTable WHERE $_leafId = ${folder.id}');

      if (result.isNotEmpty) folder.folderId = result[0]['$_folderId'] as int;
    }

    return folderList;
  }

  Future<Folder> getFolder(int id) async {
    Database db = await this.database;

    var result =
        await db.rawQuery('SELECT * FROM $_folderTable WHERE $_leafId = 1');
    if (result.isEmpty) {
      return null;

      ///throw error
    } else {
      return Folder.fromFolderMap(result[0]);
    }
  }
}
