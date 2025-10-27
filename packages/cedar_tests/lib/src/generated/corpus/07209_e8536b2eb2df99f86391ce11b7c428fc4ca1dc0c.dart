// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"e8536b2eb2df99f86391ce11b7c428fc4ca1dc0c","schema_json":{"":{"entityTypes":{"_":{},"r":{}},"actions":{"dd":{"memberOf":[{"type":"Action","id":"ip"}],"appliesTo":{"principalTypes":["r"],"resourceTypes":["_"],"context":{"type":"Record","attributes":{}}}},"ip":{"memberOf":null,"appliesTo":null}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"Action","id":"dd"},"attrs":{},"parents":[{"type":"Action","id":"ip"}]},{"uid":{"type":"Action","id":"ip"},"attrs":{},"parents":[]},{"uid":{"type":"_","id":""},"attrs":{},"parents":[]},{"uid":{"type":"r","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"r","id":""},"resource":{"type":"_","id":""},"action":{"type":"Action","id":"dd"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"r","id":""},"resource":{"type":"_","id":""},"action":{"type":"Action","id":"dd"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"r","id":""},"resource":{"type":"_","id":""},"action":{"type":"Action","id":"dd"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"r","id":""},"resource":{"type":"_","id":""},"action":{"type":"Action","id":"dd"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"r","id":""},"resource":{"type":"_","id":""},"action":{"type":"Action","id":"dd"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"r","id":""},"resource":{"type":"_","id":""},"action":{"type":"Action","id":"dd"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"r","id":""},"resource":{"type":"_","id":""},"action":{"type":"Action","id":"dd"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"r","id":""},"resource":{"type":"_","id":""},"action":{"type":"Action","id":"dd"},"context":{},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
