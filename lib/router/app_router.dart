import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/garage/garage_screen.dart';
import '../screens/garage/add_car_screen.dart';
import '../screens/tournament/tournament_setup_screen.dart';
import '../screens/tournament/tournament_dashboard_screen.dart';
import '../screens/tournament/tournament_history_screen.dart';
import '../screens/tournament/champion_screen.dart';
import '../screens/tournament/standings_screen.dart';
import '../screens/match/match_screen.dart';
import '../screens/home_screen.dart';
import '../screens/tournament/bracket_screen.dart';
import '../screens/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/garage',
      name: 'garage',
      builder: (context, state) => const GarageScreen(),
      routes: [
        GoRoute(
          path: 'add',
          name: 'addCar',
          builder: (context, state) => const AddCarScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/tournament/setup',
      name: 'tournamentSetup',
      builder: (context, state) => const TournamentSetupScreen(),
    ),
    GoRoute(
      path: '/tournament/history',
      name: 'tournamentHistory',
      builder: (context, state) => const TournamentHistoryScreen(),
    ),
    GoRoute(
      path: '/tournament/:id',
      name: 'tournamentDashboard',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TournamentDashboardScreen(tournamentId: id);
      },
      routes: [
        GoRoute(
          path: 'match/:matchId',
          name: 'match',
          builder: (context, state) {
            final tournamentId = int.parse(state.pathParameters['id']!);
            final matchId = int.parse(state.pathParameters['matchId']!);
            return MatchScreen(
              tournamentId: tournamentId,
              matchId: matchId,
            );
          },
        ),
        GoRoute(
          path: 'bracket',
          name: 'bracket',
          builder: (context, state) {
            final tournamentId = int.parse(state.pathParameters['id']!);
            return BracketScreen(tournamentId: tournamentId);
          },
        ),
        GoRoute(
          path: 'champion',
          name: 'champion',
          builder: (context, state) {
            final tournamentId = int.parse(state.pathParameters['id']!);
            return ChampionScreen(tournamentId: tournamentId);
          },
        ),
        GoRoute(
          path: 'standings',
          name: 'standings',
          builder: (context, state) {
            final tournamentId = int.parse(state.pathParameters['id']!);
            return StandingsScreen(tournamentId: tournamentId);
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text(
        'Page not found',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    ),
  ),
);
