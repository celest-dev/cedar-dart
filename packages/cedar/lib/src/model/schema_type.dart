sealed class CedarType {
  factory CedarType.fromJson(Map<String, Object?> json) {
    switch (json) {
      case {'type': 'Boolean'}:
        return CedarBooleanType(
          required: json['required'] as bool?,
        );
      case {'type': 'String'}:
        return CedarStringType(
          required: json['required'] as bool?,
        );
      case {'type': 'Long'}:
        return CedarLongType(
          required: json['required'] as bool?,
        );
      case {'type': 'Set'}:
        return CedarSetType(
          elementType: CedarType.fromJson(
            json['element'] as Map<String, Object?>,
          ),
          required: json['required'] as bool?,
        );
      case {'type': 'Record'}:
        return CedarRecordType(
          attributes: (json['attributes'] as Map<Object?, Object?>)
              .cast<String, Object?>()
              .map(
                (name, json) => MapEntry(
                  name,
                  CedarType.fromJson(json as Map<String, Object?>),
                ),
              ),
          required: json['required'] as bool?,
          additionalAttributes: json['additionalAttributes'] as bool?,
        );
      case {'type': 'Entity'}:
        return CedarEntityType(
          entityName: json['name'] as String,
          required: json['required'] as bool?,
        );
      case {'type': 'Extension', 'name': 'ipaddr'}:
        return CedarIpAddressType(
          required: json['required'] as bool?,
        );
      case {'type': 'Extension', 'name': 'decimal'}:
        return CedarDecimalType(
          required: json['required'] as bool?,
        );
      case {'type': final String type}:
        if (json.keys.length > 1) {
          throw ArgumentError.value(json, 'json', 'Invalid Cedar type');
        }
        return CedarTypeReference(type: type);
      default:
        throw ArgumentError.value(json, 'json', 'Invalid Cedar type');
    }
  }

  const factory CedarType.boolean({
    bool required,
  }) = CedarBooleanType;

  const factory CedarType.string({
    bool required,
  }) = CedarStringType;

  const factory CedarType.long({
    bool required,
  }) = CedarLongType;

  const factory CedarType.set({
    required CedarType elementType,
    bool required,
  }) = CedarSetType;

  const factory CedarType.record({
    required Map<String, CedarType> attributes,
    bool required,
  }) = CedarRecordType;

  const factory CedarType.entity({
    required String entityName,
    bool required,
  }) = CedarEntityType;

  const factory CedarType.ipAddress({
    bool required,
  }) = CedarIpAddressType;

  const factory CedarType.decimal({
    bool required,
  }) = CedarDecimalType;

  const factory CedarType.reference({
    required String type,
  }) = CedarTypeReference;

  Map<String, Object?> toJson();
}

final class CedarTypeReference implements CedarType {
  const CedarTypeReference({
    required this.type,
  });

  factory CedarTypeReference.fromJson(Map<String, Object?> json) {
    return CedarTypeReference(type: json['type'] as String);
  }

  final String type;

  @override
  Map<String, Object?> toJson() => {
        'type': type,
      };
}

sealed class CedarTypeDefinition implements CedarType {
  const CedarTypeDefinition({
    this.required,
  });

  /// Whether a value of this type is required.
  ///
  /// Defaults to `true`.
  final bool? required;

  const factory CedarTypeDefinition.boolean({
    bool required,
  }) = CedarBooleanType;

  const factory CedarTypeDefinition.string({
    bool required,
  }) = CedarStringType;

  const factory CedarTypeDefinition.long({
    bool required,
  }) = CedarLongType;

  const factory CedarTypeDefinition.set({
    required CedarType elementType,
    bool required,
  }) = CedarSetType;

  const factory CedarTypeDefinition.record({
    required Map<String, CedarType> attributes,
    bool required,
  }) = CedarRecordType;

  const factory CedarTypeDefinition.entity({
    required String entityName,
    bool required,
  }) = CedarEntityType;

  const factory CedarTypeDefinition.ipAddress({
    bool required,
  }) = CedarIpAddressType;

  const factory CedarTypeDefinition.decimal({
    bool required,
  }) = CedarDecimalType;
}

final class CedarBooleanType extends CedarTypeDefinition {
  const CedarBooleanType({
    super.required,
  });

  @override
  Map<String, Object?> toJson() => {
        'type': 'Boolean',
        if (required != null) 'required': required,
      };
}

final class CedarStringType extends CedarTypeDefinition {
  const CedarStringType({
    super.required,
  });

  @override
  Map<String, Object?> toJson() => {
        'type': 'String',
        if (required != null) 'required': required,
      };
}

final class CedarLongType extends CedarTypeDefinition {
  const CedarLongType({
    super.required,
  });

  @override
  Map<String, Object?> toJson() => {
        'type': 'Long',
        if (required != null) 'required': required,
      };
}

final class CedarSetType extends CedarTypeDefinition {
  const CedarSetType({
    required this.elementType,
    super.required,
  });

  /// The type of the elements in the set.
  final CedarType elementType;

  @override
  Map<String, Object?> toJson() => {
        'type': 'Set',
        if (required != null) 'required': required,
        'element': elementType.toJson(),
      };
}

final class CedarRecordType extends CedarTypeDefinition {
  const CedarRecordType({
    required this.attributes,
    super.required,
    this.additionalAttributes,
  });

  final Map<String, CedarType> attributes;
  // TODO: What is this used for?
  final bool? additionalAttributes;

  @override
  Map<String, Object?> toJson() => {
        'type': 'Record',
        if (required != null) 'required': required,
        'attributes': attributes.map(
          (name, type) => MapEntry(name, type.toJson()),
        ),
        if (additionalAttributes != null)
          'additionalAttributes': additionalAttributes,
      };
}

final class CedarEntityType extends CedarTypeDefinition {
  const CedarEntityType({
    required this.entityName,
    super.required,
  });

  /// The namespaced name of the entity type.
  final String entityName;

  @override
  Map<String, Object?> toJson() => {
        'type': 'Entity',
        if (required != null) 'required': required,
        'name': entityName,
      };
}

final class CedarIpAddressType extends CedarTypeDefinition {
  const CedarIpAddressType({
    super.required,
  });

  @override
  Map<String, Object?> toJson() => {
        'type': 'Extension',
        if (required != null) 'required': required,
        'name': 'ipaddr',
      };
}

final class CedarDecimalType extends CedarTypeDefinition {
  const CedarDecimalType({
    super.required,
  });

  @override
  Map<String, Object?> toJson() => {
        'type': 'Extension',
        if (required != null) 'required': required,
        'name': 'decimal',
      };
}
