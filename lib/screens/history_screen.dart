import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/history_provider.dart';
import '../widgets/workout_history_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _from;
  DateTime? _to;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load history when screen first builds
    // Capture provider synchronously and schedule load to avoid holding BuildContext across async gap.
    final provider = context.read<HistoryProvider>();
    Future.microtask(provider.loadHistory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final provider = context.read<HistoryProvider>();
    provider.applyFilter(
      HistoryFilter(
        from: _from,
        to: _to,
        exerciseNameQuery: _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim(),
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialFirst = _from ?? now.subtract(const Duration(days: 30));
    final initialLast = _to ?? now;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(start: initialFirst, end: initialLast),
    );
    if (picked != null) {
      setState(() {
        _from = picked.start;
        _to = picked.end;
      });
      _applyFilter();
    }
  }

  void _clearFilters() {
    setState(() {
      _from = null;
      _to = null;
      _searchController.clear();
    });
    context.read<HistoryProvider>().clearFilter();
  }

  Future<void> _exportHistory(
    BuildContext context,
    HistoryProvider provider,
  ) async {
    try {
      final jsonData = await provider.exportHistory();

      if (!context.mounted) {
        return;
      }

      // Show export dialog with data
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Export History'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('History data exported successfully!'),
                const SizedBox(height: 16),
                const Text(
                  'Copy the data below or save it to a file:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SelectableText(
                    jsonData,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmClearHistory(
    BuildContext context,
    HistoryProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to clear all workout history? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await provider.clearAllHistory();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('History cleared successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear history: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<HistoryProvider>(
    builder: (context, provider, _) => Scaffold(
      appBar: AppBar(
        title: const Text('History & Stats'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportHistory(context, provider);
              } else if (value == 'clear') {
                _confirmClearHistory(context, provider);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download),
                    SizedBox(width: 8),
                    Text('Export History'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever),
                    SizedBox(width: 8),
                    Text('Clear History'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: provider.isLoading
                ? null
                : () => provider.refreshHistory(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _FiltersBar(
            from: _from,
            to: _to,
            onPickDateRange: _pickDateRange,
            onClear: _clearFilters,
            searchController: _searchController,
            onSearchChanged: (_) => _applyFilter(),
            isLoading: provider.isLoading,
          ),
          _StatsSummary(stats: provider.stats),
          const Divider(height: 1),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.hasError
                ? Center(
                    child: Text(
                      provider.errorMessage ?? 'Unknown error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : provider.sessions.isEmpty
                ? const Center(child: Text('No sessions match current filters'))
                : ListView.separated(
                    itemCount: provider.sessions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) =>
                        WorkoutHistoryCard(session: provider.sessions[index]),
                  ),
          ),
        ],
      ),
    ),
  );
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.from,
    required this.to,
    required this.onPickDateRange,
    required this.onClear,
    required this.searchController,
    required this.onSearchChanged,
    required this.isLoading,
  });

  final DateTime? from;
  final DateTime? to;
  final VoidCallback onPickDateRange;
  final VoidCallback onClear;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final rangeLabel = from == null || to == null
        ? 'Any Date'
        : '${_fmt(from!)} - ${_fmt(to!)}';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  decoration: const InputDecoration(
                    labelText: 'Search Exercise',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Pick date range',
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onPickDateRange,
                  icon: const Icon(Icons.date_range),
                  label: Text(rangeLabel),
                ),
              ),
              IconButton(
                tooltip: 'Clear filters',
                onPressed:
                    (from == null &&
                        to == null &&
                        searchController.text.isEmpty)
                    ? null
                    : onClear,
                icon: const Icon(Icons.clear),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsSummary extends StatelessWidget {
  const _StatsSummary({required this.stats});
  final HistoryStats stats;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Summary', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _statChip('Workouts', stats.totalWorkouts.toString()),
              _statChip('Sets', stats.totalSets.toString()),
              _statChip('Volume', stats.totalVolume.toStringAsFixed(1)),
              _statChip('Avg Duration', _formatDuration(stats.averageDuration)),
            ],
          ),
          if (stats.volumePerExercise.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Top Volume Exercises',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: () {
                  final entries = stats.volumePerExercise.entries.toList();
                  entries.sort((a, b) => b.value.compareTo(a.value));
                  return entries
                      .take(5)
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(
                              '${e.key}: ${e.value.toStringAsFixed(1)}',
                            ),
                          ),
                        ),
                      )
                      .toList();
                }(),
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _statChip(String label, String value) => Chip(
    avatar: const Icon(Icons.fitness_center, size: 16),
    label: Text('$label: $value'),
  );

  String _formatDuration(Duration d) => d == Duration.zero
      ? '0m'
      : d.inMinutes > 0
      ? '${d.inMinutes}m ${d.inSeconds % 60}s'
      : '${d.inSeconds % 60}s';
}

String _fmt(DateTime dt) => '${dt.year}-${_two(dt.month)}-${_two(dt.day)}';
String _two(int v) => v.toString().padLeft(2, '0');
