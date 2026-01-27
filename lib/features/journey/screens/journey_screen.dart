import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bike_petrol_app/features/journey/providers/journeys_provider.dart';
import 'package:bike_petrol_app/common/models/journey.dart';
import 'package:bike_petrol_app/utils/date_formatter.dart';
import 'package:bike_petrol_app/features/journey/widgets/journey_dialog.dart';

class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                if (scrollInfo.metrics.pixels >=
                    scrollInfo.metrics.maxScrollExtent - 200) {
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
                            DateFormatter.formatJourneyTime(
                                j.date, j.startTime, j.endTime),
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
                                ref
                                    .read(journeyListProvider.notifier)
                                    .deleteJourney(j.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Journey deleted')),
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
                                    Icon(Icons.delete,
                                        size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete',
                                        style: TextStyle(color: Colors.red)),
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
    showDialog(
      context: context,
      builder: (ctx) => JourneyDialog(journey: journey),
    );
  }
}
