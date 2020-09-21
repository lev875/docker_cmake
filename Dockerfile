FROM ubuntu AS build_stage

ARG MAKEFLAGS="-j 1"
ARG BUILD_DEPENDANCIES="wget gcc g++ make libssl-dev"

ENV MAKEFLAGS=${MAKEFLAGS}

WORKDIR /tmp
RUN apt update && apt install -y ${BUILD_DEPENDANCIES}

ARG CMAKE_VERSION=3.18.2

RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz -O cmake.tar.gz
RUN mkdir cmake_source && tar xf cmake.tar.gz -C cmake_source --strip-components 1
RUN mkdir /tmp/cmake && cd cmake_source && ./bootstrap --prefix=/tmp/cmake/ && make && make install

FROM ubuntu
RUN mkdir /root/app
WORKDIR /root/app
RUN apt update && apt install -y gcc g++ make openssl
COPY --from=build_stage /tmp/cmake /usr/local/
ENTRYPOINT [ "/bin/bash" ]
