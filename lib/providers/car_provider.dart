import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../data/models/car.dart';
import '../data/repositories/car_repository.dart';
import 'database_provider.dart';

part 'car_provider.g.dart';

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
    required String tempPhotoPath,
  }) async {
    final repository = ref.read(carRepositoryProvider);

    // Copy photo to permanent storage
    final permanentPath = await _savePhoto(tempPhotoPath);

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

@riverpod
Future<CarStats> carStats(CarStatsRef ref, int carId) async {
  final repository = ref.watch(carRepositoryProvider);
  final wins = await repository.getWinCount(carId);
  final losses = await repository.getLossCount(carId);
  final matches = await repository.getMatchCount(carId);

  return CarStats(wins: wins, losses: losses, totalMatches: matches);
}

class CarStats {
  final int wins;
  final int losses;
  final int totalMatches;

  CarStats({
    required this.wins,
    required this.losses,
    required this.totalMatches,
  });

  double get winRate => totalMatches > 0 ? wins / totalMatches : 0.0;
}
