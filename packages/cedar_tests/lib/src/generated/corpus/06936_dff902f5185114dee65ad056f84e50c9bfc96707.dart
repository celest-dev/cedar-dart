// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"dff902f5185114dee65ad056f84e50c9bfc96707","schema_json":{"m":{"entityTypes":{"a":{"tags":{"type":"Entity","name":"m::a"}}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["m::a"],"resourceTypes":["m::a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"m::Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"m::a","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"m::a","id":""},"resource":{"type":"m::a","id":""},"action":{"type":"m::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"m::a","id":""},"resource":{"type":"m::a","id":""},"action":{"type":"m::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"m::a","id":""},"resource":{"type":"m::a","id":""},"action":{"type":"m::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"m::a","id":""},"resource":{"type":"m::a","id":""},"action":{"type":"m::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"m::a","id":""},"resource":{"type":"m::a","id":""},"action":{"type":"m::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"m::a","id":""},"resource":{"type":"m::a","id":""},"action":{"type":"m::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"m::a","id":""},"resource":{"type":"m::a","id":""},"action":{"type":"m::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"m::a","id":""},"resource":{"type":"m::a","id":""},"action":{"type":"m::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
