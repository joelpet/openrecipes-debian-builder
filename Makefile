docker_tag = openrecipes-debian-builder

.PHONY: docker-build
docker-build:
docker-build:
	docker build \
		--tag $(docker_tag) \
		.

.PHONY: docker-run
docker-run:
	docker run --rm -it $(docker_tag)
