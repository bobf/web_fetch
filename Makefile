.PHONY: docker manifest

manifest:
	git ls-files > manifest

test:
	bin/rspec
	bin/rubocop
	bin/strong_versions

docker: version := $(shell bundle exec ruby -e "require 'web_fetch'; puts WebFetch::VERSION")
docker:
	mkdir -p docker/.build
	git archive --format tar.gz -o docker/.build/web_fetch.tar.gz master
	docker build -t webfetch/webfetch:${version} docker
