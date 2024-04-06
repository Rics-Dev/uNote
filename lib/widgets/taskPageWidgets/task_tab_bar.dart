import 'package:flutter/material.dart';

class TaskTabBar extends StatelessWidget {
  const TaskTabBar({
    super.key,
    required TabController tabController,
  }) : _tabController = tabController;

  final TabController _tabController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      // decoration: BoxDecoration(
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.grey.shade300,
      //       spreadRadius: 1,
      //       blurRadius: 10,
      //       offset: const Offset(0, 10), // changes position of shadow
      //     ),
      //   ],
      //   color: Colors.white,
      // ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        isScrollable: false,
        tabs: const [
          Tab(
            iconMargin: EdgeInsets.only(bottom: 2),
            text: 'Inbox',
            icon: Icon(Icons.inbox_rounded),
          ),
          Tab(
            text: 'Lists',
            icon: Icon(Icons.format_list_bulleted_rounded),
            iconMargin: EdgeInsets.only(bottom: 2),
          )
        ],
      ),
    );
  }
}
