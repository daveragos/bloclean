import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class CreateProjectCommand extends Command<int> {
  CreateProjectCommand({required Logger logger}) : _logger = logger {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'The name of the project to create.',
      valueHelp: 'project_name',
    );
  }

  @override
  String get description =>
      'Creates a new Flutter project with a clean architecture folder structure.';

  @override
  String get name => 'create-project';

  final Logger _logger;

  @override
  Future<int> run() async {
    final projectName = argResults?['name'] as String?;

    if (projectName == null || projectName.isEmpty) {
      _logger.err(
          'Project name is required. Use --name or -n to specify the project name.');
      return ExitCode.usage.code;
    }

    final projectPath = Directory(projectName);

    if (projectPath.existsSync()) {
      _logger.err('Project "$projectName" already exists.');
      return ExitCode.usage.code;
    }

    try {
      _logger.info('Creating Flutter project "$projectName"...');

      final orgName =
          _logger.prompt('Enter the organization name (e.g., com.example):');
      final stateManagement = _logger.chooseOne(
        'Choose a state management solution:',
        choices: ['flutter_bloc', 'provider', 'riverpod'],
        defaultValue: 'flutter_bloc',
      );

      final platforms = _logger.chooseAny(
        'Select the platforms to support:',
        choices: ['android', 'ios', 'web', 'linux', 'macos', 'windows'],
        defaultValues: ['android', 'ios', 'web'],
      );

      final template = _logger.chooseOne(
        'Choose a Flutter project template:',
        choices: ['app', 'package', 'plugin'],
        defaultValue: 'app',
      );

      final starterTemplate = _logger.chooseOne(
        'Choose a starter template:',
        choices: ['empty', 'counter'],
        defaultValue: 'empty',
      );

      // Adjust the template flag for `flutter create` based on the starter template
      final templateFlag =
          starterTemplate == 'counter' ? '--sample=counter' : '--no-sample';

      // Run `flutter create` command with org name, platforms, template, and starter template
      final result = await Process.run(
        'flutter',
        [
          'create',
          '--org',
          orgName,
          '--template',
          template,
          '--platforms',
          platforms.join(','),
          templateFlag,
          projectName,
        ],
      );
      if (result.exitCode != 0) {
        _logger.err('Failed to create Flutter project: ${result.stderr}');
        return ExitCode.software.code;
      }

      // Navigate to the project directory
      Directory.current = projectPath;

      // Add the chosen state management package using `flutter pub add`
      _logger.info('Adding $stateManagement to the project...');
      final pubAddResult =
          await Process.run('flutter', ['pub', 'add', stateManagement]);
      if (pubAddResult.exitCode != 0) {
        _logger.err('Failed to add $stateManagement: ${pubAddResult.stderr}');
        return ExitCode.software.code;
      }

      // Create the folder structure
      _logger.info('Setting up clean architecture folder structure...');
      final directories = [
        'lib/config',
        'lib/core/bloc',
        'lib/core/database',
        'lib/core/di',
        'lib/core/error',
        'lib/core/loaders',
        'lib/core/networks',
        'lib/core/shared',
        'lib/core/theme',
        'lib/core/widgets',
        'lib/features',
      ];

      for (final dir in directories) {
        final directory = Directory(dir);
        directory.createSync(recursive: true);
      }

      _logger.info('Flutter project "$projectName" created successfully.');
      return ExitCode.success.code;
    } catch (e) {
      _logger.err('Failed to create project "$projectName": $e');
      return ExitCode.software.code;
    }
  }
}
