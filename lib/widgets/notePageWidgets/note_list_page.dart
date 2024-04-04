import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/entities.dart';
import '../../providers/note_provider.dart';
import 'note_details_page.dart';
import 'package:badges/badges.dart' as badges;

class NoteListPage extends StatefulWidget {
  final NoteBook noteBook;
  final Function(int) onNavigateToNoteBook;
  const NoteListPage(this.noteBook,
      {super.key, required this.onNavigateToNoteBook});

  @override
  State<NoteListPage> createState() => _NoteListPageState();
}

class _NoteListPageState extends State<NoteListPage> {
  Future<dynamic> _showAddNoteDetailsDialog(BuildContext context, Note note) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => NoteDetailPage(note: note),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final disposition = notesProvider.selectedView;
    final selectedNoteBook = notesProvider.selectedNoteBook;
    List<Note> notes = notesProvider.notes;
    List<NoteBook> allNoteBooks = notesProvider.noteBooks;

    if (widget.noteBook.name == 'All Notes Ric') {
      notes = notesProvider.notes.where((note) => !note.isSecured).toList();
    } else if (widget.noteBook.name == 'All Notes Ric are secured') {
      notes = notesProvider.notes.where((note) => note.isSecured).toList();
    } else {
      notes = notesProvider.notes
          .where((note) => note.notebook.target?.id == widget.noteBook.id)
          .toList();
    }

    if (notesProvider.isSearchingNotes) {
      notes = widget.noteBook.name == 'All Notes Ric'
          ? notesProvider.searchedNotes
              .where((note) => !note.isSecured)
              .toList()
          : widget.noteBook.name == 'All Notes Ric are secured'
              ? notesProvider.searchedNotes
                  .where((note) => note.isSecured)
                  .toList()
              : notesProvider.searchedNotes
                  .where(
                      (note) => note.notebook.target?.id == widget.noteBook.id)
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
                            // setState(() {
                            //   _isSelecting = true;
                            //   _selectedNote[index] = !_selectedNote[index];
                            // });
                          },
                          child: badges.Badge(
                            showBadge: false,
                            ignorePointer: false,
                            badgeContent: const Icon(
                              Icons.done,
                              color: Colors.white,
                              size: 16,
                            ),
                            badgeStyle: const badges.BadgeStyle(
                              badgeColor: Color.fromARGB(255, 0, 73, 133),
                              elevation: 5,
                            ),
                            child: ListTile(
                              trailing: disposition == 'list'
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                                padding:
                                                    const EdgeInsets.all(4),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                              ),
                                              onPressed: () {
                                                final noteBook = notes[index]
                                                    .notebook
                                                    .target;

                                                final noteBookPosition =
                                                    allNoteBooks.indexWhere(
                                                        (nb) =>
                                                            nb.id ==
                                                            noteBook!.id);
                                                if (noteBookPosition != -1) {
                                                  widget.onNavigateToNoteBook(
                                                      noteBookPosition);
                                                }
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                      Icons.book_rounded),
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
                                  padding: const EdgeInsets.only(
                                      top: 8.0, bottom: 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
