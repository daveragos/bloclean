import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

class CreateFeatureCommand extends Command<int> {
  CreateFeatureCommand({required Logger logger}) : _logger = logger {
    argParser.addOption(
      'name',
      abbr: 'n',
      help: 'The name of the feature to create.',
      valueHelp: 'feature_name',
    );
  }

  @override
  String get description =>
      'Creates a new feature with a clean architecture folder structure.';

  @override
  String get name => 'create-feature';

  final Logger _logger;

  @override
  Future<int> run() async {
    final featureName = argResults?['name'] as String?;

    if (featureName == null || featureName.isEmpty) {
      _logger.err(
          'Feature name is required. Use --name or -n to specify the feature name.');
      return ExitCode.usage.code;
    }

    final featurePath = Directory('lib/features/$featureName');

    if (featurePath.existsSync()) {
      _logger.err('Feature "$featureName" already exists.');
      return ExitCode.usage.code;
    }

    try {
      _logger.info('Creating feature "$featureName"...');

      // Create the folder structure
      final directories = [
        'data/datasources',
        'data/models',
        'data/repositories',
        'domain/entities',
        'domain/repositories',
        'domain/usecases',
        'presentation/blocs',
        'presentation/pages',
        'presentation/widgets',
      ];

      for (final dir in directories) {
        final directory = Directory('${featurePath.path}/$dir');
        directory.createSync(recursive: true);
      }

      _logger.info('Feature "$featureName" created successfully.');
      return ExitCode.success.code;
    } catch (e) {
      _logger.err('Failed to create feature "$featureName": $e');
      return ExitCode.software.code;
    }
  }
}
