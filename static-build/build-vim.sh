#!/bin/bash

if [ -d "io/deps" ]; then
	echo "cleaning io/deps"
	rm -rf io/deps
fi

docker run -i --rm -v `pwd`/io:/io \
  ubuntu:trusty \
  bash /io/compile-vim.sh
