#!/bin/bash

set -e

dart --enable-experiment=native-assets run ffigen --config ffigen.yaml
