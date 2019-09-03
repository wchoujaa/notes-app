import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:notes_app/db_helper/db_helper.dart';
import 'package:notes_app/modal_class/leaf.dart';
import 'package:notes_app/modal_class/folder.dart';
import 'package:notes_app/modal_class/notes.dart';
import 'package:notes_app/screens/note_detail.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes_app/screens/search_note.dart';
import 'package:notes_app/utils/widgets.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> _noteList;
  List<Folder> _folderList;
  int _noteCount = 0;
  int axisCount = 2;
  int _folderCount = 0;
  int allCount = 0;
  Folder _currentFolder;
  Folder _rootFolder;
  List<Folder> folderNavigationState = new List();
  int notesInFolderList = 0;
  List<Leaf> _leafList;

  @override
  void initState() {
    super.initState();
    updateListView();
  }

  String getCurrentPath() {
    String currentPath = "";
    for (Folder folder in folderNavigationState) {
      currentPath += folder.title + "/";
    }
    return currentPath;
  }

  List<Note> getNoteInFolder(Folder folder) {
    List<Note> noteInFolder = new List();

    for (Leaf leaf in _leafList) {
      var l_id = leaf.id;

      for (Note note in _noteList) {
        if (l_id == note.id) {
          noteInFolder.add(note);
        }
      }
    }

    return noteInFolder;
  }

  List<Leaf> getLeafInFolder(Folder parentFolder) {
    List<Leaf> leafList = new List();

    for (Leaf leaf in _leafList) {
      var l_id = leaf.id;
      var f_id = leaf.folderId;
      for (Note note in _noteList) {
        if (l_id == note.id && f_id == parentFolder.id) {
          leafList.add(note);
        }
      }
      for (Folder folder in _folderList) {
        if (folder.id == _rootFolder.id) continue;
        if (l_id == folder.id && f_id == parentFolder.id) {
          leafList.add(folder);
        }
      }
    }

    return leafList;
  }

  @override
  Widget build(BuildContext context) {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();

    Widget myAppBar() {
      return AppBar(
        title: Text('Notes', style: Theme.of(context).textTheme.headline),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: _noteCount == 0
            ? Container()
            : IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                onPressed: () async {
                  final Note result = await showSearch(
                      context: context,
                      delegate: NotesSearch(notes: _noteList));
                  if (result != null) {
                    navigateToDetail(result, 'Edit Note');
                  }
                },
              ),
        actions: <Widget>[
          _noteCount == 0
              ? Container()
              : IconButton(
                  icon: Icon(
                    axisCount == 2 ? Icons.list : Icons.grid_on,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      axisCount = axisCount == 2 ? 4 : 2;
                    });
                  },
                )
        ],
      );
    }

    getFolder(Folder folder) {
      return GestureDetector(
        onTap: () {
          folderNavigationState.add(folder);
          navigateTo(folder);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.black),
                borderRadius: BorderRadius.circular(8.0)),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          folder.title,
                          style: Theme.of(context).textTheme.body1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    getModal() {
      return Positioned(
        top: 50,
        right: 50,
        child: new Card(
          child: new Row(children: [
            new CircleAvatar(
              backgroundImage: new AssetImage('folder.jpg'),
              radius: 100.0,
            ),
            new Text(
              'News Location',
              style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ]),
        ),
      );
    }

    Widget getLeafList() {
      List<Leaf> leafInFolder = getLeafInFolder(_currentFolder);
      int noteInFolderCount = leafInFolder.length;

      return new Expanded(
        child: new StaggeredGridView.countBuilder(
            physics: BouncingScrollPhysics(),
            crossAxisCount: 4,
            staggeredTileBuilder: (int index) => StaggeredTile.fit(axisCount),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            itemCount: noteInFolderCount,
            itemBuilder: (context, index) {
              Leaf leaf = leafInFolder[index];

              if (leaf is Note) {
                Note note = leaf;
                return GestureDetector(
                  onTap: () {
                    navigateToDetail(leaf, 'Edit Note');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: colors[note.color],
                          border: Border.all(width: 2, color: Colors.black),
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    leafInFolder[index].title,
                                    style: Theme.of(context).textTheme.body1,
                                  ),
                                ),
                              ),
                              Text(
                                getPriorityText(note.priority),
                                style: TextStyle(
                                    color: getPriorityColor(note.priority)),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                      note.description == null
                                          ? ''
                                          : note.description,
                                      style: Theme.of(context).textTheme.body2),
                                )
                              ],
                            ),
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Text(note.date,
                                    style:
                                        Theme.of(context).textTheme.subtitle),
                              ])
                        ],
                      ),
                    ),
                  ),
                );
              } else if (leaf is Folder) {
                Folder folder = leaf;

                return getFolder(folder);
              } else {
                return Text('Error loading the note');
              }
            }),
      );
    }

    Widget getInfoBar() {
      return new Container(
        child: Text(
          getCurrentPath(),
          style: TextStyle(color: Colors.blue, fontSize: 30.0),
        ),
      );
    }

    var leafCount = getLeafInFolder(_currentFolder).length;

    Widget getEmptyPage() {
      return Container(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Click on the add button to add a new note!',
                style: Theme.of(context).textTheme.body1),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: myAppBar(),
      body: Column(
        children: [
          getInfoBar(),
          leafCount == 0 ? getEmptyPage() : getLeafList()
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigateToDetail(Note('', '', 3, 0), 'Add Note');
        },
        label: const Text('Add a Note'),
        tooltip: 'Add Note',
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Folder folder = (folderNavigationState.isNotEmpty)
                    ? folderNavigationState.removeLast()
                    : _rootFolder;

                Folder parent = getFolderFrom(folder.folderId);

                navigateTo(parent);
                updateListView();
              },
            ),
            new Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit),
                    alignment: Alignment.centerRight,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: Icon(Icons.folder),
                    onPressed: () {
                      databaseHelper.insertFolder(
                        new Folder("", _currentFolder.id),
                      );
                      updateListView();
                    },
                  ),
                ])
          ],
        ),
      ),
    );
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      case 3:
        return Colors.green;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  String getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return '!!!';
        break;
      case 2:
        return '!!';
        break;
      case 3:
        return '!';
        break;

      default:
        return '!';
    }
  }

  // void _delete(BuildContext context, Note note) async {
  //   int result = await databaseHelper.deleteNote(note.id);
  //   if (result != 0) {
  //     _showSnackBar(context, 'Note Deleted Successfully');
  //     updateListView();
  //   }
  // }

  // void _showSnackBar(BuildContext context, String message) {
  //   final snackBar = SnackBar(content: Text(message));
  //   Scaffold.of(context).showSnackBar(snackBar);
  // }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NoteDetail(note, _currentFolder, title)));

    if (result == true) {
      updateListView();
    }
  }

  Future updateListView() async {
    Folder rootFolder = await databaseHelper.getRoot();
    this._rootFolder = rootFolder;

    if (_currentFolder == null) {
      this._currentFolder = rootFolder;
      log('${_currentFolder.title}');
    }

    List<Note> noteList = await databaseHelper.getNoteList();

    setState(() {
      this._noteList = noteList;
      this._noteCount = noteList.length;
    });

    List<Folder> folderList = await databaseHelper.getFolderList();

    setState(() {
      this._folderList = folderList;
      this._folderCount = folderList.length;
    });

    List<Leaf> leafList = await databaseHelper.getLeafList();

    setState(() {
      this._leafList = leafList;
    });
  }

  void navigateTo(Folder folder) {
    _currentFolder = folder;
    updateListView();
  }

  Folder getFolderFrom(int folderId) {
    for (Folder folder in _folderList) {
      if (folder.id == folderId) {
        return folder;
      }
    }
    return _rootFolder;
  }
}
