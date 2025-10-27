// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"bec625ba626c84bf943a0d41a5e268cd0791e194","schema_json":{"":{"entityTypes":{"a":{"tags":{"type":"Boolean"}}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"forbid(\\n  principal == a::\\"+\\",\\n  action,\\n  resource\\n) when {\\n  ((true && ([].contains(\\"\\"))) && true) && false\\n};\\n","should_validate":false,"entities_json":[{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"a","id":"+"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"+"},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":""},"resource":{"type":"a","id":"+"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":"+"},"resource":{"type":"a","id":"+"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":"+"},"resource":{"type":"a","id":"+"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"+"},"resource":{"type":"a","id":"+"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":"+"},"resource":{"type":"a","id":"+"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"+"},"resource":{"type":"a","id":"+"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":"+"},"resource":{"type":"a","id":"+"},"action":{"type":"Action","id":"action"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
