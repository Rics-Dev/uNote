import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utask/providers/note_provider.dart';

import '../../providers/task_provider.dart';

class SortView extends StatelessWidget {
  const SortView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();
    final notesProvider = context.watch<NotesProvider>();
    final oldToNew = tasksProvider.oldToNew;

    SortCriteria sortCriteria = tasksProvider.sortCriteria;

    return SafeArea(
        child: SizedBox(
      height: MediaQuery.of(context).size.height * 0.40,
      width: double.infinity,
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 10,
          ),
          const Text('Sort by',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal)),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  tasksProvider.toggleSortByCreationDate();
                  notesProvider.toggleSortByCreationDate();   
                },
                style: sortCriteria == SortCriteria.creationDate
                    ? ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 0, 73,
                              133), // Change the text color when not selected
                        ),
                      )
                    : null,
                child: Text('Date Created',
                    style: TextStyle(
                      color: sortCriteria == SortCriteria.creationDate
                          ? Colors.white
                          : const Color.fromARGB(255, 0, 73, 133),
                    )),
              ),
              Column(
                children: [
                  const Text('Old'),
                  ElevatedButton(
                    onPressed: () {
                      tasksProvider.toggleNewToOld();
                      notesProvider.toggleNewToOld();
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(), elevation: 3,
                      // padding: const EdgeInsets.all(10),
                    ),
                    // color: const Color.fromARGB(255, 0, 73, 133),
                    child: Icon(
                      oldToNew
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color: const Color.fromARGB(255, 0, 73, 133),
                    ),
                  ),
                  const Text('New'),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  tasksProvider.toggleSortByEditionDate();
                  notesProvider.toggleSortByEditionDate();

                },
                style: sortCriteria == SortCriteria.editionDate
                    ? ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 0, 73,
                              133), // Change the text color when not selected
                        ),
                      )
                    : null,
                child: Text('Date Edited',
                    style: TextStyle(
                      color: sortCriteria == SortCriteria.editionDate
                          ? Colors.white
                          : const Color.fromARGB(255, 0, 73, 133),
                    )),
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  tasksProvider.toggleSortByNameAZ();
                  notesProvider.toggleSortByNameAZ();

                },
                style: sortCriteria == SortCriteria.nameAZ
                    ? ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 0, 73,
                              133), // Change the text color when not selected
                        ),
                      )
                    : null,
                child: Text('Name A - Z',
                    style: TextStyle(
                      color: sortCriteria == SortCriteria.nameAZ
                          ? Colors.white
                          : const Color.fromARGB(255, 0, 73, 133),
                    )),
              ),
              ElevatedButton(
                onPressed: () {
                  tasksProvider.toggleSortByNameZA();
                  notesProvider.toggleSortByNameZA();

                },
                style: sortCriteria == SortCriteria.nameZA
                    ? ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromARGB(255, 0, 73,
                              133), // Change the text color when not selected
                        ),
                      )
                    : null,
                child: Text('Name Z - A',
                    style: TextStyle(
                      color: sortCriteria == SortCriteria.nameZA
                          ? Colors.white
                          : const Color.fromARGB(255, 0, 73, 133),
                    )),
              )
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          // const Text('Filter by',
          //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal)),

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
          ),
        ],
      ),
    ));
  }
}



// Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //   children: [
          //     OutlinedButton.icon(
          //       icon: (Icon(
          //         Icons.label_outline_rounded,
          //         color: filterCriteria == FilterCriteria.tags
          //             ? Colors.white
          //             : const Color.fromARGB(255, 0, 73, 133),
          //       )),
          //       onPressed: () {
          //         tasksAPI.toggleFilterByTags();
          //       },
          //       style: filterCriteria == FilterCriteria.tags
          //           ? ButtonStyle(
          //               backgroundColor: MaterialStateProperty.all<Color>(
          //                 const Color.fromARGB(255, 0, 73,
          //                     133), // Change the text color when not selected
          //               ),
          //             )
          //           : null,
          //       label: Text('Tags',
          //           style: TextStyle(
          //             color: filterCriteria == FilterCriteria.tags
          //                 ? Colors.white
          //                 : const Color.fromARGB(255, 0, 73, 133),
          //           )),
          //     ),
          //     OutlinedButton.icon(
          //       icon: (Icon(
          //         Icons.flag_outlined,
          //         color: filterCriteria == FilterCriteria.priority
          //             ? Colors.white
          //             : const Color.fromARGB(255, 0, 73, 133),
          //       )),
          //       onPressed: () {
          //         tasksAPI.toggleFilterByPriority();
          //       },
          //       style: filterCriteria == FilterCriteria.priority
          //           ? ButtonStyle(
          //               backgroundColor: MaterialStateProperty.all<Color>(
          //                 const Color.fromARGB(255, 0, 73,
          //                     133), // Change the text color when not selected
          //               ),
          //             )
          //           : null,
          //       label: Text('Priority',
          //           style: TextStyle(
          //             color: filterCriteria == FilterCriteria.priority
          //                 ? Colors.white
          //                 : const Color.fromARGB(255, 0, 73, 133),
          //           )),
          //     )
          //   ],
          // ),