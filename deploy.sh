#!/bin/sh

flutter build web && mag modify bump --targets 'build-number' && firebase deploy