#==============================================================================
# Copyright (c) 2016-2019 Allan CORNET (Nelson)
#==============================================================================
# LICENCE_BLOCK_BEGIN
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# LICENCE_BLOCK_END
#==============================================================================

FROM debian:buster
MAINTAINER Allan CORNET "nelson.numerical.computation@gmail.com"

RUN apt-get update
RUN apt-get install -y build-essential;
RUN apt-get install -y autotools-dev;
RUN apt-get install -y libtool;
RUN apt-get install -y automake;
RUN apt-get install -y xvfb;
RUN apt-get install -y git;
RUN apt-get install -y libboost-all-dev;
RUN apt-get install -y libopenmpi-dev;
RUN apt-get install -y openmpi-bin;
RUN apt-get install -y gettext;
RUN apt-get install -y pkg-config;
RUN apt-get install -y cmake;
RUN apt-get install -y libffi-dev;
RUN apt-get install -y libicu-dev;
RUN apt-get install -y libxml2-dev;
RUN apt-get install -y liblapack-dev;
RUN apt-get install -y liblapacke-dev;
RUN apt-get install -y fftw3;
RUN apt-get install -y fftw3-dev;
RUN apt-get install -y libasound-dev;
RUN apt-get install -y portaudio19-dev;
RUN apt-get install -y libsndfile1-dev;
RUN apt-get install -y libtag1-dev;
RUN apt-get install -y alsa-utils;
RUN apt-get install -y qtbase5-dev;
RUN apt-get install -y qtdeclarative5-dev;
RUN apt-get install -y libqt5webkit5-dev;
RUN apt-get install -y libsqlite3-dev;
RUN apt-get install -y qt5-default qttools5-dev-tools;
RUN apt-get install -y libqt5opengl5-dev;
RUN apt-get install -y qtbase5-private-dev;
RUN apt-get install -y qtdeclarative5-dev;
RUN apt-get install -y libhdf5-dev;
RUN apt-get install -y hdf5-tools;
RUN apt-get install -y libmatio-dev;
RUN apt-get install -y libslicot0;
RUN apt-get install -y zlib1g-dev;
RUN apt-get install -y libcurl4-openssl-dev;
RUN apt-get install -y libgit2-dev;
RUN apt-get install -y libzmq3-dev;

RUN rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/live-clones/hdf5.git /tmp/hdf5_1_10_5 
RUN cd /tmp/hdf5_1_10_5 && git checkout hdf5-1_10_5 && ./configure --quiet --enable-shared --disable-deprecated-symbols --disable-hl --disable-strict-format-checks --disable-memory-alloc-sanity-check --disable-instrument --disable-parallel --disable-trace --disable-asserts --with-pic --with-default-api-version=v110 CFLAGS="-w" && make install -C src

RUN git clone https://github.com/tbeu/matio /tmp/matio 
RUN cd /tmp/matio && git checkout v1.5.16 && cd /tmp/matio && ./autogen.sh && ./configure --enable-shared --enable-mat73=yes --enable-extended-sparse=no --with-pic --with-hdf5=/tmp/hdf5_1_10_5/hdf5 && make && make install;

RUN git clone https://github.com/eigenteam/eigen-git-mirror /tmp/eigen
RUN mkdir /tmp/eigen-build && cd /tmp/eigen && git checkout 3.3.7 && cd - && cd /tmp/eigen-build && cmake . /tmp/eigen && make -j4 && make install;

RUN git clone https://github.com/Nelson-numerical-software/nelson.git /nelson
WORKDIR "/nelson"
RUN git checkout -b v0.4.7

RUN mkdir /home/nelsonuser

RUN groupadd -g 999 nelsonuser && \
    useradd -r -u 999 -g nelsonuser nelsonuser

RUN chown -R nelsonuser:nelsonuser /home/nelsonuser

RUN chown -R nelsonuser:nelsonuser /nelson

USER nelsonuser

ENV AUDIODEV null

RUN cmake -G "Unix Makefiles"
RUN make -j4

RUN make get_module_skeleton
RUN make buildhelp
RUN make tests_minimal


EXPOSE 10000:20000

ENTRYPOINT ["/nelson/bin/linux64/nelson-sio-cli"]
