FROM debian:buster AS builder

RUN apt-get update && apt-get install -y \
    build-essential \
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

ARG user_id
ARG group_id
ARG user_name=builder
ARG group_name=builder
ARG home_dir=/home/${user_name}

RUN groupadd --system --gid ${group_id} ${group_name}  \
    && useradd --no-log-init --system --create-home --gid ${group_id} --uid ${user_id} ${user_name}

USER ${user_name}

WORKDIR ${home_dir}

ARG upstream_version=0.2.2

ADD --chown=builder:builder \
    https://gitlab.com/ddorian/openrecipes/-/archive/v${upstream_version}/openrecipes-v${upstream_version}.tar.gz \
    .

RUN mkdir openrecipes-${upstream_version}
WORKDIR openrecipes-${upstream_version}

RUN mkdir debian
VOLUME debian

RUN tar --strip-components=1 -xf ../openrecipes-v${upstream_version}.tar.gz


FROM builder AS testbuild

RUN qmake
RUN make
USER root
RUN make install


FROM debian:buster AS testrun

USER root

RUN apt-get update && apt-get install -y \
    libqrencode4 \
    libqt5network5 \
    libqt5quickcontrols2-5 \
    libqt5sql5 \
    libqt5xml5 \
    libsodium23 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=testbuild \
    /usr/bin/openrecipes \
    /usr/bin/openrecipes

COPY --from=testbuild \
    /usr/bin/openrecipesserver \
    /usr/bin/openrecipesserver

COPY --from=testbuild \
    /usr/share/applications/openrecipes.desktop \
    /usr/share/applications/openrecipes.desktop

COPY --from=testbuild \
    /usr/share/pixmaps/openrecipes.svg \
    /usr/share/pixmaps/openrecipes.svg

RUN /usr/bin/openrecipes --help ||:
RUN /usr/bin/openrecipesserver --help ||:


# https://www.debian.org/doc/manuals/debmake-doc/ch05.en.html#workflow
FROM builder AS debianizer

USER root

RUN apt-get update && apt-get install -y \
    dh-make \
    && rm -rf /var/lib/apt/lists/*

USER ${user_name}

ENV DEBEMAIL="your.email.address@example.org"
ENV DEBFULLNAME="Firstname Lastname"

ENTRYPOINT dh_make --yes --single --copyright gpl3 --addmissing --file ../openrecipes-v0.2.2.tar.gz
# --addmissing (reprocess package and add missing files):
# https://www.debian.org/doc/manuals/maint-guide/first.en.html#ftn.idm874
# https://wiki.debian.org/DebianMentorsFaq#What.27s_wrong_with_upstream_shipping_a_debian.2F_directory.3F

