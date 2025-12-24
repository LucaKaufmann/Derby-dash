// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMatchCollection on Isar {
  IsarCollection<Match> get matchs => this.collection();
}

const MatchSchema = CollectionSchema(
  name: r'Match',
  id: -4384922031457139852,
  properties: {
    r'isBye': PropertySchema(
      id: 0,
      name: r'isBye',
      type: IsarType.bool,
    )
  },
  estimateSize: _matchEstimateSize,
  serialize: _matchSerialize,
  deserialize: _matchDeserialize,
  deserializeProp: _matchDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'carA': LinkSchema(
      id: 1178776969551712226,
      name: r'carA',
      target: r'Car',
      single: true,
    ),
    r'carB': LinkSchema(
      id: 3162666483550728794,
      name: r'carB',
      target: r'Car',
      single: true,
    ),
    r'winner': LinkSchema(
      id: 313124811080743694,
      name: r'winner',
      target: r'Car',
      single: true,
    ),
    r'round': LinkSchema(
      id: -2988937188433222196,
      name: r'round',
      target: r'Round',
      single: true,
      linkName: r'matches',
    )
  },
  embeddedSchemas: {},
  getId: _matchGetId,
  getLinks: _matchGetLinks,
  attach: _matchAttach,
  version: '3.1.0+1',
);

int _matchEstimateSize(
  Match object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _matchSerialize(
  Match object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.isBye);
}

Match _matchDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Match();
  object.id = id;
  object.isBye = reader.readBool(offsets[0]);
  return object;
}

P _matchDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _matchGetId(Match object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _matchGetLinks(Match object) {
  return [object.carA, object.carB, object.winner, object.round];
}

void _matchAttach(IsarCollection<dynamic> col, Id id, Match object) {
  object.id = id;
  object.carA.attach(col, col.isar.collection<Car>(), r'carA', id);
  object.carB.attach(col, col.isar.collection<Car>(), r'carB', id);
  object.winner.attach(col, col.isar.collection<Car>(), r'winner', id);
  object.round.attach(col, col.isar.collection<Round>(), r'round', id);
}

extension MatchQueryWhereSort on QueryBuilder<Match, Match, QWhere> {
  QueryBuilder<Match, Match, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension MatchQueryWhere on QueryBuilder<Match, Match, QWhereClause> {
  QueryBuilder<Match, Match, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Match, Match, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Match, Match, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Match, Match, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Match, Match, QAfterWhereClause> idBetween(
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

extension MatchQueryFilter on QueryBuilder<Match, Match, QFilterCondition> {
  QueryBuilder<Match, Match, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Match, Match, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Match, Match, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Match, Match, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Match, Match, QAfterFilterCondition> isByeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBye',
        value: value,
      ));
    });
  }
}

extension MatchQueryObject on QueryBuilder<Match, Match, QFilterCondition> {}

extension MatchQueryLinks on QueryBuilder<Match, Match, QFilterCondition> {
  QueryBuilder<Match, Match, QAfterFilterCondition> carA(FilterQuery<Car> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'carA');
    });
  }

  QueryBuilder<Match, Match, QAfterFilterCondition> carAIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'carA', 0, true, 0, true);
    });
  }

  QueryBuilder<Match, Match, QAfterFilterCondition> carB(FilterQuery<Car> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'carB');
    });
  }

  QueryBuilder<Match, Match, QAfterFilterCondition> carBIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'carB', 0, true, 0, true);
    });
  }

  QueryBuilder<Match, Match, QAfterFilterCondition> winner(FilterQuery<Car> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'winner');
    });
  }

  QueryBuilder<Match, Match, QAfterFilterCondition> winnerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'winner', 0, true, 0, true);
    });
  }

  QueryBuilder<Match, Match, QAfterFilterCondition> round(
      FilterQuery<Round> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'round');
    });
  }

  QueryBuilder<Match, Match, QAfterFilterCondition> roundIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'round', 0, true, 0, true);
    });
  }
}

extension MatchQuerySortBy on QueryBuilder<Match, Match, QSortBy> {
  QueryBuilder<Match, Match, QAfterSortBy> sortByIsBye() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBye', Sort.asc);
    });
  }

  QueryBuilder<Match, Match, QAfterSortBy> sortByIsByeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBye', Sort.desc);
    });
  }
}

extension MatchQuerySortThenBy on QueryBuilder<Match, Match, QSortThenBy> {
  QueryBuilder<Match, Match, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Match, Match, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Match, Match, QAfterSortBy> thenByIsBye() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBye', Sort.asc);
    });
  }

  QueryBuilder<Match, Match, QAfterSortBy> thenByIsByeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBye', Sort.desc);
    });
  }
}

extension MatchQueryWhereDistinct on QueryBuilder<Match, Match, QDistinct> {
  QueryBuilder<Match, Match, QDistinct> distinctByIsBye() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBye');
    });
  }
}

extension MatchQueryProperty on QueryBuilder<Match, Match, QQueryProperty> {
  QueryBuilder<Match, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Match, bool, QQueryOperations> isByeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBye');
    });
  }
}
