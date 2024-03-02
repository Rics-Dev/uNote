import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import 'package:utask/widgets/inboxPage/sort_view.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:searchbar_animation/searchbar_animation.dart';

import '../../providers/task_provider.dart';

class SortAndFilterView extends StatefulWidget {
  const SortAndFilterView({
    super.key,
  });

  @override
  State<SortAndFilterView> createState() => _SortAndFilterViewState();
}

class _SortAndFilterViewState extends State<SortAndFilterView> {
  final TextEditingController searchBar = TextEditingController();

  @override
  void dispose() {
    searchBar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.outlined(
            color: const Color.fromARGB(255, 0, 73, 133),
            icon: const Icon(
              Icons.sort_rounded,
              color: Color.fromARGB(255, 0, 73, 133),
            ),
            onPressed: () {
              showSortView(context);
            },
          ),
          SearchBarAnimation(
            durationInMilliSeconds: 500,
            searchBoxWidth: 300,
            isOriginalAnimation: false,
            isSearchBoxOnRightSide: true,
            buttonBorderColour: Colors.black,
            textEditingController: searchBar,
            trailingWidget: const Icon(Icons.search_rounded, color: Color.fromARGB(255, 0, 73, 133),),
            secondaryButtonWidget: const Icon(Icons.close_rounded, color: Color.fromARGB(255, 0, 73, 133),),
            buttonWidget: const Icon(Icons.search_rounded, color: Color.fromARGB(255, 0, 73, 133),),
            onFieldSubmitted: (String value) {
              debugPrint('onFieldSubmitted value $value');
            },
            onChanged: (String value) {
              searchTasks(searchBar.text);
            },
          ),
        ],
      ),
    );
  }

  Future<dynamic> showSortView(BuildContext context) {
    return showTopModalSheet(
      context,
      const SortView(),
      backgroundColor: Colors.white,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(25),
      ),
    );
  }
  
  void searchTasks(String query) {
    if (query.isEmpty){
      context.read<TasksAPI>().setSearchedTasks([]);
    }else{
      final suggestions = context.read<TasksAPI>().tasks.where((task) {
        return task.content.toLowerCase().contains(query.toLowerCase());
      }).toList();
      context.read<TasksAPI>().setSearchedTasks(suggestions);
    }
  }
}
