#!/bin/bash

set -e

dart --enable-experiment=native-assets run ffigen --config ffigen.symbols.yaml
dart --enable-experiment=native-assets run ffigen --config ffigen.loaded.yaml
dart --enable-experiment=native-assets run ffigen --config ffigen.bundled.yaml
