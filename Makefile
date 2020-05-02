docker_tag_prefix = openrecipes-
upstream_version = 0.2.2

debian: .docker-image/debianizer
	-mkdir $@
	docker run --rm -it \
		-v "$(abspath $@)":/home/builder/workspace/pkg/openrecipes-$(upstream_version)/debian \
		$(docker_tag_prefix)debianizer
	touch $@

out: debian .docker-image/dpkg
	-mkdir $@
	docker run --rm -it \
		-v "$(abspath debian)":/home/builder/workspace/pkg/openrecipes-$(upstream_version)/debian \
		-v "$(abspath $@)":/out \
		$(docker_tag_prefix)dpkg
	touch $@

.docker-image: ; mkdir -p $@
.docker-image/builder:
.docker-image/debianizer:
.docker-image/dpkg:
.docker-image/testbuild:
.docker-image/restrun:
.docker-image/%: Dockerfile | .docker-image
	docker build \
		--build-arg user_id=$(shell id -u) \
		--build-arg group_id=$(shell id -g) \
		--build-arg upstream_version=$(upstream_version) \
		--target $* \
		--tag $(docker_tag_prefix)$* \
		.
	touch $@

.PHONY: docker-run/%
docker-run/builder:
docker-run/debianizer:
docker-run/dpkg:
docker-run/testbuild:
docker-run/testrun:
docker-run/%: | .docker-image/%
	-mkdir debian
	docker run --rm -it \
		-v "$(realpath debian)":/home/builder/workspace/pkg/openrecipes-$(upstream_version)/debian \
		$(docker_tag_prefix)$*
