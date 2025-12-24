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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
