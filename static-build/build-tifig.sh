#!/bin/bash

# docker run -i -v `pwd`/io:/io \
docker run -i --rm -v `pwd`/io:/io \
  ubuntu:trusty \
  bash /io/compile.sh
