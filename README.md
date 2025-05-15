## bloclean

![coverage][coverage_badge]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]

bloclean is a CLI tool designed to streamline Flutter project development by providing commands for creating projects and features with clean architecture.

---

## Getting Started 🚀

Activate the CLI globally via:

```sh
dart pub global activate --source=path <path to this package>
```

## Usage


```sh
# Create a new Flutter project (current directory)
$ bloclean create my_project

# Create a new Flutter project in a specific path
$ bloclean create my_project path/to/dir

# Create one or more features (new syntax)
$ bloclean create login profile

# Create a new Flutter project (legacy/explicit flags)
$ bloclean create -p my_project

# Add one or more features to an existing project (legacy/explicit flags)
$ bloclean create -f login
$ bloclean create -f -l login,profile

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