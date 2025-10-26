import 'package:cedar/src/parser/tokenizer.dart';
import 'package:logging/logging.dart';

final Logger _logger = Logger('cedar.SchemaParser');

/// Thrown when Cedar schema parsing fails.
///
/// The message includes a brief description of the problem plus, when
/// available, the token that triggered the error.
class SchemaParseException extends FormatException {
  SchemaParseException(super.message, [super.source, super.offset]);
}

/// Thrown when Cedar schema validation fails after parsing.
class SchemaValidationException extends FormatException {
  SchemaValidationException(super.message);
}

/// Parses Cedar schema IDL (the human-readable syntax) into the canonical JSON
/// representation used by the Cedar SDKs.
final class SchemaParser {
  SchemaParser(this._source, {Uri? sourceUrl})
    : _tokens = Tokenizer(_source, sourceUrl: sourceUrl).tokenize(),
      _sourceUrl = sourceUrl;

  final String _source;
  final Uri? _sourceUrl;
  final List<Token> _tokens;
  var _index = 0;

  /// Parses the source schema and returns a JSON object that matches the shape
  /// expected by [CedarSchema.fromJson].
  Map<String, Object?> parse() {
    if (_logger.isLoggable(Level.FINE)) {
      _logger.fine('Starting schema parse (length: ${_source.length})');
    }
    if (_logger.isLoggable(Level.FINEST)) {
      for (var i = 0; i < _tokens.length; i++) {
        _logger.finest('Token[$i]: ${_tokens[i]}');
      }
    }
    final builder = _SchemaBuilder();
    if (_logger.isLoggable(Level.FINE)) {
      _logger.fine(
        'Beginning namespace body parse at index $_index of ${_tokens.length} tokens',
      );
    }
    _parseNamespaceBody(builder, namespace: '');
    if (_logger.isLoggable(Level.FINE)) {
      _logger.fine('Finished namespace body parse at index $_index');
    }
    _expectEof();
    final resolver = _SchemaResolver(builder, _source, _sourceUrl);
    final result = resolver.build();
    if (_logger.isLoggable(Level.FINE)) {
      _logger.fine('Completed schema parse; namespaces: ${result.length}');
    }
    return result;
  }

  void _parseNamespaceBody(
    _SchemaBuilder builder, {
    required String namespace,
  }) {
    _skipSemicolons();
    while (!_isDone && !_checkOperator('}')) {
      if (_logger.isLoggable(Level.FINEST)) {
        _logger.finest(
          'Namespace "${namespace.isEmpty ? '(root)' : namespace}": loop start at index $_index (token: ${_peek()})',
        );
      }
      _skipAnnotations();
      if (_isDone || _checkOperator('}')) {
        if (_logger.isLoggable(Level.FINEST)) {
          _logger.finest(
            'Namespace "${namespace.isEmpty ? '(root)' : namespace}": exiting loop after annotations at index $_index',
          );
        }
        break;
      }
      final token = _peek();
      if (_logger.isLoggable(Level.FINEST)) {
        _logger.finest(
          'Namespace "${namespace.isEmpty ? '(root)' : namespace}": processing token ${token.text}',
        );
      }
      switch (token.text) {
        case 'namespace':
          _parseNamespace(builder, currentNamespace: namespace);
          break;
        case 'entity':
          _parseEntity(builder.namespace(namespace));
          break;
        case 'action':
          _parseAction(builder.namespace(namespace));
          break;
        case 'type':
          _parseType(builder.namespace(namespace));
          break;
        case ';':
          advance();
          break;
        default:
          _error('Unexpected token "${token.text}"');
      }
      _skipSemicolons();
    }
    if (_logger.isLoggable(Level.FINER)) {
      _logger.finer(
        'Namespace "${namespace.isEmpty ? '(root)' : namespace}" parse complete at index $_index',
      );
    }
  }

  void _parseNamespace(
    _SchemaBuilder builder, {
    required String currentNamespace,
  }) {
    _expectKeyword('namespace');
    final path = _parseTypePath();
    final namespace = path.join();
    if (_logger.isLoggable(Level.FINER)) {
      _logger.finer('Entering namespace "$namespace" from "$currentNamespace"');
    }
    _expectOperator('{');
    _parseNamespaceBody(builder, namespace: namespace);
    _expectOperator('}');
    _skipSemicolons();
  }

  void _parseEntity(_NamespaceBuilder namespace) {
    final keyword = _expectKeyword('entity');
    final names = <String>[];
    names.add(_expectIdent().text);
    while (_matchOperator(',')) {
      names.add(_expectIdent().text);
    }
    if (_logger.isLoggable(Level.FINER)) {
      _logger.finer(
        'Parsing entity ${names.join(', ')} in namespace "${namespace.namespace}"',
      );
    }

    final memberOf = <_TypePath>[];
    if (_matchKeyword('in')) {
      memberOf.addAll(_parseTypePathList());
    }

    List<String>? enumValues;
    _RecordTypeNode? record;
    _TypeNode? tags;

    if (_checkKeyword('enum')) {
      if (memberOf.isNotEmpty) {
        _error('Enumerated entity types cannot specify "in"');
      }
      enumValues = _parseEnumValues();
    } else {
      if (_matchOperator('=')) {
        record = _parseRecordLiteral();
      } else if (_checkOperator('{')) {
        record = _parseRecordLiteral();
      }

      if (_matchKeyword('tags')) {
        tags = _parseTypeNode();
      }
    }

    _expectOperator(';');

    for (final name in names) {
      namespace.entities[name] = _EntityDecl(
        name: name,
        memberOf: memberOf,
        shape: record,
        tagsType: tags,
        enumValues: enumValues,
        token: keyword,
      );
      if (_logger.isLoggable(Level.FINER)) {
        _logger.finer(
          'Finished entity "$name" with memberOf=${memberOf.map((e) => e.join()).toList()} enumValues=${enumValues?.length ?? 0}',
        );
      }
    }
  }

  void _parseAction(_NamespaceBuilder namespace) {
    _expectKeyword('action');
    final names = <String>[];
    do {
      final token = _expectIdentifierOrString();
      names.add(token);
    } while (_matchOperator(','));

    final memberOf = <_EntityUidLiteral>[];
    if (_matchKeyword('in')) {
      memberOf.addAll(_parseEntityUidList());
    }

    _ActionAppliesTo? appliesTo;
    if (_matchKeyword('appliesTo')) {
      appliesTo = _parseAppliesTo();
    }

    _expectOperator(';');

    for (final name in names) {
      namespace.actions[name] = _ActionDecl(
        name: name,
        memberOf: memberOf,
        appliesTo: appliesTo,
      );
      if (_logger.isLoggable(Level.FINER)) {
        _logger.finer(
          'Registered action "$name" in namespace "${namespace.namespace}"',
        );
      }
    }
  }

  void _parseType(_NamespaceBuilder namespace) {
    _expectKeyword('type');
    final nameToken = _expectIdent();
    final name = nameToken.text;
    if (_logger.isLoggable(Level.FINER)) {
      _logger.finer(
        'Parsing common type "$name" in namespace "${namespace.namespace}"',
      );
    }
    _expectOperator('=');
    final type = _parseTypeNode();
    _expectOperator(';');
    namespace.commonTypes[name] = type;
    if (_logger.isLoggable(Level.FINER)) {
      _logger.finer('Registered common type "$name"');
    }
  }

  _ActionAppliesTo _parseAppliesTo() {
    _expectOperator('{');
    final principalTypes = <_TypePath>[];
    final resourceTypes = <_TypePath>[];
    _TypeNode? contextType;

    while (!_checkOperator('}')) {
      final field = _expectIdent().text;
      _expectOperator(':');
      switch (field) {
        case 'principal':
          principalTypes.addAll(_parseTypePathList());
          break;
        case 'resource':
          resourceTypes.addAll(_parseTypePathList());
          break;
        case 'context':
          contextType = _parseTypeNode();
          break;
        default:
          _error('Unknown appliesTo field "$field"');
      }
      if (!_checkOperator('}')) {
        _expectOperator(',');
      }
    }

    _expectOperator('}');
    return _ActionAppliesTo(
      principalTypes: principalTypes,
      resourceTypes: resourceTypes,
      contextType: contextType,
    );
  }

  List<_TypePath> _parseTypePathList() {
    final paths = <_TypePath>[];
    _expectOperator('[');
    if (!_checkOperator(']')) {
      do {
        paths.add(_parseTypePath());
      } while (_matchOperator(','));
    }
    _expectOperator(']');
    return paths;
  }

  List<_EntityUidLiteral> _parseEntityUidList() {
    final list = <_EntityUidLiteral>[];
    _expectOperator('[');
    if (!_checkOperator(']')) {
      do {
        list.add(_parseEntityUid());
      } while (_matchOperator(','));
    }
    _expectOperator(']');
    return list;
  }

  List<String> _parseEnumValues() {
    _expectKeyword('enum');
    _expectOperator('[');
    final values = <String>[];
    if (!_checkOperator(']')) {
      do {
        values.add(_expectString().stringValue);
      } while (_matchOperator(','));
    }
    if (values.isEmpty) {
      _error('Enumerated entity types must declare at least one value');
    }
    _expectOperator(']');
    return values;
  }

  _EntityUidLiteral _parseEntityUid() {
    final segments = <String>[];
    segments.add(_expectIdent().text);
    while (_checkOperator('::')) {
      final nextToken = _tokens[_index + 1];
      if (nextToken.isString) {
        break;
      }
      _expectOperator('::');
      segments.add(_expectIdent().text);
    }
    _expectOperator('::');
    final id = _expectString().stringValue;
    if (_logger.isLoggable(Level.FINEST)) {
      _logger.finest('Parsed entity UID ${segments.join('::')}::"$id"');
    }
    return _EntityUidLiteral(type: _TypePath(segments), id: id);
  }

  _RecordTypeNode _parseRecordLiteral() {
    _expectOperator('{');
    final attributes = <String, _AttributeNode>{};
    var additionalAttributes = false;

    while (!_checkOperator('}')) {
      _skipAnnotations();
      if (_checkOperator('}')) {
        break;
      }
      if (_matchOperator('...')) {
        additionalAttributes = true;
      } else {
        final nameToken = _expectAttributeName();
        var required = true;
        if (_matchOperator('?')) {
          required = false;
        }
        _expectOperator(':');
        final type = _parseTypeNode();
        attributes[nameToken] = _AttributeNode(type: type, required: required);
      }
      if (!_checkOperator('}')) {
        _matchOperator(',');
      }
    }

    _expectOperator('}');
    if (_logger.isLoggable(Level.FINEST)) {
      _logger.finest(
        'Parsed record literal with ${attributes.length} attributes and additionalAttributes=$additionalAttributes',
      );
    }
    return _RecordTypeNode(
      attributes: attributes,
      additionalAttributes: additionalAttributes,
    );
  }

  _TypeNode _parseTypeNode() {
    final token = _peek();
    switch (token.type) {
      case TokenType.ident:
        final ident = advance().text;
        switch (ident) {
          case 'String':
          case 'Long':
          case 'Boolean':
          case 'Bool':
            return _PrimitiveTypeNode(_primitiveKindFor(ident)!);
          case 'Set':
            _expectOperator('<');
            final element = _parseTypeNode();
            _expectOperator('>');
            return _SetTypeNode(elementType: element);
          case 'Record':
            if (_checkOperator('{')) {
              return _parseRecordLiteral();
            }
            return const _RecordTypeNode(
              attributes: {},
              additionalAttributes: false,
            );
        }
        final segments = <String>[ident];
        while (_matchOperator('::')) {
          segments.add(_expectIdent().text);
        }
        final joined = segments.join('::');
        final primitive = _primitiveKindFor(joined);
        if (primitive != null) {
          return _PrimitiveTypeNode(primitive);
        }
        if (_isExtensionName(joined)) {
          return _ExtensionTypeNode(joined);
        }
        return _PathTypeNode(_TypePath(segments));
      case TokenType.operator when token.text == '{':
        return _parseRecordLiteral();
      case TokenType.operator when token.text == '__cedar::':
        advance();
        final ident = _expectIdent();
        return _ExtensionTypeNode('__cedar::${ident.text}');
      default:
        if (token.text == '__cedar::') {
          advance();
          final next = _expectIdent();
          return _ExtensionTypeNode('__cedar::${next.text}');
        }
        _error('Unexpected token "${token.text}" in type expression');
    }
  }

  PrimitiveKind? _primitiveKindFor(String name) {
    switch (name) {
      case 'String':
      case '__cedar::String':
        return PrimitiveKind.string;
      case 'Long':
      case '__cedar::Long':
        return PrimitiveKind.long;
      case 'Boolean':
      case 'Bool':
      case '__cedar::Bool':
        return PrimitiveKind.boolean;
    }
    return null;
  }

  String _expectAttributeName() {
    final token = _peek();
    switch (token.type) {
      case TokenType.ident:
        advance();
        return token.text;
      case TokenType.string:
        advance();
        return token.stringValue;
      default:
        _error('Expected attribute name');
    }
  }

  _TypePath _parseTypePath() {
    final segments = <String>[];
    final first = _expectIdent();
    segments.add(first.text);
    while (_matchOperator('::')) {
      final next = _expectIdent();
      segments.add(next.text);
    }
    return _TypePath(segments);
  }

  bool get _isDone => _peek().isEof;

  Token _peek() => _tokens[_index];

  Token advance() {
    if (_isDone) {
      return _peek();
    }
    return _tokens[_index++];
  }

  bool _matchOperator(String operator) {
    if (_checkOperator(operator)) {
      advance();
      return true;
    }
    return false;
  }

  bool _checkOperator(String operator) {
    if (_isDone) {
      return false;
    }
    return _peek().text == operator;
  }

  bool _matchKeyword(String keyword) {
    if (_checkKeyword(keyword)) {
      advance();
      return true;
    }
    return false;
  }

  bool _checkKeyword(String keyword) {
    if (_isDone) {
      return false;
    }
    final token = _peek();
    return token.type == TokenType.ident && token.text == keyword;
  }

  Token _expectKeyword(String keyword) {
    final token = _peek();
    if (token.type == TokenType.ident && token.text == keyword) {
      return advance();
    }
    _error('Expected "$keyword"');
  }

  void _expectOperator(String operator) {
    if (!_matchOperator(operator)) {
      _error('Expected "$operator"');
    }
  }

  Token _expectIdent() {
    final token = _peek();
    if (token.type == TokenType.ident) {
      return advance();
    }
    _error('Expected identifier');
  }

  Token _expectString() {
    final token = _peek();
    if (token.isString) {
      return advance();
    }
    _error('Expected string literal');
  }

  String _expectIdentifierOrString() {
    final token = _peek();
    if (token.type == TokenType.ident) {
      advance();
      return token.text;
    }
    if (token.isString) {
      advance();
      return token.stringValue;
    }
    _error('Expected identifier or string');
  }

  void _expectEof() {
    if (_logger.isLoggable(Level.FINE)) {
      _logger.fine('Expecting EOF at token index $_index (${_peek().text})');
    }
    if (!_peek().isEof) {
      _error('Unexpected content after schema');
    }
  }

  void _skipAnnotations() {
    while (_matchOperator('@')) {
      _expectIdent();
      if (_matchOperator('(')) {
        if (_peek().isString) {
          advance();
        }
        _expectOperator(')');
      }
    }
  }

  void _skipSemicolons() {
    while (_matchOperator(';')) {
      // no-op
    }
  }

  Never _error(String message) {
    final token = _peek();
    throw SchemaParseException(
      '$message at token "${token.text}"',
      _source,
      token.span.start.offset,
    );
  }
}

// ---------------------------------------------------------------------------
// Internal model used during parsing before conversion to JSON.

enum PrimitiveKind { boolean, string, long }

sealed class _TypeNode {
  const _TypeNode();
}

final class _PrimitiveTypeNode extends _TypeNode {
  const _PrimitiveTypeNode(this.kind);
  final PrimitiveKind kind;
}

final class _SetTypeNode extends _TypeNode {
  const _SetTypeNode({required this.elementType});
  final _TypeNode elementType;
}

final class _RecordTypeNode extends _TypeNode {
  const _RecordTypeNode({
    required this.attributes,
    required this.additionalAttributes,
  });
  final Map<String, _AttributeNode> attributes;
  final bool additionalAttributes;
}

final class _PathTypeNode extends _TypeNode {
  const _PathTypeNode(this.path);
  final _TypePath path;
}

final class _ExtensionTypeNode extends _TypeNode {
  const _ExtensionTypeNode(this.name);
  final String name;
}

final class _AttributeNode {
  const _AttributeNode({required this.type, required this.required});
  final _TypeNode type;
  final bool required;
}

final class _EntityDecl {
  const _EntityDecl({
    required this.name,
    required this.memberOf,
    required this.shape,
    required this.tagsType,
    required this.enumValues,
    required this.token,
  });

  final String name;
  final List<_TypePath> memberOf;
  final _RecordTypeNode? shape;
  final _TypeNode? tagsType;
  final List<String>? enumValues;
  final Token token;
}

final class _ActionDecl {
  const _ActionDecl({
    required this.name,
    required this.memberOf,
    required this.appliesTo,
  });

  final String name;
  final List<_EntityUidLiteral> memberOf;
  final _ActionAppliesTo? appliesTo;
}

final class _ActionAppliesTo {
  const _ActionAppliesTo({
    required this.principalTypes,
    required this.resourceTypes,
    required this.contextType,
  });

  final List<_TypePath> principalTypes;
  final List<_TypePath> resourceTypes;
  final _TypeNode? contextType;
}

final class _EntityUidLiteral {
  const _EntityUidLiteral({required this.type, required this.id});
  final _TypePath type;
  final String id;
}

final class _TypePath {
  const _TypePath(this.segments);
  final List<String> segments;

  String join() => segments.join('::');
}

final class _SchemaBuilder {
  final Map<String, _NamespaceBuilder> namespaces = {};

  _NamespaceBuilder namespace(String name) {
    return namespaces.putIfAbsent(
      name,
      () => _NamespaceBuilder(namespace: name),
    );
  }
}

final class _NamespaceBuilder {
  _NamespaceBuilder({required this.namespace});

  final String namespace;
  final Map<String, _EntityDecl> entities = {};
  final Map<String, _ActionDecl> actions = {};
  final Map<String, _TypeNode> commonTypes = {};
}

// ---------------------------------------------------------------------------
// Validation & JSON conversion.

final class _SchemaResolver {
  _SchemaResolver(this.builder, this.source, this.sourceUrl);

  final _SchemaBuilder builder;
  final String source;
  final Uri? sourceUrl;

  Map<String, Object?> build() {
    if (_logger.isLoggable(Level.FINE)) {
      _logger.fine('Resolving parsed schema into JSON structure');
    }
    final errors = <String>[];
    final entityIndex = _buildEntityIndex();
    final typeIndex = _buildTypeIndex();
    if (_logger.isLoggable(Level.FINER)) {
      _logger.finer(
        'Entity index contains ${entityIndex.length} entries; type index contains ${typeIndex.length} entries',
      );
    }

    final result = <String, Object?>{};
    for (final entry in builder.namespaces.entries) {
      final namespaceName = entry.key;
      final namespace = entry.value;
      if (_logger.isLoggable(Level.FINER)) {
        _logger.finer('Building namespace "$namespaceName"');
      }
      final entitiesJson = <String, Object?>{};
      final actionsJson = <String, Object?>{};
      final commonTypesJson = <String, Object?>{};

      for (final entityEntry in namespace.entities.entries) {
        final entity = entityEntry.value;
        if (_logger.isLoggable(Level.FINEST)) {
          _logger.finest(
            'Resolving entity "${entity.name}" in namespace "$namespaceName"',
          );
        }
        final qualifiedName = _qualifiedName(namespaceName, entity.name);
        final memberOfTypes = <String>[];
        for (final path in entity.memberOf) {
          final resolved = _resolveEntityType(path, namespaceName, entityIndex);
          if (resolved == null) {
            errors.add(
              'Unknown entity type "${path.join()}" in memberOf for $qualifiedName',
            );
          } else {
            memberOfTypes.add(resolved);
          }
        }

        Map<String, Object?>? shapeJson;
        Map<String, Object?>? tagsJson;

        final entityJson = <String, Object?>{};
        if (memberOfTypes.isNotEmpty) {
          if (entity.enumValues != null) {
            errors.add(
              'Enumerated entity type $qualifiedName cannot specify memberOf',
            );
          } else {
            entityJson['memberOfTypes'] = memberOfTypes;
          }
        }

        if (entity.enumValues case final values?) {
          if (values.isEmpty) {
            errors.add(
              'Enumerated entity type $qualifiedName must declare at least one value',
            );
          } else {
            entityJson['enum'] = values;
          }
          if (entity.shape != null) {
            errors.add(
              'Enumerated entity type $qualifiedName cannot declare a shape',
            );
          }
          if (entity.tagsType != null) {
            errors.add(
              'Enumerated entity type $qualifiedName cannot declare tags',
            );
          }
        } else {
          if (entity.shape case final record?) {
            shapeJson = _resolveRecord(
              record,
              namespaceName,
              entityIndex,
              typeIndex,
              errors,
              context: 'entity ${entity.name}',
            );
          }
          if (entity.tagsType case final tagsType?) {
            tagsJson = _resolveType(
              tagsType,
              namespaceName,
              entityIndex,
              typeIndex,
              errors,
              required: true,
              context: 'tags of entity $qualifiedName',
            );
          }
        }

        if (shapeJson != null) {
          entityJson['shape'] = shapeJson;
        }
        if (tagsJson != null) {
          entityJson['tags'] = tagsJson;
        }

        entitiesJson[entity.name] = entityJson;
      }

      for (final actionEntry in namespace.actions.entries) {
        final action = actionEntry.value;
        if (_logger.isLoggable(Level.FINEST)) {
          _logger.finest(
            'Resolving action "${action.name}" in namespace "$namespaceName"',
          );
        }
        final memberOfJson = <Map<String, Object?>>[];
        for (final literal in action.memberOf) {
          final type = _resolveEntityType(
            literal.type,
            namespaceName,
            entityIndex,
          );
          if (type == null) {
            errors.add(
              'Unknown entity type "${literal.type.join()}" in action memberOf for ${_qualifiedName(namespaceName, action.name)}',
            );
          } else {
            memberOfJson.add({'type': type, 'id': literal.id});
          }
        }

        Map<String, Object?>? appliesToJson;
        if (action.appliesTo case final appliesTo?) {
          final principal = <String>[];
          for (final path in appliesTo.principalTypes) {
            final resolved = _resolveEntityType(
              path,
              namespaceName,
              entityIndex,
            );
            if (resolved == null) {
              errors.add(
                'Unknown principal entity type "${path.join()}" for action ${_qualifiedName(namespaceName, action.name)}',
              );
            } else {
              principal.add(resolved);
            }
          }
          final resource = <String>[];
          for (final path in appliesTo.resourceTypes) {
            final resolved = _resolveEntityType(
              path,
              namespaceName,
              entityIndex,
            );
            if (resolved == null) {
              errors.add(
                'Unknown resource entity type "${path.join()}" for action ${_qualifiedName(namespaceName, action.name)}',
              );
            } else {
              resource.add(resolved);
            }
          }

          Map<String, Object?>? contextJson;
          if (appliesTo.contextType != null) {
            contextJson = _resolveType(
              appliesTo.contextType!,
              namespaceName,
              entityIndex,
              typeIndex,
              errors,
              required: true,
              context:
                  'context of action ${_qualifiedName(namespaceName, action.name)}',
            );
            if (contextJson != null &&
                !_isRecordLikeType(
                  appliesTo.contextType!,
                  namespaceName,
                  entityIndex,
                  typeIndex,
                )) {
              errors.add(
                'Context for action ${_qualifiedName(namespaceName, action.name)} must be a record',
              );
            }
          }

          appliesToJson = {
            if (principal.isNotEmpty) 'principalTypes': principal,
            if (resource.isNotEmpty) 'resourceTypes': resource,
            if (contextJson != null) 'context': contextJson,
          };
        }

        actionsJson[action.name] = {
          if (memberOfJson.isNotEmpty) 'memberOf': memberOfJson,
          if (appliesToJson != null) 'appliesTo': appliesToJson,
        };
      }

      for (final commonTypeEntry in namespace.commonTypes.entries) {
        if (_logger.isLoggable(Level.FINEST)) {
          _logger.finest(
            'Resolving common type "${commonTypeEntry.key}" in namespace "$namespaceName"',
          );
        }
        final resolved = _resolveType(
          commonTypeEntry.value,
          namespaceName,
          entityIndex,
          typeIndex,
          errors,
          required: true,
          context: 'type ${_qualifiedName(namespaceName, commonTypeEntry.key)}',
        );
        if (resolved != null) {
          commonTypesJson[commonTypeEntry.key] = resolved;
        }
      }

      result[namespaceName] = {
        if (entitiesJson.isNotEmpty) 'entityTypes': entitiesJson,
        if (actionsJson.isNotEmpty) 'actions': actionsJson,
        if (commonTypesJson.isNotEmpty) 'commonTypes': commonTypesJson,
      };
    }
    if (_logger.isLoggable(Level.FINE)) {
      _logger.fine(
        'Schema resolution complete; emitting JSON for ${result.length} namespaces',
      );
    }

    if (errors.isNotEmpty) {
      throw SchemaValidationException(errors.join('\n'));
    }
    return result;
  }

  Map<String, _EntityDecl> _buildEntityIndex() {
    final map = <String, _EntityDecl>{};
    for (final entry in builder.namespaces.entries) {
      final namespace = entry.key;
      for (final entityEntry in entry.value.entities.entries) {
        map[_qualifiedName(namespace, entityEntry.key)] = entityEntry.value;
      }
    }
    return map;
  }

  Map<String, _TypeNode> _buildTypeIndex() {
    final map = <String, _TypeNode>{};
    for (final entry in builder.namespaces.entries) {
      final namespace = entry.key;
      for (final typeEntry in entry.value.commonTypes.entries) {
        map[_qualifiedName(namespace, typeEntry.key)] = typeEntry.value;
      }
    }
    return map;
  }

  Map<String, Object?>? _resolveType(
    _TypeNode node,
    String namespace,
    Map<String, _EntityDecl> entityIndex,
    Map<String, _TypeNode> typeIndex,
    List<String> errors, {
    required bool required,
    required String context,
    Set<String>? seen,
  }) {
    seen ??= <String>{};
    switch (node) {
      case _PrimitiveTypeNode(kind: final kind):
        final json = switch (kind) {
          PrimitiveKind.boolean => {'type': 'Boolean'},
          PrimitiveKind.string => {'type': 'String'},
          PrimitiveKind.long => {'type': 'Long'},
        };
        return _withRequired(json, required);
      case _ExtensionTypeNode(name: final name):
        final extension = _normalizeExtensionName(name);
        if (extension == null) {
          errors.add('Unsupported extension type "$name" in $context');
          return null;
        }
        return _withRequired({
          'type': 'Extension',
          'name': extension,
        }, required);
      case _RecordTypeNode(:final attributes, :final additionalAttributes):
        final attrsJson = <String, Object?>{};
        for (final attrEntry in attributes.entries) {
          final attrType = _resolveType(
            attrEntry.value.type,
            namespace,
            entityIndex,
            typeIndex,
            errors,
            required: attrEntry.value.required,
            context: '$context attribute ${attrEntry.key}',
            seen: seen,
          );
          if (attrType != null) {
            attrsJson[attrEntry.key] = attrType;
          }
        }
        return _withRequired({
          'type': 'Record',
          'attributes': attrsJson,
          if (additionalAttributes) 'additionalAttributes': true,
        }, required);
      case _SetTypeNode(elementType: final element):
        final elementJson = _resolveType(
          element,
          namespace,
          entityIndex,
          typeIndex,
          errors,
          required: true,
          context: '$context (set element)',
          seen: seen,
        );
        if (elementJson == null) {
          return null;
        }
        return _withRequired({'type': 'Set', 'element': elementJson}, required);
      case _PathTypeNode(path: final path):
        final resolved = _resolvePath(path, namespace, entityIndex, typeIndex);
        if (resolved is _EntityResolvedPath) {
          return _withRequired({
            'type': 'Entity',
            'name': resolved.name,
          }, required);
        }
        if (resolved is _CommonTypeResolvedPath) {
          final typeName = resolved.name;
          if (!seen.add(typeName)) {
            errors.add(
              'Recursive type reference detected for $typeName in $context',
            );
            return null;
          }
          final referenced = typeIndex[typeName];
          if (referenced == null) {
            errors.add('Unknown type reference "${path.join()}" in $context');
            seen.remove(typeName);
            return null;
          }
          final aliasJson = _resolveType(
            referenced,
            _namespaceOf(typeName),
            entityIndex,
            typeIndex,
            errors,
            required: true,
            context: 'type $typeName',
            seen: seen,
          );
          seen.remove(typeName);
          if (aliasJson == null) {
            return null;
          }
          if (_namespaceOf(typeName) == namespace) {
            return _withRequired({'type': _basename(typeName)}, required);
          }
          return _withRequired({'type': typeName}, required);
        }
        if (_isPrimitive(path.join())) {
          final primitive = _parsePrimitive(path.join());
          return _withRequired({'type': primitive}, required);
        }
        if (_isExtensionName(path.join())) {
          final extension = _normalizeExtensionName(path.join());
          if (extension == null) {
            errors.add(
              'Unsupported extension type "${path.join()}" in $context',
            );
            return null;
          }
          return _withRequired({
            'type': 'Extension',
            'name': extension,
          }, required);
        }
        errors.add('Unknown type "${path.join()}" in $context');
        return null;
    }
  }

  Map<String, Object?> _resolveRecord(
    _RecordTypeNode record,
    String namespace,
    Map<String, _EntityDecl> entityIndex,
    Map<String, _TypeNode> typeIndex,
    List<String> errors, {
    required String context,
  }) {
    return _resolveType(
      record,
      namespace,
      entityIndex,
      typeIndex,
      errors,
      required: true,
      context: context,
    )!;
  }

  _ResolvedPath? _resolvePath(
    _TypePath path,
    String currentNamespace,
    Map<String, _EntityDecl> entityIndex,
    Map<String, _TypeNode> typeIndex,
  ) {
    final candidates = _candidateNames(path, currentNamespace);
    for (final candidate in candidates) {
      if (entityIndex.containsKey(candidate) ||
          _isImplicitEntityType(candidate)) {
        return _ResolvedPath.entity(candidate);
      }
      if (typeIndex.containsKey(candidate)) {
        return _ResolvedPath.commonType(candidate);
      }
    }
    return null;
  }

  Iterable<String> _candidateNames(
    _TypePath path,
    String currentNamespace,
  ) sync* {
    final joined = path.join();
    if (path.segments.length > 1) {
      yield joined;
    } else {
      if (currentNamespace.isNotEmpty) {
        yield '$currentNamespace::$joined';
      }
      yield joined;
    }
  }

  String? _resolveEntityType(
    _TypePath path,
    String currentNamespace,
    Map<String, _EntityDecl> entityIndex,
  ) {
    final candidates = _candidateNames(path, currentNamespace);
    for (final candidate in candidates) {
      if (entityIndex.containsKey(candidate) ||
          _isImplicitEntityType(candidate)) {
        return candidate;
      }
    }
    return null;
  }

  bool _isImplicitEntityType(String candidate) {
    return _basename(candidate) == 'Action';
  }

  Map<String, Object?> _withRequired(Map<String, Object?> json, bool required) {
    if (!required) {
      json = Map<String, Object?>.from(json);
      json['required'] = false;
    }
    return json;
  }

  bool _isRecordLikeType(
    _TypeNode node,
    String namespace,
    Map<String, _EntityDecl> entityIndex,
    Map<String, _TypeNode> typeIndex, {
    Set<String>? seen,
  }) {
    switch (node) {
      case _RecordTypeNode():
        return true;
      case _PathTypeNode(path: final path):
        final resolved = _resolvePath(path, namespace, entityIndex, typeIndex);
        if (resolved is _CommonTypeResolvedPath) {
          final typeName = resolved.name;
          seen ??= <String>{};
          if (!seen.add(typeName)) {
            return false;
          }
          final target = typeIndex[typeName];
          if (target == null) {
            seen.remove(typeName);
            return false;
          }
          final result = _isRecordLikeType(
            target,
            _namespaceOf(typeName),
            entityIndex,
            typeIndex,
            seen: seen,
          );
          seen.remove(typeName);
          return result;
        }
        return false;
      default:
        return false;
    }
  }

  bool _isPrimitive(String name) {
    const primitives = {
      'String',
      '__cedar::String',
      'Long',
      '__cedar::Long',
      'Boolean',
      'Bool',
      '__cedar::Bool',
    };
    return primitives.contains(name);
  }

  String _parsePrimitive(String name) {
    switch (name) {
      case 'String':
      case '__cedar::String':
        return 'String';
      case 'Long':
      case '__cedar::Long':
        return 'Long';
      case 'Bool':
      case 'Boolean':
      case '__cedar::Bool':
        return 'Boolean';
      default:
        return name;
    }
  }

  String _qualifiedName(String namespace, String name) {
    if (namespace.isEmpty) {
      return name;
    }
    return '$namespace::$name';
  }

  String _namespaceOf(String qualifiedName) {
    final index = qualifiedName.lastIndexOf('::');
    if (index == -1) {
      return '';
    }
    return qualifiedName.substring(0, index);
  }

  String _basename(String qualifiedName) {
    final index = qualifiedName.lastIndexOf('::');
    if (index == -1) {
      return qualifiedName;
    }
    return qualifiedName.substring(index + 2);
  }
}

sealed class _ResolvedPath {
  const _ResolvedPath();

  factory _ResolvedPath.entity(String name) = _EntityResolvedPath;
  factory _ResolvedPath.commonType(String name) = _CommonTypeResolvedPath;
}

final class _EntityResolvedPath extends _ResolvedPath {
  const _EntityResolvedPath(this.name);
  final String name;
}

final class _CommonTypeResolvedPath extends _ResolvedPath {
  const _CommonTypeResolvedPath(this.name);
  final String name;
}

const Set<String> _knownExtensionNames = {
  'ipaddr',
  '__cedar::ipaddr',
  'decimal',
  '__cedar::decimal',
  'datetime',
  '__cedar::datetime',
  'duration',
  '__cedar::duration',
};

bool _isExtensionName(String name) => _knownExtensionNames.contains(name);

String? _normalizeExtensionName(String name) {
  switch (name) {
    case 'ipaddr':
    case '__cedar::ipaddr':
      return 'ipaddr';
    case 'decimal':
    case '__cedar::decimal':
      return 'decimal';
    case 'datetime':
    case '__cedar::datetime':
      return 'datetime';
    case 'duration':
    case '__cedar::duration':
      return 'duration';
  }
  return null;
}
