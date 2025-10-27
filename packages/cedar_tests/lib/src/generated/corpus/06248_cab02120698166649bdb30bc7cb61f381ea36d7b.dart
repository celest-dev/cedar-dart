// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"cab02120698166649bdb30bc7cb61f381ea36d7b","schema_json":{"A":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["A::a"],"resourceTypes":["A::a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal is A::a in A::a::\\"U\$\\",\\n  action in [A::Action::\\"action\\"],\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"A::Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"A::a","id":"U\$"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"A::a","id":"U\$"},"resource":{"type":"A::a","id":"U\$"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"A::a","id":"U\$"},"resource":{"type":"A::a","id":"U\$"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"A::a","id":"U\$"},"resource":{"type":"A::a","id":"U\$"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"A::a","id":"U\$"},"resource":{"type":"A::a","id":"U\$"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"A::a","id":"U\$"},"resource":{"type":"A::a","id":"U\$"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"A::a","id":"U\$"},"resource":{"type":"A::a","id":"U\$"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"A::a","id":"U\$"},"resource":{"type":"A::a","id":"U\$"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"A::a","id":"U\$"},"resource":{"type":"A::a","id":"U\$"},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
