// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"e63859727cd607d96dbd28881a8630a3ec835804","schema_json":{"":{"entityTypes":{"a":{}},"actions":{"action":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{"i":{"type":"Record","required":false,"attributes":{}}}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action,\\n  resource\\n) when {\\n  true\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"Action","id":"action"},"attrs":{},"parents":[]},{"uid":{"type":"a","id":"5an"},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":"5an"},"resource":{"type":"a","id":"5an"},"action":{"type":"Action","id":"action"},"context":{"i":{}},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":"5an"},"resource":{"type":"a","id":"5an"},"action":{"type":"Action","id":"action"},"context":{"i":{}},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":"5an"},"resource":{"type":"a","id":"5an"},"action":{"type":"Action","id":"action"},"context":{"i":{}},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":"5an"},"resource":{"type":"a","id":"5an"},"action":{"type":"Action","id":"action"},"context":{"i":{}},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"5an"},"resource":{"type":"a","id":"5an"},"action":{"type":"Action","id":"action"},"context":{"i":{}},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":"5an"},"resource":{"type":"a","id":"5an"},"action":{"type":"Action","id":"action"},"context":{"i":{}},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":"5an"},"resource":{"type":"a","id":"5an"},"action":{"type":"Action","id":"action"},"context":{"i":{}},"decision":"Allow","reasons":["policy0"],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":"5an"},"resource":{"type":"a","id":"5an"},"action":{"type":"Action","id":"action"},"context":{"i":{}},"decision":"Allow","reasons":["policy0"],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
