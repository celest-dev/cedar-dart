// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"c66748f76919e9d4b2e6cc43ca61840abba8817e","schema_json":{"":{"entityTypes":{"A0":{},"v0":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["v0"],"resourceTypes":["v0"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"v0","id":""},"attrs":{},"parents":[]},{"uid":{"type":"A0","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"v0","id":""},"resource":{"type":"v0","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"v0","id":""},"resource":{"type":"v0","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"v0","id":""},"resource":{"type":"v0","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"v0","id":""},"resource":{"type":"v0","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"v0","id":""},"resource":{"type":"v0","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"v0","id":""},"resource":{"type":"v0","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"v0","id":""},"resource":{"type":"v0","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"v0","id":""},"resource":{"type":"v0","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
