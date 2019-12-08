#!/usr/bin/env bash
ENTRYPOINT=""
# ENTRYPOINT="--entrypoint /bin/sh"
CMD_ARGS="-v --recursive --min-file-size=0 --overwrite --accuracy-threshold 80 \
--tv-dir /workspace/media/tv --movie-dir /workspace/media/movies \
--concurrency 1 /workspace/media/raw"
#CMD_ARGS=""
docker run --rm -it -P -v ${PWD}/:/workspace \
$ENTRYPOINT test $CMD_ARGS