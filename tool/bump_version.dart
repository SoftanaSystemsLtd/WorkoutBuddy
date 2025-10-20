#!/usr/bin/env dart
// Bump the version in pubspec.yaml following semver.
// Usage: dart run tool/bump_version.dart <part> [--pre <alpha|beta|rc>]
// parts: major | minor | patch
// Options:
//   --pre <label>   Append or update a pre-release label (e.g. 1.2.3-beta.1)
//   --no-tag        Do not create git tag automatically
//   --no-commit     Do not commit changes
//   --build <meta>  Set build metadata (+meta)
//   --dry-run       Show changes without writing
//
// Examples:
// dart run tool/bump_version.dart minor
// dart run tool/bump_version.dart patch --pre beta
// dart run tool/bump_version.dart patch --pre beta --dry-run
// dart run tool/bump_version.dart patch --build 42

import 'dart:io';

void main(List<String> args) async {
  if (args.isEmpty) {
    _fail('Missing part (major|minor|patch).');
  }
  final part = args.first;
  final rest = args.skip(1).toList();

  var preLabel = _readOption(rest, '--pre');
  final buildMeta = _readOption(rest, '--build');
  final dryRun = rest.contains('--dry-run');
  final noCommit = rest.contains('--no-commit');
  final noTag = rest.contains('--no-tag');

  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    _fail('pubspec.yaml not found. Run from project root.');
  }

  final lines = pubspec.readAsLinesSync();
  final versionIndex = lines.indexWhere((l) => l.trim().startsWith('version:'));
  if (versionIndex == -1) {
    _fail('version: line not found in pubspec.yaml');
  }

  final currentLine = lines[versionIndex];
  final currentVersion = currentLine.split(':').last.trim();

  final parsed = _parseVersion(currentVersion);
  final bumped = _bump(parsed, part, preLabel);
  final finalVersion = _composeVersion(
    bumped,
    preLabel: preLabel,
    build: buildMeta,
  );

  if (dryRun) {
    stdout.writeln('Current: $currentVersion');
    stdout.writeln('Bumped : $finalVersion');
    exit(0);
  }

  lines[versionIndex] = 'version: $finalVersion';
  pubspec.writeAsStringSync(lines.join('\n') + '\n');
  stdout.writeln('Updated version: $currentVersion -> $finalVersion');

  if (!noCommit) {
    await _run('git', ['add', 'pubspec.yaml']);
    await _run('git', ['commit', '-m', 'chore: bump version to $finalVersion']);
  }
  if (!noTag) {
    final tagName = 'v$finalVersion';
    await _run('git', ['tag', tagName]);
    stdout.writeln('Created tag: $tagName');
  }
}

Future<void> _run(String cmd, List<String> args) async {
  final res = await Process.run(cmd, args);
  if (res.exitCode != 0) {
    stderr.writeln(res.stderr);
    _fail('Command failed: $cmd ${args.join(' ')}');
  }
}

void _fail(String msg) {
  stderr.writeln('Error: $msg');
  exit(1);
}

String? _readOption(List<String> args, String name) {
  final idx = args.indexOf(name);
  if (idx == -1 || idx == args.length - 1) return null;
  return args[idx + 1];
}

class SemVer {
  SemVer(this.major, this.minor, this.patch, {this.pre, this.build});
  int major;
  int minor;
  int patch;
  String? pre;
  String? build;
}

SemVer _parseVersion(String v) {
  final buildSplit = v.split('+');
  final build = buildSplit.length > 1 ? buildSplit.sublist(1).join('+') : null;
  final coreAndPre = buildSplit.first.split('-');
  final pre = coreAndPre.length > 1 ? coreAndPre.sublist(1).join('-') : null;
  final core = coreAndPre.first.split('.');
  if (core.length != 3) _fail('Invalid version core: $v');
  return SemVer(
    int.parse(core[0]),
    int.parse(core[1]),
    int.parse(core[2]),
    pre: pre,
    build: build,
  );
}

SemVer _bump(SemVer v, String part, String? preLabel) {
  switch (part) {
    case 'major':
      v = SemVer(v.major + 1, 0, 0);
      break;
    case 'minor':
      v = SemVer(v.major, v.minor + 1, 0);
      break;
    case 'patch':
      v = SemVer(v.major, v.minor, v.patch + 1);
      break;
    default:
      _fail('Unknown part: $part');
  }
  if (preLabel != null) {
    v.pre = '$preLabel.1';
  }
  return v;
}

String _composeVersion(SemVer v, {String? preLabel, String? build}) {
  final buffer = StringBuffer()..write('${v.major}.${v.minor}.${v.patch}');
  if (preLabel != null) {
    if (v.pre != null && v.pre!.startsWith('$preLabel.')) {
      final parts = v.pre!.split('.');
      final num = int.tryParse(parts.last) ?? 1;
      buffer.write('-$preLabel.${num + 1}');
    } else {
      buffer.write('-$preLabel.1');
    }
  } else if (v.pre != null) {
    buffer.write('-${v.pre}');
  }
  if (build != null) buffer.write('+${build}');
  return buffer.toString();
}
