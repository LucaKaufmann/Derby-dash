import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/tournament_provider.dart';
import '../../theme/app_theme.dart';

class ByeScreen extends ConsumerWidget {
  final int tournamentId;
  final int matchId;

  const ByeScreen({
    super.key,
    required this.tournamentId,
    required this.matchId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchAsync = ref.watch(matchDetailsProvider(matchId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: matchAsync.when(
        data: (match) {
          if (match == null) {
            return const Center(child: Text('Match not found'));
          }

          final car = match.carA.value;

          if (car == null) {
            return const Center(child: Text('Car not found'));
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Trophy icon
                  const Icon(
                    Icons.celebration,
                    size: 80,
                    color: AppTheme.winnerColor,
                  ),
                  const SizedBox(height: 24),

                  // Free pass message
                  Text(
                    'FREE PASS!',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppTheme.winnerColor,
                          letterSpacing: 4,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),

                  // Car photo
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.winnerColor,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.winnerColor.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: car.photoPath.isNotEmpty &&
                            File(car.photoPath).existsSync()
                        ? Image.file(
                            File(car.photoPath),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: AppTheme.surfaceColor,
                            child: const Icon(
                              Icons.directions_car,
                              size: 80,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Car name
                  Text(
                    car.name,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppTheme.winnerColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'advances to the next round!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 64),

                  // Next button - kid must tap to continue
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate back to tournament dashboard
                        context.go('/tournament/$tournamentId');
                      },
                      icon: const Icon(Icons.arrow_forward, size: 32),
                      label: const Text('NEXT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successColor,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
