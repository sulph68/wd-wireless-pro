#!/bin/bash

# make tools in build direcotry
# make prefix=/usr/local DESTDIR=/home/wdpro/deploy install
tar --group=0 --owner=0 -zcvf deploy.tar.gz usr etc var
