import 'package:isar/isar.dart';
import '../models/car.dart';
import '../models/match.dart';

class CarRepository {
  final Isar _isar;

  CarRepository(this._isar);

  // Get all non-deleted cars
  Future<List<Car>> getAllCars() async {
    return await _isar.cars.filter().isDeletedEqualTo(false).findAll();
  }

  // Get a car by ID
  Future<Car?> getCarById(Id id) async {
    return await _isar.cars.get(id);
  }

  // Get a car by UUID
  Future<Car?> getCarByUuid(String uuid) async {
    return await _isar.cars.filter().uuidEqualTo(uuid).findFirst();
  }

  // Add a new car
  Future<Id> addCar(Car car) async {
    return await _isar.writeTxn(() async {
      return await _isar.cars.put(car);
    });
  }

  // Update a car
  Future<void> updateCar(Car car) async {
    await _isar.writeTxn(() async {
      await _isar.cars.put(car);
    });
  }

  // Soft delete a car
  Future<void> deleteCar(Id id) async {
    await _isar.writeTxn(() async {
      final car = await _isar.cars.get(id);
      if (car != null) {
        car.isDeleted = true;
        await _isar.cars.put(car);
      }
    });
  }

  // Get win count for a car (dynamically calculated)
  Future<int> getWinCount(Id carId) async {
    return await _isar.matchs
        .filter()
        .winner((q) => q.idEqualTo(carId))
        .count();
  }

  // Get loss count for a car (dynamically calculated)
  Future<int> getLossCount(Id carId) async {
    // Get all completed non-bye matches where car participated
    final allMatches = await _isar.matchs
        .filter()
        .isByeEqualTo(false)
        .findAll();

    int losses = 0;
    for (final match in allMatches) {
      await match.carA.load();
      await match.carB.load();
      await match.winner.load();

      // Check if car participated and lost
      final carAId = match.carA.value?.id;
      final carBId = match.carB.value?.id;
      final winnerId = match.winner.value?.id;

      if (winnerId != null) {
        if ((carAId == carId || carBId == carId) && winnerId != carId) {
          losses++;
        }
      }
    }

    return losses;
  }

  // Get total match count for a car
  Future<int> getMatchCount(Id carId) async {
    final allMatches = await _isar.matchs
        .filter()
        .isByeEqualTo(false)
        .findAll();

    int count = 0;
    for (final match in allMatches) {
      await match.carA.load();
      await match.carB.load();
      await match.winner.load();

      final carAId = match.carA.value?.id;
      final carBId = match.carB.value?.id;
      final winnerId = match.winner.value?.id;

      // Count if car participated and match is completed
      if (winnerId != null && (carAId == carId || carBId == carId)) {
        count++;
      }
    }

    return count;
  }

  // Watch cars stream for real-time updates
  Stream<List<Car>> watchCars() {
    return _isar.cars
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true);
  }
}
