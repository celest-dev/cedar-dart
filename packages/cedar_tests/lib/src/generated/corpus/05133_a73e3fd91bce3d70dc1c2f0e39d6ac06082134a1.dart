// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"a73e3fd91bce3d70dc1c2f0e39d6ac06082134a1","schema_json":{"":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action in [Action::\\"action\\"],\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"a","id":"0"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
