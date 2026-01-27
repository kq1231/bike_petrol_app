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

          // Build list items with date headers
          final listItems = _buildListItemsWithHeaders(journeys);

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
                itemCount: listItems.length + (paginatedState.hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  // Show loading indicator at bottom
                  if (index == listItems.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final item = listItems[index];

                  // Render date header
                  if (item is _DateHeader) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        bottom: 8,
                        left: 4,
                      ),
                      child: Text(
                        item.dateText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    );
                  }

                  // Render journey card
                  final j = (item as _JourneyItem).journey;
                  final routeName = '${j.startName} → ${j.endName}';
                  return Card(
                    child: ListTile(
                      onTap: () => _showAddDialog(context, journey: j),
                      title: Row(
                        children: [
                          Expanded(child: Text(routeName)),
                          if (j.isRoundTrip)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Round Trip',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${j.distanceKm.toStringAsFixed(1)} km'),
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

  /// Build a list of items that includes both date headers and journey items
  List<_ListItem> _buildListItemsWithHeaders(List<Journey> journeys) {
    final List<_ListItem> items = [];
    DateTime? lastDate;

    for (final journey in journeys) {
      final journeyDate = DateTime(
        journey.date.year,
        journey.date.month,
        journey.date.day,
      );

      // Add date header if this is a new date
      if (lastDate == null ||
          journeyDate.year != lastDate.year ||
          journeyDate.month != lastDate.month ||
          journeyDate.day != lastDate.day) {
        items.add(_DateHeader(
          date: journeyDate,
          dateText: DateFormatter.formatFriendlyDate(journeyDate),
        ));
        lastDate = journeyDate;
      }

      // Add journey item
      items.add(_JourneyItem(journey: journey));
    }

    return items;
  }
}

// Base class for list items
abstract class _ListItem {}

// Date header item
class _DateHeader extends _ListItem {
  final DateTime date;
  final String dateText;

  _DateHeader({required this.date, required this.dateText});
}

// Journey item
class _JourneyItem extends _ListItem {
  final Journey journey;

  _JourneyItem({required this.journey});
}
