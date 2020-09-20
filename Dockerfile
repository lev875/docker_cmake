FROM alpine/git AS build_stage

ARG CMAKE_VERSION=3.18.2
ARG MAKE_OPTS=-j4

WORKDIR /tmp
RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz -O cmake.tar.gz
RUN mkdir cmake_source && tar xf cmake.tar.gz -C cmake_source --strip-components 1
RUN apk add build-base linux-headers openssl-dev
RUN mkdir /tmp/cmake && cd cmake_source && ./bootstrap --prefix=/tmp/cmake/ && make ${MAKE_OPTS} && make install
WORKDIR /tmp
ENTRYPOINT [ "/bin/ash" ]

FROM alpine/git
WORKDIR /root
RUN apk add build-base
COPY --from=build_stage /tmp/cmake /usr/local/
ENTRYPOINT [ "/bin/ash" ]
