# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y clang

## Add source code to the build stage.
ADD . /ufbx
WORKDIR /ufbx

## Build
RUN clang -fsanitize=fuzzer fuzz_load_mem.c ufbx.c -I. -o ufbx-fuzz

## Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /ufbx/ufbx-fuzz /ufbx-fuzz
