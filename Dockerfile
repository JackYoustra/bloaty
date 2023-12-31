FROM emscripten/emsdk AS build
# install emscripten too 
RUN apt update && apt install -y git cmake build-essential zlib1g-dev 
RUN emsdk install latest && emsdk activate latest
WORKDIR /bloaty
RUN git clone --recurse-submodules -j8 https://github.com/jackyoustra/bloaty.git
WORKDIR /bloaty/bloaty
RUN emcmake cmake -B build -S . -DCMakeBuildType=MinSizeRel -DCMAKE_CXX_FLAGS="-s USE_ZLIB=1" -DCMAKE_C_FLAGS="-s USE_ZLIB=1"
RUN cmake --build build -j 10
RUN cmake --build build --target install -j 10

FROM alpine:latest

RUN apk update && apk add libstdc++ libgcc

COPY --from=build /bloaty/bloaty/build/bloaty /usr/local/bin/bloaty

# Check that bloaty is installed
RUN bloaty --version

ENTRYPOINT [ "bloaty" ]
