FROM ubuntu AS build_stage

ARG MAKEFLAGS="-j 1"
ARG BUILD_DEPENDANCIES="wget git gcc g++ make libssl-dev"

ENV MAKEFLAGS=${MAKEFLAGS}

WORKDIR /tmp
RUN apt update && apt install -y ${BUILD_DEPENDANCIES}

ARG CMAKE_VERSION=3.18.2

RUN wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}.tar.gz -O cmake.tar.gz
RUN mkdir cmake_source && tar xf cmake.tar.gz -C cmake_source --strip-components 1
RUN mkdir /tmp/cmake && cd cmake_source && ./bootstrap --prefix=/tmp/cmake/ && make && make install
RUN ln -s /tmp/cmake/bin/cmake /usr/local/bin/cmake  

RUN git clone https://github.com/ninja-build/ninja.git /tmp/ninja --depth 1
RUN cd /tmp/ninja && \
    cmake -Bbuild-cmake -H. && \
    cmake --build build-cmake


FROM ubuntu
COPY --from=build_stage /tmp/ninja/build-cmake/ninja /usr/local/bin/ninja
COPY --from=build_stage /tmp/cmake /usr/local/
RUN apt update && apt install -y gcc g++ make openssl
ENTRYPOINT [ "/bin/bash" ]
