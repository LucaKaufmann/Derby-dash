import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/models/models.dart';

class BackupService {
  static const _format = 'derby_dash_backup';
  static const _schemaVersion = 1;

  final Isar _isar;

  BackupService(this._isar);

  Future<BackupSummary> summarize() async {
    final cars = await _isar.cars.where().count();
    final tournaments = await _isar.tournaments.where().count();
    final rounds = await _isar.rounds.where().count();
    final matches = await _isar.matchs.where().count();
    return BackupSummary(
      cars: cars,
      tournaments: tournaments,
      rounds: rounds,
      matches: matches,
    );
  }

  Future<File> exportBackup() async {
    final timestamp = DateTime.now().toIso8601String().replaceAll(
      RegExp(r'[:.]'),
      '-',
    );
    final output = File(
      p.join(
        (await getTemporaryDirectory()).path,
        'DerbyDash-backup-$timestamp.derbydash',
      ),
    );
    await exportBackupToFile(output);
    return output;
  }

  Future<BackupSummary> exportBackupToFile(File output) async {
    final export = await _buildBackupArchive();
    await output.parent.create(recursive: true);
    await output.writeAsBytes(export.bytes, flush: true);
    return export.summary;
  }

  Future<({List<int> bytes, BackupSummary summary})>
  _buildBackupArchive() async {
    final archive = Archive();
    final cars = await _isar.cars.where().findAll();
    final tournaments = await _isar.tournaments.where().findAll();

    final carRecords = <Map<String, dynamic>>[];
    for (final car in cars) {
      final photoEntryName = await _addCarPhotoToArchive(archive, car);
      carRecords.add({
        'id': car.id,
        'uuid': car.uuid,
        'name': car.name,
        'photoEntryName': photoEntryName,
        'isDeleted': car.isDeleted,
        'createdAt': car.createdAt.toIso8601String(),
      });
    }

    final tournamentRecords = <Map<String, dynamic>>[];
    final roundRecords = <Map<String, dynamic>>[];
    final matchRecords = <Map<String, dynamic>>[];

    for (final tournament in tournaments) {
      await tournament.rounds.load();
      final rounds = tournament.rounds.toList()
        ..sort((a, b) => a.roundNumber.compareTo(b.roundNumber));

      tournamentRecords.add({
        'id': tournament.id,
        'date': tournament.date.toIso8601String(),
        'status': tournament.status.name,
        'type': tournament.type.name,
        'phase': tournament.phase.name,
        'groupCount': tournament.groupCount,
        'knockoutFormat': tournament.knockoutFormat,
        'teamAName': tournament.teamAName,
        'teamBName': tournament.teamBName,
        'teamAScore': tournament.teamAScore,
        'teamBScore': tournament.teamBScore,
        'targetScore': tournament.targetScore,
        'teamAssignmentsJson': tournament.teamAssignmentsJson,
        'roundIds': rounds.map((round) => round.id).toList(),
      });

      for (final round in rounds) {
        await round.matches.load();
        final matches = round.matches.toList()
          ..sort((a, b) => a.matchPosition.compareTo(b.matchPosition));

        roundRecords.add({
          'id': round.id,
          'roundNumber': round.roundNumber,
          'isCompleted': round.isCompleted,
          'bracketType': round.bracketType.name,
          'groupIndex': round.groupIndex,
          'knockoutRoundName': round.knockoutRoundName,
          'matchIds': matches.map((match) => match.id).toList(),
        });

        for (final match in matches) {
          await match.carA.load();
          await match.carB.load();
          await match.winner.load();

          matchRecords.add({
            'id': match.id,
            'carAId': match.carA.value?.id,
            'carBId': match.carB.value?.id,
            'winnerId': match.winner.value?.id,
            'matchPosition': match.matchPosition,
            'loserDestinationMatchId': match.loserDestinationMatchId,
            'seriesLength': match.seriesLength,
            'carASeriesWins': match.carASeriesWins,
            'carBSeriesWins': match.carBSeriesWins,
          });
        }
      }
    }

    final backup = {
      'format': _format,
      'schemaVersion': _schemaVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'cars': carRecords,
      'tournaments': tournamentRecords,
      'rounds': roundRecords,
      'matches': matchRecords,
    };

    archive.addFile(
      ArchiveFile.string(
        'backup.json',
        const JsonEncoder.withIndent('  ').convert(backup),
      ),
    );

    final bytes = ZipEncoder().encodeBytes(archive);
    final summary = BackupSummary(
      cars: carRecords.length,
      tournaments: tournamentRecords.length,
      rounds: roundRecords.length,
      matches: matchRecords.length,
    );

    return (bytes: bytes, summary: summary);
  }

  Future<ImportSummary> importBackup(File file) async {
    final archive = ZipDecoder().decodeBytes(await file.readAsBytes());
    final backupEntry = archive.findFile('backup.json');
    if (backupEntry == null) {
      throw const FormatException('This is not a Derby Dash backup file.');
    }

    final backup = jsonDecode(utf8.decode(backupEntry.content));
    if (backup is! Map<String, dynamic> ||
        backup['format'] != _format ||
        backup['schemaVersion'] != _schemaVersion) {
      throw const FormatException('Unsupported Derby Dash backup file.');
    }

    final carRecords = _list(backup['cars']);
    final tournamentRecords = _list(backup['tournaments']);
    final roundRecords = _list(backup['rounds']);
    final matchRecords = _list(backup['matches']);

    final appDir = await getApplicationDocumentsDirectory();
    final carPhotosDir = Directory(p.join(appDir.path, 'car_photos'));
    if (await carPhotosDir.exists()) {
      await carPhotosDir.delete(recursive: true);
    }
    await carPhotosDir.create(recursive: true);

    final carsById = <int, Car>{};
    for (final record in carRecords) {
      final id = _int(record['id']);
      final photoPath = await _restoreCarPhoto(
        archive: archive,
        carPhotosDir: carPhotosDir,
        carId: id,
        photoEntryName: record['photoEntryName'] as String?,
      );

      carsById[id] = Car()
        ..id = id
        ..uuid = record['uuid'] as String
        ..name = record['name'] as String
        ..photoPath = photoPath
        ..isDeleted = record['isDeleted'] as bool? ?? false
        ..createdAt = DateTime.parse(record['createdAt'] as String);
    }

    final tournamentsById = <int, Tournament>{};
    for (final record in tournamentRecords) {
      final id = _int(record['id']);
      tournamentsById[id] = Tournament()
        ..id = id
        ..date = DateTime.parse(record['date'] as String)
        ..status = TournamentStatus.values.byName(record['status'] as String)
        ..type = TournamentType.values.byName(record['type'] as String)
        ..phase = TournamentPhase.values.byName(record['phase'] as String)
        ..groupCount = record['groupCount'] as int?
        ..knockoutFormat = record['knockoutFormat'] as String?
        ..teamAName = record['teamAName'] as String?
        ..teamBName = record['teamBName'] as String?
        ..teamAScore = record['teamAScore'] as int? ?? 0
        ..teamBScore = record['teamBScore'] as int? ?? 0
        ..targetScore = record['targetScore'] as int? ?? 3
        ..teamAssignmentsJson = record['teamAssignmentsJson'] as String?;
    }

    final roundsById = <int, Round>{};
    for (final record in roundRecords) {
      final id = _int(record['id']);
      roundsById[id] = Round()
        ..id = id
        ..roundNumber = _int(record['roundNumber'])
        ..isCompleted = record['isCompleted'] as bool? ?? false
        ..bracketType = BracketType.values.byName(
          record['bracketType'] as String,
        )
        ..groupIndex = record['groupIndex'] as int?
        ..knockoutRoundName = record['knockoutRoundName'] as String?;
    }

    final matchesById = <int, Match>{};
    for (final record in matchRecords) {
      final id = _int(record['id']);
      final match = Match()
        ..id = id
        ..matchPosition = _int(record['matchPosition'])
        ..loserDestinationMatchId = record['loserDestinationMatchId'] as int?
        ..seriesLength = record['seriesLength'] as int? ?? 1
        ..carASeriesWins = record['carASeriesWins'] as int? ?? 0
        ..carBSeriesWins = record['carBSeriesWins'] as int? ?? 0;

      match.carA.value = carsById[record['carAId']];
      match.carB.value = carsById[record['carBId']];
      match.winner.value = carsById[record['winnerId']];
      matchesById[id] = match;
    }

    final existingCars = await _isar.cars.where().idProperty().findAll();
    final existingTournaments = await _isar.tournaments
        .where()
        .idProperty()
        .findAll();
    final existingRounds = await _isar.rounds.where().idProperty().findAll();
    final existingMatches = await _isar.matchs.where().idProperty().findAll();

    await _isar.writeTxn(() async {
      await _isar.matchs.deleteAll(existingMatches);
      await _isar.rounds.deleteAll(existingRounds);
      await _isar.tournaments.deleteAll(existingTournaments);
      await _isar.cars.deleteAll(existingCars);

      await _isar.cars.putAll(carsById.values.toList());
      await _isar.tournaments.putAll(tournamentsById.values.toList());
      await _isar.rounds.putAll(roundsById.values.toList());

      for (final match in matchesById.values) {
        await _isar.matchs.put(match);
        await match.carA.save();
        await match.carB.save();
        await match.winner.save();
      }

      for (final record in roundRecords) {
        final round = roundsById[_int(record['id'])]!;
        for (final matchId in _list(record['matchIds']).map((id) => _int(id))) {
          final match = matchesById[matchId];
          if (match != null) {
            round.matches.add(match);
          }
        }
        await round.matches.save();
      }

      for (final record in tournamentRecords) {
        final tournament = tournamentsById[_int(record['id'])]!;
        for (final roundId in _list(record['roundIds']).map((id) => _int(id))) {
          final round = roundsById[roundId];
          if (round != null) {
            tournament.rounds.add(round);
          }
        }
        await tournament.rounds.save();
      }
    });

    return ImportSummary(
      cars: carsById.length,
      tournaments: tournamentsById.length,
      matches: matchesById.length,
    );
  }

  Future<String?> _addCarPhotoToArchive(Archive archive, Car car) async {
    if (car.photoPath.isEmpty) return null;

    final photo = File(car.photoPath);
    if (!await photo.exists()) return null;

    final extension = p.extension(photo.path).isEmpty
        ? '.jpg'
        : p.extension(photo.path);
    final entryName = 'images/car_${car.id}$extension';
    archive.addFile(ArchiveFile.bytes(entryName, await photo.readAsBytes()));
    return entryName;
  }

  Future<String> _restoreCarPhoto({
    required Archive archive,
    required Directory carPhotosDir,
    required int carId,
    required String? photoEntryName,
  }) async {
    if (photoEntryName == null || photoEntryName.isEmpty) return '';

    final photoEntry = archive.findFile(photoEntryName);
    if (photoEntry == null) return '';

    final extension = p.extension(photoEntryName).isEmpty
        ? '.jpg'
        : p.extension(photoEntryName);
    final photoFile = File(
      p.join(carPhotosDir.path, 'imported_$carId$extension'),
    );
    await photoFile.writeAsBytes(photoEntry.content, flush: true);
    return photoFile.path;
  }

  List<dynamic> _list(Object? value) {
    if (value is List<dynamic>) return value;
    throw const FormatException('Backup file is missing required data.');
  }

  int _int(Object? value) {
    if (value is int) return value;
    throw const FormatException('Backup file contains invalid IDs.');
  }
}

class BackupSummary {
  final int cars;
  final int tournaments;
  final int rounds;
  final int matches;

  const BackupSummary({
    required this.cars,
    required this.tournaments,
    required this.rounds,
    required this.matches,
  });

  int get score => cars + tournaments + rounds + matches;

  Map<String, Object> toJson() {
    return {
      'cars': cars,
      'tournaments': tournaments,
      'rounds': rounds,
      'matches': matches,
      'score': score,
    };
  }

  static BackupSummary? fromJson(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    return BackupSummary(
      cars: value['cars'] as int? ?? 0,
      tournaments: value['tournaments'] as int? ?? 0,
      rounds: value['rounds'] as int? ?? 0,
      matches: value['matches'] as int? ?? 0,
    );
  }
}

class ImportSummary {
  final int cars;
  final int tournaments;
  final int matches;

  const ImportSummary({
    required this.cars,
    required this.tournaments,
    required this.matches,
  });
}
