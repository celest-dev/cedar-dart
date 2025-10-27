// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"8080b47559e07103e7b78844dac6f6ebe081bfe0","schema_json":{"K":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["K::a"],"resourceTypes":["K::a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action in [K::Action::\\"action\\"],\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"K::a","id":"\\n"},"attrs":{},"parents":[]},{"uid":{"type":"K::Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"K::a","id":"\\n"},"resource":{"type":"K::a","id":"\\n"},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"K::a","id":"\\n"},"resource":{"type":"K::a","id":"\\n"},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"K::a","id":"\\n"},"resource":{"type":"K::a","id":"\\n"},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"K::a","id":"\\n"},"resource":{"type":"K::a","id":"\\n"},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"K::a","id":"\\n"},"resource":{"type":"K::a","id":"\\n"},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"K::a","id":"\\n"},"resource":{"type":"K::a","id":"\\n"},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"K::a","id":"\\n"},"resource":{"type":"K::a","id":"\\n"},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"K::a","id":"\\n"},"resource":{"type":"K::a","id":"\\n"},"action":{"type":"K::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
