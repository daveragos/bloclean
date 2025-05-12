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
# Create a new Flutter project
$ bloclean create-project --name <project_name>

# Follow the prompts for:
# - Organization name (e.g., com.example)
# - Platforms to support (e.g., android, ios, web)
# - Project template (e.g., app, package, plugin)
# - Starter template (e.g., empty, counter)
# - State management solution (e.g., flutter_bloc, provider, riverpod)

# Add a new feature to an existing project
$ bloclean create-feature --name <feature_name>

# Show CLI version
$ bloclean --version

# Show usage help
$ bloclean --help
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