import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vsm_app/provider/coach/event_provider.dart';
import 'package:vsm_app/provider/announcement_provider.dart';
import 'package:vsm_app/widgets/coach/AnnouncementOverviewCard.dart';
import 'package:vsm_app/widgets/coach/effectif_status_widget.dart';
import 'package:vsm_app/widgets/coach/event_card_widget.dart';

class OverviewTabWidget extends StatefulWidget {
  const OverviewTabWidget({super.key});

  @override
  State<OverviewTabWidget> createState() => _OverviewTabWidgetState();
}

class _OverviewTabWidgetState extends State<OverviewTabWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider.fetchUpcomingEvent();

      final announcementProvider = Provider.of<AnnouncementProvider>(
        context,
        listen: false,
      );
      announcementProvider.fetchLatestAnnouncement();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          Provider.of<EventProvider>(
            context,
            listen: false,
          ).fetchUpcomingEvent(),
          Provider.of<AnnouncementProvider>(
            context,
            listen: false,
          ).fetchLatestAnnouncement(),
        ]);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION PROCHAIN ÉVÉNEMENT / MATCH ---
            Consumer<EventProvider>(
              builder: (context, eventProvider, child) {
                final upcomingEvent = eventProvider.upcomingEvent;

                // Récupération directe depuis EventModel
                final available = upcomingEvent?.availableCount ?? 0;
                final uncertain = upcomingEvent?.uncertainCount ?? 0;
                final unavailable = upcomingEvent?.unavailableCount ?? 0;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (eventProvider.isLoading)
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      )
                    else if (eventProvider.hasError)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                eventProvider.errorMessage,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.red,
                              ),
                              onPressed: () =>
                                  eventProvider.fetchUpcomingEvent(),
                            ),
                          ],
                        ),
                      )
                    else if (!eventProvider.hasEvent)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            "Aucun événement à venir pour le moment.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      EventCardWidget(
                        event: upcomingEvent!,
                        isCoachOrAdmin:
                            true, // Affiche le menu des 3 points pour le coach/admin[cite: 6]
                        onTap: () {
                          // Navigation vers les détails du match
                        },
                        onPresenceChanged: (newStatus) {
                          eventProvider.updatePresence(newStatus);
                        },
                      ),

                    const SizedBox(height: 24),

                    // --- SECTION ÉTAT DE L'EFFECTIF (BOUTONS & COMPTEURS) ---
                    if (eventProvider.hasEvent)
                      EffectifStatusWidget(
                        availableCount: available,
                        uncertainCount: uncertain,
                        unavailableCount: unavailable,
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // --- SECTION DERNIER COMMUNIQUÉ (EN BAS) ---
            AnnouncementOverviewCard(
              onTap: () {
                // Navigation vers la liste complète des communiqués
                Navigator.pushNamed(context, '/announcements');
              },
            ),
          ],
        ),
      ),
    );
  }
}
