import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/features/journey/providers/journeys_provider.dart';
import 'package:bike_petrol_app/features/bike_profile/providers/bike_provider.dart';
import 'package:bike_petrol_app/features/routes/providers/routes_provider.dart';
import 'package:bike_petrol_app/common/models/journey.dart';
import 'package:bike_petrol_app/common/models/driving_route.dart';
import 'package:bike_petrol_app/utils/date_formatter.dart';

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
  bool _isReversed = false;
  bool _recordTime = false;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _useCustomEntry = false;

  void _submit([Journey? existingJourney]) {
    if (_formKey.currentState!.validate()) {
      final distance = double.tryParse(_distanceController.text) ?? 0;
      if (distance <= 0) return;

      // Get Mileage
      final mileage = ref.read(bikeProvider)?.mileage ?? 50.0;

      // Distance is already doubled in the text field if round trip is on
      // So we use it directly without further multiplication
      final litresConsumed = distance / mileage;

      // Construct Name (Start -> End), considering reverse
      String routeName;
      if (_routeNameController.text.isNotEmpty) {
        routeName = _routeNameController.text;
      } else if (_selectedRoute != null) {
        routeName = _isReversed ? _selectedRoute!.reverseName : _selectedRoute!.name;
      } else {
        routeName = 'Custom Journey';
      }

      // Combine date with times if provided
      final journeyDate = DateTime.parse(_dateController.text);
      DateTime? startDateTime;
      DateTime? endDateTime;
      
      if (_recordTime && _startTime != null) {
        startDateTime = DateTime(
          journeyDate.year,
          journeyDate.month,
          journeyDate.day,
          _startTime!.hour,
          _startTime!.minute,
        );
      }
      
      if (_recordTime && _endTime != null) {
        endDateTime = DateTime(
          journeyDate.year,
          journeyDate.month,
          journeyDate.day,
          _endTime!.hour,
          _endTime!.minute,
        );
      }

      final journey = Journey(
        id: existingJourney?.id ?? 0,
        date: journeyDate,
        recordedAt: existingJourney?.recordedAt ?? DateTime.now(), // Preserve old recordedAt or set new
        startTime: startDateTime,
        endTime: endDateTime,
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
                  return Card(
                    child: ListTile(
                      onTap: () => _showAddDialog(context, journey: j),
                      title: Text('${j.distanceKm.toStringAsFixed(1)} km'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(j.startName),
                          Text(
                            DateFormatter.formatJourneyTime(j.date, j.startTime, j.endTime),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${j.litresConsumed.toStringAsFixed(2)} L'),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showAddDialog(context, journey: j);
                              } else if (value == 'delete') {
                                ref.read(journeyListProvider.notifier).deleteJourney(j.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Journey deleted')),
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
    final routes = ref.read(routesListProvider);

    // Pre-fill if editing
    if (journey != null) {
      _dateController.text = journey.date.toIso8601String().split('T')[0];
      _routeNameController.text = journey.startName;
      // Load the stored distance (which is already the total/doubled distance)
      _distanceController.text = journey.distanceKm.toString();
      _isRoundTrip = journey.isRoundTrip;
      _recordTime = journey.startTime != null || journey.endTime != null;
      _startTime = journey.startTime != null 
        ? TimeOfDay.fromDateTime(journey.startTime!) 
        : null;
      _endTime = journey.endTime != null 
        ? TimeOfDay.fromDateTime(journey.endTime!) 
        : null;
      _selectedRoute = null; // Clear selection when editing custom
    } else {
      _dateController.text = DateTime.now().toIso8601String().split('T')[0];
      _routeNameController.clear();
      _distanceController.clear();
      _isRoundTrip = false;
      _isReversed = false;
      _recordTime = false;
      _startTime = null;
      _endTime = null;
      _useCustomEntry = false;
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

                  // Entry Mode Selector
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('Saved Route'),
                        icon: Icon(Icons.map, size: 16),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('Custom Entry'),
                        icon: Icon(Icons.edit, size: 16),
                      ),
                    ],
                    selected: {_useCustomEntry},
                    onSelectionChanged: (Set<bool> selection) {
                      setDialogState(() {
                        _useCustomEntry = selection.first;
                        if (_useCustomEntry) {
                          _selectedRoute = null;
                          _isReversed = false;
                        } else {
                          _routeNameController.clear();
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // Route Selector (only show if not custom entry)
                  if (!_useCustomEntry)
                    DropdownButtonFormField<DrivingRoute>(
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
                          _isReversed = false; // Reset reverse when changing route
                          if (r != null) {
                            _routeNameController.text = r.name;
                            // If Round Trip is ON, show doubled distance immediately
                            final dist = _isRoundTrip ? r.distanceKm * 2 : r.distanceKm;
                            _distanceController.text = dist.toString();
                          }
                        });
                      },
                    ),

                  // Custom Entry Fields (only show if custom entry mode)
                  if (_useCustomEntry) ...[
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _routeNameController,
                      decoration: const InputDecoration(
                        labelText: 'Journey Name',
                        hintText: 'e.g., Home to Office',
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ],

                  const SizedBox(height: 10),

                  // Time Recording Toggle
                  SwitchListTile(
                    title: const Text('Record Time'),
                    value: _recordTime,
                    onChanged: (v) {
                      setDialogState(() {
                        _recordTime = v;
                        if (!v) {
                          _startTime = null;
                          _endTime = null;
                        }
                      });
                    },
                  ),

                  // Time Pickers (only show if recording time)
                  if (_recordTime) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            title: const Text('Start Time'),
                            subtitle: Text(_startTime?.format(context) ?? 'Not set'),
                            trailing: const Icon(Icons.access_time),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _startTime ?? TimeOfDay.now(),
                              );
                              if (time != null) {
                                setDialogState(() => _startTime = time);
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: const Text('End Time'),
                            subtitle: Text(_endTime?.format(context) ?? 'Not set'),
                            trailing: const Icon(Icons.access_time),
                            onTap: () async {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: _endTime ?? TimeOfDay.now(),
                              );
                              if (time != null) {
                                setDialogState(() => _endTime = time);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    // Show duration if both times are set
                    if (_startTime != null && _endTime != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Duration: ${_calculateDuration(_startTime!, _endTime!)}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],

                  // Reverse Route Toggle (only show if route is selected and not custom)
                  if (!_useCustomEntry && _selectedRoute != null) ...[
                    const SizedBox(height: 10),
                      SwitchListTile(
                        title: const Text('Reverse Route'),
                        subtitle: Text(_isReversed 
                          ? _selectedRoute!.reverseName 
                          : _selectedRoute!.name),
                        value: _isReversed,
                        onChanged: (v) {
                          setDialogState(() {
                            _isReversed = v;
                            // Update the route name display
                            _routeNameController.text = v 
                              ? _selectedRoute!.reverseName 
                              : _selectedRoute!.name;
                          });
                        },
                      ),
                  ],
                  
                  // Distance field with quick-add buttons for custom entry
                  TextFormField(
                    controller: _distanceController,
                    decoration: const InputDecoration(labelText: 'Distance (km)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),

                  // Quick-add distance buttons (only for custom entry)
                  if (_useCustomEntry) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [5, 10, 20, 50].map((distance) {
                        return ActionChip(
                          label: Text('${distance}km'),
                          onPressed: () {
                            setDialogState(() {
                              _distanceController.text = distance.toString();
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],

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

  String _calculateDuration(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final durationMinutes = endMinutes - startMinutes;
    
    if (durationMinutes < 0) {
      return 'End time is before start time';
    }
    
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    
    if (hours > 0) {
      return minutes > 0 ? '${hours}h ${minutes}min' : '${hours}h';
    } else {
      return '${minutes}min';
    }
  }
}
