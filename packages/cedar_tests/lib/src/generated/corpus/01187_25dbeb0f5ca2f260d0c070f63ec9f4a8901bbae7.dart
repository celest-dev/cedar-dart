// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"25dbeb0f5ca2f260d0c070f63ec9f4a8901bbae7","schema_json":{"C":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["C::a"],"resourceTypes":["C::a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"C::a","id":""},"attrs":{},"parents":[]},{"uid":{"type":"C::Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"C::a","id":""},"resource":{"type":"C::a","id":""},"action":{"type":"C::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"C::a","id":""},"resource":{"type":"C::a","id":""},"action":{"type":"C::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"C::a","id":""},"resource":{"type":"C::a","id":""},"action":{"type":"C::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"C::a","id":""},"resource":{"type":"C::a","id":""},"action":{"type":"C::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"C::a","id":""},"resource":{"type":"C::a","id":""},"action":{"type":"C::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"C::a","id":""},"resource":{"type":"C::a","id":""},"action":{"type":"C::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"C::a","id":""},"resource":{"type":"C::a","id":""},"action":{"type":"C::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"C::a","id":""},"resource":{"type":"C::a","id":""},"action":{"type":"C::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
