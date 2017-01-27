#!/usr/bin/env bash

echo "using ANDROID_HOME=$ANDROID_HOME"
printenv
./gradlew clean build
