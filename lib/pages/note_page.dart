import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:utask/models/entities.dart';

import '../providers/note_provider.dart';
import '../providers/notebook.dart';
import '../widgets/notePageWidgets/note_list_page.dart';
import '../widgets/notePageWidgets/search_disposition_view.dart';

// enum _SupportState {
//   unknown,
//   supported,
//   unsupported,
// }

class NotesPage extends StatefulWidget {
  final String adUnitId = 'ca-app-pub-3940256099942544/6300978111'; //test

  const NotesPage({
    super.key
  });

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
  // _SupportState _supportState = _SupportState.unknown;
  // bool? _canCheckBiometrics;
  // List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  bool showSecondTabBar = false;

  // TabController? _tabController2;

  @override
  void initState() {
    super.initState();
    updateTabController();
    // _loadAd();
    // auth.isDeviceSupported().then(
    //       (bool isSupported) => setState(() => _supportState = isSupported
    //           ? _SupportState.supported
    //           : _SupportState.unsupported),
    //     );
  }

  // void _loadAd() {
  //   final bannerAd = BannerAd(
  //     size: widget.adSize,
  //     adUnitId: widget.adUnitId,
  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       // Called when an ad is successfully received.
  //       onAdLoaded: (ad) {
  //         if (!mounted) {
  //           ad.dispose();
  //           return;
  //         }
  //         setState(() {
  //           _bannerAd = ad as BannerAd;
  //         });
  //       },
  //       // Called when an ad request failed.
  //       onAdFailedToLoad: (ad, error) {
  //         debugPrint('BannerAd failed to load: $error');
  //         ad.dispose();
  //       },
  //     ),
  //   );

  //   // Start loading.
  //   bannerAd.load();
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
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 10), // changes position of shadow
                ),
              ],
            ),
            child: Column(
              children: [
                const SortAndFilterView(),
                // HorizontalTagsView(),
                TabBar(
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

                    if (index == 0) {

                      _authenticate();
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
                                _selectedTabIndex -
                                    1, // index of the new notebook
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
              ],
            ),
          ),
          const SizedBox(height: 10),
          // SizedBox(
          //   width: widget.adSize.width.toDouble(),
          //   height: widget.adSize.height.toDouble(),
          //   child: _bannerAd == null
          //       // Nothing to render yet.
          //       ? const SizedBox()
          //       // The actual ad.
          //       : AdWidget(ad: _bannerAd!),
          // ),
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
                // _buildAddNotebookPage(),
                Container(),
              ],
            ),
          ),
          //   SizedBox(
          //   width: widget.adSize.width.toDouble(),
          //   height: widget.adSize.height.toDouble(),
          //   child: _bannerAd == null
          //       // Nothing to render yet.
          //       ? const SizedBox()
          //       // The actual ad.
          //       : AdWidget(ad: _bannerAd!),
          // ),
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

  void _showAddNotebookDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
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
