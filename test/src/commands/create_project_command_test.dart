import 'package:bloclean/src/commands/create_project_command.dart';
import 'package:mason_logger/mason_logger.dart';
import 'package:test/test.dart';

void main() {
  group('CreateProjectCommand', () {
    late CreateProjectCommand command;

    setUp(() {
      command = CreateProjectCommand();
    });

    test('has correct name and description', () {
      expect(command.name, equals('create-project'));
      expect(
        command.description,
        equals(
          'Creates a new Flutter project with a clean architecture folder structure.',
        ),
      );
    });

    test('throws usage error when name is not provided', () async {
      final result = await command.run();
      expect(result, equals(ExitCode.usage.code));
    });

    // Add more tests to validate prompts and functionality
  });
}
