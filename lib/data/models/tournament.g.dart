// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetTournamentCollection on Isar {
  IsarCollection<Tournament> get tournaments => this.collection();
}

const TournamentSchema = CollectionSchema(
  name: r'Tournament',
  id: 3840673688892599922,
  properties: {
    r'date': PropertySchema(id: 0, name: r'date', type: IsarType.dateTime),
    r'groupCount': PropertySchema(
      id: 1,
      name: r'groupCount',
      type: IsarType.long,
    ),
    r'knockoutFormat': PropertySchema(
      id: 2,
      name: r'knockoutFormat',
      type: IsarType.string,
    ),
    r'phase': PropertySchema(
      id: 3,
      name: r'phase',
      type: IsarType.string,
      enumMap: _TournamentphaseEnumValueMap,
    ),
    r'status': PropertySchema(
      id: 4,
      name: r'status',
      type: IsarType.string,
      enumMap: _TournamentstatusEnumValueMap,
    ),
    r'targetScore': PropertySchema(
      id: 5,
      name: r'targetScore',
      type: IsarType.long,
    ),
    r'teamAName': PropertySchema(
      id: 6,
      name: r'teamAName',
      type: IsarType.string,
    ),
    r'teamAScore': PropertySchema(
      id: 7,
      name: r'teamAScore',
      type: IsarType.long,
    ),
    r'teamAssignmentsJson': PropertySchema(
      id: 8,
      name: r'teamAssignmentsJson',
      type: IsarType.string,
    ),
    r'teamBName': PropertySchema(
      id: 9,
      name: r'teamBName',
      type: IsarType.string,
    ),
    r'teamBScore': PropertySchema(
      id: 10,
      name: r'teamBScore',
      type: IsarType.long,
    ),
    r'type': PropertySchema(
      id: 11,
      name: r'type',
      type: IsarType.string,
      enumMap: _TournamenttypeEnumValueMap,
    ),
  },

  estimateSize: _tournamentEstimateSize,
  serialize: _tournamentSerialize,
  deserialize: _tournamentDeserialize,
  deserializeProp: _tournamentDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'rounds': LinkSchema(
      id: -2635089030773280737,
      name: r'rounds',
      target: r'Round',
      single: false,
    ),
  },
  embeddedSchemas: {},

  getId: _tournamentGetId,
  getLinks: _tournamentGetLinks,
  attach: _tournamentAttach,
  version: '3.3.2',
);

int _tournamentEstimateSize(
  Tournament object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.knockoutFormat;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.phase.name.length * 3;
  bytesCount += 3 + object.status.name.length * 3;
  {
    final value = object.teamAName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.teamAssignmentsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.teamBName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.type.name.length * 3;
  return bytesCount;
}

void _tournamentSerialize(
  Tournament object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.date);
  writer.writeLong(offsets[1], object.groupCount);
  writer.writeString(offsets[2], object.knockoutFormat);
  writer.writeString(offsets[3], object.phase.name);
  writer.writeString(offsets[4], object.status.name);
  writer.writeLong(offsets[5], object.targetScore);
  writer.writeString(offsets[6], object.teamAName);
  writer.writeLong(offsets[7], object.teamAScore);
  writer.writeString(offsets[8], object.teamAssignmentsJson);
  writer.writeString(offsets[9], object.teamBName);
  writer.writeLong(offsets[10], object.teamBScore);
  writer.writeString(offsets[11], object.type.name);
}

Tournament _tournamentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Tournament();
  object.date = reader.readDateTime(offsets[0]);
  object.groupCount = reader.readLongOrNull(offsets[1]);
  object.id = id;
  object.knockoutFormat = reader.readStringOrNull(offsets[2]);
  object.phase =
      _TournamentphaseValueEnumMap[reader.readStringOrNull(offsets[3])] ??
      TournamentPhase.group;
  object.status =
      _TournamentstatusValueEnumMap[reader.readStringOrNull(offsets[4])] ??
      TournamentStatus.setup;
  object.targetScore = reader.readLong(offsets[5]);
  object.teamAName = reader.readStringOrNull(offsets[6]);
  object.teamAScore = reader.readLong(offsets[7]);
  object.teamAssignmentsJson = reader.readStringOrNull(offsets[8]);
  object.teamBName = reader.readStringOrNull(offsets[9]);
  object.teamBScore = reader.readLong(offsets[10]);
  object.type =
      _TournamenttypeValueEnumMap[reader.readStringOrNull(offsets[11])] ??
      TournamentType.knockout;
  return object;
}

P _tournamentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (_TournamentphaseValueEnumMap[reader.readStringOrNull(offset)] ??
              TournamentPhase.group)
          as P;
    case 4:
      return (_TournamentstatusValueEnumMap[reader.readStringOrNull(offset)] ??
              TournamentStatus.setup)
          as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (_TournamenttypeValueEnumMap[reader.readStringOrNull(offset)] ??
              TournamentType.knockout)
          as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _TournamentphaseEnumValueMap = {
  r'group': r'group',
  r'knockout': r'knockout',
};
const _TournamentphaseValueEnumMap = {
  r'group': TournamentPhase.group,
  r'knockout': TournamentPhase.knockout,
};
const _TournamentstatusEnumValueMap = {
  r'setup': r'setup',
  r'active': r'active',
  r'completed': r'completed',
};
const _TournamentstatusValueEnumMap = {
  r'setup': TournamentStatus.setup,
  r'active': TournamentStatus.active,
  r'completed': TournamentStatus.completed,
};
const _TournamenttypeEnumValueMap = {
  r'knockout': r'knockout',
  r'roundRobin': r'roundRobin',
  r'doubleElimination': r'doubleElimination',
  r'groupKnockout': r'groupKnockout',
  r'tinyTournament': r'tinyTournament',
  r'mysteryRace': r'mysteryRace',
  r'teamBattle': r'teamBattle',
};
const _TournamenttypeValueEnumMap = {
  r'knockout': TournamentType.knockout,
  r'roundRobin': TournamentType.roundRobin,
  r'doubleElimination': TournamentType.doubleElimination,
  r'groupKnockout': TournamentType.groupKnockout,
  r'tinyTournament': TournamentType.tinyTournament,
  r'mysteryRace': TournamentType.mysteryRace,
  r'teamBattle': TournamentType.teamBattle,
};

Id _tournamentGetId(Tournament object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _tournamentGetLinks(Tournament object) {
  return [object.rounds];
}

void _tournamentAttach(IsarCollection<dynamic> col, Id id, Tournament object) {
  object.id = id;
  object.rounds.attach(col, col.isar.collection<Round>(), r'rounds', id);
}

extension TournamentQueryWhereSort
    on QueryBuilder<Tournament, Tournament, QWhere> {
  QueryBuilder<Tournament, Tournament, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension TournamentQueryWhere
    on QueryBuilder<Tournament, Tournament, QWhereClause> {
  QueryBuilder<Tournament, Tournament, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension TournamentQueryFilter
    on QueryBuilder<Tournament, Tournament, QFilterCondition> {
  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> dateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'date', value: value),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> dateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> dateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'date',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'date',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  groupCountIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'groupCount'),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  groupCountIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'groupCount'),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> groupCountEqualTo(
    int? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupCount', value: value),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  groupCountGreaterThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  groupCountLessThan(int? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupCount',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> groupCountBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupCount',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  knockoutFormatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'knockoutFormat'),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  knockoutFormatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'knockoutFormat'),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  knockoutFormatEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'knockoutFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  knockoutFormatGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'knockoutFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  knockoutFormatLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'knockoutFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  knockoutFormatBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'knockoutFormat',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  knockoutFormatStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'knockoutFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  knockoutFormatEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'knockoutFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  knockoutFormatContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'knockoutFormat',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  knockoutFormatMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'knockoutFormat',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  knockoutFormatIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'knockoutFormat', value: ''),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  knockoutFormatIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'knockoutFormat', value: ''),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> phaseEqualTo(
    TournamentPhase value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'phase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> phaseGreaterThan(
    TournamentPhase value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'phase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> phaseLessThan(
    TournamentPhase value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'phase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> phaseBetween(
    TournamentPhase lower,
    TournamentPhase upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'phase',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> phaseStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'phase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> phaseEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'phase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> phaseContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'phase',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> phaseMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'phase',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> phaseIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'phase', value: ''),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  phaseIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'phase', value: ''),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> statusEqualTo(
    TournamentStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> statusGreaterThan(
    TournamentStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> statusLessThan(
    TournamentStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> statusBetween(
    TournamentStatus lower,
    TournamentStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'status',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> statusContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'status',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> statusMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'status',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'status', value: ''),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  targetScoreEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'targetScore', value: value),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  targetScoreGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'targetScore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  targetScoreLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'targetScore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  targetScoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'targetScore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamANameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'teamAName'),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamANameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'teamAName'),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamANameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'teamAName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamANameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'teamAName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamANameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'teamAName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamANameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'teamAName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamANameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'teamAName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamANameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'teamAName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamANameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'teamAName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamANameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'teamAName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamANameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'teamAName', value: ''),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamANameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'teamAName', value: ''),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamAScoreEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'teamAScore', value: value),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAScoreGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'teamAScore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAScoreLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'teamAScore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamAScoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'teamAScore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAssignmentsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'teamAssignmentsJson'),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAssignmentsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'teamAssignmentsJson'),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAssignmentsJsonEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'teamAssignmentsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAssignmentsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'teamAssignmentsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAssignmentsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'teamAssignmentsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAssignmentsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'teamAssignmentsJson',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAssignmentsJsonStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'teamAssignmentsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAssignmentsJsonEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'teamAssignmentsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAssignmentsJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'teamAssignmentsJson',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAssignmentsJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'teamAssignmentsJson',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAssignmentsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'teamAssignmentsJson', value: ''),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamAssignmentsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'teamAssignmentsJson',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamBNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'teamBName'),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamBNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'teamBName'),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamBNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'teamBName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamBNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'teamBName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamBNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'teamBName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamBNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'teamBName',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamBNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'teamBName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamBNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'teamBName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamBNameContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'teamBName',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamBNameMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'teamBName',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamBNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'teamBName', value: ''),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamBNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'teamBName', value: ''),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamBScoreEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'teamBScore', value: value),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamBScoreGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'teamBScore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  teamBScoreLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'teamBScore',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> teamBScoreBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'teamBScore',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> typeEqualTo(
    TournamentType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> typeGreaterThan(
    TournamentType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> typeLessThan(
    TournamentType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> typeBetween(
    TournamentType lower,
    TournamentType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'type',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> typeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> typeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> typeContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'type',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> typeMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'type',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> typeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'type', value: ''),
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> typeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'type', value: ''),
      );
    });
  }
}

extension TournamentQueryObject
    on QueryBuilder<Tournament, Tournament, QFilterCondition> {}

extension TournamentQueryLinks
    on QueryBuilder<Tournament, Tournament, QFilterCondition> {
  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> rounds(
    FilterQuery<Round> q,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'rounds');
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  roundsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'rounds', length, true, length, true);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition> roundsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'rounds', 0, true, 0, true);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  roundsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'rounds', 0, false, 999999, true);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  roundsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'rounds', 0, true, length, include);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  roundsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'rounds', length, include, 999999, true);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterFilterCondition>
  roundsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
        r'rounds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension TournamentQuerySortBy
    on QueryBuilder<Tournament, Tournament, QSortBy> {
  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByGroupCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCount', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByGroupCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCount', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByKnockoutFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knockoutFormat', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy>
  sortByKnockoutFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knockoutFormat', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByPhase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phase', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByPhaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phase', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByTargetScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetScore', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByTargetScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetScore', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByTeamAName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamAName', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByTeamANameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamAName', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByTeamAScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamAScore', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByTeamAScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamAScore', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy>
  sortByTeamAssignmentsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamAssignmentsJson', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy>
  sortByTeamAssignmentsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamAssignmentsJson', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByTeamBName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamBName', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByTeamBNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamBName', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByTeamBScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamBScore', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByTeamBScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamBScore', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension TournamentQuerySortThenBy
    on QueryBuilder<Tournament, Tournament, QSortThenBy> {
  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'date', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByGroupCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCount', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByGroupCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupCount', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByKnockoutFormat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knockoutFormat', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy>
  thenByKnockoutFormatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knockoutFormat', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByPhase() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phase', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByPhaseDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phase', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByTargetScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetScore', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByTargetScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'targetScore', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByTeamAName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamAName', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByTeamANameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamAName', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByTeamAScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamAScore', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByTeamAScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamAScore', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy>
  thenByTeamAssignmentsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamAssignmentsJson', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy>
  thenByTeamAssignmentsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamAssignmentsJson', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByTeamBName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamBName', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByTeamBNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamBName', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByTeamBScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamBScore', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByTeamBScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'teamBScore', Sort.desc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.asc);
    });
  }

  QueryBuilder<Tournament, Tournament, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'type', Sort.desc);
    });
  }
}

extension TournamentQueryWhereDistinct
    on QueryBuilder<Tournament, Tournament, QDistinct> {
  QueryBuilder<Tournament, Tournament, QDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'date');
    });
  }

  QueryBuilder<Tournament, Tournament, QDistinct> distinctByGroupCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupCount');
    });
  }

  QueryBuilder<Tournament, Tournament, QDistinct> distinctByKnockoutFormat({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'knockoutFormat',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QDistinct> distinctByPhase({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phase', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Tournament, Tournament, QDistinct> distinctByStatus({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Tournament, Tournament, QDistinct> distinctByTargetScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'targetScore');
    });
  }

  QueryBuilder<Tournament, Tournament, QDistinct> distinctByTeamAName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'teamAName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Tournament, Tournament, QDistinct> distinctByTeamAScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'teamAScore');
    });
  }

  QueryBuilder<Tournament, Tournament, QDistinct>
  distinctByTeamAssignmentsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'teamAssignmentsJson',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<Tournament, Tournament, QDistinct> distinctByTeamBName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'teamBName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Tournament, Tournament, QDistinct> distinctByTeamBScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'teamBScore');
    });
  }

  QueryBuilder<Tournament, Tournament, QDistinct> distinctByType({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'type', caseSensitive: caseSensitive);
    });
  }
}

extension TournamentQueryProperty
    on QueryBuilder<Tournament, Tournament, QQueryProperty> {
  QueryBuilder<Tournament, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Tournament, DateTime, QQueryOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'date');
    });
  }

  QueryBuilder<Tournament, int?, QQueryOperations> groupCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupCount');
    });
  }

  QueryBuilder<Tournament, String?, QQueryOperations> knockoutFormatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'knockoutFormat');
    });
  }

  QueryBuilder<Tournament, TournamentPhase, QQueryOperations> phaseProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phase');
    });
  }

  QueryBuilder<Tournament, TournamentStatus, QQueryOperations>
  statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<Tournament, int, QQueryOperations> targetScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'targetScore');
    });
  }

  QueryBuilder<Tournament, String?, QQueryOperations> teamANameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teamAName');
    });
  }

  QueryBuilder<Tournament, int, QQueryOperations> teamAScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teamAScore');
    });
  }

  QueryBuilder<Tournament, String?, QQueryOperations>
  teamAssignmentsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teamAssignmentsJson');
    });
  }

  QueryBuilder<Tournament, String?, QQueryOperations> teamBNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teamBName');
    });
  }

  QueryBuilder<Tournament, int, QQueryOperations> teamBScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'teamBScore');
    });
  }

  QueryBuilder<Tournament, TournamentType, QQueryOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'type');
    });
  }
}
