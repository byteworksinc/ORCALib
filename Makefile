#
# Makefile for GNO version of ORCALib
#
# To use this, you need a GNO system with the GNO source code in /src.
#
# This currently builds the library as "liborca".
# You will have to manually copy it to /lib/ORCALib.
#
# The assert.o file is not included in ORCALib but is used in libc.

LIB     = orca
SRCS	= cc.asm ctype.asm orca.asm signal2.c stdlib.asm string.asm \
	  time.asm toolglue.asm vars.asm int64.asm locale.asm uchar.asm

buildall .PHONY: build assert.o

.INCLUDE: /src/gno/lib/lib.mk
