FROM emscripten/emsdk AS build
# install emscripten too 
RUN apt update && apt install -y git cmake build-essential zlib1g-dev 
RUN emsdk install latest && emsdk activate latest
WORKDIR /bloaty
RUN git clone https://github.com/google/bloaty.git
WORKDIR /bloaty/bloaty
RUN emcmake cmake -B build -S . -DCMakeBuildType=MinSizeRel
RUN cmake --build build -j 10 || true
RUN cd third_party/zlib && git reset --hard && cd ../.. && cmake --build build
RUN cmake --build build --target install -j 10 || yes
RUN cd third_party/zlib && git reset --hard && cd ../.. && cmake --build build --target install

FROM alpine:latest

RUN apk update && apk add libstdc++ libgcc

COPY --from=build /bloaty/bloaty/build/bloaty /usr/local/bin/bloaty

# Check that bloaty is installed
RUN bloaty --version

ENTRYPOINT [ "bloaty" ]
