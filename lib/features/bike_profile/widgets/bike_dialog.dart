import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/common/models/bike.dart';
import 'package:bike_petrol_app/features/bike_profile/providers/bike_provider.dart';

class BikeDialog extends ConsumerStatefulWidget {
  final Bike? initialBike;
  final VoidCallback? onSave;

  const BikeDialog({super.key, this.initialBike, this.onSave});

  @override
  ConsumerState<BikeDialog> createState() => _EditBikeDialogState();
}

class _EditBikeDialogState extends ConsumerState<BikeDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mileageController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialBike?.name ?? 'My Bike');
    _mileageController = TextEditingController(
        text: widget.initialBike?.mileage.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final bike = Bike(
      name: _nameController.text,
      mileage: double.parse(_mileageController.text),
    );

    if (widget.initialBike != null) {
      bike.id = widget.initialBike!.id;
    }

    ref.read(bikeProvider.notifier).updateBike(bike);

    // Call outside-exposed onSave method
    widget.onSave?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialBike == null ? 'Setup Your Bike' : 'Edit Bike'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Bike Name'),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _mileageController,
              decoration: const InputDecoration(labelText: 'Mileage (km/L)'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
