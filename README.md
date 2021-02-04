# rename_package_name plugin

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin, designed by the team at MyOxygen. To get started with `fastlane-plugin-rename_package_name`, add it to your project by running:

```bash
fastlane add_plugin rename_package_name
```

## About rename_package_name

A shorthand way of renaming the package name (App ID / Bundle ID) of an app in Fastlane.

To prevent having to manually go through either the iOS and/or Android projects to reconfigure the project with a new package name, this script does it all for you. On iOS is uses the pre-existing [`update_app_identifier`](https://docs.fastlane.tools/actions/update_app_identifier/) provided by Fastlane. For Android, a custom script is implemented that runs through all the project, and updates both the project files and the folder structure.

## Example

Check out the [example `Fastfile`](example/fastlane/Fastfile) to see how to use this plugin. To test it out:
1. Clone the repo, and in a console run `fastlane install_plugins`.
2. Navigate to the `example` folder.
3. Run `bundle exec fastlane test`.

You can change the package name to whatever is needed. The example shows changing between a development package name and a production package name.

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
