all: build

test:
	mocha --compilers coffee:coffee-script -R spec

build:
	coffee src/build.coffee

.PHONY: test
