.PHONY: docker manifest

manifest:
	git ls-files > manifest

docker:
	mkdir -p docker/.build
	git archive --format tar.gz -o docker/.build/web_fetch.tar.gz master
	docker build --no-cache -t webfetch/webfetch docker
