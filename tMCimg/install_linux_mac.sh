#!/bin/sh
OS_TYPE=`uname`

mkdir -p bin
mkdir -p bin/$OS_TYPE
mkdir -p obj
mkdir -p obj/$OS_TYPE

echo cp makefile.linux_mac makefile
cp makefile.linux_mac makefile

echo cp src/makefile.$OS_TYPE src/makefile
cp src/makefile.$OS_TYPE src/makefile

