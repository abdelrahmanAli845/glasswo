import 'package:flutter/material.dart';
import 'package:glass_wo/screens/worker%20screen/worker_form.dart';
import 'package:provider/provider.dart';

import '../../models/worker.dart';
import '../../providers/worker_provider.dart';

class WorkerItem extends StatelessWidget {
  final Worker worker;

  const WorkerItem({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<WorkerProvider>();

    return Card(
      child: ListTile(
        title: Text(worker.name),
        subtitle: Text("${worker.dailySalary} جنيه"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                showWorkerForm(context, worker: worker);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                provider.delete(worker.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}