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
      '''Creates a new Flutter project with a clean architecture folder structure.''';

  @override
  String get name => 'create-project';

  final Logger _logger;

  @override
  Future<int> run() async {
    final projectName = argResults?['name'] as String?;

    if (projectName == null || projectName.isEmpty) {
      _logger.err(
        '''Project name is required. Use --name or -n to specify the project name.''',
      );
      return ExitCode.usage.code;
    }

    final projectPath = Directory(projectName);

    if (projectPath.existsSync()) {
      _logger.err('Project "$projectName" already exists.');
      return ExitCode.usage.code;
    }

    try {
      _logger.info('Creating Flutter project "$projectName"...');

      final useDefaults =
          _logger.confirm('Do you want to use the default options?');

      String orgName;
      String stateManagement;
      List<String> platforms;
      String template;
      String starterTemplate;

      if (useDefaults) {
        _logger.info('Using default options...');
        orgName = 'com.example';
        stateManagement = 'flutter_bloc';
        platforms = ['android', 'ios', 'web'];
        template = 'app';
        starterTemplate = 'empty';
      } else {
        orgName =
            _logger.prompt('Enter the organization name (e.g., com.example):');
        stateManagement = _logger.chooseOne(
          'Choose a state management solution:',
          choices: ['flutter_bloc', 'provider', 'riverpod'],
          defaultValue: 'flutter_bloc',
        );

        platforms = _logger.chooseAny(
          'Select the platforms to support:',
          choices: ['android', 'ios', 'web', 'linux', 'macos', 'windows'],
          defaultValues: ['android', 'ios', 'web'],
        );

        template = _logger.chooseOne(
          'Choose a Flutter project template:',
          choices: ['app', 'package', 'plugin'],
          defaultValue: 'app',
        );

        starterTemplate = _logger.chooseOne(
          'Choose a starter template:',
          choices: ['empty', 'counter'],
          defaultValue: 'empty',
        );
      }

      // Adjust the template flag for `flutter create` based on the starter template
      final templateFlag =
          starterTemplate == 'counter' ? '--sample=counter' : '-e';

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
        runInShell: true,
      );
      if (result.exitCode != 0) {
        _logger.err('Failed to create Flutter project: ${result.stderr}');
        return ExitCode.software.code;
      }

      // Navigate to the project directory
      Directory.current = projectPath;

      // Add the chosen state management package using `flutter pub add`
      _logger.info('Adding $stateManagement to the project...');
      final pubAddResult = await Process.run(
        'flutter',
        ['pub', 'add', stateManagement],
        runInShell: true,
      );
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
        Directory(dir).createSync(recursive: true);
      }

      // Append folder structure and resources to README.md
      final readmeFile = File('README.md');
      const folderStructure = '''
## Folder Structure

```
lib/
  config/
  core/
    bloc/
    database/
    di/
    error/
    loaders/
    networks/
    shared/
    theme/
    widgets/
  features/
```

''';
      const resources = '''
## Suggested Resources

- [Flutter Clean Architecture Implementation Guide](https://gist.github.com/ahmedyehya92/0257809d6fbd3047e408869f3d747a2c#file-flutter-clean-architecture-implementation-guide-md)
- [Reso Coder Tutorials on Flutter TDD Clean Architecture](https://resocoder.com/category/tutorials/flutter/tdd-clean-architecture/)
- [YouTube: Flutter Clean Architecture by Reso Coder](https://www.youtube.com/watch?v=ELFORM9fmss)

''';

      if (readmeFile.existsSync()) {
        readmeFile.writeAsStringSync(folderStructure + resources,
            mode: FileMode.append,);
      } else {
        readmeFile.writeAsStringSync(
            '# $projectName\n\n$folderStructure$resources',);
      }

      _logger.info('Flutter project "$projectName" created successfully.');
      return ExitCode.success.code;
    } catch (e) {
      _logger.err('Failed to create project "$projectName": $e');
      return ExitCode.software.code;
    }
  }
}
