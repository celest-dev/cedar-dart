// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"fe1d9f7e9edb8a8c7bd62acb117df343a84889ad","schema_json":{"":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"@lH444(\\"\\")\\npermit(\\n  principal in a::\\"\\",\\n  action in [Action::\\"action\\"],\\n  resource in a::\\".bi\\"\\n) when {\\n  true && (!((((datetime(\\"1028-05-12T03:51:39.028-00740\\")).toTime()).toMinutes()) <= 7148113328928521216))\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"a","id":".bi"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":".bi"},"resource":{"type":"a","id":".bi"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":".bi"},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":""},"resource":{"type":"a","id":".bi"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]},{"desc":"Request 5","principal":{"type":"a","id":".bi"},"resource":{"type":"a","id":".bi"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":""},"resource":{"type":"a","id":".bi"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":["policy0"]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
