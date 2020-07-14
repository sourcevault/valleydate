SRC_NAME = $(shell ls src)

TEST_NAME = $(shell ls test | grep ".ls")

SRC_FILES = ${SRC_NAME:%=--watch src/%}

TEST_FILES = ${TEST_NAME:%=--watch test/%}

MAKEFLAGS += --no-print-directory

file = test/test.js

pgk:
	yaml2json src/package.yaml > package.json

compile:
	make pgk
	lsc -co dist src
	lsc -c test
	node ${file}

w.compile:
	make pgk
	nodemon  --exec "make compile || exit 1" ${SRC_FILES} ${TEST_FILES}


.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS = -ec

travis:
	@for i in test/*.js
	do
		node $$i
	done

testy:
	@lsc -co dist src
	@lsc -c test/*.ls
	make pkg
	make travis

w.testy:
	nodemon --exec "make testy" ${TEST_FILES} ${SRC_FILES}



