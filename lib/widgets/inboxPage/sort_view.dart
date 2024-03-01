import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/task.dart';

class SortView extends StatelessWidget {
  const SortView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tasksAPI = context.watch<TasksAPI>();
    final sortByCreationDate = tasksAPI.sortByCreationDate;
    final sortByEditionDate = tasksAPI.sortByEditionDate;
    final oldToNew = tasksAPI.oldToNew;

    return SafeArea(
        child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      width: double.infinity,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text('Sort by',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton(
                onPressed: () {
                  tasksAPI.toggleSortByCreationDate();
                },
                style: sortByCreationDate
                    ? ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 0, 73,
                              133), // Change the text color when not selected
                        ),
                      )
                    : null,
                child: Text('Date Created',
                    style: TextStyle(
                      color: sortByCreationDate
                          ? Colors.white
                          : const Color.fromARGB(255, 0, 73, 133),
                    )),
              ),
              Column(
                children: [
                  Text('Old'),
                  IconButton.outlined(
                    onPressed: () {
                      tasksAPI.toggleNewToOld();
                    },
                    color: const Color.fromARGB(255, 0, 73, 133),
                    icon: Icon(
                      oldToNew
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: const Color.fromARGB(255, 0, 73, 133),
                    ),
                  ),
                  Text('New'),
                ],
              ),
              OutlinedButton(
                onPressed: () {
                  tasksAPI.toggleSortByEditionDate();
                },
                style: sortByEditionDate
                    ? ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 0, 73,
                              133), // Change the text color when not selected
                        ),
                      )
                    : null,
                child: Text('Date Edited',
                    style: TextStyle(
                      color: sortByEditionDate
                          ? Colors.white
                          : const Color.fromARGB(255, 0, 73, 133),
                    )),
              )
            ],
          ),
          const Spacer(),
          Container(
            width: 100,
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.grey,
            ),
          ),
          const SizedBox(
            height: 5,
          )
        ],
      ),
    ));
  }
}
