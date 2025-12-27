import 'package:mason/mason.dart';
import 'package:path/path.dart' as path;
import 'package:universal_io/io.dart';
import 'package:very_good_cli/src/commands/create/templates/templates.dart';
import 'package:very_good_cli/src/logger_extension.dart';

/// {@template very_good_starter_template}
/// A Very Good Flutter Starter template with Auth, Onboarding,
/// Subscriptions, and Notifications.
/// {@endtemplate}
class VeryGoodStarterTemplate extends Template {
  /// {@macro very_good_starter_template}
  VeryGoodStarterTemplate()
      : super(
          name: 'starter',
          bundle: veryGoodStarterBundle,
          help: 'Generate a Very Good Flutter Starter with advanced features.',
        );

  @override
  Future<void> onGenerateComplete(Logger logger, Directory outputDir) async {
    if (await installFlutterPackages(logger, outputDir)) {
      await applyDartFixes(logger, outputDir);
    }
    _logSummary(logger, outputDir);
  }

  void _logSummary(Logger logger, Directory outputDir) {
    final relativePath = path.relative(
      outputDir.path,
      from: Directory.current.path,
    );

    final projectPath = relativePath;
    final projectPathLink = link(
      uri: Uri.parse(projectPath),
      message: projectPath,
    );

    final readmePath = path.join(relativePath, 'README.md');
    final readmePathLink = link(
      uri: Uri.parse(readmePath),
      message: readmePath,
    );

    final details = '''
  • To get started refer to $readmePathLink
  • Your project code is in $projectPathLink

  Features included:
  • Authentication (Firebase Auth)
  • Onboarding flow
  • Bloc + Repository pattern
  • Go Router navigation
''';

    logger
      ..info('\n')
      ..created('Created a Very Good Flutter Starter! 🚀')
      ..info(details);
  }
}
