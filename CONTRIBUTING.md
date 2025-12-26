# Contributing to Derby Dash

Thank you for your interest in contributing to Derby Dash! This document provides guidelines and information for contributors.

## Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md) to keep our community welcoming and respectful.

## Getting Started

### Development Setup

1. **Fork and clone the repository**
   ```bash
   git clone https://github.com/lucakaufmann/derby-dash.git
   cd derby-dash
   ```

2. **Install Flutter** (if not already installed)
   - Follow the [official Flutter installation guide](https://docs.flutter.dev/get-started/install)

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Generate code** (Isar schemas and Riverpod providers)
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

### Development Workflow

1. Create a new branch for your feature or fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following our coding standards

3. Run tests and analysis:
   ```bash
   flutter test
   flutter analyze
   ```

4. Commit your changes with a descriptive message

5. Push and create a pull request

## Coding Standards

### Dart/Flutter Style

- Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check for issues
- Format code with `dart format .`

### Architecture Guidelines

- **Models**: Place Isar collections in `lib/data/models/`
- **Providers**: Use Riverpod with code generation in `lib/providers/`
- **Screens**: Organize by feature in `lib/screens/`
- **Services**: Business logic goes in `lib/services/`
- **Widgets**: Reusable components in `lib/widgets/`

### Key Principles

1. **Kid-First Design**: UI should have large touch targets, high contrast, and be resilient to accidental taps

2. **Local-First**: No network dependencies - all data must work offline

3. **Soft Delete**: Never remove Car records from database - use `isDeleted` flag

4. **Dynamic Stats**: Calculate wins/losses from match data, don't store aggregates

## Pull Request Process

1. **Before submitting**:
   - Ensure all tests pass (`flutter test`)
   - Run static analysis (`flutter analyze`)
   - Update documentation if needed

2. **PR Description**:
   - Clearly describe what changes you made
   - Reference any related issues
   - Include screenshots for UI changes

3. **Review Process**:
   - PRs require at least one approval
   - Address feedback promptly
   - Keep PRs focused and reasonably sized

## Reporting Issues

### Bug Reports

Please include:
- Flutter version (`flutter --version`)
- Device/emulator information
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if applicable

### Feature Requests

- Describe the feature and its use case
- Explain how it fits the "Kid-First" design philosophy
- Consider if it works offline

## Questions?

Feel free to open an issue for questions or join discussions in existing issues.

Thank you for contributing!
