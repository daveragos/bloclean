import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template create_feature_command}
/// A command which creates a new feature with a clean architecture folder structure.
/// {@endtemplate}
class CreateFeatureCommand extends Command<int> {
  /// {@macro create_feature_command}
  CreateFeatureCommand();

  @override
  String get description =>
      'Creates a new feature with a clean architecture folder structure.';
  @override
  String get name => 'feature';

  static Future<int> runCreate({
    required Logger logger,
    required String featureName,
  }) async {
    final featurePath = Directory('lib/features/$featureName');
    if (featurePath.existsSync()) {
      logger.err('Feature "$featureName" already exists.');
      return ExitCode.usage.code;
    }
    try {
      logger.info('Creating feature "$featureName"...');
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
        Directory('${featurePath.path}/$dir').createSync(recursive: true);
      }
      logger.info('Feature "$featureName" created successfully.');
      return ExitCode.success.code;
    } catch (e) {
      logger.err('Failed to create feature "$featureName": $e');
      return ExitCode.software.code;
    }
  }
}
