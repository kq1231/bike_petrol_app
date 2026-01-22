import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/features/dashboard/providers/dashboard_provider.dart';
import 'package:bike_petrol_app/common/services/map_service.dart';

class EstimatorScreen extends ConsumerStatefulWidget {
  const EstimatorScreen({super.key});

  @override
  ConsumerState<EstimatorScreen> createState() => _EstimatorScreenState();
}

class _EstimatorScreenState extends ConsumerState<EstimatorScreen> {
  final MapService _mapService = MapService();
  
  final _startController = TextEditingController();
  final _destController = TextEditingController();
  bool _isRoundTrip = false;
  
  List<LocationResult> _startResults = [];
  List<LocationResult> _destResults = [];
  
  LocationResult? _selectedStart;
  LocationResult? _selectedDest;
  
  double _distance = 0.0;
  bool _calculating = false;

  Future<void> _searchStart(String query) async {
    if (query.isEmpty) {
      setState(() => _startResults = []);
      return;
    }
    final res = await _mapService.searchLocation(query);
    if (mounted) setState(() => _startResults = res);
  }

  Future<void> _searchDest(String query) async {
    if (query.isEmpty) {
      setState(() => _destResults = []);
      return;
    }
    final res = await _mapService.searchLocation(query);
    if (mounted) setState(() => _destResults = res);
  }

  Future<void> _estimate() async {
    if (_selectedStart == null || _selectedDest == null) return;
    
    setState(() => _calculating = true);
    final d = await _mapService.calculateDistance(
      _selectedStart!.lat, _selectedStart!.lng,
      _selectedDest!.lat, _selectedDest!.lng
    );
    if (mounted) {
      setState(() {
        _distance = d;
        _calculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Journey Estimator')),
      body: statsAsync.when(
        data: (stats) {
          final mileage = stats.avgMileage;
          final totalDist = _isRoundTrip ? _distance * 2 : _distance;
          final litresNeeded = totalDist / mileage;
          final balance = stats.currentBalance;
          final deficit = litresNeeded - balance;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LocationSearch(
                  controller: _startController,
                  results: _startResults,
                  label: 'Start Location',
                  onSearch: _searchStart,
                  onSelect: (loc) {
                    setState(() {
                      _selectedStart = loc;
                      _startController.text = loc.name.split(',')[0];
                      _startResults = [];
                    });
                  },
                ),
                const SizedBox(height: 10),
                _LocationSearch(
                  controller: _destController,
                  results: _destResults,
                  label: 'Destination',
                  onSearch: _searchDest,
                  onSelect: (loc) {
                    setState(() {
                      _selectedDest = loc;
                      _destController.text = loc.name.split(',')[0];
                      _destResults = [];
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Round Trip'),
                  value: _isRoundTrip,
                  onChanged: (v) => setState(() => _isRoundTrip = v),
                ),
                const SizedBox(height: 20),
                if (_calculating)
                  const Center(child: CircularProgressIndicator()),
                if (_distance > 0) ...[
                  Text('Distance: ${totalDist.toStringAsFixed(1)} km', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('Litres Needed: ${litresNeeded.toStringAsFixed(2)} L'),
                  const SizedBox(height: 10),
                  Text('Current Balance: ${balance.toStringAsFixed(2)} L'),
                  const SizedBox(height: 10),
                  if (deficit > 0)
                    Text('Deficit: ${deficit.toStringAsFixed(2)} L (Refill needed!)', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                  else
                    Text('Surplus: ${(-deficit).toStringAsFixed(2)} L', style: const TextStyle(color: Colors.green)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedStart != null && _selectedDest != null ? _estimate : null,
                    child: const Text('Estimate'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _LocationSearch extends StatelessWidget {
  final TextEditingController controller;
  final List<LocationResult> results;
  final String label;
  final Function(String) onSearch;
  final Function(LocationResult) onSelect;

  const _LocationSearch({
    required this.controller,
    required this.results,
    required this.label,
    required this.onSearch,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          onChanged: onSearch,
        ),
        if (results.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: results.length,
              itemBuilder: (ctx, i) => ListTile(
                dense: true,
                title: Text(results[i].name, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => onSelect(results[i]),
              ),
            ),
          ),
      ],
    );
  }
}
