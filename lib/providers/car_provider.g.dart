// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$carRepositoryHash() => r'1316fc29febc14503547fd526391805203d4d462';

/// See also [carRepository].
@ProviderFor(carRepository)
final carRepositoryProvider = Provider<CarRepository>.internal(
  carRepository,
  name: r'carRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$carRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CarRepositoryRef = ProviderRef<CarRepository>;
String _$carStatsHash() => r'403f4bd10ca2c8bad6b029b8e6ac9368a0f3d2f6';

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

/// See also [carStats].
@ProviderFor(carStats)
const carStatsProvider = CarStatsFamily();

/// See also [carStats].
class CarStatsFamily extends Family<AsyncValue<CarStats>> {
  /// See also [carStats].
  const CarStatsFamily();

  /// See also [carStats].
  CarStatsProvider call(
    int carId,
  ) {
    return CarStatsProvider(
      carId,
    );
  }

  @override
  CarStatsProvider getProviderOverride(
    covariant CarStatsProvider provider,
  ) {
    return call(
      provider.carId,
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
  String? get name => r'carStatsProvider';
}

/// See also [carStats].
class CarStatsProvider extends FutureProvider<CarStats> {
  /// See also [carStats].
  CarStatsProvider(
    int carId,
  ) : this._internal(
          (ref) => carStats(
            ref as CarStatsRef,
            carId,
          ),
          from: carStatsProvider,
          name: r'carStatsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$carStatsHash,
          dependencies: CarStatsFamily._dependencies,
          allTransitiveDependencies: CarStatsFamily._allTransitiveDependencies,
          carId: carId,
        );

  CarStatsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.carId,
  }) : super.internal();

  final int carId;

  @override
  Override overrideWith(
    FutureOr<CarStats> Function(CarStatsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CarStatsProvider._internal(
        (ref) => create(ref as CarStatsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        carId: carId,
      ),
    );
  }

  @override
  FutureProviderElement<CarStats> createElement() {
    return _CarStatsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CarStatsProvider && other.carId == carId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, carId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CarStatsRef on FutureProviderRef<CarStats> {
  /// The parameter `carId` of this provider.
  int get carId;
}

class _CarStatsProviderElement extends FutureProviderElement<CarStats>
    with CarStatsRef {
  _CarStatsProviderElement(super.provider);

  @override
  int get carId => (origin as CarStatsProvider).carId;
}

String _$carsHash() => r'86ee550ad600bc5675e153f834501df12d1d1adc';

/// See also [Cars].
@ProviderFor(Cars)
final carsProvider = AutoDisposeAsyncNotifierProvider<Cars, List<Car>>.internal(
  Cars.new,
  name: r'carsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$carsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Cars = AutoDisposeAsyncNotifier<List<Car>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
