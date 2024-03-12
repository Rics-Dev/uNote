import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthAPI>().localUserName;
    final userEmail = context.watch<AuthAPI>().localUserEmail;
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
                        context.read<AuthAPI>().signOut();
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
                child: Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // Add this line
                    children: [
                      CircleAvatar(
                        radius: 30, // Increased from 22 to 24
                        // backgroundColor: const Color.fromARGB(255, 0, 73, 133),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(
                                    0, 3), // Adjust the offset as needed
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white,
                            child: Text(
                              (userName?.isNotEmpty ?? false)
                                  ? userName![0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 73, 133),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Add this line
                        children: [
                          Text(
                            userName ?? 'User',
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            userEmail ?? 'Email',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
