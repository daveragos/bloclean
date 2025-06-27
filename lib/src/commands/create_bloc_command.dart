import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:mason_logger/mason_logger.dart';

/// {@template create_bloc_command}
/// A command which creates bloc files with templates for an existing feature.
/// {@endtemplate}
class CreateBlocCommand extends Command<int> {
  /// {@macro create_bloc_command}
  CreateBlocCommand({required Logger logger}) : _logger = logger {
    argParser
      ..addOption(
        'feature',
        abbr: 'f',
        help: 'The feature name to create bloc files for',
        mandatory: true,
      )
      ..addOption(
        'name',
        abbr: 'n',
        help: 'The name for the bloc (e.g., user, product, auth)',
        mandatory: true,
      );
  }

  final Logger _logger;

  @override
  String get description =>
      'Creates bloc files with initial state structure for an existing feature.';

  @override
  String get name => 'bloc';

  @override
  String get invocation =>
      'bloclean create bloc -f <feature_name> -n <bloc_name>';

  @override
  String get usage => '''
Create bloc files with initial state structure for an existing feature.

USAGE:
  bloclean create bloc -f user -n auth
    - Creates a basic bloc structure for authentication in the user feature.

  bloclean create bloc -f product -n product
    - Creates a basic bloc structure for products in the product feature.

OPTIONS:
  -f, --feature    The feature name to create bloc files for (required)
  -n, --name       The name for the bloc (required)
''';

  @override
  Future<int> run() async {
    final featureName = argResults?['feature'] as String?;
    final blocName = argResults?['name'] as String?;

    if (featureName == null || blocName == null) {
      _logger.err('Feature name and bloc name are required.');
      return ExitCode.usage.code;
    }

    return runCreate(
      logger: _logger,
      featureName: featureName,
      blocName: blocName,
    );
  }

  static Future<int> runCreate({
    required Logger logger,
    required String featureName,
    required String blocName,
  }) async {
    final featurePath = Directory('lib/features/$featureName');
    if (!featurePath.existsSync()) {
      logger.err('Feature "$featureName" does not exist.');
      logger.info('Please create the feature first using: bloclean create $featureName');
      return ExitCode.usage.code;
    }

    final blocPath = Directory('${featurePath.path}/presentation/blocs');
    if (!blocPath.existsSync()) {
      logger.err('Bloc directory does not exist in feature "$featureName".');
      logger.info('Please ensure the feature has the correct structure.');
      return ExitCode.usage.code;
    }

    try {
      logger.info('Creating bloc "$blocName"...');

      final blocFiles = _generateBlocFiles(blocName);
      
      for (final file in blocFiles.entries) {
        final filePath = '${blocPath.path}/${file.key}';
        final fileContent = file.value;
        
        final fileObj = File(filePath);
        if (fileObj.existsSync()) {
          logger.warn('File $filePath already exists, skipping...');
          continue;
        }
        
        await fileObj.writeAsString(fileContent);
        logger.detail('Created: $filePath');
      }

      logger.info('Bloc "$blocName" created successfully in feature "$featureName".');
      return ExitCode.success.code;
    } catch (e) {
      logger.err('Failed to create bloc "$blocName": $e');
      return ExitCode.software.code;
    }
  }

  static Map<String, String> _generateBlocFiles(String blocName) {
    final className = _toPascalCase(blocName);
    final variableName = _toCamelCase(blocName);
    
    return {
      '${variableName}_bloc.dart': '''
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part '${variableName}_event.dart';
part '${variableName}_state.dart';

class ${className}Bloc extends Bloc<${className}Event, ${className}State> {
  ${className}Bloc() : super(${className}Initial()) {
    // TODO: Add your events here
    // on<CustomEvent>(_onCustomEvent);
  }

  // TODO: Implement your event handlers
  // Future<void> _onCustomEvent(
  //   CustomEvent event,
  //   Emitter<${className}State> emit,
  // ) async {
  //   // Your logic here
  // }
}
''',
      '${variableName}_event.dart': '''
part of '${variableName}_bloc.dart';

abstract class ${className}Event extends Equatable {
  const ${className}Event();

  @override
  List<Object> get props => [];
}

// TODO: Add your events here
// class CustomEvent extends ${className}Event {
//   final String data;
//
//   const CustomEvent(this.data);
//
//   @override
//   List<Object> get props => [data];
// }
''',
      '${variableName}_state.dart': '''
part of '${variableName}_bloc.dart';

abstract class ${className}State extends Equatable {
  const ${className}State();

  @override
  List<Object> get props => [];
}

class ${className}Initial extends ${className}State {}

// TODO: Add your states here
// class CustomState extends ${className}State {
//   final String data;
//
//   const CustomState(this.data);
//
//   @override
//   List<Object> get props => [data];
// }
''',
    };
  }

  static String _toPascalCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }

  static String _toCamelCase(String input) {
    if (input.isEmpty) return input;
    return input[0].toLowerCase() + input.substring(1);
  }
} 