BASE := chaudhryfaisal
NAME := media-sort
GITCOMMIT := $(shell git rev-parse --short=10 HEAD 2>/dev/null)

BASE_IMAGE_URL := $(BASE)/$(NAME)
IMAGE_URL := $(BASE_IMAGE_URL):$(GITCOMMIT)

TEST_CMD_ARGS :=-v --recursive --min-file-size=0 --overwrite --accuracy-threshold 80 --tv-dir /workspace/media/tv --movie-dir /workspace/media/movies --concurrency 1 /workspace/media/raw

build:
	docker build --pull -t ${IMAGE_URL} .

build-debug:
	docker build --pull -f Dockerfile.debug -t ${IMAGE_URL} .

run: build
	docker run -p 8091:80 -it ${IMAGE_URL}

push: build
	docker push ${IMAGE_URL}
	docker tag ${IMAGE_URL} $(BASE_IMAGE_URL):latest
	docker push $(BASE_IMAGE_URL):latest

sh: build-debug
	docker run --rm -it -P -v ${PWD}/:/workspace --entrypoint /bin/sh ${IMAGE_URL}

test:
	docker run --rm -it -P -v ${PWD}/:/workspace ${IMAGE_URL} ${TEST_CMD_ARGS}