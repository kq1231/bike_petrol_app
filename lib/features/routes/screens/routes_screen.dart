import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/features/routes/providers/routes_provider.dart';
import 'package:bike_petrol_app/common/models/driving_route.dart';

class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routesAsync = ref.watch(routesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Routes')),
      body: routesAsync.when(
        data: (routes) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: routes.length,
          itemBuilder: (context, index) {
            final r = routes[index];
            return Card(
              child: ListTile(
                onTap: () => _showEditDialog(context, ref, r),
                title: Text(r.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${r.distanceKm.toStringAsFixed(1)} km'),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditDialog(context, ref, r);
                        } else if (value == 'delete') {
                          ref.read(routesListProvider.notifier).deleteRoute(r.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${r.name} deleted')),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    _showDialog(context, ref, null);
  }

  void _showEditDialog(
      BuildContext context, WidgetRef ref, DrivingRoute route) {
    _showDialog(context, ref, route);
  }

  void _showDialog(BuildContext context, WidgetRef ref, DrivingRoute? route) {
    final startController = TextEditingController(text: route?.startLocation ?? '');
    final endController = TextEditingController(text: route?.endLocation ?? '');
    final viaController = TextEditingController(text: route?.via ?? '');
    final distanceController =
        TextEditingController(text: route?.distanceKm.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(route == null ? 'Add Route' : 'Edit Route'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: startController,
                  decoration: const InputDecoration(
                    labelText: 'Start Location',
                    hintText: 'e.g., Home',
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: endController,
                  decoration: const InputDecoration(
                    labelText: 'End Location',
                    hintText: 'e.g., Office',
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: viaController,
                  decoration: const InputDecoration(
                    labelText: 'Via (Optional)',
                    hintText: 'e.g., Shahrahe Faisal',
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: distanceController,
                  decoration: const InputDecoration(labelText: 'Distance (km)'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newRoute = DrivingRoute(
                  id: route?.id ?? 0,
                  startLocation: startController.text,
                  endLocation: endController.text,
                  via: viaController.text.isEmpty ? null : viaController.text,
                  distanceKm: double.parse(distanceController.text),
                );

                if (route != null) {
                  ref.read(routesListProvider.notifier).updateRoute(newRoute);
                } else {
                  ref.read(routesListProvider.notifier).addRoute(newRoute);
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
