
all:	build test

build:
	coffee -o lib/ -c srcs/*.coffee
	coffee -o . -c *.coffee
	coffee -o test/ -c test/*.coffee

clean:
	rm -rvf lib/*.js *.js test/*.js

test:
	mocha -R spec

.PHONY: all build clean test

