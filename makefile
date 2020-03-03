SRC_NAME = $(shell ls src)

FILE_NAME = ${SRC_NAME:%= src/%} 

WATCH = ${FILE_NAME:%=--watch %}

file = test.js

compile:
	lsc -co dist src
	yaml2json src/package.yaml > package.json
	node dist/${file}

cmd = make --no-print-directory compile || exit 1

watch: 
	yaml2json src/package.yaml > package.json
	nodemon  --exec "${cmd}" ${WATCH}

