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
    // Losses = completed matches participated in - wins
    final matchCount = await getMatchCount(carId);
    final winCount = await getWinCount(carId);
    return matchCount - winCount;
  }

  // Get total match count for a car (completed matches only)
  Future<int> getMatchCount(Id carId) async {
    // Count completed matches where car was carA
    final asCarA = await _isar.matchs
        .filter()
        .carA((q) => q.idEqualTo(carId))
        .and()
        .winner((q) => q.idGreaterThan(0))
        .count();

    // Count completed matches where car was carB
    final asCarB = await _isar.matchs
        .filter()
        .carB((q) => q.idEqualTo(carId))
        .and()
        .winner((q) => q.idGreaterThan(0))
        .count();

    return asCarA + asCarB;
  }

  // Watch cars stream for real-time updates
  Stream<List<Car>> watchCars() {
    return _isar.cars
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true);
  }
}
