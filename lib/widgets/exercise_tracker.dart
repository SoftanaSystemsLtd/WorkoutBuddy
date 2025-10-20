import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workout_plan.dart';
import '../models/workout_session.dart';

class ExerciseTracker extends StatefulWidget {
  const ExerciseTracker({
    required this.exercise,
    required this.onSetsChanged,
    this.existingSets,
    this.onComplete,
    super.key,
  });

  final Exercise exercise;
  final List<SetData>? existingSets;
  final Function(List<SetData>) onSetsChanged;
  final VoidCallback? onComplete;

  @override
  State<ExerciseTracker> createState() => _ExerciseTrackerState();
}

class _ExerciseTrackerState extends State<ExerciseTracker> {
  final List<_SetEntry> _sets = [];
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingSets != null && widget.existingSets!.isNotEmpty) {
      _sets.addAll(widget.existingSets!.map(_SetEntry.fromSetData));
    } else {
      _sets.add(_SetEntry());
    }
  }

  void _addSet() {
    setState(() {
      _sets.add(_SetEntry());
    });
    _notifyChanges();
  }

  void _removeSet(int index) {
    if (_sets.length == 1) {
      return; // Guard
    }
    setState(() {
      final removed = _sets.removeAt(index);
      removed.dispose();
    });
    _notifyChanges();
  }

  void _toggleComplete() {
    setState(() {
      _isCompleted = !_isCompleted;
    });
    if (_isCompleted && widget.onComplete != null) {
      widget.onComplete!();
    }
  }

  void _notifyChanges() {
    final data = _sets
        .map(
          (e) => SetData(
            reps: int.tryParse(e.repsController.text) ?? 0,
            weight: double.tryParse(e.weightController.text),
          ),
        )
        .toList();
    widget.onSetsChanged(data);
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Exercise: ${widget.exercise.name}',
    child: Card(
      elevation: _isCompleted ? 0 : 2,
      color: _isCompleted
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Semantics(
                  label: _isCompleted
                      ? 'Mark as incomplete'
                      : 'Mark as complete',
                  child: Checkbox(
                    value: _isCompleted,
                    onChanged: (_) => _toggleComplete(),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.exercise.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      decoration: _isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      color: _isCompleted
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            if (!_isCompleted) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Reps',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Weight (kg)',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              const SizedBox(height: 8),
              ..._sets.asMap().entries.map((entry) {
                final index = entry.key;
                final set = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${index + 1}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: set.repsController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            hintText: '0',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _notifyChanges(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: set.weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d*'),
                            ),
                          ],
                          decoration: const InputDecoration(
                            hintText: '0.0',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => _notifyChanges(),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: _sets.length > 1
                              ? () => _removeSet(index)
                              : null,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _addSet,
                icon: const Icon(Icons.add),
                label: const Text('Add Set'),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  @override
  void dispose() {
    for (final s in _sets) {
      s.dispose();
    }
    super.dispose();
  }
}

class _SetEntry {
  _SetEntry({String? reps, String? weight})
    : repsController = TextEditingController(text: reps),
      weightController = TextEditingController(text: weight);

  factory _SetEntry.fromSetData(SetData data) =>
      _SetEntry(reps: data.reps.toString(), weight: data.weight?.toString());

  final TextEditingController repsController;
  final TextEditingController weightController;

  void dispose() {
    repsController.dispose();
    weightController.dispose();
  }
}
