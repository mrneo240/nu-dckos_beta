FROM gcc:7.4 as builder
MAINTAINER HaydenKow <hayden@hkowsoftware.com>
ENV DEBIAN_FRONTEND noninteractive

WORKDIR /src

# Prerequirements / second line for libs / third line for mksdiso & img4dc
# Build Toolchain 
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends --no-upgrade \
        git curl texinfo python subversion \
        libjpeg-dev libpng++-dev \
        genisoimage p7zip-full cmake make  \
    && echo "dash dash/sh boolean false" | debconf-set-selections \
    && dpkg-reconfigure --frontend=noninteractive dash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt/toolchains/dc \
    && git clone --depth=1 git://git.code.sf.net/p/cadcdev/kallistios /opt/toolchains/dc/kos  \
    && git clone --depth=1 --recursive git://git.code.sf.net/p/cadcdev/kos-ports /opt/toolchains/dc/kos-ports \
    && rm -rf /opt/toolchains/dc/kos-ports/libGL \
    && cp /opt/toolchains/dc/kos/doc/environ.sh.sample /opt/toolchains/dc/kos/environ.sh \
    && sed -i 's/-fno-rtti//' /opt/toolchains/dc/kos/environ.sh \
    && sed -i 's/-fno-exceptions//' /opt/toolchains/dc/kos/environ.sh \
    && sed -i 's/-fno-operator-names//' /opt/toolchains/dc/kos/environ.sh \
    && echo 'source /opt/toolchains/dc/kos/environ.sh' >> /root/.bashrc 

# Build Toolchain   
RUN curl -SL https://github.com/mrneo240/nu-dckos_beta/archive/v2.tar.gz | tar --strip-components=1 -xzf - -C . \
	&& bash download.sh \
	&& bash unpack.sh \
	&& make erase=1 patch build gdb \
	&& bash cleanup.sh

WORKDIR /opt/toolchains/dc/kos/utils
RUN bash -c 'source /opt/toolchains/dc/kos/environ.sh ; make -C kmgenc; make -C genromfs'

# Build KOS-/Ports
WORKDIR /opt/toolchains/dc/kos
RUN bash -c 'source /opt/toolchains/dc/kos/environ.sh ; make -j5 && make -j5 kos-ports_all'

FROM debian:stretch
COPY --from=builder /opt/toolchains/dc /opt/toolchains/dc

RUN apt-get update \
    && apt-get install -y --no-install-recommends --no-upgrade \
        cmake \
        make \
        git \
        wget \
    && echo "dash dash/sh boolean false" | debconf-set-selections \
    && dpkg-reconfigure --frontend=noninteractive dash \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && wget http://http.us.debian.org/debian/pool/main/n/ncurses/libncurses6_6.1+20191019-1_amd64.deb \
    && wget http://http.us.debian.org/debian/pool/main/n/ncurses/libtinfo6_6.1+20191019-1_amd64.deb \
    && dpkg -i *.deb \
    && rm *.deb \
    && chmod +x /opt/toolchains/dc/kos/environ.sh

RUN sed -i '1isource /opt/toolchains/dc/kos/environ.sh\' /etc/bash.bashrc \
    && echo 'source /opt/toolchains/dc/kos/environ.sh' >> /root/.bashrc 

WORKDIR /src
COPY entry.sh /usr/local/bin/
RUN rm -rf /usr/share/locale /usr/share/man /usr/share/doc
ENTRYPOINT ["entry.sh"]
SHELL ["/bin/bash", "-l", "-c", "source /opt/toolchains/dc/kos/environ.sh"]
CMD ["bash"]
