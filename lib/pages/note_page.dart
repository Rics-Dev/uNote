import 'dart:convert';

import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:utask/models/entities.dart';

import '../providers/note_provider.dart';
import '../providers/notebook.dart';
import '../widgets/notePageWidgets/search_disposition_view.dart';

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

  final LocalAuthentication auth = LocalAuthentication();
  // ignore: unused_field
  _SupportState _supportState = _SupportState.unknown;
  // bool? _canCheckBiometrics;
  // List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  bool showSecondTabBar = false;

  // TabController? _tabController2;

  @override
  void initState() {
    super.initState();
    // _tabController2 = TabController(length: 1, vsync: this);
    updateTabController();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
  }

  // Future<void> _checkBiometrics() async {
  //   late bool canCheckBiometrics;
  //   try {
  //     canCheckBiometrics = await auth.canCheckBiometrics;
  //   } on PlatformException catch (e) {
  //     canCheckBiometrics = false;
  //     print(e);
  //   }
  //   if (!mounted) {
  //     return;
  //   }

  //   setState(() {
  //     _canCheckBiometrics = canCheckBiometrics;
  //   });
  // }

  // Future<void> _getAvailableBiometrics() async {
  //   late List<BiometricType> availableBiometrics;
  //   try {
  //     availableBiometrics = await auth.getAvailableBiometrics();
  //   } on PlatformException catch (e) {
  //     availableBiometrics = <BiometricType>[];
  //     print(e);
  //   }
  //   if (!mounted) {
  //     return;
  //   }

  //   setState(() {
  //     _availableBiometrics = availableBiometrics;
  //   });
  // }

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

    if (_authorized == 'Not Authorized') {
      failedAuthetication();
    }
  }

  // Future<void> _authenticateWithBiometrics() async {
  //   bool authenticated = false;
  //   try {
  //     setState(() {
  //       _isAuthenticating = true;
  //       _authorized = 'Authenticating';
  //     });
  //     authenticated = await auth.authenticate(
  //       localizedReason:
  //           'Scan your fingerprint (or face or whatever) to authenticate',
  //       options: const AuthenticationOptions(
  //         stickyAuth: true,
  //         biometricOnly: true,
  //       ),
  //     );
  //     setState(() {
  //       _isAuthenticating = false;
  //       _authorized = 'Authenticating';
  //     });
  //   } on PlatformException catch (e) {
  //     print(e);
  //     setState(() {
  //       _isAuthenticating = false;
  //       _authorized = 'Error - ${e.message}';
  //     });
  //     return;
  //   }
  //   if (!mounted) {
  //     return;
  //   }

  //   final String message = authenticated ? 'Authorized' : 'Not Authorized';
  //   setState(() {
  //     _authorized = message;
  //   });

  //   if (_authorized == 'Not Authorized') {
  //     failedAuthetication();
  //   }
  // }

  // Future<void> _cancelAuthentication() async {
  //   await auth.stopAuthentication();
  //   setState(() => _isAuthenticating = false);
  // }

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
      context.read<NotesProvider>().setSelectedNoteBook(noteBookPosition + 2);
    }
  }

  void failedAuthetication() {
    if (_tabController != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tabController!.animateTo(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
        context.read<NotesProvider>().setSelectedNoteBook(1);
      });
    }
    toastification.show(
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      context: context,
      title: const Text('Unable to authenticate'),
      autoCloseDuration: const Duration(seconds: 5),
    );
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

                if (index == 0) {
                  // _checkBiometrics();
                  // _getAvailableBiometrics();
                  _authenticate();
                  // _authenticateWithBiometrics();
                }
              },
              tabs: [
                const Tab(
                  icon: Icon(
                    Icons.shield_outlined,
                    size: 20,
                  ),
                ),
                const Tab(text: 'All Notes'),
                ...noteBooks
                    .map(
                      (noteBook) => GestureDetector(
                        onLongPress: () {
                          deleteNoteBook(context, noteBook);
                          _tabController?.animateTo(
                            _selectedTabIndex - 1, // index of the new notebook
                            duration: const Duration(
                                milliseconds:
                                    300), // optional animation duration
                            curve: Curves.ease, // optional animation curve
                          );
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
                _isAuthenticating
                    ? const Center(child: CircularProgressIndicator())
                    : _authorized == 'Authorized'
                        ? NoteListPage(
                            NoteBook(
                              name: 'All Notes Ric are secured',
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            ),
                            onNavigateToNoteBook: handleTabControllerUpdate,
                          )
                        : const SizedBox(),
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
    List<Note> notes = notesProvider.notes;
    List<NoteBook> allNoteBooks = notesProvider.noteBooks;

    if (noteBook.name == 'All Notes Ric') {
      notes = notesProvider.notes.where((note) => !note.isSecured).toList();
    } else if (noteBook.name == 'All Notes Ric are secured') {
      notes = notesProvider.notes.where((note) => note.isSecured).toList();
    } else {
      notes = notesProvider.notes
          .where((note) => note.notebook.target?.id == noteBook.id)
          .toList();
    }

    if (notesProvider.isSearchingNotes) {
      notes = noteBook.name == 'All Notes Ric'
          ? notesProvider.searchedNotes
              .where((note) => !note.isSecured)
              .toList()
          : noteBook.name == 'All Notes Ric are secured'
              ? notesProvider.searchedNotes
                  .where((note) => note.isSecured)
                  .toList()
              : notesProvider.searchedNotes
                  .where((note) => note.notebook.target?.id == noteBook.id)
                  .toList();
    }

    if (notesProvider.sortedNotes.isNotEmpty) {
      notes = notesProvider.sortedNotes;
    }

    const options = LiveOptions(
      delay: Duration(seconds: -5),
      showItemInterval: Duration(milliseconds: 100),
      showItemDuration: Duration(milliseconds: 100),
      visibleFraction: 0.01,
      reAnimateOnVisibility: false,
    );

    return disposition == 'list' || disposition == 'compactList'
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
                        height: disposition == 'compactList' ? 50 : null,
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
                            trailing: disposition == 'list'
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Visibility(
                                        visible: notes[index].isSecured,
                                        child: SizedBox(
                                          width: 40,
                                          height: 40,
                                          child: IconButton(
                                              onPressed: () {
                                                context
                                                    .read<NotesProvider>()
                                                    .updateSecuredNote(
                                                        notes[index].id);
                                              },
                                              icon: const Icon(
                                                Icons.shield_rounded,
                                                color: Color.fromARGB(
                                                    255, 0, 73, 133),
                                              )),
                                        ),
                                      ),
                                      Visibility(
                                        visible: !notes[index].isSecured &&
                                            notes[index].notebook.target !=
                                                null &&
                                            selectedNoteBook <= 1,
                                        child: SizedBox(
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
                                                  allNoteBooks.indexWhere(
                                                      (nb) =>
                                                          nb.id ==
                                                          noteBook!.id);
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
                                      ),
                                      const Spacer(),
                                      Text(
                                        notes[index]
                                            .createdAt
                                            .toString()
                                            .substring(0, 10),
                                      ),
                                      // const Icon(Icons.more_horiz_rounded),
                                    ],
                                  )
                                : Text(
                                    notes[index]
                                        .createdAt
                                        .toString()
                                        .substring(0, 10),
                                  ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            title: Text(
                              notes[index].title,
                              // noteBook.notes[index].title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Visibility(
                              visible: disposition == 'list',
                              child: Padding(
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
                                          fontSize: 14,
                                          color: Colors.grey[600]),
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
                      child: Card(
                        surfaceTintColor: Colors.white,
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Flexible(
                                child: Text(
                                  notes[index].title,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600),
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
    contentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final note = notesProvider.getNoteById(widget.note.id) ?? widget.note;
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
                            context.read<NotesProvider>().updateNote(note.id,
                                title, content, json, selectedNoteBookIndex);
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
              IconButton(
                  onPressed: () {
                    context.read<NotesProvider>().deleteNote(note.id);
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.delete,
                  )),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Visibility(
                      visible: !note.isSecured,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          textStyle:
                              const TextStyle(overflow: TextOverflow.ellipsis),
                          padding: const EdgeInsets.all(4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onPressed: () {
                          showAddNoteBookDialog(context, note);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.book_rounded),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(note.notebook.target?.name ?? '+ Notebook'),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {
                        context.read<NotesProvider>().updateSecuredNote(
                              note.id,
                            );
                      },
                      icon: note.isSecured
                          ? const Icon(
                              Icons.shield_rounded,
                              size: 28,
                              color: Color.fromARGB(255, 0, 73, 133),
                            )
                          : const Icon(Icons.shield_outlined, size: 28),
                    ),
                    // IconButton(
                    //   onPressed: () {
                    //     context.read<NotesProvider>().updateFavoriteNote(
                    //           note.id,
                    //         );
                    //   },
                    //   icon: note.isFavorite
                    //       ? const Icon(Icons.star,
                    //           size: 28, color: Color.fromARGB(255, 0, 73, 133))
                    //       : const Icon(Icons.star_border_outlined, size: 28),
                    // ),
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
                      'Words: ${note.content.trim().isNotEmpty ? note.content.trim().split(RegExp(r'\s+')).length : 0}',
                    ),
                    Text(
                      note.updatedAt.toString().substring(0, 16),
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

  Future<dynamic> showAddNoteBookDialog(BuildContext context, Note note) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => AddNoteBook(note: note),
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
    );
  }
}

class AddNoteBook extends StatefulWidget {
  const AddNoteBook({super.key, required this.note});
  final Note note;

  @override
  State<AddNoteBook> createState() => _AddNoteBookState();
}

class _AddNoteBookState extends State<AddNoteBook> {
  final TextEditingController noteBookController = TextEditingController();

  @override
  void dispose() {
    noteBookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final noteBooks = context.watch<NotesProvider>().noteBooks;
    final searchedNoteBooks = context.watch<NotesProvider>().searchedNoteBooks;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SizedBox(
        // padding: const EdgeInsets.only(top: 8),
        // width: MediaQuery.of(context).size.width * 0.90,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            const Text(
              'Add NoteBook',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                height: 40,
                child: TextField(
                  controller: noteBookController,
                  decoration: const InputDecoration(
                    labelText: 'Add NoteBook or select already existing ones',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  onChanged: (String value) {
                    searchNoteBook(noteBookController.text);
                  },
                  onSubmitted: (_) {
                    if (_.isNotEmpty) {
                      final noteBookId = context
                          .read<NotesProvider>()
                          .addNotebook(NoteBook(
                              name: noteBookController.text,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now()));
                      context
                          .read<NotesProvider>()
                          .addNoteToNoteBook(noteBookId, widget.note.id);
                      noteBookController.clear();
                    }
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Visibility(
              visible: searchedNoteBooks.isEmpty,
              child: const Center(
                child: Text('Add a new NoteBook'),
              ),
            ),
            Visibility(
              visible: searchedNoteBooks.isNotEmpty,
              child: Expanded(
                child: GridView.extent(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  childAspectRatio: 2.5,
                  maxCrossAxisExtent: 150.0,
                  mainAxisSpacing: 12.0, // spacing between rows
                  crossAxisSpacing: 8.0, // spacing between columns
                  children: [
                    ...searchedNoteBooks.map((noteBook) {
                      return Container(
                        padding: const EdgeInsets.all(2),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context
                                .read<NotesProvider>()
                                .addNoteToNoteBook(noteBook.id, widget.note.id);
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.book_rounded,
                            size: 18,
                            color:
                                noteBook.id == widget.note.notebook.target?.id
                                    ? Colors.white
                                    : const Color.fromARGB(255, 0, 73, 133),
                          ),
                          label: Text(
                            semanticsLabel: noteBook.name,
                            noteBook.name,
                            style: TextStyle(
                              color:
                                  noteBook.id == widget.note.notebook.target?.id
                                      ? Colors.white
                                      : const Color.fromARGB(255, 0, 73, 133),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            backgroundColor:
                                noteBook.id == widget.note.notebook.target?.id
                                    ? const Color.fromARGB(255, 0, 73, 133)
                                    : null,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void searchNoteBook(String query) {
    if (query.isEmpty) {
      // If the query is empty, show all tags
      context
          .read<NotesProvider>()
          .setSearchedNoteBooks(context.read<NotesProvider>().noteBooks);
    } else {
      // search tags based on the query
      final suggestions =
          context.read<NotesProvider>().noteBooks.where((noteBook) {
        return noteBook.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
      context.read<NotesProvider>().setSearchedNoteBooks(suggestions);
    }
  }

  // void searchTags(String query) {
  //   if (query.isEmpty) {
  //     // If the query is empty, show all tags
  //     context
  //         .read<TasksProvider>()
  //         .setSearchedTags(context.read<TasksProvider>().tags);
  //   } else {
  //     // search tags based on the query
  //     final suggestions = context.read<TasksProvider>().tags.where((tag) {
  //       return tag.name.toLowerCase().contains(query.toLowerCase());
  //     }).toList();
  //     context.read<TasksProvider>().setSearchedTags(suggestions);
  //   }
  // }
}
