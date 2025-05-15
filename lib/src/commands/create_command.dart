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
      ..addFlag(
        'feature',
        abbr: 'f',
        help:
            'Create one or more features (can also just provide feature names without this flag)',
      )
      ..addMultiOption(
        'list',
        abbr: 'l',
        help: 'List of feature names to create (comma separated or repeated)',
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

  bloclean create -p my_project -f -l login,profile
    - Creates a project and features using explicit flags (legacy style).

OPTIONS:
  -p, --project    Create a new Flutter project (can also just provide a name)
  -f, --feature    Create one or more features (can also just provide feature names)
  -l, --list       List of feature names to create (comma separated or repeated)

If neither -p nor -f is specified:
  - If one name is provided, it is treated as a project name.
  - If two names are provided, the first is the project name and the second is the path.
  - If multiple names are provided, each is treated as a feature name.
''';

  @override
  Future<int> run() async {
    final isProject = argResults?['project'] == true;
    final isFeature = argResults?['feature'] == true;
    final rest = argResults?.rest ?? <String>[];

    // If neither -p nor -f is specified, infer intent from positional arguments
    if (!isProject && !isFeature) {
      if (rest.isEmpty) {
        _logger.err(
          'Specify at least -p (project), -f (feature), or provide a name.',
        );
        return ExitCode.usage.code;
      }
      // If only one positional argument, treat as project name
      if (rest.length == 1) {
        final projectName = rest[0];
        final code = await CreateProjectCommand.runCreate(
          logger: _logger,
          projectName: projectName,
        );
        return code;
      }
      // If two positional arguments, treat as project name and path
      if (rest.length == 2) {
        final projectName = rest[0];
        final projectPath = rest[1];
        final code = await CreateProjectCommand.runCreate(
          logger: _logger,
          projectName: projectName,
          projectPath: projectPath,
        );
        return code;
      }
      // If more than two positional arguments, treat as features
      var exitCode = ExitCode.success.code;
      for (final feature in rest) {
        final code = await CreateFeatureCommand.runCreate(
          logger: _logger,
          featureName: feature,
        );
        if (code != ExitCode.success.code) {
          exitCode = code;
        }
      }
      return exitCode;
    }

    // Support chaining: bloclean create -p my_project -f login -l signup,profile
    var exitCode = ExitCode.success.code;
    var i = 0;
    while (i < rest.length) {
      if (rest[i] == '-p' || rest[i] == '--project') {
        i++;
        if (i >= rest.length) {
          _logger.err('Project name is required after -p/--project.');
          return ExitCode.usage.code;
        }
        final projectName = rest[i];
        final code = await CreateProjectCommand.runCreate(
          logger: _logger,
          projectName: projectName,
        );
        if (code != ExitCode.success.code) {
          exitCode = code;
        }
        i++;
      } else if (rest[i] == '-f' || rest[i] == '--feature') {
        i++;
        // Check for -l/--list after -f
        final allFeatures = <String>[];
        if (i < rest.length && (rest[i] == '-l' || rest[i] == '--list')) {
          i++;
          while (i < rest.length && !rest[i].startsWith('-')) {
            allFeatures.addAll(
              rest[i]
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty),
            );
            i++;
          }
        } else if (i < rest.length && !rest[i].startsWith('-')) {
          allFeatures.add(rest[i]);
          i++;
        } else {
          _logger.err('Feature name or -l/--list required after -f/--feature.');
          return ExitCode.usage.code;
        }
        for (final feature in allFeatures) {
          final code = await CreateFeatureCommand.runCreate(
            logger: _logger,
            featureName: feature,
          );
          if (code != ExitCode.success.code) {
            exitCode = code;
          }
        }
      } else {
        _logger.err("Unknown argument: '${rest[i]}'.");
        return ExitCode.usage.code;
      }
    }
    return exitCode;
  }
}
