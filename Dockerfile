# Build Stage
FROM --platform=linux/amd64 ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git clang

## Add source code to the build stage.
WORKDIR /
ADD https://api.github.com/repos/capuanob/ufbx/git/refs/heads/mayhem version.json
RUN git clone -b mayhem https://github.com/capuanob/ufbx.git
WORKDIR ufbx

## Build
RUN clang -fsanitize=fuzzer fuzz.c ufbx.c -I. -o ufbx-fuzz

## Consolidate all dynamic libraries used by the fuzzer
RUN mkdir /deps
RUN cp `ldd /ufbx/ufbx-fuzz | grep so | sed -e '/^[^\t]/ d' | sed -e 's/\t//' | sed -e 's/.*=..//' | sed -e 's/ (0.*)//' | sort | uniq` /deps 2>/dev/null || :

## Package Stage
FROM --platform=linux/amd64 ubuntu:20.04
COPY --from=builder /ufbx/ufbx-fuzz /ufbx-fuzz
COPY --from=builder /deps /usr/lib

CMD /ufbx-fuzz -close_fd_mask=2
