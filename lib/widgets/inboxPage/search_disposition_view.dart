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
          disposition == 'list'
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    // padding: const EdgeInsets.all(10),
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: Color.fromARGB(255, 0, 73, 133),
                  ),
                  onPressed: () {
                    context.read<NotesProvider>().changeView('grid');
                  },
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shape: const CircleBorder(),
                  ),
                  child: const Icon(
                    Icons.list_rounded,
                    color: Color.fromARGB(255, 0, 73, 133),
                  ),
                  onPressed: () {
                    context.read<NotesProvider>().changeView('list');
                  },
                ),
          SearchBarAnimation(
            // buttonColour: AppColours.white,
            // enableBoxShadow: false,
            // enableButtonShadow: false,
            durationInMilliSeconds: 500,
            searchBoxWidth: MediaQuery.of(context).size.width * 0.7,
            isOriginalAnimation: false,
            isSearchBoxOnRightSide: true,
            buttonBorderColour: Colors.black,
            textEditingController: searchBar,
            trailingWidget: const Icon(
              Icons.search_rounded,
              color: Color.fromARGB(255, 0, 73, 133),
            ),
            secondaryButtonWidget: const Icon(
              Icons.close_rounded,
              color: Color.fromARGB(255, 0, 73, 133),
            ),
            buttonWidget: const Icon(
              Icons.search_rounded,
              color: Color.fromARGB(255, 0, 73, 133),
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
