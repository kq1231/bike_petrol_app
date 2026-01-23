import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/features/refill/providers/refill_provider.dart';
import 'package:bike_petrol_app/common/models/refill.dart';

class RefillScreen extends ConsumerStatefulWidget {
  const RefillScreen({super.key});

  @override
  ConsumerState<RefillScreen> createState() => _RefillScreenState();
}

class _RefillScreenState extends ConsumerState<RefillScreen> {
  bool _isCostBased = true;
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController(
    text: DateTime.now().toIso8601String().split('T')[0],
  );
  final _litresController = TextEditingController();
  final _costController = TextEditingController();
  final _pricePerLitreController = TextEditingController();
  final _odometerController = TextEditingController();
  final _notesController = TextEditingController();

  void _calculateLitres() {
    if (_costController.text.isNotEmpty &&
        _pricePerLitreController.text.isNotEmpty) {
      final cost = double.tryParse(_costController.text) ?? 0;
      final price = double.tryParse(_pricePerLitreController.text) ?? 0;
      if (price > 0) {
        _litresController.text = (cost / price).toStringAsFixed(2);
      }
    }
  }

  void _submit([Refill? existingRefill]) {
    if (_formKey.currentState!.validate()) {
      final refill = Refill(
        id: existingRefill?.id ?? 0,
        date: DateTime.parse(_dateController.text),
        litres: double.parse(_litresController.text),
        totalCost: _costController.text.isNotEmpty
            ? double.parse(_costController.text)
            : null,
        costPerLitre: _pricePerLitreController.text.isNotEmpty
            ? double.parse(_pricePerLitreController.text)
            : null,
        odometerReading: _odometerController.text.isNotEmpty
            ? int.parse(_odometerController.text)
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (existingRefill != null) {
        ref.read(refillListProvider.notifier).updateRefill(refill);
      } else {
        ref.read(refillListProvider.notifier).addRefill(refill);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final refillsAsync = ref.watch(refillListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Petrol Refills')),
      body: refillsAsync.when(
        data: (refills) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: refills.length,
          itemBuilder: (context, index) {
            final r = refills[index];
            return Dismissible(
              key: Key('refill_${r.id}'),
              onDismissed: (direction) async {
                ref.read(refillListProvider.notifier).deleteRefill(r.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${r.litres}L deleted')),
                  );
                }
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              child: Card(
                child: ListTile(
                  onTap: () => _showAddDialog(context, refill: r),
                  title: Text('${r.litres} L'),
                  subtitle: Text('${r.date.toLocal()}'.split(' ')[0]),
                  trailing:
                      r.totalCost != null ? Text('\$${r.totalCost}') : null,
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, {Refill? refill}) {
    // Initialize controllers if editing
    if (refill != null) {
      _dateController.text = refill.date.toIso8601String().split('T')[0];
      _litresController.text = refill.litres.toString();
      _costController.text = refill.totalCost?.toString() ?? '';
      _pricePerLitreController.text = refill.costPerLitre?.toString() ?? '';
      _odometerController.text = refill.odometerReading?.toString() ?? '';
      _notesController.text = refill.notes ?? '';
    } else {
      // Reset for new
      _dateController.text = DateTime.now().toIso8601String().split('T')[0];
      _litresController.clear();
      _costController.clear();
      _pricePerLitreController.clear();
      _odometerController.clear();
      _notesController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(refill == null ? 'Add Refill' : 'Edit Refill'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _dateController,
                    decoration: const InputDecoration(labelText: 'Date'),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        _dateController.text =
                            date.toIso8601String().split('T')[0];
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('By Cost')),
                      ButtonSegment(value: false, label: Text('Direct Litres')),
                    ],
                    selected: {_isCostBased},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setDialogState(() => _isCostBased = newSelection.first);
                    },
                  ),
                  const SizedBox(height: 10),
                  if (_isCostBased) ...[
                    TextFormField(
                      controller: _costController,
                      decoration:
                          const InputDecoration(labelText: 'Total Cost'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateLitres(),
                    ),
                    TextFormField(
                      controller: _pricePerLitreController,
                      decoration:
                          const InputDecoration(labelText: 'Price per Litre'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _calculateLitres(),
                    ),
                  ],
                  TextFormField(
                    controller: _litresController,
                    decoration: const InputDecoration(labelText: 'Litres'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                    enabled: !_isCostBased,
                  ),
                  TextFormField(
                    controller: _odometerController,
                    decoration:
                        const InputDecoration(labelText: 'Odometer (Optional)'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _submit(refill),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
