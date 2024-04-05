import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utask/providers/note_provider.dart';
import 'package:searchbar_animation/searchbar_animation.dart';

class SortAndFilterView extends StatefulWidget {
  const SortAndFilterView({
    super.key,
  });

  @override
  State<SortAndFilterView> createState() => _SortAndFilterViewState();
}

class _SortAndFilterViewState extends State<SortAndFilterView> {
  TextEditingController searchBar = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final notesProvider = context.watch<NotesProvider>();
    final disposition = notesProvider.selectedView;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          buildDispositionButtons(disposition, context),
          SearchBarAnimation(
            buttonColour: Theme.of(context).colorScheme.surface,
            // enableBoxShadow: false,
            // enableButtonShadow: false,
            durationInMilliSeconds: 500,
            searchBoxWidth: MediaQuery.of(context).size.width * 0.7,
            isOriginalAnimation: false,
            isSearchBoxOnRightSide: true,
            buttonBorderColour: Colors.black,
            textEditingController: searchBar,
            trailingWidget: Icon(
              Icons.search_rounded,
              // color: Color.fromARGB(255, 0, 73, 133),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            secondaryButtonWidget: Icon(
              Icons.close_rounded,
              // color: Color.fromARGB(255, 0, 73, 133),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            buttonWidget: Icon(
              Icons.search_rounded,
              // color: Color.fromARGB(255, 0, 73, 133),
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onFieldSubmitted: (String value) {
              debugPrint('onFieldSubmitted value $value');
            },
            onCollapseComplete: () {
              searchBar.clear();
              context.read<NotesProvider>().setIsSearching(false);
            },
            onChanged: (String value) {
              if (mounted) {
                searchTasks(searchBar.text);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildDispositionButtons(String disposition, BuildContext context) {
    IconData icon;
    String nextDisposition;
    switch (disposition) {
      case 'list':
        icon = Icons.view_stream;
        nextDisposition = 'compactList';
        break;
      case 'compactList':
        icon = Icons.grid_view_rounded;
        nextDisposition = 'grid';
        break;
      case 'grid':
        icon = Icons.view_list_rounded;
        nextDisposition = 'list';
        break;
      default:
        return Container();
    }
    return buildDispositionButton(disposition, icon, nextDisposition, context);
  }

  Widget buildDispositionButton(String disposition, IconData icon,
      String nextDisposition, BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 3,
        padding: const EdgeInsets.all(8),
        shape: const CircleBorder(),
      ),
      child: Icon(
        icon,
        // color: const Color.fromARGB(255, 0, 73, 133),
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onPressed: () {
        context.read<NotesProvider>().changeView(nextDisposition);
      },
    );
  }

  void searchTasks(String query) {
    if (query.isEmpty) {
      context.read<NotesProvider>().setIsSearching(false);
      // context.read<NotesProvider>().setSearchedTags(context.read<NotesProvider>().tags);
    } else {
      final suggestions = context.read<NotesProvider>().notes.where((note) {
        return note.title.toLowerCase().contains(query.toLowerCase()) ||
            note.content.toLowerCase().contains(query.toLowerCase());
      }).toList();
      context.read<NotesProvider>().setSearchedNotes(suggestions);
    }
  }
}
