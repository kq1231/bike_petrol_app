import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/features/journey/providers/journeys_provider.dart';
import 'package:bike_petrol_app/features/bike_profile/providers/bike_provider.dart';
import 'package:bike_petrol_app/features/routes/providers/routes_provider.dart';
import 'package:bike_petrol_app/common/models/journey.dart';
import 'package:bike_petrol_app/common/models/driving_route.dart';

class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0]);
  final _distanceController = TextEditingController();
  final _routeNameController = TextEditingController();

  DrivingRoute? _selectedRoute;
  bool _isRoundTrip = false;

  void _submit([Journey? existingJourney]) {
    if (_formKey.currentState!.validate()) {
      final distance = double.tryParse(_distanceController.text) ?? 0;
      if (distance <= 0) return;

      // Get Mileage
      final mileage = ref.read(bikeProvider).value?.mileage ?? 50.0;

      // Distance is already doubled in the text field if round trip is on
      // So we use it directly without further multiplication
      final litresConsumed = distance / mileage;

      // Construct Name (Start -> End)
      final routeName = _routeNameController.text.isNotEmpty
          ? _routeNameController.text
          : (_selectedRoute?.name ?? 'Custom Journey');

      final journey = Journey(
        id: existingJourney?.id ?? 0,
        date: DateTime.parse(_dateController.text),
        startName: routeName,
        startLat: 0, // Not used without maps
        startLng: 0, // Not used without maps
        endName: 'Destination', // Generic since we don't track Lat/Lng
        endLat: 0,
        endLng: 0,
        distanceKm: distance,
        isRoundTrip: _isRoundTrip,
        litresConsumed: litresConsumed,
      );

      if (existingJourney != null) {
        ref.read(journeyListProvider.notifier).updateJourney(journey);
      } else {
        ref.read(journeyListProvider.notifier).addJourney(journey);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final journeysAsync = ref.watch(journeyListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journeys')),
      body: journeysAsync.when(
        data: (paginatedState) {
          final journeys = paginatedState.items;
          
          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(journeyListProvider.notifier).refresh();
            },
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                // Load more when user scrolls near bottom
                if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                  if (paginatedState.hasMore && !paginatedState.isLoadingMore) {
                    ref.read(journeyListProvider.notifier).loadMore();
                  }
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: journeys.length + (paginatedState.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show loading indicator at bottom
                  if (index == journeys.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final j = journeys[index];
                  return Dismissible(
                    key: Key('journey_${j.id}'),
                    onDismissed: (direction) {
                      ref.read(journeyListProvider.notifier).deleteJourney(j.id);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: Card(
                      child: ListTile(
                        onTap: () => _showAddDialog(context, journey: j),
                        title: Text('${j.distanceKm.toStringAsFixed(1)} km'),
                        subtitle: Text(j.startName),
                        trailing: Text('${j.litresConsumed.toStringAsFixed(2)} L'),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, {Journey? journey}) {
    final routesAsync = ref.read(routesListProvider);

    // Pre-fill if editing
    if (journey != null) {
      _dateController.text = journey.date.toIso8601String().split('T')[0];
      _routeNameController.text = journey.startName;
      // Load the stored distance (which is already the total/doubled distance)
      _distanceController.text = journey.distanceKm.toString();
      _isRoundTrip = journey.isRoundTrip;
      _selectedRoute = null; // Clear selection when editing custom
    } else {
      _dateController.text = DateTime.now().toIso8601String().split('T')[0];
      _routeNameController.clear();
      _distanceController.clear();
      _isRoundTrip = false;
      _selectedRoute = null;
    }

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(journey == null ? 'Log Journey' : 'Edit Journey'),
            content: SizedBox(
              width: double.maxFinite,
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
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

                  // Route Selector or Manual Input
                  routesAsync.when(
                    data: (routes) => DropdownButtonFormField<DrivingRoute>(
                      decoration: const InputDecoration(
                        label: Text(
                          'Select Saved Route',
                        ),
                      ),
                      initialValue: _selectedRoute,
                      items: routes
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text('${r.name} (${r.distanceKm}km)'),
                              ))
                          .toList(),
                      onChanged: (r) {
                        setDialogState(() {
                          _selectedRoute = r;
                          if (r != null) {
                            _routeNameController.text = r.name;
                            // If Round Trip is ON, show doubled distance immediately
                            final dist = _isRoundTrip ? r.distanceKm * 2 : r.distanceKm;
                            _distanceController.text = dist.toString();
                          }
                        });
                      },
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Text('Error loading routes'),
                  ),

                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _distanceController,
                    decoration:
                        const InputDecoration(labelText: 'Distance (km)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),

                  SwitchListTile(
                    title: const Text('Round Trip'),
                    value: _isRoundTrip,
                    onChanged: (v) {
                      setDialogState(() {
                        _isRoundTrip = v;
                        // Update distance field to reflect new total
                        final currentDist = double.tryParse(_distanceController.text) ?? 0;
                        if (currentDist > 0) {
                          _distanceController.text = v 
                              ? (currentDist * 2).toString() 
                              : (currentDist / 2).toString();
                        }
                      });
                    },
                  ),
                ],
              ),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => _submit(journey),
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
