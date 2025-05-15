import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:bloclean/src/command_runner.dart';
import 'package:bloclean/src/version.dart';
import 'package:mason_logger/mason_logger.dart';


/// {@template update_command}
/// A command which updates the CLI.
/// {@endtemplate}

/// {@macro update_command}
UpdateCommand({required Logger logger}) : _logger = logger;

final Logger _logger;

  @override
  String get description => 'Update the CLI from the GitHub repository.';

  static const String commandName = 'update';

  @override
  String get name => commandName;

  @override
  Future<int> run() async {
    _logger.info('Attempting to update bloclean from GitHub...');

    // Try to find the global package path
    final whichResult = await Process.run('which', ['bloclean'], runInShell: true);
    if (whichResult.exitCode != 0) {
      _logger.err('Could not find the bloclean executable in your PATH.');
      _logger.info('Please ensure bloclean is activated globally.');
      return ExitCode.software.code;
    }

    // Try to find the install directory (assume user cloned and activated from a path)
    // This is a best-effort guess: user should have activated from a local path
    final envResult = await Process.run('dart', ['pub', 'global', 'list'], runInShell: true);
    if (envResult.exitCode != 0 || !envResult.stdout.toString().contains('bloclean')) {
      _logger.err('bloclean is not installed as a global package.');
      return ExitCode.software.code;
    }

    // Try to get the path from pub cache (not reliable for path activation)
    // Instead, ask user to provide the path if not found
    // For now, assume current directory is the repo
    final currentDir = Directory.current.path;
    if (!File('$currentDir/pubspec.yaml').existsSync()) {
      _logger.err('Could not find pubspec.yaml in the current directory.');
      _logger.info('Please run this command from the bloclean repository directory.');
      return ExitCode.software.code;
    }

    // Pull latest changes
    final pullResult = await Process.run('git', ['pull'], workingDirectory: currentDir, runInShell: true);
    if (pullResult.exitCode != 0) {
      _logger.err('Failed to pull latest changes from GitHub.');
      _logger.err(pullResult.stderr.toString());
      return ExitCode.software.code;
    }
    _logger.info('Successfully pulled latest changes.');

    // Re-activate globally
    final activateResult = await Process.run(
      'dart',
      ['pub', 'global', 'activate', '--source=path', currentDir],
      runInShell: true,
    );
    if (activateResult.exitCode != 0) {
      _logger.err('Failed to activate bloclean globally.');
      _logger.err(activateResult.stderr.toString());
      return ExitCode.software.code;
    }
    _logger.info('bloclean has been updated and re-activated globally!');
    return ExitCode.success.code;
  }
}
