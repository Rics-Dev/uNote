import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
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
  TabController? _tabController;
  NoteBookProvider? _noteBookProvider;
  int _selectedTabIndex = 0;

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
    _noteBookProvider?.removeListener(updateTabController);
    super.dispose();
  }

  void updateTabController() {
    if (mounted) {
      // Check if the widget is still mounted
      final noteBookProvider =
          Provider.of<NotesProvider>(context, listen: false);
      final noteBooks = noteBookProvider.noteBooks;
      if (_tabController != null) {
        _selectedTabIndex = _tabController!.index;
      }

      _tabController = TabController(
          length: noteBooks.length + 2,
          vsync: this,
          initialIndex: _selectedTabIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final noteBooks = notesProvider.noteBooks;

    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: const Column(
            children: [
              SortAndFilterView(),
              SizedBox(height: 10),
              HorizontalTagsView(),
            ],
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              const Tab(text: 'All Notes'),
              ...noteBooks.map((noteBook) => Tab(text: noteBook.name)).toList(),
              const Tab(icon: Icon(Icons.add)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // TasksViewInboxPage(),
              const NoteListPage(),
              ...noteBooks.map((noteBook) => const NoteListPage()).toList(),
              const NoteListPage(),
            ],
          ),
        ),
      ],
    );
  }
}

class NoteListPage extends StatelessWidget {
  const NoteListPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final disposition = notesProvider.selectedView;
    final notes = notesProvider.notes;
    return disposition == 'list'
        ? ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12, 8.0),
                child: Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    context.read<NotesProvider>().deleteNote(notes[index].id);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 243, 243, 243),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset:
                              const Offset(0, 5), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: GestureDetector(
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        title: Text(
                          notes[index].title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            notes[index].content,
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                            // overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        : GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1,
              crossAxisCount: 2,
              crossAxisSpacing: 1.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 5), // changes position of shadow
                      ),
                    ],
                    color: const Color.fromARGB(255, 245, 245, 245),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      Flexible(
                        child: Text(
                          notes[index].title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w500),
                          // overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          notes[index].content,
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                          // overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
