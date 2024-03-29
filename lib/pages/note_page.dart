import 'dart:convert';

import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:utask/main.dart';
import 'package:utask/models/entities.dart';
import 'package:utask/objectbox.g.dart';

import '../providers/note_provider.dart';
import '../providers/notebook.dart';
import '../providers/taskProvider.dart';
import '../widgets/inboxPage/horizontal_tags_view.dart';
import '../widgets/inboxPage/search_disposition_view.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> with TickerProviderStateMixin {
  TextEditingController noteBookController = TextEditingController();
  TabController? _tabController;
  NoteBookProvider? _noteBookProvider;
  int _selectedTabIndex = 1;
  final int _previouslySelectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    updateTabController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _noteBookProvider = Provider.of<NoteBookProvider>(context);
    _noteBookProvider?.addListener(updateTabController);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    noteBookController.dispose();
    _noteBookProvider?.removeListener(updateTabController);
    super.dispose();
  }

  void updateTabController() {
    if (mounted) {
      final noteBookProvider =
          Provider.of<NotesProvider>(context, listen: false);
      final noteBooks = noteBookProvider.noteBooks;
      if (_tabController != null) {
        _selectedTabIndex = _tabController!.index;
        noteBookProvider.setSelectedNoteBook(_tabController!.index);
      }

      _tabController = TabController(
          length: noteBooks.length + 3,
          vsync: this,
          initialIndex: _selectedTabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final noteBooks = notesProvider.noteBooks;

    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: const Column(
              children: [
                SortAndFilterView(),
                // HorizontalTagsView(),
              ],
            ),
          ),
          Container(
            height: 50,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 10), // changes position of shadow
                ),
              ],
              color: Colors.white,
            ),
            child: TabBar(
              tabAlignment: TabAlignment.start,
              controller: _tabController,
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.tab,
              onTap: (index) {
                if (index == noteBooks.length + 2) {
                  // If "Add Notebook" tab is tapped
                  _showAddNotebookDialog(context);
                  // _selectedTabIndex = noteBooks.length + 1;
                }
                // if (index > 1 && index < noteBooks.length + 2) {
                context.read<NotesProvider>().setSelectedNoteBook(index);
                // }
              },
              tabs: [
                const Tab(
                  icon: Icon(Icons.star),
                ),
                const Tab(text: 'All Notes'),
                ...noteBooks
                    .map(
                      (noteBook) => GestureDetector(
                        onLongPress: () {
                          deleteNoteBook(context, noteBook);
                        },
                        child: Tab(
                          // text: noteBook.name,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.book_rounded),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(noteBook.name),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
                const Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add),
                      // SizedBox(
                      //   width: ,
                      // ),
                      Text('NoteBook'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                const Placeholder(),
                // TasksViewInboxPage(),
                NoteListPage(NoteBook(
                    name: 'All Notes Ric',
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now())),
                ...noteBooks.map((noteBook) => NoteListPage(noteBook)).toList(),
                _buildAddNotebookPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> deleteNoteBook(BuildContext context, NoteBook noteBook) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog.adaptive(
          elevation: 5,
          actionsAlignment: MainAxisAlignment.center,
          title: const Text('Delete NoteBook?'),
          content: const Text('Are you sure you want to delete this Notebook?'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                context.read<NotesProvider>().deleteNotebook(noteBook.id);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAddNotebookPage() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _showAddNotebookDialog(context);
        },
        child: const Text('Add Notebook'),
      ),
    );
  }

  void _showAddNotebookDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Notebook'),
          content: TextField(
            controller: noteBookController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Notebook Name'),
            onChanged: (value) {
              // Handle onChanged if needed
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _tabController?.animateTo(
                  _tabController!.previousIndex, // index of the new notebook
                  duration: const Duration(
                      milliseconds: 300), // optional animation duration
                  curve: Curves.ease, // optional animation curve
                );
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<NotesProvider>().addNotebook(NoteBook(
                    name: noteBookController.text,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now()));
                _tabController?.animateTo(
                  _tabController!.length - 1, // index of the new notebook
                  duration: const Duration(
                      milliseconds: 300), // optional animation duration
                  curve: Curves.ease, // optional animation curve
                );
                noteBookController.clear();
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class NoteListPage extends StatelessWidget {
  final NoteBook noteBook;
  const NoteListPage(
    this.noteBook, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final disposition = notesProvider.selectedView;
    var notes = notesProvider.notes;

    noteBook.name == 'All Notes Ric'
        ? notes = notesProvider.notes
        : notes = notesProvider.notes
            .where((note) => note.notebook.target?.id == noteBook.id)
            .toList();

    if (notesProvider.isSearchingNotes == true) {
      noteBook.name == 'All Notes Ric'
          ? notes = notesProvider.searchedNotes
          : notes = notesProvider.searchedNotes
              .where((note) => note.notebook.target?.id == noteBook.id)
              .toList();
    }

    if (notesProvider.filteredNotes.isNotEmpty) {
      notes = notesProvider.filteredNotes;
    }

    const options = LiveOptions(
      delay: Duration(seconds: -5),
      showItemInterval: Duration(milliseconds: 100),
      showItemDuration: Duration(milliseconds: 100),
      visibleFraction: 0.01,
      reAnimateOnVisibility: false,
    );

    return disposition == 'list'
        ? LiveList.options(
            // reverse: true,
            options: options,
            itemCount: notes.length,
            itemBuilder: (context, index, animation) {
              return FadeTransition(
                opacity: Tween<double>(
                  begin: 0,
                  end: 1,
                ).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12, 8.0),
                    child: Dismissible(
                      key: UniqueKey(),
                      onDismissed: (direction) {
                        context
                            .read<NotesProvider>()
                            .deleteNote(notes[index].id);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          // color: const Color.fromARGB(255, 243, 243, 243),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(
                                  0, 5), // changes position of shadow
                            ),
                          ],
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         NoteDetailPage(note: notes[index]),
                            //   ),
                            // );
                            context
                                .go("/noteDetails?noteId=${notes[index].id}");
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog.adaptive(
                                  elevation: 5,
                                  // icon: const Icon(Icons.delete,
                                  //     color: Colors.red),
                                  actionsAlignment: MainAxisAlignment.center,
                                  title: const Text('Delete Note?'),
                                  content: const Text(
                                      'Are you sure you want to delete this note?'),
                                  actions: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        context
                                            .read<NotesProvider>()
                                            .deleteNote(notes[index].id);
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: ListTile(
                            // visualDensity: VisualDensity.compact,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            title: Text(
                              notes[index].title,
                              // noteBook.notes[index].title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                maxLines: 1,
                                // noteBook.notes[index].content,
                                notes[index].content,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                                overflow: TextOverflow.ellipsis,
                                // maxLines: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : LiveGrid.options(
            options: options,
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1,
              crossAxisCount: 2,
              crossAxisSpacing: 1.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index, animation) {
              return FadeTransition(
                opacity: Tween<double>(
                  begin: 0,
                  end: 1,
                ).animate(animation),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 5), // changes position of shadow
                          ),
                        ],
                        // color: const Color.fromARGB(255, 245, 245, 245),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        children: [
                          Flexible(
                            child: Text(
                              notes[index].title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w500),
                              maxLines: 2,
                              // overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Flexible(
                            child: Text(
                              notes[index].content,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                              // overflow: TextOverflow.ellipsis,
                              // maxLines: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
  }
}

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({super.key, required this.noteId});
  final int noteId;

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final TextEditingController _titleController = TextEditingController();
  final QuillController _contentController = QuillController.basic();
  bool _isEditing = false;
  late Note note;

  @override
  void initState() {
    super.initState();
    note = objectbox.noteBox.get(widget.noteId)!;
    _titleController.text = note.title;
    final jsonNote = note.json;
    final json = jsonDecode(jsonNote);
    _contentController.document = Document.fromJson(json);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        title: _isEditing
            ? TextField(
                autofocus: true,
                controller: _titleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Title',
                ),
              )
            : Text(
                _titleController.text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: !_isEditing
            ? [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                  icon: const Icon(Icons.edit),
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          Visibility(
            visible: _isEditing,
            child: QuillToolbar.simple(
              configurations: QuillSimpleToolbarConfigurations(
                multiRowsDisplay: true,
                controller: _contentController,
                sharedConfigurations: const QuillSharedConfigurations(
                  locale: Locale('en'),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24),
              child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(
                  readOnly: _isEditing ? false : true,
                  controller: _contentController,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
