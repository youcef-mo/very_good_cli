# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Very Good CLI is a Dart command-line interface tool for generating scalable templates and running helpful commands. It uses the Mason package for code generation and provides wrappers around dart, flutter, and git CLIs.

## Development Commands

### Setup

```sh
# Install dependencies for all projects (recommended)
very_good packages get -r

# Or install manually for each project
dart pub get
cd bricks/test_optimizer && dart pub get && cd ../../
cd e2e && dart pub get && cd ../
cd tool/spdx_license && dart pub get && cd ../../
```

### Testing

```sh
# Run unit tests (excludes pull-request-only and e2e tests)
flutter test -x pull-request-only -x e2e

# Run all tests with coverage
flutter pub global activate coverage 1.15.0
flutter test -j 1 -x pull-request-only -x e2e --coverage=coverage --test-randomize-ordering-seed random
dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --packages=.dart_tool/package_config.json --report-on=lib

# Run tests tagged for pull requests only (build verification)
flutter pub run test --run-skipped -t pull-request-only

# Run e2e tests
cd e2e && very_good test --recursive && cd ../
```

Tests tagged with `pull-request-only` are skipped by default and only run during CI for build verification (see [dart_test.yaml](dart_test.yaml)).

### Code Quality

```sh
# Format code
dart format lib test

# Check formatting
dart format --set-exit-if-changed lib test

# Analyze code
dart analyze --fatal-infos --fatal-warnings .

# Or use Flutter analyzer
flutter analyze lib test

# Auto-fix analysis issues
dart fix --apply
```

### Local Installation

```sh
# Install your local development version globally
dart pub global activate --source path .

# Then use it like the published version
very_good --version
```

### Bundle Generation

Templates are bundled from Mason bricks. When templates change, regenerate bundles:

```sh
# Generate all template bundles (requires mason CLI)
./tool/generate_bundles.sh

# Generate test optimizer bundle
./tool/generate_test_optimizer_bundle.sh
```

This fetches bricks from the [very_good_templates](https://github.com/VeryGoodOpenSource/very_good_templates) repository and bundles them as Dart code in [lib/src/commands/create/templates/](lib/src/commands/create/templates/).

## Architecture

### Command Structure

The CLI uses the `args` package with a hierarchical command structure:

```
VeryGoodCommandRunner (lib/src/command_runner.dart)
├── CreateCommand (lib/src/commands/create/create.dart)
│   ├── DartCliCommand
│   ├── DartPackageCommand
│   ├── DocsiteCommand
│   ├── FlameGameCommand
│   ├── FlutterAppCommand
│   ├── FlutterPackageCommand
│   ├── FlutterPluginCommand
│   └── FlutterStarterCommand
├── PackagesCommand (lib/src/commands/packages/packages.dart)
│   ├── PackagesGetCommand
│   └── CheckCommand
│       └── LicensesCommand
├── TestCommand (lib/src/commands/test/test.dart)
├── UpdateCommand (lib/src/commands/update.dart)
└── DartCommand (lib/src/commands/dart/dart.dart)
    └── DartTestCommand
```

Each command extends either `Command<int>` or a base class like `CreateSubCommand`.

### Template System

Templates are based on [Mason](https://pub.dev/packages/mason):

1. **Template Definition** ([lib/src/commands/create/templates/template.dart](lib/src/commands/create/templates/template.dart)): Abstract class defining `name`, `bundle`, `help`, and `onGenerateComplete` hook
2. **Bundle Files**: Pre-generated Dart bundles (`*_bundle.dart`) containing template content
3. **Template Classes**: Implementations (`*_template.dart`) that wrap bundles and define post-generation actions
4. **Local vs Hosted**: Most templates are hosted in the [very_good_templates](https://github.com/VeryGoodOpenSource/very_good_templates) repo, but `very_good_starter` is a local brick in [bricks/very_good_starter/](bricks/very_good_starter/)

When modifying templates:
- External templates: Contribute to the very_good_templates repository
- Local templates: Edit in [bricks/](bricks/) directory
- After changes: Run `./tool/generate_bundles.sh` to regenerate bundles

### CLI Wrappers

The [lib/src/cli/](lib/src/cli/) directory contains wrappers around external tools:

- **cli.dart**: Base abstraction using `ProcessOverrides` for testability
- **dart_cli.dart**: Wraps `dart` commands (pub get, analyze, format, etc.)
- **flutter_cli.dart**: Wraps `flutter` commands (pub get, test, packages get recursively)
- **git_cli.dart**: Wraps `git` commands
- **test_cli_runner.dart**: Custom test runner with coverage and optimization features using `very_good_test_runner`

All wrappers use `_Cmd.run()` which respects `ProcessOverrides` for testing.

### Multi-Project Structure

This repository contains multiple Dart projects:

- **Main CLI** (`pubspec.yaml`): The very_good_cli package
- **Bricks** ([bricks/](bricks/)):
  - `test_optimizer`: Mason brick for test optimization
  - `very_good_starter`: Local template brick for Flutter starter apps
- **E2E Tests** ([e2e/](e2e/)): End-to-end integration tests
- **Tools** ([tool/](tool/)):
  - `spdx_license`: Tool for generating license data

Each has its own `pubspec.yaml` and must be managed separately for dependencies.

### Test Organization

- **Unit Tests** ([test/](test/)): Test the CLI code directly using mocks
  - Helper utilities in [test/helpers/](test/helpers/)
  - Fixtures in [test/fixtures/](test/fixtures/)
  - Tagged tests: Use `-t pull-request-only` for build verification tests
- **E2E Tests** ([e2e/](e2e/)): Integration tests that run actual CLI commands
  - Tagged with `e2e` and excluded from normal test runs
  - Test real template generation and command execution

### Code Generation

Generated files (`.gen.dart` suffix) are created by:
- Mason bundles: From `./tool/generate_bundles.sh`
- SPDX licenses: From [tool/spdx_license/](tool/spdx_license/)

These should not be edited manually. Exclude them from coverage with `**/*.gen.dart`.

## CI/CD

- **CI Workflow** ([.github/workflows/very_good_cli.yaml](.github/workflows/very_good_cli.yaml)): Runs on Ubuntu and Windows
- **E2E Workflow** ([.github/workflows/e2e.yaml](.github/workflows/e2e.yaml)): End-to-end tests
- **Release Process**: Automated via `release-please` (see [CONTRIBUTING.md](CONTRIBUTING.md))
  - Uses conventional commits for versioning
  - Auto-publishes to pub.dev on release

## Coding Standards

- **Analysis**: Uses [very_good_analysis](https://pub.dev/packages/very_good_analysis) (see [analysis_options.yaml](analysis_options.yaml))
- **Coverage**: Requires 100% test coverage for all PRs
- **Formatting**: Standard Dart formatting (`dart format`)
- **Commits**: Follow [Conventional Commits](https://www.conventionalcommits.org/) specification
