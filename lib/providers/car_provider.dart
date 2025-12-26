import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/car.dart';
import '../data/repositories/car_repository.dart';
import 'database_provider.dart';

part 'car_provider.g.dart';

enum GarageSortOption {
  wins,
  losses,
  winRate,
  tournamentWins,
  name,
  newest,
  oldest,
}

@Riverpod(keepAlive: true)
class GarageSort extends _$GarageSort {
  @override
  GarageSortOption build() => GarageSortOption.wins;

  void setSort(GarageSortOption option) {
    state = option;
  }
}

class CarWithStats {
  final Car car;
  final CarStats stats;

  CarWithStats({required this.car, required this.stats});
}

@riverpod
Future<List<CarWithStats>> sortedCars(SortedCarsRef ref) async {
  final cars = await ref.watch(carsProvider.future);
  final sortOption = ref.watch(garageSortProvider);
  final repository = ref.watch(carRepositoryProvider);

  // Fetch stats for all cars
  final carsWithStats = await Future.wait(
    cars.map((car) async {
      final wins = await repository.getWinCount(car.id);
      final losses = await repository.getLossCount(car.id);
      final matches = await repository.getMatchCount(car.id);
      final tournamentWins = await repository.getTournamentWinCount(car.id);
      return CarWithStats(
        car: car,
        stats: CarStats(
          wins: wins,
          losses: losses,
          totalMatches: matches,
          tournamentWins: tournamentWins,
        ),
      );
    }),
  );

  // Sort based on selected option
  switch (sortOption) {
    case GarageSortOption.wins:
      carsWithStats.sort((a, b) => b.stats.wins.compareTo(a.stats.wins));
    case GarageSortOption.losses:
      carsWithStats.sort((a, b) => b.stats.losses.compareTo(a.stats.losses));
    case GarageSortOption.winRate:
      carsWithStats.sort((a, b) => b.stats.winRate.compareTo(a.stats.winRate));
    case GarageSortOption.tournamentWins:
      carsWithStats.sort(
          (a, b) => b.stats.tournamentWins.compareTo(a.stats.tournamentWins));
    case GarageSortOption.name:
      carsWithStats.sort(
          (a, b) => a.car.name.toLowerCase().compareTo(b.car.name.toLowerCase()));
    case GarageSortOption.newest:
      carsWithStats.sort((a, b) => b.car.createdAt.compareTo(a.car.createdAt));
    case GarageSortOption.oldest:
      carsWithStats.sort((a, b) => a.car.createdAt.compareTo(b.car.createdAt));
  }

  return carsWithStats;
}

@Riverpod(keepAlive: true)
CarRepository carRepository(CarRepositoryRef ref) {
  final isar = ref.watch(databaseProvider).requireValue;
  return CarRepository(isar);
}

@riverpod
class Cars extends _$Cars {
  @override
  Future<List<Car>> build() async {
    final repository = ref.watch(carRepositoryProvider);
    return await repository.getAllCars();
  }

  Future<void> addCar({
    required String name,
    String? tempPhotoPath,
  }) async {
    final repository = ref.read(carRepositoryProvider);

    // Copy photo to permanent storage if provided
    String permanentPath = '';
    if (tempPhotoPath != null) {
      permanentPath = await _savePhoto(tempPhotoPath);
    }

    final car = Car()
      ..uuid = const Uuid().v4()
      ..name = name
      ..photoPath = permanentPath;

    await repository.addCar(car);
    ref.invalidateSelf();
  }

  Future<void> deleteCar(int id) async {
    final repository = ref.read(carRepositoryProvider);
    await repository.deleteCar(id);
    ref.invalidateSelf();
  }

  Future<void> updateCar(Car car) async {
    final repository = ref.read(carRepositoryProvider);
    await repository.updateCar(car);
    ref.invalidateSelf();
  }

  Future<void> updateCarDetails({
    required int carId,
    String? name,
    String? tempPhotoPath,
  }) async {
    final repository = ref.read(carRepositoryProvider);
    final car = await repository.getCarById(carId);
    if (car == null) return;

    if (name != null) {
      car.name = name;
    }

    if (tempPhotoPath != null) {
      final permanentPath = await _savePhoto(tempPhotoPath);
      car.photoPath = permanentPath;
    }

    await repository.updateCar(car);
    ref.invalidateSelf();
  }

  Future<String> _savePhoto(String tempPath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final carPhotosDir = Directory('${appDir.path}/car_photos');
    if (!await carPhotosDir.exists()) {
      await carPhotosDir.create(recursive: true);
    }

    final fileName = '${const Uuid().v4()}.jpg';
    final permanentPath = '${carPhotosDir.path}/$fileName';

    final tempFile = File(tempPath);
    await tempFile.copy(permanentPath);

    return permanentPath;
  }
}

@Riverpod(keepAlive: true)
Future<CarStats> carStats(CarStatsRef ref, int carId) async {
  final repository = ref.watch(carRepositoryProvider);
  final wins = await repository.getWinCount(carId);
  final losses = await repository.getLossCount(carId);
  final matches = await repository.getMatchCount(carId);
  final tournamentWins = await repository.getTournamentWinCount(carId);

  return CarStats(
    wins: wins,
    losses: losses,
    totalMatches: matches,
    tournamentWins: tournamentWins,
  );
}

class CarStats {
  final int wins;
  final int losses;
  final int totalMatches;
  final int tournamentWins;

  CarStats({
    required this.wins,
    required this.losses,
    required this.totalMatches,
    this.tournamentWins = 0,
  });

  double get winRate => totalMatches > 0 ? wins / totalMatches : 0.0;
}
