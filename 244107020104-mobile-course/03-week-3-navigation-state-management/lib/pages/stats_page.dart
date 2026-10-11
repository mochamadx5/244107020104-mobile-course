import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../stats_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsFutureProvider);
    final isErrorMode = ref.watch(simulateErrorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistik Tugas (AsyncValue)'),
        actions: [
          IconButton(
            tooltip: isErrorMode ? 'Mode Normal' : 'Simulasi Error',
            icon: Icon(
              isErrorMode ? Icons.bug_report : Icons.bug_report_outlined,
              color: isErrorMode ? Colors.red : null,
            ),
            onPressed: () {
              ref.read(simulateErrorProvider.notifier).toggle();
              ref.invalidate(statsFutureProvider);
            },
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Memuat ringkasan statistik...'),
            ],
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  error.toString().replaceAll('Exception: ', ''),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(simulateErrorProvider.notifier).reset();
                    ref.invalidate(statsFutureProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi (Retry)'),
                ),
              ],
            ),
          ),
        ),
        data: (stats) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildStatCard('Total Tugas', stats.total.toString(), Colors.blue),
              const SizedBox(height: 12),
              _buildStatCard('Selesai', stats.completed.toString(), Colors.green),
              const SizedBox(height: 12),
              _buildStatCard('Belum Selesai', stats.pending.toString(), Colors.orange),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(statsFutureProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Data'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Text(
            count,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
