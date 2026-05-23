import 'package:isar/isar.dart';

part 'car.g.dart';

@collection
class Car {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;

  late String photoPath;

  @Index()
  bool isDeleted = false;

  DateTime createdAt = DateTime.now();
}
