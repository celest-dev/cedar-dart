// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"664ca9ec7f4103ea1aee29c0ee1b0293529a3fc9","schema_json":{"":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"@o000D00000(\\"\\")\\nforbid(\\n  principal in a::\\"0\\",\\n  action == Action::\\"action\\",\\n  resource in a::\\"0\\"\\n) when {\\n  (true && ((([].isEmpty()) || ([].isEmpty())) || (!(!false)))) && (!false)\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"a","id":"0"},"attrs":{},"parents":[]},{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":"0"},"resource":{"type":"a","id":"0"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
