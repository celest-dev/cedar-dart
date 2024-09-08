// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'policy_set.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<PolicySet> _$policySetSerializer = new _$PolicySetSerializer();

class _$PolicySetSerializer implements StructuredSerializer<PolicySet> {
  @override
  final Iterable<Type> types = const [PolicySet, _$PolicySet];
  @override
  final String wireName = 'PolicySet';

  @override
  Iterable<Object?> serialize(Serializers serializers, PolicySet object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'policies',
      serializers.serialize(object.policies,
          specifiedType: const FullType(BuiltMap,
              const [const FullType(String), const FullType(Policy)])),
      'templates',
      serializers.serialize(object.templates,
          specifiedType: const FullType(BuiltMap,
              const [const FullType(String), const FullType(Policy)])),
      'templateLinks',
      serializers.serialize(object.templateLinks,
          specifiedType:
              const FullType(BuiltList, const [const FullType(TemplateLink)])),
    ];

    return result;
  }

  @override
  PolicySet deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new PolicySetBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'policies':
          result.policies.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap,
                  const [const FullType(String), const FullType(Policy)]))!);
          break;
        case 'templates':
          result.templates.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltMap,
                  const [const FullType(String), const FullType(Policy)]))!);
          break;
        case 'templateLinks':
          result.templateLinks.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(TemplateLink)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$PolicySet extends PolicySet {
  @override
  final BuiltMap<String, Policy> policies;
  @override
  final BuiltMap<String, Policy> templates;
  @override
  final BuiltList<TemplateLink> templateLinks;

  factory _$PolicySet([void Function(PolicySetBuilder)? updates]) =>
      (new PolicySetBuilder()..update(updates))._build();

  _$PolicySet._(
      {required this.policies,
      required this.templates,
      required this.templateLinks})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(policies, r'PolicySet', 'policies');
    BuiltValueNullFieldError.checkNotNull(templates, r'PolicySet', 'templates');
    BuiltValueNullFieldError.checkNotNull(
        templateLinks, r'PolicySet', 'templateLinks');
  }

  @override
  PolicySet rebuild(void Function(PolicySetBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PolicySetBuilder toBuilder() => new PolicySetBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PolicySet &&
        policies == other.policies &&
        templates == other.templates &&
        templateLinks == other.templateLinks;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, policies.hashCode);
    _$hash = $jc(_$hash, templates.hashCode);
    _$hash = $jc(_$hash, templateLinks.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PolicySet')
          ..add('policies', policies)
          ..add('templates', templates)
          ..add('templateLinks', templateLinks))
        .toString();
  }
}

class PolicySetBuilder implements Builder<PolicySet, PolicySetBuilder> {
  _$PolicySet? _$v;

  MapBuilder<String, Policy>? _policies;
  MapBuilder<String, Policy> get policies =>
      _$this._policies ??= new MapBuilder<String, Policy>();
  set policies(MapBuilder<String, Policy>? policies) =>
      _$this._policies = policies;

  MapBuilder<String, Policy>? _templates;
  MapBuilder<String, Policy> get templates =>
      _$this._templates ??= new MapBuilder<String, Policy>();
  set templates(MapBuilder<String, Policy>? templates) =>
      _$this._templates = templates;

  ListBuilder<TemplateLink>? _templateLinks;
  ListBuilder<TemplateLink> get templateLinks =>
      _$this._templateLinks ??= new ListBuilder<TemplateLink>();
  set templateLinks(ListBuilder<TemplateLink>? templateLinks) =>
      _$this._templateLinks = templateLinks;

  PolicySetBuilder();

  PolicySetBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _policies = $v.policies.toBuilder();
      _templates = $v.templates.toBuilder();
      _templateLinks = $v.templateLinks.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PolicySet other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$PolicySet;
  }

  @override
  void update(void Function(PolicySetBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PolicySet build() => _build();

  _$PolicySet _build() {
    _$PolicySet _$result;
    try {
      _$result = _$v ??
          new _$PolicySet._(
              policies: policies.build(),
              templates: templates.build(),
              templateLinks: templateLinks.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'policies';
        policies.build();
        _$failedField = 'templates';
        templates.build();
        _$failedField = 'templateLinks';
        templateLinks.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'PolicySet', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
