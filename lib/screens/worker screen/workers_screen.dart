import 'package:flutter/material.dart';
import 'package:glass_wo/screens/worker%20screen/worker_form.dart';
import 'package:provider/provider.dart';
import 'worker_history_screen.dart';

import '../../providers/worker_provider.dart';

class WorkersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WorkerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("العمال")),
      body: ListView.builder(
        itemCount: provider.workers.length,
        itemBuilder: (_, i) {
          final worker = provider.workers[i];

          return Card(
            child: ListTile(
              title: Text(worker.name),
              subtitle: Text("${worker.dailySalary} جنيه"),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 📋 سجل
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.purple),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => WorkerHistoryScreen(worker: worker),
                      ));
                    },
                  ),

                  // ✏️ تعديل
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      showWorkerForm(context, worker: worker);
                    },
                  ),

                  // 🗑 حذف
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      provider.delete(worker.id);
                    },
                  ),
                ],
              ),
            ),
          );        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showWorkerForm(context);
        },
        child: Icon(Icons.add),
      ),
    );

  }
}