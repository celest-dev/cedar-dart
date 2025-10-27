// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"7f14967dfd5475ad780298d274a0eb3ecdd65eeb","schema_json":{"C000":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["C000::a"],"resourceTypes":["C000::a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"C000::Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"C000::a","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"C000::a","id":""},"resource":{"type":"C000::a","id":""},"action":{"type":"C000::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"C000::a","id":""},"resource":{"type":"C000::a","id":""},"action":{"type":"C000::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"C000::a","id":""},"resource":{"type":"C000::a","id":""},"action":{"type":"C000::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"C000::a","id":""},"resource":{"type":"C000::a","id":""},"action":{"type":"C000::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"C000::a","id":""},"resource":{"type":"C000::a","id":""},"action":{"type":"C000::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"C000::a","id":""},"resource":{"type":"C000::a","id":""},"action":{"type":"C000::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"C000::a","id":""},"resource":{"type":"C000::a","id":""},"action":{"type":"C000::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"C000::a","id":""},"resource":{"type":"C000::a","id":""},"action":{"type":"C000::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
