// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetGlobalSettingsCollection on Isar {
  IsarCollection<GlobalSettings> get globalSettings => this.collection();
}

const GlobalSettingsSchema = CollectionSchema(
  name: r'GlobalSettings',
  id: 2650722966929233656,
  properties: {
    r'address': PropertySchema(
      id: 0,
      name: r'address',
      type: IsarType.string,
    ),
    r'city': PropertySchema(
      id: 1,
      name: r'city',
      type: IsarType.string,
    ),
    r'companyName': PropertySchema(
      id: 2,
      name: r'companyName',
      type: IsarType.string,
    ),
    r'currency': PropertySchema(
      id: 3,
      name: r'currency',
      type: IsarType.string,
    ),
    r'nif': PropertySchema(
      id: 4,
      name: r'nif',
      type: IsarType.string,
    ),
    r'phones': PropertySchema(
      id: 5,
      name: r'phones',
      type: IsarType.string,
    ),
    r'rcs': PropertySchema(
      id: 6,
      name: r'rcs',
      type: IsarType.string,
    ),
    r'sectorActivity': PropertySchema(
      id: 7,
      name: r'sectorActivity',
      type: IsarType.string,
    ),
    r'slogan': PropertySchema(
      id: 8,
      name: r'slogan',
      type: IsarType.string,
    ),
    r'stat': PropertySchema(
      id: 9,
      name: r'stat',
      type: IsarType.string,
    )
  },
  estimateSize: _globalSettingsEstimateSize,
  serialize: _globalSettingsSerialize,
  deserialize: _globalSettingsDeserialize,
  deserializeProp: _globalSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _globalSettingsGetId,
  getLinks: _globalSettingsGetLinks,
  attach: _globalSettingsAttach,
  version: '3.1.0+1',
);

int _globalSettingsEstimateSize(
  GlobalSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.address.length * 3;
  bytesCount += 3 + object.city.length * 3;
  bytesCount += 3 + object.companyName.length * 3;
  bytesCount += 3 + object.currency.length * 3;
  bytesCount += 3 + object.nif.length * 3;
  bytesCount += 3 + object.phones.length * 3;
  bytesCount += 3 + object.rcs.length * 3;
  bytesCount += 3 + object.sectorActivity.length * 3;
  bytesCount += 3 + object.slogan.length * 3;
  bytesCount += 3 + object.stat.length * 3;
  return bytesCount;
}

void _globalSettingsSerialize(
  GlobalSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.address);
  writer.writeString(offsets[1], object.city);
  writer.writeString(offsets[2], object.companyName);
  writer.writeString(offsets[3], object.currency);
  writer.writeString(offsets[4], object.nif);
  writer.writeString(offsets[5], object.phones);
  writer.writeString(offsets[6], object.rcs);
  writer.writeString(offsets[7], object.sectorActivity);
  writer.writeString(offsets[8], object.slogan);
  writer.writeString(offsets[9], object.stat);
}

GlobalSettings _globalSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = GlobalSettings();
  object.address = reader.readString(offsets[0]);
  object.city = reader.readString(offsets[1]);
  object.companyName = reader.readString(offsets[2]);
  object.currency = reader.readString(offsets[3]);
  object.id = id;
  object.nif = reader.readString(offsets[4]);
  object.phones = reader.readString(offsets[5]);
  object.rcs = reader.readString(offsets[6]);
  object.sectorActivity = reader.readString(offsets[7]);
  object.slogan = reader.readString(offsets[8]);
  object.stat = reader.readString(offsets[9]);
  return object;
}

P _globalSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _globalSettingsGetId(GlobalSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _globalSettingsGetLinks(GlobalSettings object) {
  return [];
}

void _globalSettingsAttach(
    IsarCollection<dynamic> col, Id id, GlobalSettings object) {
  object.id = id;
}

extension GlobalSettingsQueryWhereSort
    on QueryBuilder<GlobalSettings, GlobalSettings, QWhere> {
  QueryBuilder<GlobalSettings, GlobalSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension GlobalSettingsQueryWhere
    on QueryBuilder<GlobalSettings, GlobalSettings, QWhereClause> {
  QueryBuilder<GlobalSettings, GlobalSettings, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterWhereClause> idBetween(
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

extension GlobalSettingsQueryFilter
    on QueryBuilder<GlobalSettings, GlobalSettings, QFilterCondition> {
  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      addressEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      addressGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      addressLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      addressBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'address',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      addressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      addressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      addressContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'address',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      addressMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'address',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      addressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'address',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      addressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'address',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      cityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      cityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      cityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      cityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'city',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      cityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      cityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      cityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'city',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      cityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'city',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      cityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'city',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      cityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'city',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      companyNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'companyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      companyNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'companyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      companyNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'companyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      companyNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'companyName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      companyNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'companyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      companyNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'companyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      companyNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'companyName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      companyNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'companyName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      companyNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'companyName',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      companyNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'companyName',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      currencyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      currencyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      currencyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      currencyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      currencyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      currencyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      currencyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currency',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      currencyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currency',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      currencyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      currencyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currency',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition> idBetween(
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

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      nifEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      nifGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      nifLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      nifBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nif',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      nifStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      nifEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      nifContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nif',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      nifMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nif',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      nifIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nif',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      nifIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nif',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      phonesEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      phonesGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'phones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      phonesLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'phones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      phonesBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'phones',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      phonesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'phones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      phonesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'phones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      phonesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'phones',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      phonesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'phones',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      phonesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'phones',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      phonesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'phones',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      rcsEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rcs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      rcsGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rcs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      rcsLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rcs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      rcsBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rcs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      rcsStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rcs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      rcsEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rcs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      rcsContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rcs',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      rcsMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rcs',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      rcsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rcs',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      rcsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rcs',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sectorActivityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sectorActivity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sectorActivityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sectorActivity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sectorActivityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sectorActivity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sectorActivityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sectorActivity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sectorActivityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sectorActivity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sectorActivityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sectorActivity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sectorActivityContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sectorActivity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sectorActivityMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sectorActivity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sectorActivityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sectorActivity',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sectorActivityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sectorActivity',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sloganEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'slogan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sloganGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'slogan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sloganLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'slogan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sloganBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'slogan',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sloganStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'slogan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sloganEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'slogan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sloganContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'slogan',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sloganMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'slogan',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sloganIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'slogan',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      sloganIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'slogan',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      statEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      statGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      statLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      statBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      statStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'stat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      statEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'stat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      statContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'stat',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      statMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'stat',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      statIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stat',
        value: '',
      ));
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterFilterCondition>
      statIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'stat',
        value: '',
      ));
    });
  }
}

extension GlobalSettingsQueryObject
    on QueryBuilder<GlobalSettings, GlobalSettings, QFilterCondition> {}

extension GlobalSettingsQueryLinks
    on QueryBuilder<GlobalSettings, GlobalSettings, QFilterCondition> {}

extension GlobalSettingsQuerySortBy
    on QueryBuilder<GlobalSettings, GlobalSettings, QSortBy> {
  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> sortByAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      sortByAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> sortByCity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'city', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> sortByCityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'city', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      sortByCompanyName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyName', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      sortByCompanyNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyName', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> sortByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      sortByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> sortByNif() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nif', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> sortByNifDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nif', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> sortByPhones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phones', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      sortByPhonesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phones', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> sortByRcs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rcs', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> sortByRcsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rcs', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      sortBySectorActivity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectorActivity', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      sortBySectorActivityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectorActivity', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> sortBySlogan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slogan', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      sortBySloganDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slogan', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> sortByStat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stat', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> sortByStatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stat', Sort.desc);
    });
  }
}

extension GlobalSettingsQuerySortThenBy
    on QueryBuilder<GlobalSettings, GlobalSettings, QSortThenBy> {
  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenByAddress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      thenByAddressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'address', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenByCity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'city', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenByCityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'city', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      thenByCompanyName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyName', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      thenByCompanyNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'companyName', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenByCurrency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      thenByCurrencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currency', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenByNif() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nif', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenByNifDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nif', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenByPhones() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phones', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      thenByPhonesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'phones', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenByRcs() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rcs', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenByRcsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rcs', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      thenBySectorActivity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectorActivity', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      thenBySectorActivityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectorActivity', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenBySlogan() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slogan', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy>
      thenBySloganDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'slogan', Sort.desc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenByStat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stat', Sort.asc);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QAfterSortBy> thenByStatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stat', Sort.desc);
    });
  }
}

extension GlobalSettingsQueryWhereDistinct
    on QueryBuilder<GlobalSettings, GlobalSettings, QDistinct> {
  QueryBuilder<GlobalSettings, GlobalSettings, QDistinct> distinctByAddress(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'address', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QDistinct> distinctByCity(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'city', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QDistinct> distinctByCompanyName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'companyName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QDistinct> distinctByCurrency(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currency', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QDistinct> distinctByNif(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nif', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QDistinct> distinctByPhones(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'phones', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QDistinct> distinctByRcs(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rcs', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QDistinct>
      distinctBySectorActivity({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sectorActivity',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QDistinct> distinctBySlogan(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'slogan', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<GlobalSettings, GlobalSettings, QDistinct> distinctByStat(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stat', caseSensitive: caseSensitive);
    });
  }
}

extension GlobalSettingsQueryProperty
    on QueryBuilder<GlobalSettings, GlobalSettings, QQueryProperty> {
  QueryBuilder<GlobalSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<GlobalSettings, String, QQueryOperations> addressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'address');
    });
  }

  QueryBuilder<GlobalSettings, String, QQueryOperations> cityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'city');
    });
  }

  QueryBuilder<GlobalSettings, String, QQueryOperations> companyNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'companyName');
    });
  }

  QueryBuilder<GlobalSettings, String, QQueryOperations> currencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currency');
    });
  }

  QueryBuilder<GlobalSettings, String, QQueryOperations> nifProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nif');
    });
  }

  QueryBuilder<GlobalSettings, String, QQueryOperations> phonesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'phones');
    });
  }

  QueryBuilder<GlobalSettings, String, QQueryOperations> rcsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rcs');
    });
  }

  QueryBuilder<GlobalSettings, String, QQueryOperations>
      sectorActivityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sectorActivity');
    });
  }

  QueryBuilder<GlobalSettings, String, QQueryOperations> sloganProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'slogan');
    });
  }

  QueryBuilder<GlobalSettings, String, QQueryOperations> statProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stat');
    });
  }
}
