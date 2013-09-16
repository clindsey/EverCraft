install:
	npm install
	./node_modules/.bin/bower install

clean:
	rm -rf node_modules
	rm -rf bower_components
	rm -rf public/*

live:
	./node_modules/.bin/grunt live --force

tdd:
	./node_modules/.bin/grunt tdd --force

serve:
	./node_modules/.bin/grunt serve

build:
	./node_modules/.bin/grunt build

deploy:
	./node_modules/.bin/grunt deploy

test:
	./node_modules/.bin/grunt test

docs:
	./node_modules/.bin/grunt docs

mocha:
	./node_modules/grunt-mocha/node_modules/.bin/mocha

.PHONY: test docs
