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
            return Dismissible(
              key: Key('route_${r.id}'),
              onDismissed: (direction) {
                ref.read(routesListProvider.notifier).deleteRoute(r.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${r.name} deleted')),
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
                  onTap: () => _showEditDialog(context, ref, r),
                  title: Text(r.name),
                  trailing: Text('${r.distanceKm.toStringAsFixed(1)} km'),
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
    final nameController = TextEditingController(text: route?.name ?? '');
    final distanceController =
        TextEditingController(text: route?.distanceKm.toString() ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(route == null ? 'Add Route' : 'Edit Route'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Route Name (e.g., Home -> Work)'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: distanceController,
                decoration: const InputDecoration(labelText: 'Distance (km)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
            ],
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
                  name: nameController.text,
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
