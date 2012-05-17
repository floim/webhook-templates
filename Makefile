all: build

test:
	mocha --compilers coffee:coffee-script

build:
	coffee build.coffee

.PHONY: test
