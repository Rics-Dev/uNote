import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_down_button/pull_down_button.dart';


class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          GestureDetector(
            onTap: () async {
              await showPullDownMenu(
                  context: context,
                  items: [
                    PullDownMenuItem(
                      title: 'Disconnect',
                      onTap: () {
                        context.go('/landingPage');
                      },
                      icon: Icons.logout,
                      isDestructive: true,
                      iconColor: Colors.red,
                    ),
                  ],
                  position: const Rect.fromLTWH(50, 25, 100, 100));
            },
            child: Container(
              height: 125,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // Adjust the offset as needed
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 0),
                child: const Center(
                  child: Text('Not connected'),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text('Home'),
            onTap: () {
              context.go('/');
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.alarm_on_rounded),
          //   title: const Text('Pomodoro'),
          //   onTap: () {
          //     context.go('/pomodoro');
          //   },
          // ),
          // Add more ListTile widgets for additional items as needed
        ],
      ),
    );
  }
}
