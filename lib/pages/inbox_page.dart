import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Inbox extends StatefulWidget {
  const Inbox({super.key});

  @override
  State<Inbox> createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  int _bottomNavIndex = 0;
  List<IconData> iconList = [
    Icons.inbox_rounded,
    Icons.format_list_bulleted_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your inbox'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.search),
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
          shadow: BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10),
          onTap: (index) => setState(() => _bottomNavIndex = index),
          //other params
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
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
        body: <Widget>[
          Center(
            child: Text('Your inbox content goes here'),
          ),
          Center(
            child: Text('Your List content goes here'),
          ),
        ][_bottomNavIndex]);
  }
}

// class _InboxState extends State<Inbox> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your inbox'),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//               ),
//               child: Text(
//                 'Drawer Header',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 24,
//                 ),
//               ),
//             ),
//             ListTile(
//               title: Text('Item 1'),
//               onTap: () {
//                 // Update UI based on drawer item selected
//               },
//             ),
//             ListTile(
//               title: Text('Item 2'),
//               onTap: () {
//                 // Update UI based on drawer item selected
//               },
//             ),
//             // Add more ListTile widgets for additional items as needed
//           ],
//         ),
//       ),
//       body: Center(
//         child: Text('Your inbox content goes here'),
//       ),
//     );
//   }
// }
