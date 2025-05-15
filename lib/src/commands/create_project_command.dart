import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class CreateProjectCommand extends Command<int> {
  CreateProjectCommand();
  @override
  String get description =>
      '''Creates a new Flutter project with a clean architecture folder structure.''';
  @override
  String get name => 'create-project';

  static Future<int> runCreate({
    required Logger logger,
    required String projectName,
    String? projectPath,
  }) async {
    final targetDir =
        projectPath != null ? Directory(projectPath) : Directory(projectName);
    final fullProjectDir = projectPath != null
        ? Directory('${targetDir.path}/$projectName')
        : targetDir;
    if (fullProjectDir.existsSync()) {
      logger.err(
        'Project "$projectName" already exists at ${fullProjectDir.path}.',
      );
      return ExitCode.usage.code;
    }
    try {
      logger.info('Creating Flutter project "$projectName"...');
      final useDefaults =
          logger.confirm('Do you want to use the default options?');
      String orgName;
      String stateManagement;
      List<String> platforms;
      String template;
      String starterTemplate;
      if (useDefaults) {
        logger.info('Using default options...');
        orgName = 'com.example';
        stateManagement = 'flutter_bloc';
        platforms = ['android', 'ios', 'web'];
        template = 'app';
        starterTemplate = 'empty';
      } else {
        orgName =
            logger.prompt('Enter the organization name (e.g., com.example):');
        stateManagement = logger.chooseOne(
          'Choose a state management solution:',
          choices: ['flutter_bloc', 'provider', 'riverpod'],
          defaultValue: 'flutter_bloc',
        );
        platforms = logger.chooseAny(
          'Select the platforms to support:',
          choices: ['android', 'ios', 'web', 'linux', 'macos', 'windows'],
          defaultValues: ['android', 'ios', 'web'],
        );
        template = logger.chooseOne(
          'Choose a Flutter project template:',
          choices: ['app', 'package', 'plugin'],
          defaultValue: 'app',
        );
        starterTemplate = logger.chooseOne(
          'Choose a starter template:',
          choices: ['empty', 'counter'],
          defaultValue: 'empty',
        );
      }
      final templateFlag =
          starterTemplate == 'counter' ? '--sample=counter' : '-e';
      final args = [
        'create',
        '--org',
        orgName,
        '--template',
        template,
        '--platforms',
        platforms.join(','),
        templateFlag,
        projectName,
      ];
      final result = await Process.run(
        'flutter',
        args,
        runInShell: true,
        workingDirectory: projectPath,
      );
      if (result.exitCode != 0) {
        logger.err('Failed to create Flutter project: ${result.stderr}');
        return ExitCode.software.code;
      }
      Directory.current = fullProjectDir;
      logger.info('Adding $stateManagement to the project...');
      final pubAddResult = await Process.run(
        'flutter',
        ['pub', 'add', stateManagement],
        runInShell: true,
      );
      if (pubAddResult.exitCode != 0) {
        logger.err('Failed to add $stateManagement: ${pubAddResult.stderr}');
        return ExitCode.software.code;
      }
      logger.info('Setting up clean architecture folder structure...');
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
        readmeFile.writeAsStringSync(
          folderStructure + resources,
          mode: FileMode.append,
        );
      } else {
        readmeFile
            .writeAsStringSync('# $projectName\n\n$folderStructure$resources');
      }
      logger.info('Flutter project "$projectName" created successfully.');
      return ExitCode.success.code;
    } catch (e) {
      logger.err('Failed to create project "$projectName": $e');
      return ExitCode.software.code;
    }
  }
}
