// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"fa3d448670a80f66a12adfb2ec64c66269f38784","schema_json":{"K":{"entityTypes":{"a":{}},"actions":{"":{"memberOf":[{"type":"K::Action","id":"}"}],"appliesTo":{"principalTypes":["K::a"],"resourceTypes":["K::a"],"context":{"type":"Record","attributes":{}}}},"}":{"memberOf":null,"appliesTo":null}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"K::Action","id":""},"attrs":{},"parents":[{"type":"K::Action","id":"}"}]},{"uid":{"type":"K::Action","id":"}"},"attrs":{},"parents":[]},{"uid":{"type":"K::a","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"K::a","id":""},"resource":{"type":"K::a","id":""},"action":{"type":"K::Action","id":""},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
