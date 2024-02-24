import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';

import '../widgets/build_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _bottomNavIndex = 0;
  List<IconData> iconList = [
    Icons.inbox_rounded,
    Icons.format_list_bulleted_rounded,
  ];
  List<String> appBarTitles = [
    'Your inbox',
    'Your lists',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(appBarTitles[_bottomNavIndex]),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.calendar_month_rounded),
              onPressed: () {
                // Add your search functionality here
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          shape: const CircleBorder(),
          tooltip: 'Increment',
          onPressed: () {},
          child: const Icon(Icons.add, color: Colors.white, size: 38),
          //params
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar(
            height: 65.0,
            icons: iconList,
            activeIndex: _bottomNavIndex,
            gapLocation: GapLocation.center,
            leftCornerRadius: 32,
            rightCornerRadius: 32,
            notchSmoothness: NotchSmoothness.softEdge,
            iconSize: 28,
            activeColor: Color.fromARGB(255, 0, 73, 133),
            inactiveColor: Colors.grey,
            shadow: BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 10),
            onTap: (index) {
              setState(() {
                _bottomNavIndex = index;
              });
            }
            //other params
            ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Drawer Header',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: Text('Item 1'),
                onTap: () {
                  // Update UI based on drawer item selected
                },
              ),
              ListTile(
                title: Text('Item 2'),
                onTap: () {
                  // Update UI based on drawer item selected
                },
              ),
              // Add more ListTile widgets for additional items as needed
            ],
          ),
        ),
        body: buildBody(_bottomNavIndex),);
  }
}
