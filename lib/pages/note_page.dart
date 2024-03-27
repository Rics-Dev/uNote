import 'package:flutter/cupertino.dart';

import '../widgets/inboxPage/horizontal_tags_view.dart';
import '../widgets/inboxPage/search_disposition_view.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SortAndFilterView(),
        SizedBox(height: 10),
        HorizontalTagsView(),
      ],
    );
  }
}
