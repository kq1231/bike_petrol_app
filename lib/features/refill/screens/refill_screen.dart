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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final refill = Refill(
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
      ref.read(refillRepositoryProvider).addRefill(refill);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final refillsAsync = ref.watch(refillListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Petrol Refills')),
      body: Column(
        children: [
          Expanded(
            child: refillsAsync.when(
              data: (refills) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: refills.length,
                itemBuilder: (context, index) {
                  final r = refills[index];
                  return Card(
                    child: ListTile(
                      title: Text('${r.litres} L'),
                      subtitle: Text('${r.date.toLocal()}'.split(' ')[0]),
                      trailing:
                          r.totalCost != null ? Text('\$${r.totalCost}') : null,
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) =>
                  const Center(child: Text('Error loading refills')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (stfulBuilderContext, stfulBuilderSetState) => AlertDialog(
          title: const Text('Add Refill'),
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
                  SizedBox(height: 10),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('By Cost')),
                      ButtonSegment(value: false, label: Text('Direct Litres')),
                    ],
                    selected: {_isCostBased},
                    onSelectionChanged: (Set<bool> newSelection) {
                      stfulBuilderSetState(
                          () => _isCostBased = newSelection.first);
                    },
                  ),
                  SizedBox(height: 10),
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
            ElevatedButton(onPressed: _submit, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
