// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'car_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GarageSort)
final garageSortProvider = GarageSortProvider._();

final class GarageSortProvider
    extends $NotifierProvider<GarageSort, GarageSortOption> {
  GarageSortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'garageSortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$garageSortHash();

  @$internal
  @override
  GarageSort create() => GarageSort();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GarageSortOption value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GarageSortOption>(value),
    );
  }
}

String _$garageSortHash() => r'c7b3c21533721784c8d25ef1bb84fdb29c1c9046';

abstract class _$GarageSort extends $Notifier<GarageSortOption> {
  GarageSortOption build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<GarageSortOption, GarageSortOption>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<GarageSortOption, GarageSortOption>,
              GarageSortOption,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(sortedCars)
final sortedCarsProvider = SortedCarsProvider._();

final class SortedCarsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CarWithStats>>,
          List<CarWithStats>,
          FutureOr<List<CarWithStats>>
        >
    with
        $FutureModifier<List<CarWithStats>>,
        $FutureProvider<List<CarWithStats>> {
  SortedCarsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sortedCarsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sortedCarsHash();

  @$internal
  @override
  $FutureProviderElement<List<CarWithStats>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CarWithStats>> create(Ref ref) {
    return sortedCars(ref);
  }
}

String _$sortedCarsHash() => r'541dda2ba378613e9a83caffe50eabb8fef932c5';

@ProviderFor(carRepository)
final carRepositoryProvider = CarRepositoryProvider._();

final class CarRepositoryProvider
    extends $FunctionalProvider<CarRepository, CarRepository, CarRepository>
    with $Provider<CarRepository> {
  CarRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carRepositoryHash();

  @$internal
  @override
  $ProviderElement<CarRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CarRepository create(Ref ref) {
    return carRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CarRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CarRepository>(value),
    );
  }
}

String _$carRepositoryHash() => r'6c8979dea6c0056b31a5d8cf888c78b731e726b7';

@ProviderFor(Cars)
final carsProvider = CarsProvider._();

final class CarsProvider extends $AsyncNotifierProvider<Cars, List<Car>> {
  CarsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'carsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$carsHash();

  @$internal
  @override
  Cars create() => Cars();
}

String _$carsHash() => r'1a0bb41e3038adf3ec502e2512f2c0530216ab1d';

abstract class _$Cars extends $AsyncNotifier<List<Car>> {
  FutureOr<List<Car>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Car>>, List<Car>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Car>>, List<Car>>,
              AsyncValue<List<Car>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(carStats)
final carStatsProvider = CarStatsFamily._();

final class CarStatsProvider
    extends
        $FunctionalProvider<AsyncValue<CarStats>, CarStats, FutureOr<CarStats>>
    with $FutureModifier<CarStats>, $FutureProvider<CarStats> {
  CarStatsProvider._({
    required CarStatsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'carStatsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$carStatsHash();

  @override
  String toString() {
    return r'carStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CarStats> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CarStats> create(Ref ref) {
    final argument = this.argument as int;
    return carStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CarStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$carStatsHash() => r'f7be3eff3e57e87fc22fe762f530449d7b49d2ab';

final class CarStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CarStats>, int> {
  CarStatsFamily._()
    : super(
        retry: null,
        name: r'carStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  CarStatsProvider call(int carId) =>
      CarStatsProvider._(argument: carId, from: this);

  @override
  String toString() => r'carStatsProvider';
}
