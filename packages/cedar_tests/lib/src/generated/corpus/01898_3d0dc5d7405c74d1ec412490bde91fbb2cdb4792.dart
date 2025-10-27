// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"3d0dc5d7405c74d1ec412490bde91fbb2cdb4792","schema_json":{"fz::A0":{"entityTypes":{"k":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["fz::A0::k"],"resourceTypes":["fz::A0::k"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"forbid(\\n  principal in fz::A0::k::\\"\\",\\n  action,\\n  resource == fz::A0::k::\\"\\"\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"fz::A0::Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"fz::A0::k","id":""},"resource":{"type":"fz::A0::k","id":""},"action":{"type":"fz::A0::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"fz::A0::k","id":""},"resource":{"type":"fz::A0::k","id":""},"action":{"type":"fz::A0::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"fz::A0::k","id":""},"resource":{"type":"fz::A0::k","id":""},"action":{"type":"fz::A0::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"fz::A0::k","id":""},"resource":{"type":"fz::A0::k","id":""},"action":{"type":"fz::A0::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"fz::A0::k","id":""},"resource":{"type":"fz::A0::k","id":""},"action":{"type":"fz::A0::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"fz::A0::k","id":""},"resource":{"type":"fz::A0::k","id":""},"action":{"type":"fz::A0::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"fz::A0::k","id":""},"resource":{"type":"fz::A0::k","id":""},"action":{"type":"fz::A0::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"fz::A0::k","id":""},"resource":{"type":"fz::A0::k","id":""},"action":{"type":"fz::A0::Action","id":"action"},"context":{},"decision":"Deny","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
