#!/bin/sh
set -e
set -u
mkdir -p build
scalac -d build ch*.scala main.scala
scala -cp build runtime.Main
