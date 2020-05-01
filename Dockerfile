FROM debian:buster AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*


FROM builder AS libsodium

RUN apt-get update && apt-get install -y \
    autogen \
    libtool \
    && rm -rf /var/lib/apt/lists/*

ADD libsodium/releases/old/libsodium-1.0.16.tar.gz /src

WORKDIR /src/libsodium-1.0.16

RUN ./autogen.sh
RUN ./configure
RUN make
RUN make check
RUN make install


FROM builder AS openrecipes

RUN apt-get update && apt-get install -y \
    libqrencode-dev \
    libqt53dquick5 \
    libqt5quickcontrols2-5 \
    libqt5svg5-dev \
    libqt5webview5-dev \
    libsodium-dev \
    libsodium23 \
    pkg-config \
    qt5-default \
    qt5-qmake \
    qtquickcontrols2-5-dev \
    qttools5-dev-tools \
    && rm -rf /var/lib/apt/lists/*

COPY --from=libsodium /usr/local /usr/local

ADD openrecipes /src/openrecipes

WORKDIR /src/openrecipes

RUN qmake
RUN make


FROM debian:buster

# TODO: Create runtime environment for openrecipe
