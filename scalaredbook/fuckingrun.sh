#!/bin/sh
set -eu
mkdir -p build
scalac -d build ch*.scala main.scala
scala -cp build runtime.Main
