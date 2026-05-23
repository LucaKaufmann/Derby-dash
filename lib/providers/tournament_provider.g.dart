// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(tournamentService)
final tournamentServiceProvider = TournamentServiceProvider._();

final class TournamentServiceProvider
    extends
        $FunctionalProvider<
          TournamentService,
          TournamentService,
          TournamentService
        >
    with $Provider<TournamentService> {
  TournamentServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tournamentServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tournamentServiceHash();

  @$internal
  @override
  $ProviderElement<TournamentService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TournamentService create(Ref ref) {
    return tournamentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TournamentService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TournamentService>(value),
    );
  }
}

String _$tournamentServiceHash() => r'd8ceb0ba55d93a879d85262da8e373bd63d667dc';

@ProviderFor(tournament)
final tournamentProvider = TournamentFamily._();

final class TournamentProvider
    extends
        $FunctionalProvider<
          AsyncValue<Tournament?>,
          Tournament?,
          FutureOr<Tournament?>
        >
    with $FutureModifier<Tournament?>, $FutureProvider<Tournament?> {
  TournamentProvider._({
    required TournamentFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'tournamentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tournamentHash();

  @override
  String toString() {
    return r'tournamentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Tournament?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Tournament?> create(Ref ref) {
    final argument = this.argument as int;
    return tournament(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tournamentHash() => r'fb51d12fcc9f4793bff79f43fb2043c98abb69af';

final class TournamentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Tournament?>, int> {
  TournamentFamily._()
    : super(
        retry: null,
        name: r'tournamentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TournamentProvider call(int id) =>
      TournamentProvider._(argument: id, from: this);

  @override
  String toString() => r'tournamentProvider';
}

@ProviderFor(tournamentRounds)
final tournamentRoundsProvider = TournamentRoundsFamily._();

final class TournamentRoundsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Round>>,
          List<Round>,
          FutureOr<List<Round>>
        >
    with $FutureModifier<List<Round>>, $FutureProvider<List<Round>> {
  TournamentRoundsProvider._({
    required TournamentRoundsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'tournamentRoundsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tournamentRoundsHash();

  @override
  String toString() {
    return r'tournamentRoundsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Round>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Round>> create(Ref ref) {
    final argument = this.argument as int;
    return tournamentRounds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentRoundsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tournamentRoundsHash() => r'758cc9db4b6253c9f8c1ea8da3dd8f95ca9642cc';

final class TournamentRoundsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Round>>, int> {
  TournamentRoundsFamily._()
    : super(
        retry: null,
        name: r'tournamentRoundsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TournamentRoundsProvider call(int tournamentId) =>
      TournamentRoundsProvider._(argument: tournamentId, from: this);

  @override
  String toString() => r'tournamentRoundsProvider';
}

@ProviderFor(roundMatches)
final roundMatchesProvider = RoundMatchesFamily._();

final class RoundMatchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Match>>,
          List<Match>,
          FutureOr<List<Match>>
        >
    with $FutureModifier<List<Match>>, $FutureProvider<List<Match>> {
  RoundMatchesProvider._({
    required RoundMatchesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'roundMatchesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$roundMatchesHash();

  @override
  String toString() {
    return r'roundMatchesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Match>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Match>> create(Ref ref) {
    final argument = this.argument as int;
    return roundMatches(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RoundMatchesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$roundMatchesHash() => r'5943f6527cdc9bb817c1fdec236ab9d5c163a13a';

final class RoundMatchesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Match>>, int> {
  RoundMatchesFamily._()
    : super(
        retry: null,
        name: r'roundMatchesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RoundMatchesProvider call(int roundId) =>
      RoundMatchesProvider._(argument: roundId, from: this);

  @override
  String toString() => r'roundMatchesProvider';
}

@ProviderFor(currentRound)
final currentRoundProvider = CurrentRoundFamily._();

final class CurrentRoundProvider
    extends $FunctionalProvider<AsyncValue<Round?>, Round?, FutureOr<Round?>>
    with $FutureModifier<Round?>, $FutureProvider<Round?> {
  CurrentRoundProvider._({
    required CurrentRoundFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'currentRoundProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$currentRoundHash();

  @override
  String toString() {
    return r'currentRoundProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Round?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Round?> create(Ref ref) {
    final argument = this.argument as int;
    return currentRound(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentRoundProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$currentRoundHash() => r'f93e2c4cf51e363e39ac8ecb7d393406effc97b8';

final class CurrentRoundFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Round?>, int> {
  CurrentRoundFamily._()
    : super(
        retry: null,
        name: r'currentRoundProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  CurrentRoundProvider call(int tournamentId) =>
      CurrentRoundProvider._(argument: tournamentId, from: this);

  @override
  String toString() => r'currentRoundProvider';
}

@ProviderFor(matchDetails)
final matchDetailsProvider = MatchDetailsFamily._();

final class MatchDetailsProvider
    extends $FunctionalProvider<AsyncValue<Match?>, Match?, FutureOr<Match?>>
    with $FutureModifier<Match?>, $FutureProvider<Match?> {
  MatchDetailsProvider._({
    required MatchDetailsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'matchDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$matchDetailsHash();

  @override
  String toString() {
    return r'matchDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Match?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Match?> create(Ref ref) {
    final argument = this.argument as int;
    return matchDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$matchDetailsHash() => r'b0ae961b24946af1e2aed0dba84d254b25acd980';

final class MatchDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Match?>, int> {
  MatchDetailsFamily._()
    : super(
        retry: null,
        name: r'matchDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MatchDetailsProvider call(int matchId) =>
      MatchDetailsProvider._(argument: matchId, from: this);

  @override
  String toString() => r'matchDetailsProvider';
}

@ProviderFor(tournamentWinner)
final tournamentWinnerProvider = TournamentWinnerFamily._();

final class TournamentWinnerProvider
    extends $FunctionalProvider<AsyncValue<Car?>, Car?, FutureOr<Car?>>
    with $FutureModifier<Car?>, $FutureProvider<Car?> {
  TournamentWinnerProvider._({
    required TournamentWinnerFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'tournamentWinnerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tournamentWinnerHash();

  @override
  String toString() {
    return r'tournamentWinnerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Car?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Car?> create(Ref ref) {
    final argument = this.argument as int;
    return tournamentWinner(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentWinnerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tournamentWinnerHash() => r'9443e2a7595eafa8715f468709f71afbaf62ea73';

final class TournamentWinnerFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Car?>, int> {
  TournamentWinnerFamily._()
    : super(
        retry: null,
        name: r'tournamentWinnerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TournamentWinnerProvider call(int tournamentId) =>
      TournamentWinnerProvider._(argument: tournamentId, from: this);

  @override
  String toString() => r'tournamentWinnerProvider';
}

@ProviderFor(activeTournaments)
final activeTournamentsProvider = ActiveTournamentsProvider._();

final class ActiveTournamentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tournament>>,
          List<Tournament>,
          FutureOr<List<Tournament>>
        >
    with $FutureModifier<List<Tournament>>, $FutureProvider<List<Tournament>> {
  ActiveTournamentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeTournamentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeTournamentsHash();

  @$internal
  @override
  $FutureProviderElement<List<Tournament>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Tournament>> create(Ref ref) {
    return activeTournaments(ref);
  }
}

String _$activeTournamentsHash() => r'b2de165e903a2685636069075b5cd5cdec6d9950';

@ProviderFor(completedTournaments)
final completedTournamentsProvider = CompletedTournamentsProvider._();

final class CompletedTournamentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Tournament>>,
          List<Tournament>,
          FutureOr<List<Tournament>>
        >
    with $FutureModifier<List<Tournament>>, $FutureProvider<List<Tournament>> {
  CompletedTournamentsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completedTournamentsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completedTournamentsHash();

  @$internal
  @override
  $FutureProviderElement<List<Tournament>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Tournament>> create(Ref ref) {
    return completedTournaments(ref);
  }
}

String _$completedTournamentsHash() =>
    r'00d88bdbce93cc1f66e5252034292f909eb369bf';

@ProviderFor(tournamentParticipantCount)
final tournamentParticipantCountProvider = TournamentParticipantCountFamily._();

final class TournamentParticipantCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  TournamentParticipantCountProvider._({
    required TournamentParticipantCountFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'tournamentParticipantCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tournamentParticipantCountHash();

  @override
  String toString() {
    return r'tournamentParticipantCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as int;
    return tournamentParticipantCount(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentParticipantCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tournamentParticipantCountHash() =>
    r'768ed11bd38b880132b088594659b8c949472e59';

final class TournamentParticipantCountFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, int> {
  TournamentParticipantCountFamily._()
    : super(
        retry: null,
        name: r'tournamentParticipantCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TournamentParticipantCountProvider call(int tournamentId) =>
      TournamentParticipantCountProvider._(argument: tournamentId, from: this);

  @override
  String toString() => r'tournamentParticipantCountProvider';
}

@ProviderFor(tournamentStats)
final tournamentStatsProvider = TournamentStatsFamily._();

final class TournamentStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TournamentCarStats>>,
          List<TournamentCarStats>,
          FutureOr<List<TournamentCarStats>>
        >
    with
        $FutureModifier<List<TournamentCarStats>>,
        $FutureProvider<List<TournamentCarStats>> {
  TournamentStatsProvider._({
    required TournamentStatsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'tournamentStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tournamentStatsHash();

  @override
  String toString() {
    return r'tournamentStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<TournamentCarStats>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<TournamentCarStats>> create(Ref ref) {
    final argument = this.argument as int;
    return tournamentStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tournamentStatsHash() => r'1d16898a135ae2c22abcaea687af140b7a209cb3';

final class TournamentStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<TournamentCarStats>>, int> {
  TournamentStatsFamily._()
    : super(
        retry: null,
        name: r'tournamentStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TournamentStatsProvider call(int tournamentId) =>
      TournamentStatsProvider._(argument: tournamentId, from: this);

  @override
  String toString() => r'tournamentStatsProvider';
}

/// Get standings for a specific group in a groupKnockout tournament

@ProviderFor(groupStandings)
final groupStandingsProvider = GroupStandingsFamily._();

/// Get standings for a specific group in a groupKnockout tournament

final class GroupStandingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GroupStanding>>,
          List<GroupStanding>,
          FutureOr<List<GroupStanding>>
        >
    with
        $FutureModifier<List<GroupStanding>>,
        $FutureProvider<List<GroupStanding>> {
  /// Get standings for a specific group in a groupKnockout tournament
  GroupStandingsProvider._({
    required GroupStandingsFamily super.from,
    required (int, int) super.argument,
  }) : super(
         retry: null,
         name: r'groupStandingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupStandingsHash();

  @override
  String toString() {
    return r'groupStandingsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<GroupStanding>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GroupStanding>> create(Ref ref) {
    final argument = this.argument as (int, int);
    return groupStandings(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupStandingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupStandingsHash() => r'c4abcff7783587f3f224b1790676a3bfbfe1db22';

/// Get standings for a specific group in a groupKnockout tournament

final class GroupStandingsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<GroupStanding>>, (int, int)> {
  GroupStandingsFamily._()
    : super(
        retry: null,
        name: r'groupStandingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Get standings for a specific group in a groupKnockout tournament

  GroupStandingsProvider call(int tournamentId, int groupIndex) =>
      GroupStandingsProvider._(
        argument: (tournamentId, groupIndex),
        from: this,
      );

  @override
  String toString() => r'groupStandingsProvider';
}

/// Get all group stage rounds for a groupKnockout tournament

@ProviderFor(groupRounds)
final groupRoundsProvider = GroupRoundsFamily._();

/// Get all group stage rounds for a groupKnockout tournament

final class GroupRoundsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Round>>,
          List<Round>,
          FutureOr<List<Round>>
        >
    with $FutureModifier<List<Round>>, $FutureProvider<List<Round>> {
  /// Get all group stage rounds for a groupKnockout tournament
  GroupRoundsProvider._({
    required GroupRoundsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'groupRoundsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupRoundsHash();

  @override
  String toString() {
    return r'groupRoundsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Round>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Round>> create(Ref ref) {
    final argument = this.argument as int;
    return groupRounds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupRoundsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupRoundsHash() => r'96d25a43a4574af030b4deebe1b08ad905d65570';

/// Get all group stage rounds for a groupKnockout tournament

final class GroupRoundsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Round>>, int> {
  GroupRoundsFamily._()
    : super(
        retry: null,
        name: r'groupRoundsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Get all group stage rounds for a groupKnockout tournament

  GroupRoundsProvider call(int tournamentId) =>
      GroupRoundsProvider._(argument: tournamentId, from: this);

  @override
  String toString() => r'groupRoundsProvider';
}

/// Get all knockout stage rounds for a groupKnockout tournament

@ProviderFor(knockoutRounds)
final knockoutRoundsProvider = KnockoutRoundsFamily._();

/// Get all knockout stage rounds for a groupKnockout tournament

final class KnockoutRoundsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Round>>,
          List<Round>,
          FutureOr<List<Round>>
        >
    with $FutureModifier<List<Round>>, $FutureProvider<List<Round>> {
  /// Get all knockout stage rounds for a groupKnockout tournament
  KnockoutRoundsProvider._({
    required KnockoutRoundsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'knockoutRoundsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$knockoutRoundsHash();

  @override
  String toString() {
    return r'knockoutRoundsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Round>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Round>> create(Ref ref) {
    final argument = this.argument as int;
    return knockoutRounds(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is KnockoutRoundsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$knockoutRoundsHash() => r'b671ca09c0f6ad5182749be5ba8bae369d7c6eb8';

/// Get all knockout stage rounds for a groupKnockout tournament

final class KnockoutRoundsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Round>>, int> {
  KnockoutRoundsFamily._()
    : super(
        retry: null,
        name: r'knockoutRoundsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Get all knockout stage rounds for a groupKnockout tournament

  KnockoutRoundsProvider call(int tournamentId) =>
      KnockoutRoundsProvider._(argument: tournamentId, from: this);

  @override
  String toString() => r'knockoutRoundsProvider';
}

/// Check if the group stage is complete for a groupKnockout tournament

@ProviderFor(isGroupStageComplete)
final isGroupStageCompleteProvider = IsGroupStageCompleteFamily._();

/// Check if the group stage is complete for a groupKnockout tournament

final class IsGroupStageCompleteProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Check if the group stage is complete for a groupKnockout tournament
  IsGroupStageCompleteProvider._({
    required IsGroupStageCompleteFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'isGroupStageCompleteProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isGroupStageCompleteHash();

  @override
  String toString() {
    return r'isGroupStageCompleteProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as int;
    return isGroupStageComplete(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsGroupStageCompleteProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isGroupStageCompleteHash() =>
    r'c7c3718ef13f3dcaa00b712bc9e9967ff6909fa3';

/// Check if the group stage is complete for a groupKnockout tournament

final class IsGroupStageCompleteFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, int> {
  IsGroupStageCompleteFamily._()
    : super(
        retry: null,
        name: r'isGroupStageCompleteProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Check if the group stage is complete for a groupKnockout tournament

  IsGroupStageCompleteProvider call(int tournamentId) =>
      IsGroupStageCompleteProvider._(argument: tournamentId, from: this);

  @override
  String toString() => r'isGroupStageCompleteProvider';
}

/// Get all standings for all groups in a groupKnockout tournament

@ProviderFor(allGroupStandings)
final allGroupStandingsProvider = AllGroupStandingsFamily._();

/// Get all standings for all groups in a groupKnockout tournament

final class AllGroupStandingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, List<GroupStanding>>>,
          Map<int, List<GroupStanding>>,
          FutureOr<Map<int, List<GroupStanding>>>
        >
    with
        $FutureModifier<Map<int, List<GroupStanding>>>,
        $FutureProvider<Map<int, List<GroupStanding>>> {
  /// Get all standings for all groups in a groupKnockout tournament
  AllGroupStandingsProvider._({
    required AllGroupStandingsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'allGroupStandingsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$allGroupStandingsHash();

  @override
  String toString() {
    return r'allGroupStandingsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<int, List<GroupStanding>>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<int, List<GroupStanding>>> create(Ref ref) {
    final argument = this.argument as int;
    return allGroupStandings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AllGroupStandingsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$allGroupStandingsHash() => r'3bf8762baff8200935c2f52e8d56bf1ad3a15b36';

/// Get all standings for all groups in a groupKnockout tournament

final class AllGroupStandingsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<int, List<GroupStanding>>>,
          int
        > {
  AllGroupStandingsFamily._()
    : super(
        retry: null,
        name: r'allGroupStandingsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Get all standings for all groups in a groupKnockout tournament

  AllGroupStandingsProvider call(int tournamentId) =>
      AllGroupStandingsProvider._(argument: tournamentId, from: this);

  @override
  String toString() => r'allGroupStandingsProvider';
}
