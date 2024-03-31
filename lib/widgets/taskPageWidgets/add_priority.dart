import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/taskProvider.dart';

class AddPriorityView extends StatelessWidget {
  const AddPriorityView({super.key});

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.90,
          height: MediaQuery.of(context).size.height * 0.30,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Set Priority',
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      context.read<TasksProvider>().setTemporarySelectedPriority('Low');
                      Navigator.pop(context);
                    },
                    child: const Text('Low'),
                  ),
                  
                  ElevatedButton(
                    onPressed: () {
                      context.read<TasksProvider>().setTemporarySelectedPriority('Medium');
                      Navigator.pop(context);
                    },
                    child: const Text('Medium'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TasksProvider>().setTemporarySelectedPriority('High');
                      Navigator.pop(context);
                    },
                    child: const Text('High'),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: OutlinedButton(
                  onPressed: () {
                    context.read<TasksProvider>().setTemporarySelectedPriority(null);
                    Navigator.pop(context);
                  },
                  child: const Text('Clear'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
