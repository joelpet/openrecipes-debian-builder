FROM debian:buster AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*


FROM builder AS openrecipes

RUN apt-get update && apt-get install -y \
    libqrencode-dev \
    libqt5svg5-dev \
    libqt5webview5-dev \
    libsodium-dev \
    pkg-config \
    qt5-default \
    qt5-qmake \
    qtquickcontrols2-5-dev \
    qttools5-dev-tools \
    && rm -rf /var/lib/apt/lists/*

ADD openrecipes /src/openrecipes

WORKDIR /src/openrecipes

RUN qmake
RUN make
RUN make install

FROM debian:buster AS testrun

RUN apt-get update && apt-get install -y \
    libqrencode4 \
    libqt5network5 \
    libqt5quickcontrols2-5 \
    libqt5sql5 \
    libqt5xml5 \
    libsodium23 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=openrecipes \
    /usr/bin/openrecipes \
    /usr/bin/openrecipes

COPY --from=openrecipes \
    /usr/bin/openrecipesserver \
    /usr/bin/openrecipesserver

COPY --from=openrecipes \
    /usr/share/applications/openrecipes.desktop \
    /usr/share/applications/openrecipes.desktop

COPY --from=openrecipes \
    /usr/share/pixmaps/openrecipes.svg \
    /usr/share/pixmaps/openrecipes.svg

RUN /usr/bin/openrecipes --help ||:
RUN /usr/bin/openrecipesserver --help ||:
