// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"a979ef10cc6f6a36df6b8a323307ee3bb2e2db9c","schema_json":{"A":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["A::a"],"resourceTypes":["A::a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"A::Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"A::a","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"A::a","id":""},"resource":{"type":"A::a","id":""},"action":{"type":"A::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
