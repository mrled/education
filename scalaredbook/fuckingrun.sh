#!/bin/sh
set -eu
mkdir -p build
#scalac -d build util.scala ch*.scala main.scala
scalac -d build *.scala
scala -cp build runtime.Main
