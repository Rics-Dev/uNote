import 'dart:convert';

import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:utask/main.dart';
import 'package:utask/models/entities.dart';
import 'package:utask/objectbox.g.dart';

import '../providers/note_provider.dart';
import '../providers/notebook.dart';
import '../providers/taskProvider.dart';
import '../widgets/inboxPage/horizontal_tags_view.dart';
import '../widgets/inboxPage/search_disposition_view.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

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

  final LocalAuthentication auth = LocalAuthentication();
  final _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  bool showSecondTabBar = false;

  // TabController? _tabController2;

  @override
  void initState() {
    super.initState();
    // _tabController2 = TabController(length: 1, vsync: this);
    updateTabController();
    // auth.isDeviceSupported().then(
    //       (bool isSupported) => setState(() => _supportState = isSupported
    //           ? _SupportState.supported
    //           : _SupportState.unsupported),
    //     );
  }

  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason: 'Let OS determine authentication method',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
        localizedReason:
            'Scan your fingerprint (or face or whatever) to authenticate',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Error - ${e.message}';
      });
      return;
    }
    if (!mounted) {
      return;
    }

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
    });
  }

  Future<void> _cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => _isAuthenticating = false);
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
        initialIndex: _selectedTabIndex,
      );
    }
  }

  void handleTabControllerUpdate(int noteBookPosition) {
    if (_tabController != null) {
      _tabController!.animateTo(
        noteBookPosition + 2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
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

                context.read<NotesProvider>().setSelectedNoteBook(index);

                // if (index > 1 && index < noteBooks.length + 2) {
                //   setState(() {
                //     showSecondTabBar = true;
                //   });
                // } else {
                //   setState(() {
                //     showSecondTabBar = false;
                //   });
                // }

                // if (index == 0) {
                //   _checkBiometrics();
                //   _getAvailableBiometrics();
                //   _authenticate();
                //   _authenticateWithBiometrics();
                // }
              },
              tabs: [
                const Tab(
                  icon: Icon(
                    Icons.star,
                    size: 20,
                  ),
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
          // AnimatedContainer(
          //   duration: const Duration(milliseconds: 300),
          //   height: showSecondTabBar ? 40 : 0,
          //   child: showSecondTabBar
          //       ? Container(
          //           height: 40,
          //           decoration: BoxDecoration(
          //             boxShadow: [
          //               BoxShadow(
          //                 color: Colors.grey.shade300,
          //                 spreadRadius: 1,
          //                 blurRadius: 10,
          //                 offset: const Offset(0, 10),
          //               ),
          //             ],
          //             color: Colors.white,
          //           ),
          //           child: TabBar(
          //             tabAlignment: TabAlignment.start,
          //             controller: _tabController2,
          //             isScrollable: true,
          //             tabs: const [
          //               Tab(
          //                 icon: Icon(Icons.star),
          //               ),
          //             ],
          //           ),
          //         )
          //       : const SizedBox.shrink(),
          // ),
          const SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,
              children: [
                NoteListPage(
                  NoteBook(
                      name: 'Favorites',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now()),
                  onNavigateToNoteBook: handleTabControllerUpdate,
                ),
                NoteListPage(
                  NoteBook(
                      name: 'All Notes Ric',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now()),
                  onNavigateToNoteBook: handleTabControllerUpdate,
                ),
                ...noteBooks
                    .map((noteBook) => NoteListPage(
                          noteBook,
                          onNavigateToNoteBook: handleTabControllerUpdate,
                        ))
                    .toList(),
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
  final Function(int) onNavigateToNoteBook;
  const NoteListPage(this.noteBook,
      {super.key, required this.onNavigateToNoteBook});

  Future<dynamic> _showAddNoteDetailsDialog(BuildContext context, Note note) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => NoteDetailPage(note: note),
      isScrollControlled: true,
      // showDragHandle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final disposition = notesProvider.selectedView;
    final selectedNoteBook = notesProvider.selectedNoteBook;
    var notes = notesProvider.notes;
    var allNoteBooks = notesProvider.noteBooks;

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
                            _showAddNoteDetailsDialog(context, notes[index]);
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
                            trailing: notes[index].notebook.target != null &&
                                    selectedNoteBook <= 1
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 32,
                                        width: 75,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            elevation: 2,
                                            textStyle: const TextStyle(
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            padding: const EdgeInsets.all(4),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            final noteBook =
                                                notes[index].notebook.target;

                                            final noteBookPosition =
                                                allNoteBooks.indexWhere((nb) =>
                                                    nb.id == noteBook!.id);
                                            if (noteBookPosition != -1) {
                                              onNavigateToNoteBook(
                                                  noteBookPosition);
                                            }
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.book_rounded),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Flexible(
                                                child: Text(notes[index]
                                                        .notebook
                                                        .target
                                                        ?.name ??
                                                    ''),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // const SizedBox(
                                      //   height: 5,
                                      // ),
                                      const Spacer(),
                                      Text(
                                        // DateFormat.yMMMd().format(notes[index].updatedAt),
                                        notes[index]
                                            .createdAt
                                            .toString()
                                            .substring(0, 10),
                                      ),
                                      // const Icon(Icons.more_horiz_rounded),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                          // DateFormat.yMMMd().format(notes[index].updatedAt),
                                          notes[index]
                                              .createdAt
                                              .toString()
                                              .substring(0, 10)),
                                    ],
                                  ),
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
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    maxLines: 1,
                                    // noteBook.notes[index].content,
                                    notes[index].content,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey[600]),
                                    overflow: TextOverflow.ellipsis,
                                    // maxLines: 2,
                                  ),
                                  // const SizedBox(
                                  //   height: 10,
                                  // ),
                                  // Text(
                                  //   // DateFormat.yMMMd().format(notes[index].updatedAt),
                                  //   notes[index]
                                  //       .updatedAt
                                  //       .toString()
                                  //       .substring(0, 10),
                                  // ),
                                ],
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
                    child: GestureDetector(
                      onTap: () {
                        _showAddNoteDetailsDialog(context, notes[index]);
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
                ),
              );
            },
          );
  }
}

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({super.key, required this.note});
  final Note note;

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final QuillController _contentController = QuillController.basic();
  final TextEditingController _titleController = TextEditingController();
  FocusNode contentFocusNode = FocusNode();

  bool _isEditing = false;

  // FocusNode titleFocusNode = FocusNode();
  // FocusNode contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    final jsonNote = widget.note.json;
    final json = jsonDecode(jsonNote);
    _contentController.document = Document.fromJson(json);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    // titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final selectedNoteBookIndex = notesProvider.selectedNoteBook;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: Scaffold(
          appBar: AppBar(
            elevation: 3,
            title: TextField(
              readOnly: _isEditing ? false : true,
              // focusNode: titleFocusNode,
              controller: _titleController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Title',
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              _isEditing
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          final title = _titleController.text;
                          final content =
                              _contentController.document.toPlainText().trim();
                          final json = jsonEncode(
                              _contentController.document.toDelta().toJson());
                          if (title.isNotEmpty || content.isNotEmpty) {
                            context.read<NotesProvider>().updateNote(
                                widget.note.id,
                                title,
                                content,
                                json,
                                selectedNoteBookIndex);
                          }
                        });
                      },
                      icon: const Icon(Icons.done),
                    )
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = true;
                        });
                      },
                      icon: const Icon(Icons.edit),
                    ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        textStyle:
                            const TextStyle(overflow: TextOverflow.ellipsis),
                        padding: const EdgeInsets.all(4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.book_rounded),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(widget.note.notebook.target?.name ?? ''),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.star_border_outlined,
                      size: 28,
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: _isEditing,
                child: QuillToolbar.simple(
                  configurations: QuillSimpleToolbarConfigurations(
                    multiRowsDisplay: false,
                    controller: _contentController,
                    sharedConfigurations: const QuillSharedConfigurations(
                      locale: Locale('en'),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, top: 12.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Words: ${_contentController.document.toPlainText().split(RegExp(r'\s+')).length}',
                    ),
                    Text(
                      widget.note.updatedAt.toString().substring(0, 16),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Focus(
                  focusNode: contentFocusNode,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 14),
                    child: QuillEditor.basic(
                      configurations: QuillEditorConfigurations(
                        // onImagePaste: (imageBytes) {

                        // },
                        placeholder: 'Note Content...',
                        readOnly: _isEditing ? false : true,
                        // autoFocus: true,
                        controller: _contentController,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
