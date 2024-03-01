import 'package:flutter/material.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import 'package:utask/widgets/inboxPage/sort_view.dart';

class SortAndFilterView extends StatelessWidget {
  const SortAndFilterView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 0, 0, 0),
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
        ],
      ),
      
    );
  }

  Future<dynamic> showSortView(BuildContext context) {
    return showTopModalSheet(
              
              context, 
              SortView(),
              backgroundColor: Colors.white,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            );
  }
}

