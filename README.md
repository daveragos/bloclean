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

## Usage

```sh
# Create a new Flutter project in the current directory
$ bloclean create my_project

# Create a new Flutter project in a specific path
$ bloclean create my_project path/to/dir

# Create one or more features
$ bloclean create login profile

# Create a new Flutter project with explicit flags
$ bloclean create -p my_project

# Add one or more features to an existing project with explicit flags
$ bloclean create -f login
$ bloclean create -F login,profile

# Show CLI version
$ bloclean --version

# Show usage help
$ bloclean --help
```

### Notes

- If neither `-p` nor `-f` is specified:
  - If one name is provided, it is treated as a project name.
  - If two names are provided, the first is the project name and the second is the path.
  - If multiple names are provided, each is treated as a feature name.

- Ensure you are in a Flutter project directory (with `pubspec.yaml`) when creating features.

- **Known Issue**: Currently, command chaining (e.g., creating a project and features in a single command) is not supported. You need to run separate commands for creating a project and adding features.

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