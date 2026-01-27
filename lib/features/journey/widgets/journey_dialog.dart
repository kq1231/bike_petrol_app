import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/features/journey/providers/journeys_provider.dart';
import 'package:bike_petrol_app/features/bike_profile/providers/bike_provider.dart';
import 'package:bike_petrol_app/features/routes/providers/routes_provider.dart';
import 'package:bike_petrol_app/common/models/journey.dart';
import 'package:bike_petrol_app/common/models/driving_route.dart';
import 'package:bike_petrol_app/utils/date_formatter.dart';

class JourneyDialog extends ConsumerStatefulWidget {
  final Journey? journey;

  const JourneyDialog({
    super.key,
    this.journey,
  });

  @override
  ConsumerState<JourneyDialog> createState() => _JourneyDialogState();
}

class _JourneyDialogState extends ConsumerState<JourneyDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _dateController;
  late final TextEditingController _distanceController;
  late final TextEditingController _startLocationController;
  late final TextEditingController _endLocationController;

  late DateTime _selectedDate;
  DrivingRoute? _selectedRoute;
  String? _selectedRouteBase; // "Start → End" without via
  String? _selectedVia; // Selected via option
  bool _isRoundTrip = false;
  bool _recordTime = false;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _useCustomEntry = false;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.journey?.date ?? DateTime.now();
    _dateController = TextEditingController(
      text: DateFormatter.formatFriendlyDate(_selectedDate),
    );
    _distanceController = TextEditingController(
      text: widget.journey?.distanceKm.toString() ?? '',
    );
    _startLocationController = TextEditingController(
      text: widget.journey?.startName ?? '',
    );
    _endLocationController = TextEditingController(
      text: widget.journey?.endName ?? '',
    );

    // Initialize state from journey if editing
    if (widget.journey != null) {
      final journey = widget.journey!;
      final routes = ref.read(routesListProvider);

      _isRoundTrip = journey.isRoundTrip;
      _recordTime = journey.startTime != null || journey.endTime != null;
      _startTime = journey.startTime != null
          ? TimeOfDay.fromDateTime(journey.startTime!)
          : null;
      _endTime = journey.endTime != null
          ? TimeOfDay.fromDateTime(journey.endTime!)
          : null;

      // Find matching route from saved routes
      try {
        _selectedRoute = routes.firstWhere(
          (r) =>
              (r.startLocation == journey.startName &&
                  r.endLocation == journey.endName) ||
              (r.startLocation == journey.endName &&
                  r.endLocation == journey.startName),
        );

        // Set route base and via
        if (_selectedRoute!.startLocation == journey.startName) {
          _selectedRouteBase = '${_selectedRoute!.startLocation} → ${_selectedRoute!.endLocation}';
        } else {
          _selectedRouteBase = '${_selectedRoute!.endLocation} → ${_selectedRoute!.startLocation}';
        }
        _selectedVia = _selectedRoute!.via;
      } catch (e) {
        _selectedRoute = null;
        _selectedRouteBase = null;
        _selectedVia = null;
      }

      // If matching route found, use saved route mode
      if (_selectedRoute != null) {
        _useCustomEntry = false;
      } else {
        _useCustomEntry = true;
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _distanceController.dispose();
    _startLocationController.dispose();
    _endLocationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final distance = double.tryParse(_distanceController.text) ?? 0;
      if (distance <= 0) return;

      // Get Mileage
      final mileage = ref.read(bikeProvider)?.mileage ?? 50.0;
      final litresConsumed = distance / mileage;

      // Determine start and end locations based on route selection
      String startName;
      String endName;

      if (_selectedRouteBase != null) {
        // Using a saved route - extract from route base
        final parts = _selectedRouteBase!.split(' → ');
        startName = parts[0];
        endName = parts[1];
      } else {
        // Custom entry - use the separate start and end location fields
        startName = _startLocationController.text.trim();
        endName = _endLocationController.text.trim();
      }

      // Combine date with times if provided
      final journeyDate = _selectedDate;
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
        id: widget.journey?.id ?? 0,
        date: journeyDate,
        recordedAt: DateTime.now(),
        startTime: startDateTime,
        endTime: endDateTime,
        startName: startName,
        endName: endName,
        distanceKm: distance,
        isRoundTrip: _isRoundTrip,
        litresConsumed: litresConsumed,
      );

      if (widget.journey != null) {
        ref.read(journeyListProvider.notifier).updateJourney(journey);
      } else {
        ref.read(journeyListProvider.notifier).addJourney(journey);
      }

      Navigator.pop(context);
    }
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

  @override
  Widget build(BuildContext context) {
    final routes = ref.watch(routesListProvider);

    return AlertDialog(
      title: Text(widget.journey == null ? 'Log Journey' : 'Edit Journey'),
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
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                      _dateController.text = DateFormatter.formatFriendlyDate(date);
                    });
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
                  setState(() {
                    _useCustomEntry = selection.first;
                    if (_useCustomEntry) {
                      _selectedRoute = null;
                      _selectedRouteBase = null;
                      _selectedVia = null;
                    } else {
                      _startLocationController.clear();
                      _endLocationController.clear();
                    }
                  });
                },
              ),

              const SizedBox(height: 10),

              // Route Selector (only show if not custom entry)
              if (!_useCustomEntry) ...[
                // Route Base Picker
                GestureDetector(
                  onTap: () => _showRouteBasePicker(context, routes),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Select Route',
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      controller: TextEditingController(
                        text: _selectedRouteBase ?? '',
                      ),
                      validator: (v) => _selectedRouteBase == null ? 'Please select a route' : null,
                    ),
                  ),
                ),

                // Via Picker (only show if route base is selected and has multiple vias)
                if (_selectedRouteBase != null &&
                    _getViasForRouteBase(routes, _selectedRouteBase!).length > 1) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _showViaPicker(context, routes),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Select Via',
                          suffixIcon: Icon(Icons.arrow_drop_down),
                        ),
                        controller: TextEditingController(
                          text: _selectedVia ?? 'Direct',
                        ),
                      ),
                    ),
                  ),
                ],
              ],

              // Custom Entry Fields (only show if custom entry mode)
              if (_useCustomEntry) ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _startLocationController,
                  decoration: const InputDecoration(
                    labelText: 'Start Location',
                    hintText: 'e.g., Home',
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _endLocationController,
                  decoration: const InputDecoration(
                    labelText: 'End Location',
                    hintText: 'e.g., Office',
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Required' : null,
                ),
              ],

              const SizedBox(height: 10),

              // Time Recording Toggle
              SwitchListTile(
                title: const Text('Record Time'),
                value: _recordTime,
                onChanged: (v) {
                  setState(() {
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
                        subtitle:
                            Text(_startTime?.format(context) ?? 'Not set'),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _startTime ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() => _startTime = time);
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
                            setState(() => _endTime = time);
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

              // Distance field
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
                        setState(() {
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
                  setState(() {
                    _isRoundTrip = v;
                    final currentDist =
                        double.tryParse(_distanceController.text) ?? 0;
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
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }

  /// Get unique route bases (start → end combinations) from all routes
  List<String> _getUniqueRouteBases(List<DrivingRoute> routes) {
    final Set<String> routeBases = {};
    for (final route in routes) {
      routeBases.add('${route.startLocation} → ${route.endLocation}');
      routeBases.add('${route.endLocation} → ${route.startLocation}');
    }
    return routeBases.toList()..sort();
  }

  /// Get all via options for a selected route base
  List<String> _getViasForRouteBase(List<DrivingRoute> routes, String routeBase) {
    final parts = routeBase.split(' → ');
    if (parts.length != 2) return [];

    final start = parts[0];
    final end = parts[1];

    final vias = routes
        .where((r) => r.startLocation == start && r.endLocation == end)
        .map((r) => r.via ?? 'Direct')
        .toSet()
        .toList();

    return vias..sort();
  }

  /// Show Cupertino picker for route base selection
  void _showRouteBasePicker(BuildContext context, List<DrivingRoute> routes) {
    final routeBases = _getUniqueRouteBases(routes);
    int selectedIndex = _selectedRouteBase != null
        ? routeBases.indexOf(_selectedRouteBase!)
        : 0;
    if (selectedIndex < 0) selectedIndex = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground.resolveFrom(context),
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      setState(() {
                        _selectedRouteBase = routeBases[selectedIndex];
                        _selectedVia = null;
                        _selectedRoute = null;

                        // Auto-select via if only one option
                        final vias = _getViasForRouteBase(routes, _selectedRouteBase!);
                        if (vias.length == 1) {
                          final via = vias.first;
                          _selectedVia = via == 'Direct' ? null : via;
                        }
                        // Always update the selected route and distance
                        _updateSelectedRoute(routes);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: selectedIndex,
                ),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  selectedIndex = index;
                },
                children: routeBases
                    .map((base) => Center(child: Text(base)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show Cupertino picker for via selection
  void _showViaPicker(BuildContext context, List<DrivingRoute> routes) {
    if (_selectedRouteBase == null) return;

    final vias = _getViasForRouteBase(routes, _selectedRouteBase!);
    if (vias.isEmpty) return;

    int selectedIndex = _selectedVia != null
        ? vias.indexOf(_selectedVia!)
        : 0;
    if (selectedIndex < 0) selectedIndex = 0;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground.resolveFrom(context),
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.separator.resolveFrom(context),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.pop(context),
                  ),
                  CupertinoButton(
                    child: const Text('Done'),
                    onPressed: () {
                      setState(() {
                        final selectedViaValue = vias[selectedIndex];
                        _selectedVia = selectedViaValue == 'Direct' ? null : selectedViaValue;
                        _updateSelectedRoute(routes);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: selectedIndex,
                ),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  selectedIndex = index;
                },
                children: vias
                    .map((via) => Center(child: Text(via)))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Update the selected route based on route base and via
  void _updateSelectedRoute(List<DrivingRoute> routes) {
    if (_selectedRouteBase == null) {
      _selectedRoute = null;
      return;
    }

    final parts = _selectedRouteBase!.split(' → ');
    if (parts.length != 2) {
      _selectedRoute = null;
      return;
    }

    final start = parts[0];
    final end = parts[1];

    try {
      // Try to find exact match with via (check both directions)
      _selectedRoute = routes.firstWhere(
        (r) =>
            ((r.startLocation == start && r.endLocation == end) ||
             (r.startLocation == end && r.endLocation == start)) &&
            ((_selectedVia == null && r.via == null) ||
                r.via == _selectedVia),
      );
    } catch (e) {
      // If no exact match, find any route with the same start/end (check both directions)
      // (This handles the case where via is not selected yet but we need distance)
      try {
        _selectedRoute = routes.firstWhere(
          (r) =>
              (r.startLocation == start && r.endLocation == end) ||
              (r.startLocation == end && r.endLocation == start),
        );
      } catch (e2) {
        _selectedRoute = null;
      }
    }

    // Update distance if route found
    if (_selectedRoute != null) {
      final dist = _isRoundTrip ? _selectedRoute!.distanceKm * 2 : _selectedRoute!.distanceKm;
      _distanceController.text = dist.toString();
    }
  }
}
