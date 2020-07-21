# BuildScripts Gradle Plugin

## Introduction

Gradle plugin that creates a few useful tasks to automate common steps while building and releasing an Android app. 

## Features

By using this plugin you will get the following features:
- Automatic release notes generation
- Release branch creation, together with a respective tag
- Version bumping (useful to prepare a new build)
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

#### Prerequisites
In order to run this script two assumptions must hold:
- The project must be a Git directory since the release notes will come from the Git logs.
- The versionCode must be set directly into the build file. A sample configuration would be:
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

## Set Up


`module/build.gradle`
```
buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath 'io.voiapp.android.commons:buildscripts:0.8.7'
    }
}

apply plugin: 'io.voiapp.android.commons.buildscripts'
```