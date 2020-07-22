# BuildScripts Gradle Plugin

Gradle plugin that creates a few useful tasks to automate common steps while building and releasing an Android app. 

## Features

By using this plugin you will get the following features:
- Automatic release notes generation
- Release branch creation, together with a respective tag
- Version bumping (useful to prepare a new version release)
- Translations update using *phraseapp*

Below we present more details of each script.


### Release Notes
Generates release notes from commit messages.

#### Usage
```
gradle generateReleaseNotes
```
#### How it works
This task runs a script that will list all the commit messages between the current branch `HEAD` and the commit that contained a different (previous) `versionCode` in the `module/build.gradle` file.

In order to run this script the versionCode must be set directly into the build file. A sample configuration would be:
```
android {
    defaultConfig {
        //...
        versionCode 180
        versionName "1.17.0"
        //...
    }
}
```

#### Additional configuration
By default, this task will print the release notes in the standard output. However, you can configure it to print to a file by providing the file name.

`module/build.gradle`
```
releaseNotes {
    outputFileName "release_notes.txt"
}
```

### Release Branch
Creates a release branch for the current version and adds a release tag.

#### Usage
```
gradle createReleaseBranch
```

#### How it works
This task runs a script that creates a release branch, and a release tag from the latest commit in the currently checked out branch. In case of errors, the script will rollback any changes and checkout the master branch.

The release branch will follow the format:
```
release/<major version>.<minor version>
```

The tag name will follow the format:
```
Release_<version name>
```

The script assumes that the version name follows the semantic versioning convention `major.minor.patch`

### Version bump
Increments the current version (version name and version code) and commits the change to the current branch.

#### Usage
```
gradle bumpMinorVersion
```

#### How it works
This task runs a script that executes a version bump by:
- Checking out the master branch;
- Incrementing the minor segment of the version name by 1 (read from the `build.gradle` file);
- Incrementing the version code by 10 (also from the `build.gradle` file)

After incrementing, the script will commit the changes with the message:
```
Version bump <new version name> (<new version code>)
```

The script assumes that the version name follows the semantic versioning convention.

### Translations update
Pulls the translations from the [Phraseapp platform](https://phrase.com/), updating the `strings.xml` files for the configured languages.

#### Usage
```
gradle updateTranslations
```

#### How it works
This task download the phraseapp CLI executable and uses it to pull the latest translations.

The script assumes that the phraseapp configuration file (aka `.phraseapp.yml`) is located in the root git directory.

## Set Up
Found it useful? Here's how to install this plugin:

`module/build.gradle`
```
buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath 'io.voiapp.android:buildscripts:0.8.8'
    }
}

apply plugin: 'io.voiapp.android.buildscripts'
```

## License

Apache 2.0, see [LICENSE.md](LICENSE.md).