// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$tournamentServiceHash() => r'591b631633772ecd2c8b6f41784028ff7a08ed68';

/// See also [tournamentService].
@ProviderFor(tournamentService)
final tournamentServiceProvider = Provider<TournamentService>.internal(
  tournamentService,
  name: r'tournamentServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$tournamentServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef TournamentServiceRef = ProviderRef<TournamentService>;
String _$tournamentHash() => r'60e73bc64c1facf0941e72905813220cd63a0d01';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [tournament].
@ProviderFor(tournament)
const tournamentProvider = TournamentFamily();

/// See also [tournament].
class TournamentFamily extends Family<AsyncValue<Tournament?>> {
  /// See also [tournament].
  const TournamentFamily();

  /// See also [tournament].
  TournamentProvider call(
    int id,
  ) {
    return TournamentProvider(
      id,
    );
  }

  @override
  TournamentProvider getProviderOverride(
    covariant TournamentProvider provider,
  ) {
    return call(
      provider.id,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tournamentProvider';
}

/// See also [tournament].
class TournamentProvider extends AutoDisposeFutureProvider<Tournament?> {
  /// See also [tournament].
  TournamentProvider(
    int id,
  ) : this._internal(
          (ref) => tournament(
            ref as TournamentRef,
            id,
          ),
          from: tournamentProvider,
          name: r'tournamentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tournamentHash,
          dependencies: TournamentFamily._dependencies,
          allTransitiveDependencies:
              TournamentFamily._allTransitiveDependencies,
          id: id,
        );

  TournamentProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<Tournament?> Function(TournamentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TournamentProvider._internal(
        (ref) => create(ref as TournamentRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Tournament?> createElement() {
    return _TournamentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TournamentRef on AutoDisposeFutureProviderRef<Tournament?> {
  /// The parameter `id` of this provider.
  int get id;
}

class _TournamentProviderElement
    extends AutoDisposeFutureProviderElement<Tournament?> with TournamentRef {
  _TournamentProviderElement(super.provider);

  @override
  int get id => (origin as TournamentProvider).id;
}

String _$tournamentRoundsHash() => r'de60edbb05ceefa56b24d8b042e245832a2a8657';

/// See also [tournamentRounds].
@ProviderFor(tournamentRounds)
const tournamentRoundsProvider = TournamentRoundsFamily();

/// See also [tournamentRounds].
class TournamentRoundsFamily extends Family<AsyncValue<List<Round>>> {
  /// See also [tournamentRounds].
  const TournamentRoundsFamily();

  /// See also [tournamentRounds].
  TournamentRoundsProvider call(
    int tournamentId,
  ) {
    return TournamentRoundsProvider(
      tournamentId,
    );
  }

  @override
  TournamentRoundsProvider getProviderOverride(
    covariant TournamentRoundsProvider provider,
  ) {
    return call(
      provider.tournamentId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tournamentRoundsProvider';
}

/// See also [tournamentRounds].
class TournamentRoundsProvider extends AutoDisposeFutureProvider<List<Round>> {
  /// See also [tournamentRounds].
  TournamentRoundsProvider(
    int tournamentId,
  ) : this._internal(
          (ref) => tournamentRounds(
            ref as TournamentRoundsRef,
            tournamentId,
          ),
          from: tournamentRoundsProvider,
          name: r'tournamentRoundsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tournamentRoundsHash,
          dependencies: TournamentRoundsFamily._dependencies,
          allTransitiveDependencies:
              TournamentRoundsFamily._allTransitiveDependencies,
          tournamentId: tournamentId,
        );

  TournamentRoundsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tournamentId,
  }) : super.internal();

  final int tournamentId;

  @override
  Override overrideWith(
    FutureOr<List<Round>> Function(TournamentRoundsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TournamentRoundsProvider._internal(
        (ref) => create(ref as TournamentRoundsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tournamentId: tournamentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Round>> createElement() {
    return _TournamentRoundsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentRoundsProvider &&
        other.tournamentId == tournamentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tournamentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TournamentRoundsRef on AutoDisposeFutureProviderRef<List<Round>> {
  /// The parameter `tournamentId` of this provider.
  int get tournamentId;
}

class _TournamentRoundsProviderElement
    extends AutoDisposeFutureProviderElement<List<Round>>
    with TournamentRoundsRef {
  _TournamentRoundsProviderElement(super.provider);

  @override
  int get tournamentId => (origin as TournamentRoundsProvider).tournamentId;
}

String _$roundMatchesHash() => r'1930327e70c471d0418cab515a30c58e867a6a9d';

/// See also [roundMatches].
@ProviderFor(roundMatches)
const roundMatchesProvider = RoundMatchesFamily();

/// See also [roundMatches].
class RoundMatchesFamily extends Family<AsyncValue<List<Match>>> {
  /// See also [roundMatches].
  const RoundMatchesFamily();

  /// See also [roundMatches].
  RoundMatchesProvider call(
    int roundId,
  ) {
    return RoundMatchesProvider(
      roundId,
    );
  }

  @override
  RoundMatchesProvider getProviderOverride(
    covariant RoundMatchesProvider provider,
  ) {
    return call(
      provider.roundId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'roundMatchesProvider';
}

/// See also [roundMatches].
class RoundMatchesProvider extends AutoDisposeFutureProvider<List<Match>> {
  /// See also [roundMatches].
  RoundMatchesProvider(
    int roundId,
  ) : this._internal(
          (ref) => roundMatches(
            ref as RoundMatchesRef,
            roundId,
          ),
          from: roundMatchesProvider,
          name: r'roundMatchesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$roundMatchesHash,
          dependencies: RoundMatchesFamily._dependencies,
          allTransitiveDependencies:
              RoundMatchesFamily._allTransitiveDependencies,
          roundId: roundId,
        );

  RoundMatchesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.roundId,
  }) : super.internal();

  final int roundId;

  @override
  Override overrideWith(
    FutureOr<List<Match>> Function(RoundMatchesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoundMatchesProvider._internal(
        (ref) => create(ref as RoundMatchesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        roundId: roundId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Match>> createElement() {
    return _RoundMatchesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoundMatchesProvider && other.roundId == roundId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, roundId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin RoundMatchesRef on AutoDisposeFutureProviderRef<List<Match>> {
  /// The parameter `roundId` of this provider.
  int get roundId;
}

class _RoundMatchesProviderElement
    extends AutoDisposeFutureProviderElement<List<Match>> with RoundMatchesRef {
  _RoundMatchesProviderElement(super.provider);

  @override
  int get roundId => (origin as RoundMatchesProvider).roundId;
}

String _$currentRoundHash() => r'a4420b6dbe939c8820b8c1f6def9b308575c6412';

/// See also [currentRound].
@ProviderFor(currentRound)
const currentRoundProvider = CurrentRoundFamily();

/// See also [currentRound].
class CurrentRoundFamily extends Family<AsyncValue<Round?>> {
  /// See also [currentRound].
  const CurrentRoundFamily();

  /// See also [currentRound].
  CurrentRoundProvider call(
    int tournamentId,
  ) {
    return CurrentRoundProvider(
      tournamentId,
    );
  }

  @override
  CurrentRoundProvider getProviderOverride(
    covariant CurrentRoundProvider provider,
  ) {
    return call(
      provider.tournamentId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'currentRoundProvider';
}

/// See also [currentRound].
class CurrentRoundProvider extends AutoDisposeFutureProvider<Round?> {
  /// See also [currentRound].
  CurrentRoundProvider(
    int tournamentId,
  ) : this._internal(
          (ref) => currentRound(
            ref as CurrentRoundRef,
            tournamentId,
          ),
          from: currentRoundProvider,
          name: r'currentRoundProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$currentRoundHash,
          dependencies: CurrentRoundFamily._dependencies,
          allTransitiveDependencies:
              CurrentRoundFamily._allTransitiveDependencies,
          tournamentId: tournamentId,
        );

  CurrentRoundProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tournamentId,
  }) : super.internal();

  final int tournamentId;

  @override
  Override overrideWith(
    FutureOr<Round?> Function(CurrentRoundRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentRoundProvider._internal(
        (ref) => create(ref as CurrentRoundRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tournamentId: tournamentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Round?> createElement() {
    return _CurrentRoundProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentRoundProvider && other.tournamentId == tournamentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tournamentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CurrentRoundRef on AutoDisposeFutureProviderRef<Round?> {
  /// The parameter `tournamentId` of this provider.
  int get tournamentId;
}

class _CurrentRoundProviderElement
    extends AutoDisposeFutureProviderElement<Round?> with CurrentRoundRef {
  _CurrentRoundProviderElement(super.provider);

  @override
  int get tournamentId => (origin as CurrentRoundProvider).tournamentId;
}

String _$matchDetailsHash() => r'14350a0c5f21f5e35d40a0837e5f591e23b7a8fc';

/// See also [matchDetails].
@ProviderFor(matchDetails)
const matchDetailsProvider = MatchDetailsFamily();

/// See also [matchDetails].
class MatchDetailsFamily extends Family<AsyncValue<Match?>> {
  /// See also [matchDetails].
  const MatchDetailsFamily();

  /// See also [matchDetails].
  MatchDetailsProvider call(
    int matchId,
  ) {
    return MatchDetailsProvider(
      matchId,
    );
  }

  @override
  MatchDetailsProvider getProviderOverride(
    covariant MatchDetailsProvider provider,
  ) {
    return call(
      provider.matchId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'matchDetailsProvider';
}

/// See also [matchDetails].
class MatchDetailsProvider extends AutoDisposeFutureProvider<Match?> {
  /// See also [matchDetails].
  MatchDetailsProvider(
    int matchId,
  ) : this._internal(
          (ref) => matchDetails(
            ref as MatchDetailsRef,
            matchId,
          ),
          from: matchDetailsProvider,
          name: r'matchDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$matchDetailsHash,
          dependencies: MatchDetailsFamily._dependencies,
          allTransitiveDependencies:
              MatchDetailsFamily._allTransitiveDependencies,
          matchId: matchId,
        );

  MatchDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.matchId,
  }) : super.internal();

  final int matchId;

  @override
  Override overrideWith(
    FutureOr<Match?> Function(MatchDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MatchDetailsProvider._internal(
        (ref) => create(ref as MatchDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        matchId: matchId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Match?> createElement() {
    return _MatchDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchDetailsProvider && other.matchId == matchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, matchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin MatchDetailsRef on AutoDisposeFutureProviderRef<Match?> {
  /// The parameter `matchId` of this provider.
  int get matchId;
}

class _MatchDetailsProviderElement
    extends AutoDisposeFutureProviderElement<Match?> with MatchDetailsRef {
  _MatchDetailsProviderElement(super.provider);

  @override
  int get matchId => (origin as MatchDetailsProvider).matchId;
}

String _$tournamentWinnerHash() => r'a28b988ece64f23695c34bcdab30f73456807a9c';

/// See also [tournamentWinner].
@ProviderFor(tournamentWinner)
const tournamentWinnerProvider = TournamentWinnerFamily();

/// See also [tournamentWinner].
class TournamentWinnerFamily extends Family<AsyncValue<Car?>> {
  /// See also [tournamentWinner].
  const TournamentWinnerFamily();

  /// See also [tournamentWinner].
  TournamentWinnerProvider call(
    int tournamentId,
  ) {
    return TournamentWinnerProvider(
      tournamentId,
    );
  }

  @override
  TournamentWinnerProvider getProviderOverride(
    covariant TournamentWinnerProvider provider,
  ) {
    return call(
      provider.tournamentId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tournamentWinnerProvider';
}

/// See also [tournamentWinner].
class TournamentWinnerProvider extends AutoDisposeFutureProvider<Car?> {
  /// See also [tournamentWinner].
  TournamentWinnerProvider(
    int tournamentId,
  ) : this._internal(
          (ref) => tournamentWinner(
            ref as TournamentWinnerRef,
            tournamentId,
          ),
          from: tournamentWinnerProvider,
          name: r'tournamentWinnerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tournamentWinnerHash,
          dependencies: TournamentWinnerFamily._dependencies,
          allTransitiveDependencies:
              TournamentWinnerFamily._allTransitiveDependencies,
          tournamentId: tournamentId,
        );

  TournamentWinnerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tournamentId,
  }) : super.internal();

  final int tournamentId;

  @override
  Override overrideWith(
    FutureOr<Car?> Function(TournamentWinnerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TournamentWinnerProvider._internal(
        (ref) => create(ref as TournamentWinnerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tournamentId: tournamentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Car?> createElement() {
    return _TournamentWinnerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentWinnerProvider &&
        other.tournamentId == tournamentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tournamentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TournamentWinnerRef on AutoDisposeFutureProviderRef<Car?> {
  /// The parameter `tournamentId` of this provider.
  int get tournamentId;
}

class _TournamentWinnerProviderElement
    extends AutoDisposeFutureProviderElement<Car?> with TournamentWinnerRef {
  _TournamentWinnerProviderElement(super.provider);

  @override
  int get tournamentId => (origin as TournamentWinnerProvider).tournamentId;
}

String _$activeTournamentsHash() => r'023c9e180ef7a2fc1b4d996cca134f9e63ecefb8';

/// See also [activeTournaments].
@ProviderFor(activeTournaments)
final activeTournamentsProvider =
    AutoDisposeFutureProvider<List<Tournament>>.internal(
  activeTournaments,
  name: r'activeTournamentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeTournamentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ActiveTournamentsRef = AutoDisposeFutureProviderRef<List<Tournament>>;
String _$completedTournamentsHash() =>
    r'2b97a002b9a9c25f3a20758f1927780524c2306c';

/// See also [completedTournaments].
@ProviderFor(completedTournaments)
final completedTournamentsProvider =
    AutoDisposeFutureProvider<List<Tournament>>.internal(
  completedTournaments,
  name: r'completedTournamentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$completedTournamentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CompletedTournamentsRef
    = AutoDisposeFutureProviderRef<List<Tournament>>;
String _$tournamentParticipantCountHash() =>
    r'3be1e3c15f1e3a88559440683470605f1b555ade';

/// See also [tournamentParticipantCount].
@ProviderFor(tournamentParticipantCount)
const tournamentParticipantCountProvider = TournamentParticipantCountFamily();

/// See also [tournamentParticipantCount].
class TournamentParticipantCountFamily extends Family<AsyncValue<int>> {
  /// See also [tournamentParticipantCount].
  const TournamentParticipantCountFamily();

  /// See also [tournamentParticipantCount].
  TournamentParticipantCountProvider call(
    int tournamentId,
  ) {
    return TournamentParticipantCountProvider(
      tournamentId,
    );
  }

  @override
  TournamentParticipantCountProvider getProviderOverride(
    covariant TournamentParticipantCountProvider provider,
  ) {
    return call(
      provider.tournamentId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tournamentParticipantCountProvider';
}

/// See also [tournamentParticipantCount].
class TournamentParticipantCountProvider
    extends AutoDisposeFutureProvider<int> {
  /// See also [tournamentParticipantCount].
  TournamentParticipantCountProvider(
    int tournamentId,
  ) : this._internal(
          (ref) => tournamentParticipantCount(
            ref as TournamentParticipantCountRef,
            tournamentId,
          ),
          from: tournamentParticipantCountProvider,
          name: r'tournamentParticipantCountProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tournamentParticipantCountHash,
          dependencies: TournamentParticipantCountFamily._dependencies,
          allTransitiveDependencies:
              TournamentParticipantCountFamily._allTransitiveDependencies,
          tournamentId: tournamentId,
        );

  TournamentParticipantCountProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tournamentId,
  }) : super.internal();

  final int tournamentId;

  @override
  Override overrideWith(
    FutureOr<int> Function(TournamentParticipantCountRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TournamentParticipantCountProvider._internal(
        (ref) => create(ref as TournamentParticipantCountRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tournamentId: tournamentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<int> createElement() {
    return _TournamentParticipantCountProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentParticipantCountProvider &&
        other.tournamentId == tournamentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tournamentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TournamentParticipantCountRef on AutoDisposeFutureProviderRef<int> {
  /// The parameter `tournamentId` of this provider.
  int get tournamentId;
}

class _TournamentParticipantCountProviderElement
    extends AutoDisposeFutureProviderElement<int>
    with TournamentParticipantCountRef {
  _TournamentParticipantCountProviderElement(super.provider);

  @override
  int get tournamentId =>
      (origin as TournamentParticipantCountProvider).tournamentId;
}

String _$tournamentStatsHash() => r'0374a0a6fa3fd9d3936d5d326b2eb48ab1d57e01';

/// See also [tournamentStats].
@ProviderFor(tournamentStats)
const tournamentStatsProvider = TournamentStatsFamily();

/// See also [tournamentStats].
class TournamentStatsFamily
    extends Family<AsyncValue<List<TournamentCarStats>>> {
  /// See also [tournamentStats].
  const TournamentStatsFamily();

  /// See also [tournamentStats].
  TournamentStatsProvider call(
    int tournamentId,
  ) {
    return TournamentStatsProvider(
      tournamentId,
    );
  }

  @override
  TournamentStatsProvider getProviderOverride(
    covariant TournamentStatsProvider provider,
  ) {
    return call(
      provider.tournamentId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'tournamentStatsProvider';
}

/// See also [tournamentStats].
class TournamentStatsProvider
    extends AutoDisposeFutureProvider<List<TournamentCarStats>> {
  /// See also [tournamentStats].
  TournamentStatsProvider(
    int tournamentId,
  ) : this._internal(
          (ref) => tournamentStats(
            ref as TournamentStatsRef,
            tournamentId,
          ),
          from: tournamentStatsProvider,
          name: r'tournamentStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$tournamentStatsHash,
          dependencies: TournamentStatsFamily._dependencies,
          allTransitiveDependencies:
              TournamentStatsFamily._allTransitiveDependencies,
          tournamentId: tournamentId,
        );

  TournamentStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tournamentId,
  }) : super.internal();

  final int tournamentId;

  @override
  Override overrideWith(
    FutureOr<List<TournamentCarStats>> Function(TournamentStatsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TournamentStatsProvider._internal(
        (ref) => create(ref as TournamentStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tournamentId: tournamentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<TournamentCarStats>> createElement() {
    return _TournamentStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TournamentStatsProvider &&
        other.tournamentId == tournamentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tournamentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin TournamentStatsRef
    on AutoDisposeFutureProviderRef<List<TournamentCarStats>> {
  /// The parameter `tournamentId` of this provider.
  int get tournamentId;
}

class _TournamentStatsProviderElement
    extends AutoDisposeFutureProviderElement<List<TournamentCarStats>>
    with TournamentStatsRef {
  _TournamentStatsProviderElement(super.provider);

  @override
  int get tournamentId => (origin as TournamentStatsProvider).tournamentId;
}

String _$groupStandingsHash() => r'00067e32f8098e51a888ae08e89a3fa692253fbb';

/// Get standings for a specific group in a groupKnockout tournament
///
/// Copied from [groupStandings].
@ProviderFor(groupStandings)
const groupStandingsProvider = GroupStandingsFamily();

/// Get standings for a specific group in a groupKnockout tournament
///
/// Copied from [groupStandings].
class GroupStandingsFamily extends Family<AsyncValue<List<GroupStanding>>> {
  /// Get standings for a specific group in a groupKnockout tournament
  ///
  /// Copied from [groupStandings].
  const GroupStandingsFamily();

  /// Get standings for a specific group in a groupKnockout tournament
  ///
  /// Copied from [groupStandings].
  GroupStandingsProvider call(
    int tournamentId,
    int groupIndex,
  ) {
    return GroupStandingsProvider(
      tournamentId,
      groupIndex,
    );
  }

  @override
  GroupStandingsProvider getProviderOverride(
    covariant GroupStandingsProvider provider,
  ) {
    return call(
      provider.tournamentId,
      provider.groupIndex,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupStandingsProvider';
}

/// Get standings for a specific group in a groupKnockout tournament
///
/// Copied from [groupStandings].
class GroupStandingsProvider
    extends AutoDisposeFutureProvider<List<GroupStanding>> {
  /// Get standings for a specific group in a groupKnockout tournament
  ///
  /// Copied from [groupStandings].
  GroupStandingsProvider(
    int tournamentId,
    int groupIndex,
  ) : this._internal(
          (ref) => groupStandings(
            ref as GroupStandingsRef,
            tournamentId,
            groupIndex,
          ),
          from: groupStandingsProvider,
          name: r'groupStandingsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupStandingsHash,
          dependencies: GroupStandingsFamily._dependencies,
          allTransitiveDependencies:
              GroupStandingsFamily._allTransitiveDependencies,
          tournamentId: tournamentId,
          groupIndex: groupIndex,
        );

  GroupStandingsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tournamentId,
    required this.groupIndex,
  }) : super.internal();

  final int tournamentId;
  final int groupIndex;

  @override
  Override overrideWith(
    FutureOr<List<GroupStanding>> Function(GroupStandingsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupStandingsProvider._internal(
        (ref) => create(ref as GroupStandingsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tournamentId: tournamentId,
        groupIndex: groupIndex,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<GroupStanding>> createElement() {
    return _GroupStandingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupStandingsProvider &&
        other.tournamentId == tournamentId &&
        other.groupIndex == groupIndex;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tournamentId.hashCode);
    hash = _SystemHash.combine(hash, groupIndex.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupStandingsRef on AutoDisposeFutureProviderRef<List<GroupStanding>> {
  /// The parameter `tournamentId` of this provider.
  int get tournamentId;

  /// The parameter `groupIndex` of this provider.
  int get groupIndex;
}

class _GroupStandingsProviderElement
    extends AutoDisposeFutureProviderElement<List<GroupStanding>>
    with GroupStandingsRef {
  _GroupStandingsProviderElement(super.provider);

  @override
  int get tournamentId => (origin as GroupStandingsProvider).tournamentId;
  @override
  int get groupIndex => (origin as GroupStandingsProvider).groupIndex;
}

String _$groupRoundsHash() => r'0bd469521e0a3cf6b5bb2c96eef8a4c920e00af7';

/// Get all group stage rounds for a groupKnockout tournament
///
/// Copied from [groupRounds].
@ProviderFor(groupRounds)
const groupRoundsProvider = GroupRoundsFamily();

/// Get all group stage rounds for a groupKnockout tournament
///
/// Copied from [groupRounds].
class GroupRoundsFamily extends Family<AsyncValue<List<Round>>> {
  /// Get all group stage rounds for a groupKnockout tournament
  ///
  /// Copied from [groupRounds].
  const GroupRoundsFamily();

  /// Get all group stage rounds for a groupKnockout tournament
  ///
  /// Copied from [groupRounds].
  GroupRoundsProvider call(
    int tournamentId,
  ) {
    return GroupRoundsProvider(
      tournamentId,
    );
  }

  @override
  GroupRoundsProvider getProviderOverride(
    covariant GroupRoundsProvider provider,
  ) {
    return call(
      provider.tournamentId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'groupRoundsProvider';
}

/// Get all group stage rounds for a groupKnockout tournament
///
/// Copied from [groupRounds].
class GroupRoundsProvider extends AutoDisposeFutureProvider<List<Round>> {
  /// Get all group stage rounds for a groupKnockout tournament
  ///
  /// Copied from [groupRounds].
  GroupRoundsProvider(
    int tournamentId,
  ) : this._internal(
          (ref) => groupRounds(
            ref as GroupRoundsRef,
            tournamentId,
          ),
          from: groupRoundsProvider,
          name: r'groupRoundsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$groupRoundsHash,
          dependencies: GroupRoundsFamily._dependencies,
          allTransitiveDependencies:
              GroupRoundsFamily._allTransitiveDependencies,
          tournamentId: tournamentId,
        );

  GroupRoundsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tournamentId,
  }) : super.internal();

  final int tournamentId;

  @override
  Override overrideWith(
    FutureOr<List<Round>> Function(GroupRoundsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GroupRoundsProvider._internal(
        (ref) => create(ref as GroupRoundsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tournamentId: tournamentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Round>> createElement() {
    return _GroupRoundsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupRoundsProvider && other.tournamentId == tournamentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tournamentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin GroupRoundsRef on AutoDisposeFutureProviderRef<List<Round>> {
  /// The parameter `tournamentId` of this provider.
  int get tournamentId;
}

class _GroupRoundsProviderElement
    extends AutoDisposeFutureProviderElement<List<Round>> with GroupRoundsRef {
  _GroupRoundsProviderElement(super.provider);

  @override
  int get tournamentId => (origin as GroupRoundsProvider).tournamentId;
}

String _$knockoutRoundsHash() => r'9832a75bbdb4dbfe50f536cc70c1ce51a219e151';

/// Get all knockout stage rounds for a groupKnockout tournament
///
/// Copied from [knockoutRounds].
@ProviderFor(knockoutRounds)
const knockoutRoundsProvider = KnockoutRoundsFamily();

/// Get all knockout stage rounds for a groupKnockout tournament
///
/// Copied from [knockoutRounds].
class KnockoutRoundsFamily extends Family<AsyncValue<List<Round>>> {
  /// Get all knockout stage rounds for a groupKnockout tournament
  ///
  /// Copied from [knockoutRounds].
  const KnockoutRoundsFamily();

  /// Get all knockout stage rounds for a groupKnockout tournament
  ///
  /// Copied from [knockoutRounds].
  KnockoutRoundsProvider call(
    int tournamentId,
  ) {
    return KnockoutRoundsProvider(
      tournamentId,
    );
  }

  @override
  KnockoutRoundsProvider getProviderOverride(
    covariant KnockoutRoundsProvider provider,
  ) {
    return call(
      provider.tournamentId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'knockoutRoundsProvider';
}

/// Get all knockout stage rounds for a groupKnockout tournament
///
/// Copied from [knockoutRounds].
class KnockoutRoundsProvider extends AutoDisposeFutureProvider<List<Round>> {
  /// Get all knockout stage rounds for a groupKnockout tournament
  ///
  /// Copied from [knockoutRounds].
  KnockoutRoundsProvider(
    int tournamentId,
  ) : this._internal(
          (ref) => knockoutRounds(
            ref as KnockoutRoundsRef,
            tournamentId,
          ),
          from: knockoutRoundsProvider,
          name: r'knockoutRoundsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$knockoutRoundsHash,
          dependencies: KnockoutRoundsFamily._dependencies,
          allTransitiveDependencies:
              KnockoutRoundsFamily._allTransitiveDependencies,
          tournamentId: tournamentId,
        );

  KnockoutRoundsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tournamentId,
  }) : super.internal();

  final int tournamentId;

  @override
  Override overrideWith(
    FutureOr<List<Round>> Function(KnockoutRoundsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: KnockoutRoundsProvider._internal(
        (ref) => create(ref as KnockoutRoundsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tournamentId: tournamentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Round>> createElement() {
    return _KnockoutRoundsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is KnockoutRoundsProvider &&
        other.tournamentId == tournamentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tournamentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin KnockoutRoundsRef on AutoDisposeFutureProviderRef<List<Round>> {
  /// The parameter `tournamentId` of this provider.
  int get tournamentId;
}

class _KnockoutRoundsProviderElement
    extends AutoDisposeFutureProviderElement<List<Round>>
    with KnockoutRoundsRef {
  _KnockoutRoundsProviderElement(super.provider);

  @override
  int get tournamentId => (origin as KnockoutRoundsProvider).tournamentId;
}

String _$isGroupStageCompleteHash() =>
    r'61c4f38a9dd2b1437a4dbcb74c5784d92d12b989';

/// Check if the group stage is complete for a groupKnockout tournament
///
/// Copied from [isGroupStageComplete].
@ProviderFor(isGroupStageComplete)
const isGroupStageCompleteProvider = IsGroupStageCompleteFamily();

/// Check if the group stage is complete for a groupKnockout tournament
///
/// Copied from [isGroupStageComplete].
class IsGroupStageCompleteFamily extends Family<AsyncValue<bool>> {
  /// Check if the group stage is complete for a groupKnockout tournament
  ///
  /// Copied from [isGroupStageComplete].
  const IsGroupStageCompleteFamily();

  /// Check if the group stage is complete for a groupKnockout tournament
  ///
  /// Copied from [isGroupStageComplete].
  IsGroupStageCompleteProvider call(
    int tournamentId,
  ) {
    return IsGroupStageCompleteProvider(
      tournamentId,
    );
  }

  @override
  IsGroupStageCompleteProvider getProviderOverride(
    covariant IsGroupStageCompleteProvider provider,
  ) {
    return call(
      provider.tournamentId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'isGroupStageCompleteProvider';
}

/// Check if the group stage is complete for a groupKnockout tournament
///
/// Copied from [isGroupStageComplete].
class IsGroupStageCompleteProvider extends AutoDisposeFutureProvider<bool> {
  /// Check if the group stage is complete for a groupKnockout tournament
  ///
  /// Copied from [isGroupStageComplete].
  IsGroupStageCompleteProvider(
    int tournamentId,
  ) : this._internal(
          (ref) => isGroupStageComplete(
            ref as IsGroupStageCompleteRef,
            tournamentId,
          ),
          from: isGroupStageCompleteProvider,
          name: r'isGroupStageCompleteProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$isGroupStageCompleteHash,
          dependencies: IsGroupStageCompleteFamily._dependencies,
          allTransitiveDependencies:
              IsGroupStageCompleteFamily._allTransitiveDependencies,
          tournamentId: tournamentId,
        );

  IsGroupStageCompleteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tournamentId,
  }) : super.internal();

  final int tournamentId;

  @override
  Override overrideWith(
    FutureOr<bool> Function(IsGroupStageCompleteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: IsGroupStageCompleteProvider._internal(
        (ref) => create(ref as IsGroupStageCompleteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tournamentId: tournamentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<bool> createElement() {
    return _IsGroupStageCompleteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is IsGroupStageCompleteProvider &&
        other.tournamentId == tournamentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tournamentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin IsGroupStageCompleteRef on AutoDisposeFutureProviderRef<bool> {
  /// The parameter `tournamentId` of this provider.
  int get tournamentId;
}

class _IsGroupStageCompleteProviderElement
    extends AutoDisposeFutureProviderElement<bool>
    with IsGroupStageCompleteRef {
  _IsGroupStageCompleteProviderElement(super.provider);

  @override
  int get tournamentId => (origin as IsGroupStageCompleteProvider).tournamentId;
}

String _$allGroupStandingsHash() => r'5a4e60a0fa99fc087150e4652412658cae73e074';

/// Get all standings for all groups in a groupKnockout tournament
///
/// Copied from [allGroupStandings].
@ProviderFor(allGroupStandings)
const allGroupStandingsProvider = AllGroupStandingsFamily();

/// Get all standings for all groups in a groupKnockout tournament
///
/// Copied from [allGroupStandings].
class AllGroupStandingsFamily
    extends Family<AsyncValue<Map<int, List<GroupStanding>>>> {
  /// Get all standings for all groups in a groupKnockout tournament
  ///
  /// Copied from [allGroupStandings].
  const AllGroupStandingsFamily();

  /// Get all standings for all groups in a groupKnockout tournament
  ///
  /// Copied from [allGroupStandings].
  AllGroupStandingsProvider call(
    int tournamentId,
  ) {
    return AllGroupStandingsProvider(
      tournamentId,
    );
  }

  @override
  AllGroupStandingsProvider getProviderOverride(
    covariant AllGroupStandingsProvider provider,
  ) {
    return call(
      provider.tournamentId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allGroupStandingsProvider';
}

/// Get all standings for all groups in a groupKnockout tournament
///
/// Copied from [allGroupStandings].
class AllGroupStandingsProvider
    extends AutoDisposeFutureProvider<Map<int, List<GroupStanding>>> {
  /// Get all standings for all groups in a groupKnockout tournament
  ///
  /// Copied from [allGroupStandings].
  AllGroupStandingsProvider(
    int tournamentId,
  ) : this._internal(
          (ref) => allGroupStandings(
            ref as AllGroupStandingsRef,
            tournamentId,
          ),
          from: allGroupStandingsProvider,
          name: r'allGroupStandingsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$allGroupStandingsHash,
          dependencies: AllGroupStandingsFamily._dependencies,
          allTransitiveDependencies:
              AllGroupStandingsFamily._allTransitiveDependencies,
          tournamentId: tournamentId,
        );

  AllGroupStandingsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tournamentId,
  }) : super.internal();

  final int tournamentId;

  @override
  Override overrideWith(
    FutureOr<Map<int, List<GroupStanding>>> Function(
            AllGroupStandingsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllGroupStandingsProvider._internal(
        (ref) => create(ref as AllGroupStandingsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tournamentId: tournamentId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<int, List<GroupStanding>>>
      createElement() {
    return _AllGroupStandingsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllGroupStandingsProvider &&
        other.tournamentId == tournamentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tournamentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AllGroupStandingsRef
    on AutoDisposeFutureProviderRef<Map<int, List<GroupStanding>>> {
  /// The parameter `tournamentId` of this provider.
  int get tournamentId;
}

class _AllGroupStandingsProviderElement
    extends AutoDisposeFutureProviderElement<Map<int, List<GroupStanding>>>
    with AllGroupStandingsRef {
  _AllGroupStandingsProviderElement(super.provider);

  @override
  int get tournamentId => (origin as AllGroupStandingsProvider).tournamentId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
