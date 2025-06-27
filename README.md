## bloclean

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

bloclean, A CLI tool for creating and adding clean architecture Flutter projects and features.

---

## Getting Started 🚀

### Installation

Clone the repository and activate the CLI globally:

```sh
# Clone the repository
git clone https://github.com/daveragos/bloclean.git

# Change into the project directory
cd bloclean

# Activate the CLI globally
dart pub global activate --source=path .
```

## Commands Reference 📚

### Global Options

All commands support these global options:
- `-v, --version` - Print the current version
- `--verbose` - Noisy logging, including all shell commands executed

### 1. Create Command

**Description:** Create a new Flutter project or features.

**Usage:** `bloclean create [project_name] [feature1 feature2 ...] [options]`

**Options:**
- `-p, --project` - Create a new Flutter project (can also just provide a name without this flag)
- `-f, --feature <feature1 feature2 ...>` - Create one or more features (can also just provide feature names without this flag)
- `-F, --feature-list <feature1,feature2,...>` - Comma-separated list of feature names to create

**Examples:**
```sh
# Create a new Flutter project in the current directory
bloclean create my_project

# Create a new Flutter project in a specific path
bloclean create my_project path/to/dir

# Create one or more features
bloclean create login profile

# Create a new Flutter project with explicit flags
bloclean create -p my_project

# Add one or more features to an existing project with explicit flags
bloclean create -f login
bloclean create -F login,profile

# Create a project and features together
bloclean create -p my_project -f login -F login,profile
```

### 2. Create Bloc Command

**Description:** Creates bloc files with initial state structure for an existing feature.

**Usage:** `bloclean create bloc -f <feature_name> -n <bloc_name>`

**Options:**
- `-f, --feature <feature_name>` - The feature name to create bloc files for (required)
- `-n, --name <bloc_name>` - The name for the bloc (e.g., user, product, auth) (required)

**Examples:**
```sh
# Create a basic bloc structure for authentication in the user feature
bloclean create bloc -f user -n auth

# Create a basic bloc structure for products in the product feature
bloclean create bloc -f product -n product
```

**Generated Files:**
- `{name}_bloc.dart` - Main bloc class with initial state
- `{name}_event.dart` - Event base class with TODO comments
- `{name}_state.dart` - State base class with initial state

### 3. Update Command

**Description:** Update the CLI from the GitHub repository.

**Usage:** `bloclean update`

**Examples:**
```sh
# Update the CLI to the latest version
bloclean update
```

## Command Hierarchy

```
bloclean
├── --version (-v)
├── --verbose
├── create
│   ├── --project (-p)
│   ├── --feature (-f)
│   ├── --feature-list (-F)
│   └── [positional arguments]
├── create bloc
│   ├── --feature (-f) [required]
│   └── --name (-n) [required]
└── update
```

## Project Structure

When you create a Flutter project, bloclean sets up the following clean architecture folder structure:

```
lib/
├── config/
├── core/
│   ├── bloc/
│   ├── database/
│   ├── di/
│   ├── error/
│   ├── loaders/
│   ├── networks/
│   ├── shared/
│   ├── theme/
│   └── widgets/
└── features/
    └── {feature_name}/
        ├── data/
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        └── presentation/
            ├── blocs/
            ├── pages/
            └── widgets/
```

## Usage Notes

- **Positional Arguments:** The `create` command can accept positional arguments for project names and feature names
- **Feature Creation:** Features can be created using flags (`-f`, `-F`) or as positional arguments
- **Project Creation:** Projects can be created using the `-p` flag or inferred from positional arguments
- **Bloc Creation:** Requires both feature and bloc names to be specified
- **Update Command:** Automatically pulls latest changes from GitHub and re-activates the CLI globally

### Command Behavior Rules

- If neither `-p` nor `-f` is specified:
  - If one name is provided, it is treated as a project name.
  - If two names are provided, the first is the project name and the second is the path.
  - If multiple names are provided, each is treated as a feature name.

- Ensure you are in a Flutter project directory (with `pubspec.yaml`) when creating features.

- **Known Issue**: Currently, command chaining (e.g., creating a project and features in a single command) is not supported. You need to run separate commands for creating a project and adding features.

## Help Commands

```sh
# Show CLI version
bloclean --version

# Show usage help
bloclean --help

# Show help for specific commands
bloclean create --help
bloclean create bloc --help
bloclean update --help
```

---

## License

This project is licensed under the MIT License.

---

[coverage_badge]: coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_cli_link]: https://github.com/VeryGoodOpenSource/very_good_cli