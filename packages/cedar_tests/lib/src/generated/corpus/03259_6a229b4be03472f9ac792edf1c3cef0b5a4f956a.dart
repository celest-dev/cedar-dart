// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"6a229b4be03472f9ac792edf1c3cef0b5a4f956a","schema_json":{"r":{"entityTypes":{"r":{},"r3333333":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["r::r"],"resourceTypes":["r::r"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"r::Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"r::r","id":""},"attrs":{},"parents":[]},{"uid":{"type":"r::r3333333","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"r::r","id":""},"resource":{"type":"r::r","id":""},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"r::r","id":""},"resource":{"type":"r::r","id":""},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"r::r","id":""},"resource":{"type":"r::r","id":""},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"r::r","id":""},"resource":{"type":"r::r","id":""},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"r::r","id":""},"resource":{"type":"r::r","id":""},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"r::r","id":""},"resource":{"type":"r::r","id":""},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"r::r","id":""},"resource":{"type":"r::r","id":""},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"r::r","id":""},"resource":{"type":"r::r","id":""},"action":{"type":"r::Action","id":"action"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
