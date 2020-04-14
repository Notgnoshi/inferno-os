FROM ubuntu:18.04

RUN apt-get -yqq update && apt-get install -yqq \
    curl \
    libx11-dev \
    libxext-dev \
    libc6-dev \
    locales \
    gdb \
    gcc \
    wget

# Set up UTF8 locale
RUN locale-gen "en_US.UTF-8" && dpkg-reconfigure locales
ENV LC_ALL=C.UTF-8

# Set up GEF
RUN curl -s -L https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

# if on i386 there's no need for multilib
#RUN apt-get install -y libc6-dev-i386
#RUN apt-get install -y libx11-6:i386, libxext-dev:i386
#RUN apt-get install -y gcc-multilib

ENV INFERNO=/usr/inferno
COPY . $INFERNO
WORKDIR $INFERNO

# setup a custom mkconfig
RUN echo > mkconfig ROOT=$INFERNO && \
echo >>mkconfig TKSTYLE=std && \
echo >>mkconfig SYSHOST=Linux && \
echo >>mkconfig SYSTARG=Linux && \
echo >>mkconfig OBJTYPE=arm && \
echo >>mkconfig 'OBJDIR=$SYSTARG/$OBJTYPE' && \
echo >>mkconfig '<$ROOT/mkfiles/mkhost-$SYSHOST' && \
echo >>mkconfig '<$ROOT/mkfiles/mkfile-$SYSTARG-$OBJTYPE'

# build code
RUN ./makemk.sh
ENV PATH="$INFERNO/Linux/arm/bin:${PATH}"
RUN mk nuke
RUN mk install

CMD ["emu", "-c1",  "wm/wm"]
