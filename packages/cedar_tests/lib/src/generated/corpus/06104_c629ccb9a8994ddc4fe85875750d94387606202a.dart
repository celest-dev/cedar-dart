// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: file_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:cedar_tests/src/corpus_types.dart';

CedarTest load() {
  const String rawJson =
      '{"name":"c629ccb9a8994ddc4fe85875750d94387606202a","schema_json":{"":{"entityTypes":{"a":{}},"actions":{"쬬":{"memberOf":null,"appliesTo":{"principalTypes":["a"],"resourceTypes":["a"],"context":{"type":"Record","attributes":{}}}}}}},"policies_cedar":"permit(\\n  principal,\\n  action in [Action::\\"쬬\\",Action::\\"쬬\\",Action::\\"쬬\\"],\\n  resource\\n) when {\\n  (true && (resource in a::\\"\\")) && ((if (\\"D\\" like \\"\\") then (if false then \\"222\\\\u{e}\\\\0\\\\0\\" else \\"\\") else (if false then \\"i\\" else \\"an\\\\0\\")) like \\"\\\\0*\\\\u{16}*\\\\n+\\")\\n};\\n","should_validate":true,"entities_json":[{"uid":{"type":"Action","id":"쬬"},"attrs":{},"parents":[]},{"uid":{"type":"a","id":""},"attrs":{},"parents":[]}],"queries":[{"desc":"Request 0","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"쬬"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 1","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"쬬"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 2","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"쬬"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 3","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"쬬"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 4","principal":{"type":"a","id":"~"},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"쬬"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 5","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"쬬"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 6","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"쬬"},"context":{},"decision":"Deny","reasons":[],"errors":[]},{"desc":"Request 7","principal":{"type":"a","id":""},"resource":{"type":"a","id":""},"action":{"type":"Action","id":"쬬"},"context":{},"decision":"Deny","reasons":[],"errors":[]}]}';
  final Map<String, Object?> data = jsonDecode(rawJson) as Map<String, Object?>;
  return CedarTest.fromJson(data);
}
