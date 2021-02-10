# example_app

A Flutter application demonstrating the RenamePackageName Fastlane plugin.

## Getting Started

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Changing package names

In a console window, navigate to your Android or iOS project folder:

```bash
cd ios
```

Then execute the `change_package_name` lane:

```bash
bundle exec fastlane change_package_name
```

**Note** The above command will default to the production package name: `com.example.example_app`. To use any other package name, run the following command:

```bash
bundle exec fastlane change_package_name new_package_name:[INSERT NEW PACKAGE NAME]
```

Naturally, replace `[INSERT NEW PACKAGE NAME]` with the new package name (no square brackets), for example:

```bash
bundle exec fastlane change_package_name new_package_name:uk.co.myoxygen.my_app
```