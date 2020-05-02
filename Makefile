docker_tag_prefix = openrecipes-

debian: .docker-image/debianizer
	mkdir -p $@
	docker run --rm -it \
		-v "$(realpath $@)":/home/builder/openrecipes-0.2.2/debian \
		$(docker_tag_prefix)debianizer
	touch $@

.docker-image: ; mkdir -p $@
.docker-image/debianizer:
.docker-image/testbuild:
.docker-image/%: Dockerfile | .docker-image
	docker build \
		--build-arg user_id=$(shell id -u) \
		--build-arg group_id=$(shell id -g) \
		--target $* \
		--tag $(docker_tag_prefix)$* \
		.
	touch $@

.PHONY: docker-run/%
docker-run/debianizer:
docker-run/testbuild:
docker-run/%: | .docker-image/%
	docker run --rm -it $(docker_tag_prefix)$*
