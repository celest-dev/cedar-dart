import 'dart:convert';
import 'dart:io';

import 'package:native_assets_cli/code_assets.dart';

const packageName = 'cedar_ffi';

final IOSink buildLogs = () {
  final logsFile = File.fromUri(
    Platform.script.resolve('.dart_tool/build.log'),
  );
  logsFile.createSync(recursive: true);
  return logsFile.openWrite(mode: FileMode.write)
    ..writeln('Starting build: ${DateTime.now()}');
}();

void main(List<String> args) async {
  try {
    await build(args, (input, output) async {
      buildLogs.writeln(input.json);

      output.addDependency(input.packageRoot.resolve('src/'));

      // Build the Rust code in `src/` to `target/`.
      //
      // Since we're in a workspace, this will default to the repo root which we
      // don't want.
      final cargoOutput = input.packageRoot.resolve('target/');
      await runProcess(
        'cargo',
        ['build', '--release'],
        environment: {
          'CARGO_TARGET_DIR': cargoOutput.toFilePath(),
        },
        workingDirectory: input.packageRoot.resolve('src').toFilePath(),
      );

      final CodeConfig(:targetOS, :targetArchitecture) = input.config.code;
      final binaryName = targetOS.dylibFileName(packageName);
      final binaryOut = cargoOutput.resolve('release/$binaryName');
      if (!File.fromUri(binaryOut).existsSync()) {
        throw Exception('$binaryOut does not exist');
      }
      final nativeAsset = CodeAsset(
        package: packageName,
        name: 'src/ffi/cedar_bindings.ffi.dart',
        linkMode: DynamicLoadingBundled(),
        os: targetOS,
        architecture: targetArchitecture,
        file: binaryOut,
      );
      buildLogs.writeln('Compiled asset: ${nativeAsset.toString()}');
      output.assets.code.add(nativeAsset);
    });
  } finally {
    await buildLogs.flush();
    await buildLogs.close();
  }
}

Future<void> runProcess(
  String exe,
  List<String> args, {
  Map<String, String>? environment,
  String? workingDirectory,
}) async {
  final process = await Process.start(
    exe,
    args,
    environment: environment,
    workingDirectory: workingDirectory,
    includeParentEnvironment: true,
  );
  final stdoutBuffer = StringBuffer();
  final stderrBuffer = StringBuffer();
  final stdoutSub = process.stdout
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    buildLogs.writeln('STDOUT: $line');
    stderrBuffer.writeln(line);
  });
  final stderrSub = process.stderr
      .transform(utf8.decoder)
      .transform(const LineSplitter())
      .listen((line) {
    buildLogs.writeln('STDERR: $line');
    stderrBuffer.writeln(line);
  });
  final (exitCode, _, _) = await (
    process.exitCode,
    stdoutSub.asFuture<void>(),
    stderrSub.asFuture<void>(),
  ).wait;
  await buildLogs.flush();
  if (exitCode != 0) {
    throw ProcessException(
      exe,
      args,
      'STDOUT:\n$stdoutBuffer\n'
      'STDERR:\n$stderrBuffer',
      exitCode,
    );
  }
}
