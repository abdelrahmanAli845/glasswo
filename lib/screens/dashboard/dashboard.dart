import 'package:flutter/material.dart';
import '../../models/daily_record.dart';
import '../../models/worker.dart';
import '../../service/daily_service.dart';
import '../../service/worker_service.dart';
import 'dashboard_content.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Worker>>(
      stream: WorkerService().stream(),
      builder: (context, workerSnap) {
        if (!workerSnap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final workers = workerSnap.data!;

        return StreamBuilder<List<DailyRecord>>(
          stream: DailyService().streamAll(),
          builder: (context, recordSnap) {
            if (!recordSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            return DashboardContent(
              workers: workers,
              records: recordSnap.data!,
            );
          },
        );
      },
    );
  }
}
