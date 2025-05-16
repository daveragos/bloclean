import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:bloclean/src/commands/create_feature_command.dart';
import 'package:bloclean/src/commands/create_project_command.dart';
import 'package:mason_logger/mason_logger.dart';

class CreateCommand extends Command<int> {
  CreateCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addFlag(
        'project',
        abbr: 'p',
        help:
            'Create a new Flutter project (can also just provide a name without this flag)',
      )
      ..addMultiOption(
        'feature',
        abbr: 'f',
        help:
            'Create one or more features (can also just provide feature names without this flag)',
        valueHelp: 'feature1 feature2 ...',
      )
      ..addOption(
        'feature-list',
        abbr: 'F',
        help: 'Comma-separated list of feature names to create',
        valueHelp: 'feature1,feature2,...',
      );
  }

  final Logger _logger;

  @override
  String get description => 'Create a new project or feature.';

  @override
  String get name => 'create';

  @override
  String get invocation =>
      'bloclean create [project_name] [feature1 feature2 ...] [options]';

  @override
  String get usage => '''
Create a new Flutter project or features.

USAGE:
  bloclean create my_project
    - Creates a new Flutter project named my_project in the current directory.

  bloclean create my_project path/to/dir
    - Creates a new Flutter project named my_project in the specified path ("path/to/dir").

  bloclean create login profile
    - Creates two features: login and profile.

  bloclean create -p my_project -f login -F login,profile
    - Creates a project and features using explicit flags.

OPTIONS:
  -p, --project         Create a new Flutter project (can also just provide a name)
  -f, --feature         Create one or more features (can also just provide feature names)
  -F, --feature-list    Comma-separated list of feature names to create

If neither -p nor -f is specified:
  - If one name is provided, it is treated as a project name.
  - If two names are provided, the first is the project name and the second is the path.
  - If multiple names are provided, each is treated as a feature name.
''';

  @override
  Future<int> run() async {
    final isProject = argResults?['project'] == true;
    final featureList = (argResults?['feature'] as List<String>? ?? <String>[])
        .where((f) => !f.startsWith('-'))
        .toList();
    final featureListOption = argResults?['feature-list'] as String?;
    final rest = argResults?.rest ?? <String>[];

    // Collect all features to create
    final allFeatures = <String>[...featureList];
    if (featureListOption != null && featureListOption.isNotEmpty) {
      allFeatures.addAll(
        featureListOption
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      );
    }

    // Initialize exit code
    var exitCode = ExitCode.success.code;
    var projectCreated = false;
    var featuresCreated = false;

    // Handle project creation
    String? projectName;
    String? projectPath;

    if (isProject) {
      // Explicit -p flag
      if (rest.isEmpty) {
        _logger.err('Project name is required after -p/--project.');
        return ExitCode.usage.code;
      }
      projectName = rest[0];
      // Check for path as second argument
      if (rest.length > 1 && !rest[1].startsWith('-')) {
        projectPath = rest[1];
      }
    } else if (rest.isNotEmpty && allFeatures.isEmpty) {
      // No flags, infer project from positional arguments
      projectName = rest[0];
      if (rest.length > 1 && !rest[1].startsWith('-')) {
        projectPath = rest[1];
      }
    }

    if (projectName != null) {
      final code = await CreateProjectCommand.runCreate(
        logger: _logger,
        projectName: projectName,
        projectPath: projectPath,
      );
      if (code == ExitCode.success.code) {
        projectCreated = true;
        // Change to project directory to create features
        final targetDir = projectPath != null
            ? Directory(
                Platform.isWindows
                    ? '$projectPath\\$projectName'
                    : '$projectPath/$projectName',
              )
            : Directory(projectName);
        _logger.detail('Attempting to change to directory: ${targetDir.path}');
        if (targetDir.existsSync()) {
          Directory.current = targetDir;
        } else if (allFeatures.isNotEmpty) {
          _logger.err(
            'Project directory "${targetDir.path}" not found after creation. Please ensure the project was created successfully and the path is correct.',
          );
          return ExitCode.software.code;
        }
      } else {
        exitCode = code;
      }
    }

    // Handle feature creation
    if (allFeatures.isNotEmpty) {
      // Check if we're in a Flutter project (pubspec.yaml exists)
      if (!File('pubspec.yaml').existsSync()) {
        _logger.err(
          'No Flutter project found in the current directory. Please run this command inside a Flutter project or create a project first with -p.',
        );
        return ExitCode.usage.code;
      }

      for (final feature in allFeatures) {
        final code = await CreateFeatureCommand.runCreate(
          logger: _logger,
          featureName: feature,
        );
        if (code == ExitCode.success.code) {
          featuresCreated = true;
        } else {
          exitCode = code;
        }
      }
    }

    // Handle case where only positional arguments are provided as features
    if (!isProject &&
        allFeatures.isEmpty &&
        rest.isNotEmpty &&
        rest.length > (projectPath != null ? 2 : 1)) {
      // Check if we're in a Flutter project
      if (!File('pubspec.yaml').existsSync()) {
        _logger.err(
          'No Flutter project found in the current directory. Please run this command inside a Flutter project or create a project first with -p.',
        );
        return ExitCode.usage.code;
      }

      // Treat rest as features (skip project name and path if present)
      final featureStartIndex = projectPath != null
          ? 2
          : projectName != null
              ? 1
              : 0;
      for (final feature in rest.skip(featureStartIndex)) {
        if (!feature.startsWith('-')) {
          final code = await CreateFeatureCommand.runCreate(
            logger: _logger,
            featureName: feature,
          );
          if (code == ExitCode.success.code) {
            featuresCreated = true;
          } else {
            exitCode = code;
          }
        }
      }
    }

    if (!projectCreated && !featuresCreated) {
      _logger.err(
        'No project or feature was created. Please specify a project name, feature names, or use -p/-f/-F options.',
      );
      return ExitCode.usage.code;
    }

    return exitCode;
  }
}
