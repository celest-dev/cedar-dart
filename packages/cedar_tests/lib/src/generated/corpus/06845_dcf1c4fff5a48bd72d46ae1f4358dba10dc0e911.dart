// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"dcf1c4fff5a48bd72d46ae1f4358dba10dc0e911","schema_json":{"":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal in a::\\"k\\",\\n  action == Action::\\"action\\",\\n  resource == a::\\"k\\"\\n) when {\\n  true && (((duration(\\"238251617d\\")) == (duration(\\"0ms\\"))) == false)\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"a","id":"k"},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"k"},"resource":{"type":"a","id":"k"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":"k"},"resource":{"type":"a","id":"k"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":"k"},"resource":{"type":"a","id":"k"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":"k"},"resource":{"type":"a","id":"k"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"k"},"resource":{"type":"a","id":"k"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":"k"},"resource":{"type":"a","id":"k"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"k"},"resource":{"type":"a","id":"k"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":"k"},"resource":{"type":"a","id":"k"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
