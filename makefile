SRC_NAME = $(shell ls src)

FILE_NAME = ${SRC_NAME:%= src/%}

WATCH = ${FILE_NAME:%=--watch %}

MAKEFLAGS += --no-print-directory

file = test.js

compile:
	lsc -co dist src
	yaml2json src/package.yaml > package.json
	node dist/${file}

watch:
	nodemon  --exec "make compile || exit 1" ${WATCH}

.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS = -ec

test:
	@lsc -co dist src
	@for i in dist/test*
	do
		node $$i
	done


w.test:
	nodemon --exec "make test" ${WATCH}


