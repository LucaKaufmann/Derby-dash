// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetRoundCollection on Isar {
  IsarCollection<Round> get rounds => this.collection();
}

const RoundSchema = CollectionSchema(
  name: r'Round',
  id: 8762410198825043196,
  properties: {
    r'bracketType': PropertySchema(
      id: 0,
      name: r'bracketType',
      type: IsarType.string,
      enumMap: _RoundbracketTypeEnumValueMap,
    ),
    r'groupIndex': PropertySchema(
      id: 1,
      name: r'groupIndex',
      type: IsarType.long,
    ),
    r'isCompleted': PropertySchema(
      id: 2,
      name: r'isCompleted',
      type: IsarType.bool,
    ),
    r'knockoutRoundName': PropertySchema(
      id: 3,
      name: r'knockoutRoundName',
      type: IsarType.string,
    ),
    r'roundNumber': PropertySchema(
      id: 4,
      name: r'roundNumber',
      type: IsarType.long,
    )
  },
  estimateSize: _roundEstimateSize,
  serialize: _roundSerialize,
  deserialize: _roundDeserialize,
  deserializeProp: _roundDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'matches': LinkSchema(
      id: 7453452149809017137,
      name: r'matches',
      target: r'Match',
      single: false,
    ),
    r'tournament': LinkSchema(
      id: 1478322665502852782,
      name: r'tournament',
      target: r'Tournament',
      single: true,
      linkName: r'rounds',
    )
  },
  embeddedSchemas: {},
  getId: _roundGetId,
  getLinks: _roundGetLinks,
  attach: _roundAttach,
  version: '3.1.0+1',
);

int _roundEstimateSize(
  Round object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.bracketType.name.length * 3;
  {
    final value = object.knockoutRoundName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _roundSerialize(
  Round object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bracketType.name);
  writer.writeLong(offsets[1], object.groupIndex);
  writer.writeBool(offsets[2], object.isCompleted);
  writer.writeString(offsets[3], object.knockoutRoundName);
  writer.writeLong(offsets[4], object.roundNumber);
}

Round _roundDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Round();
  object.bracketType =
      _RoundbracketTypeValueEnumMap[reader.readStringOrNull(offsets[0])] ??
          BracketType.winners;
  object.groupIndex = reader.readLongOrNull(offsets[1]);
  object.id = id;
  object.isCompleted = reader.readBool(offsets[2]);
  object.knockoutRoundName = reader.readStringOrNull(offsets[3]);
  object.roundNumber = reader.readLong(offsets[4]);
  return object;
}

P _roundDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_RoundbracketTypeValueEnumMap[reader.readStringOrNull(offset)] ??
          BracketType.winners) as P;
    case 1:
      return (reader.readLongOrNull(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _RoundbracketTypeEnumValueMap = {
  r'winners': r'winners',
  r'losers': r'losers',
  r'grandFinals': r'grandFinals',
  r'groupA': r'groupA',
  r'groupB': r'groupB',
  r'groupC': r'groupC',
  r'groupD': r'groupD',
  r'groupE': r'groupE',
  r'groupF': r'groupF',
  r'groupG': r'groupG',
  r'groupH': r'groupH',
  r'knockout': r'knockout',
};
const _RoundbracketTypeValueEnumMap = {
  r'winners': BracketType.winners,
  r'losers': BracketType.losers,
  r'grandFinals': BracketType.grandFinals,
  r'groupA': BracketType.groupA,
  r'groupB': BracketType.groupB,
  r'groupC': BracketType.groupC,
  r'groupD': BracketType.groupD,
  r'groupE': BracketType.groupE,
  r'groupF': BracketType.groupF,
  r'groupG': BracketType.groupG,
  r'groupH': BracketType.groupH,
  r'knockout': BracketType.knockout,
};

Id _roundGetId(Round object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _roundGetLinks(Round object) {
  return [object.matches, object.tournament];
}

void _roundAttach(IsarCollection<dynamic> col, Id id, Round object) {
  object.id = id;
  object.matches.attach(col, col.isar.collection<Match>(), r'matches', id);
  object.tournament
      .attach(col, col.isar.collection<Tournament>(), r'tournament', id);
}

extension RoundQueryWhereSort on QueryBuilder<Round, Round, QWhere> {
  QueryBuilder<Round, Round, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension RoundQueryWhere on QueryBuilder<Round, Round, QWhereClause> {
  QueryBuilder<Round, Round, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Round, Round, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Round, Round, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Round, Round, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RoundQueryFilter on QueryBuilder<Round, Round, QFilterCondition> {
  QueryBuilder<Round, Round, QAfterFilterCondition> bracketTypeEqualTo(
    BracketType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bracketType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> bracketTypeGreaterThan(
    BracketType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bracketType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> bracketTypeLessThan(
    BracketType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bracketType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> bracketTypeBetween(
    BracketType lower,
    BracketType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bracketType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> bracketTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bracketType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> bracketTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bracketType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> bracketTypeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bracketType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> bracketTypeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bracketType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> bracketTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bracketType',
        value: '',
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> bracketTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bracketType',
        value: '',
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> groupIndexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'groupIndex',
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> groupIndexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'groupIndex',
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> groupIndexEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'groupIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> groupIndexGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'groupIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> groupIndexLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'groupIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> groupIndexBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'groupIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> isCompletedEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isCompleted',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> knockoutRoundNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'knockoutRoundName',
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition>
      knockoutRoundNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'knockoutRoundName',
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> knockoutRoundNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'knockoutRoundName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition>
      knockoutRoundNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'knockoutRoundName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> knockoutRoundNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'knockoutRoundName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> knockoutRoundNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'knockoutRoundName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> knockoutRoundNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'knockoutRoundName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> knockoutRoundNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'knockoutRoundName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> knockoutRoundNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'knockoutRoundName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> knockoutRoundNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'knockoutRoundName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> knockoutRoundNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'knockoutRoundName',
        value: '',
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition>
      knockoutRoundNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'knockoutRoundName',
        value: '',
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> roundNumberEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roundNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> roundNumberGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'roundNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> roundNumberLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'roundNumber',
        value: value,
      ));
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> roundNumberBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'roundNumber',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension RoundQueryObject on QueryBuilder<Round, Round, QFilterCondition> {}

extension RoundQueryLinks on QueryBuilder<Round, Round, QFilterCondition> {
  QueryBuilder<Round, Round, QAfterFilterCondition> matches(
      FilterQuery<Match> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'matches');
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> matchesLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'matches', length, true, length, true);
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> matchesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'matches', 0, true, 0, true);
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> matchesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'matches', 0, false, 999999, true);
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> matchesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'matches', 0, true, length, include);
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> matchesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'matches', length, include, 999999, true);
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> matchesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'matches', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> tournament(
      FilterQuery<Tournament> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'tournament');
    });
  }

  QueryBuilder<Round, Round, QAfterFilterCondition> tournamentIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'tournament', 0, true, 0, true);
    });
  }
}

extension RoundQuerySortBy on QueryBuilder<Round, Round, QSortBy> {
  QueryBuilder<Round, Round, QAfterSortBy> sortByBracketType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bracketType', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByBracketTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bracketType', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByGroupIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupIndex', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByGroupIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupIndex', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByKnockoutRoundName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knockoutRoundName', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByKnockoutRoundNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knockoutRoundName', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByRoundNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundNumber', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> sortByRoundNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundNumber', Sort.desc);
    });
  }
}

extension RoundQuerySortThenBy on QueryBuilder<Round, Round, QSortThenBy> {
  QueryBuilder<Round, Round, QAfterSortBy> thenByBracketType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bracketType', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByBracketTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bracketType', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByGroupIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupIndex', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByGroupIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupIndex', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByIsCompletedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isCompleted', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByKnockoutRoundName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knockoutRoundName', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByKnockoutRoundNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'knockoutRoundName', Sort.desc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByRoundNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundNumber', Sort.asc);
    });
  }

  QueryBuilder<Round, Round, QAfterSortBy> thenByRoundNumberDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roundNumber', Sort.desc);
    });
  }
}

extension RoundQueryWhereDistinct on QueryBuilder<Round, Round, QDistinct> {
  QueryBuilder<Round, Round, QDistinct> distinctByBracketType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bracketType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Round, Round, QDistinct> distinctByGroupIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupIndex');
    });
  }

  QueryBuilder<Round, Round, QDistinct> distinctByIsCompleted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isCompleted');
    });
  }

  QueryBuilder<Round, Round, QDistinct> distinctByKnockoutRoundName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'knockoutRoundName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Round, Round, QDistinct> distinctByRoundNumber() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roundNumber');
    });
  }
}

extension RoundQueryProperty on QueryBuilder<Round, Round, QQueryProperty> {
  QueryBuilder<Round, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Round, BracketType, QQueryOperations> bracketTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bracketType');
    });
  }

  QueryBuilder<Round, int?, QQueryOperations> groupIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupIndex');
    });
  }

  QueryBuilder<Round, bool, QQueryOperations> isCompletedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isCompleted');
    });
  }

  QueryBuilder<Round, String?, QQueryOperations> knockoutRoundNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'knockoutRoundName');
    });
  }

  QueryBuilder<Round, int, QQueryOperations> roundNumberProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roundNumber');
    });
  }
}
