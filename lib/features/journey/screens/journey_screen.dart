import 'package:bike_petrol_app/features/journey/repositories/journey_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/features/journey/providers/journeys_provider.dart';
import 'package:bike_petrol_app/features/bike_profile/providers/bike_provider.dart';
import 'package:bike_petrol_app/common/services/map_service.dart';
import 'package:bike_petrol_app/common/models/journey.dart';

class JourneyScreen extends ConsumerStatefulWidget {
  const JourneyScreen({super.key});

  @override
  ConsumerState<JourneyScreen> createState() => _JourneyScreenState();
}

class _JourneyScreenState extends ConsumerState<JourneyScreen> {
  final MapService _mapService = MapService();

  // Form State
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _dateController = TextEditingController(
    text: DateTime.now().toIso8601String().split('T')[0],
  );
  bool _isRoundTrip = false;
  bool _isLoading = false;
  double _distance = 0.0;

  // Search Results
  List<LocationResult> _startResults = [];
  List<LocationResult> _endResults = [];

  LocationResult? _selectedStart;
  LocationResult? _selectedEnd;

  Future<void> _search(String query, bool isStart) async {
    if (query.isEmpty) return;
    final results = await _mapService.searchLocation(query);
    setState(() {
      if (isStart) {
        _startResults = results;
      } else {
        _endResults = results;
      }
    });
  }

  Future<void> _calculateRoute() async {
    if (_selectedStart == null || _selectedEnd == null) return;

    setState(() => _isLoading = true);
    final dist = await _mapService.calculateDistance(
      _selectedStart!.lat,
      _selectedStart!.lng,
      _selectedEnd!.lat,
      _selectedEnd!.lng,
    );
    setState(() {
      _distance = dist;
      _isLoading = false;
    });
  }

  void _submit() {
    if (_selectedStart == null || _selectedEnd == null || _distance == 0) {
      return;
    }

    // Get Mileage
    final mileage = ref.read(bikeProvider).value?.mileage ?? 50.0;

    // Total Distance
    final totalDistance = _isRoundTrip ? _distance * 2 : _distance;
    final litresConsumed = totalDistance / mileage;

    final journey = Journey(
      date: DateTime.parse(_dateController.text),
      startName: _selectedStart!.name,
      startLat: _selectedStart!.lat,
      startLng: _selectedStart!.lng,
      endName: _selectedEnd!.name,
      endLat: _selectedEnd!.lat,
      endLng: _selectedEnd!.lng,
      distanceKm: totalDistance,
      isRoundTrip: _isRoundTrip,
      litresConsumed: litresConsumed,
    );

    ref.read(journeyRepositoryProvider).addJourney(journey);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final journeysAsync = ref.watch(journeyListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Journeys')),
      body: Column(
        children: [
          Expanded(
            child: journeysAsync.when(
              data: (journeys) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: journeys.length,
                itemBuilder: (context, index) {
                  final j = journeys[index];
                  return Card(
                    child: ListTile(
                      title: Text('${j.distanceKm.toStringAsFixed(1)} km'),
                      subtitle: Text(
                        '${j.startName.split(',')[0]} to ${j.endName.split(',')[0]}',
                      ),
                      trailing:
                          Text('${j.litresConsumed.toStringAsFixed(2)} L'),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) =>
                  Center(child: Text('Error loading journeys: $e')),
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
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Log Journey'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                // Start Location Search
                TextField(
                  controller: _startController,
                  decoration:
                      const InputDecoration(labelText: 'Start Location'),
                  onChanged: (v) => _search(v, true),
                ),
                if (_startResults.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _startResults.length,
                    itemBuilder: (ctx, i) => ListTile(
                      dense: true,
                      title: Text(
                        _startResults[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        setDialogState(() {
                          _selectedStart = _startResults[i];
                          _startController.text =
                              _startResults[i].name.split(',')[0];
                          _startResults = [];
                        });
                      },
                    ),
                  ),

                const SizedBox(height: 10),

                // End Location Search
                TextField(
                  controller: _endController,
                  decoration: const InputDecoration(labelText: 'End Location'),
                  onChanged: (v) => _search(v, false),
                ),
                if (_endResults.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _endResults.length,
                    itemBuilder: (ctx, i) => ListTile(
                      dense: true,
                      title: Text(
                        _endResults[i].name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        setDialogState(() {
                          _selectedEnd = _endResults[i];
                          _endController.text =
                              _endResults[i].name.split(',')[0];
                          _endResults = [];
                        });
                      },
                    ),
                  ),

                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text('Round Trip'),
                  value: _isRoundTrip,
                  onChanged: (v) => setDialogState(() => _isRoundTrip = v),
                ),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (_distance > 0)
                  Text(
                    'Distance: ${_distance.toStringAsFixed(1)} km',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                ElevatedButton(
                  onPressed: _isLoading ? null : _calculateRoute,
                  child: const Text('Calculate Distance'),
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
              onPressed: _distance > 0 ? _submit : null,
              child: const Text('Save Journey'),
            ),
          ],
        ),
      ),
    );
  }
}
