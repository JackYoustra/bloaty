FROM emscripten/emsdk AS build
# install emscripten too 
RUN apt update && apt install -y git cmake build-essential zlib1g-dev 
RUN emsdk install latest && emsdk activate latest
WORKDIR /bloaty
ARG CACHE_VALUE=3
RUN git clone --recurse-submodules -j8 https://github.com/jackyoustra/bloaty.git
WORKDIR /bloaty/bloaty
RUN emcmake cmake -B build -S . -DCMakeBuildType=MinSizeRel
RUN cmake --build build -j $(nproc)
RUN cmake --build build --target install -j $(nproc)

FROM scratch AS export-stage
COPY --from=build /bloaty/bloaty/build/bloaty.js .
COPY --from=build /bloaty/bloaty/build/bloaty.wasm .
