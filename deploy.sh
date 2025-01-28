#!/bin/sh

mag modify bump --targets 'build-number'
VERSION=$(grep '^version:' pubspec.yaml | awk '{print $2}')
sed -i -e "s/\"flutter_bootstrap\.js[^\"]*\"/\"flutter_bootstrap.js?v=$VERSION\"/g" web/index.html

flutter build web
firebase deploy