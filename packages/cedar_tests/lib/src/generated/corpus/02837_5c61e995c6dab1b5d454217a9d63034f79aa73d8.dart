// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"5c61e995c6dab1b5d454217a9d63034f79aa73d8","schema_json":{"c::b":{"entityTypes":{"A":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["c::b::A"],"resourceTypes":["c::b::A"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"c::b::A","id":""},"attrs":{},"parents":[]},{"uid":{"type":"c::b::Action","id":"action"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"c::b::A","id":""},"resource":{"type":"c::b::A","id":""},"action":{"type":"c::b::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"c::b::A","id":""},"resource":{"type":"c::b::A","id":""},"action":{"type":"c::b::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"c::b::A","id":""},"resource":{"type":"c::b::A","id":""},"action":{"type":"c::b::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"c::b::A","id":""},"resource":{"type":"c::b::A","id":""},"action":{"type":"c::b::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"c::b::A","id":""},"resource":{"type":"c::b::A","id":""},"action":{"type":"c::b::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"c::b::A","id":""},"resource":{"type":"c::b::A","id":""},"action":{"type":"c::b::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"c::b::A","id":""},"resource":{"type":"c::b::A","id":""},"action":{"type":"c::b::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"c::b::A","id":""},"resource":{"type":"c::b::A","id":""},"action":{"type":"c::b::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
