SRC_NAME = $(shell ls src)

TEST_NAME = $(shell ls test | grep ".ls")

SRC_FILES = ${SRC_NAME:%=--watch src/%}

TEST_FILES = ${TEST_NAME:%=--watch test/%}

MAKEFLAGS += --no-print-directory

file = test.js

compile:
	lsc -co dist src
	lsc -c test
	yaml2json src/package.yaml > package.json
	node dist/${file}

watch:
	nodemon  --exec "make compile || exit 1" ${SRC_FILES}

.ONESHELL:
SHELL = /bin/bash
.SHELLFLAGS = -ec

try:
	@lsc -co dist src
	@lsc -c test/*.ls
	yaml2json src/package.yaml > package.json
	@for i in test/*.js
	do
		node $$i
	done

w.try:
	nodemon --exec "make try" ${TEST_FILES}


