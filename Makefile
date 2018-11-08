.PHONY: docker

docker:
	mkdir -p docker/.build
	git archive --format tar.gz -o docker/.build/web_fetch.tar.gz master
	docker build -t webfetch/webfetch docker
