FROM ubuntu:18.04

# The following fails with ubuntu:devel, and adding ARG DEBIAN_FRONTEND=noninteractive didn't work
RUN apt-get -y update && apt-get install -y \
    curl \
    libx11-dev \
    libxext-dev \
    libc6-dev \
    locales \
    gcc \
    gdb \
    wget

# Set up UTF8 locale
RUN locale-gen "en_US.UTF-8" && dpkg-reconfigure locales
ENV LC_ALL=C.UTF-8
# Set up a nice gdbinit
RUN curl -s -L https://github.com/hugsy/gef/raw/master/scripts/gef.sh | sh

# if on i386 there's no need for multilib
#RUN apt-get install -y libc6-dev-i386
#RUN apt-get install -y libx11-6:i386, libxext-dev:i386
#RUN apt-get install -y gcc-multilib

# Create an inferno user.
ARG USER=worker
ARG UID=1000
ARG GID=1000
RUN groupadd -g $GID -o $USER
RUN useradd -m -u $UID -g $GID -s /bin/bash $USER
USER $USER

# If you change the container workspace, you must also change the mkconfig file below and the $WORKSPACE variable in docker-run.sh
ENV INFERNO=/usr/inferno
COPY --chown=$USER:$USER . $INFERNO
WORKDIR $INFERNO
# Required for the multiline echo format below
SHELL [ "/bin/bash", "-c"]

# setup a custom mkconfig
RUN echo $'ROOT=/usr/inferno \n\
    TKSTYLE=std \n\
    SYSHOST=Linux \n\
    SYSTARG=Linux \n\
    OBJTYPE=arm \n\
    OBJDIR=$SYSTARG/$OBJTYPE \n\
    <$ROOT/mkfiles/mkhost-$SYSHOST \n\
    <$ROOT/mkfiles/mkfile-$SYSTARG-$OBJTYPE' > mkconfig

# build code
RUN ./makemk.sh
ENV PATH="$INFERNO/Linux/arm/bin:${PATH}"
RUN mk nuke
RUN mk install

CMD ["emu", "-c1"]
