FROM focal	#initialisation of the image based on focal

# LABEL about the custom image
LABEL maintainer="anthony.raffeneau@ynov.com" # Your Ynov Bordeaux Campus student email address
LABEL version="0.1" # First version, nothing to change!
LABEL description="this is a image docker, contain tools" 

# Make the creation of docker images easier so that CTNG_UID/CTNG_GID have
# a default value if it's not explicitly specified when building. This
# will allow publishing of images on various package repositories (e.g.
# docker hub, gitlab containers). dmgr.sh can still be used to set the
# UID/GID to that of the current user when building a custom container.
ARG CTNG_UID=1000
ARG CTNG_GID=1000
# File to configure for your raspberry pi version
ARG CONFIG_FILE
# Crosstool-ng must be executed from a user that isn't the superuser (root)
# You must create a user and add it to the sudoer group
RUN groupadd -g $CTNG_GID ctng && useradd -d /home/ctng -m -g $CTNG_GID -u $CTNG_UID -s /bin/bash ctng  # creation of a new user and give sudo' s access
RUN apt-get -y install software-properties-common # install the ad-apt commands
# On ubuntu, lookup the command add-apt-repository and the repos universe and multiverse?
RUN sudo add-apt-repository universe # packages' installation
# update and upgrade the packages
RUN apt-get -y update && apt-get -y upgrade
# Install necessary packages to run crosstool-ng
RUN apt-get install -y gcc g++ bison flex textinfo install-info info make \
libncurses5-dev python3-dev autoconf automake libtool libtool-bin gawk bzip2 xz-utils patch libstdc++6 rsync git unzip help2man 
# install dumb init

# Install Dumb-init

RUN wget -O /sbin/dumb-init https://github.com/Yelp/dumb-init/   #install bumb init
RUN chmod a+x /sbin/dumb-init   #give file's permissions
RUN echo 'export PATH=/opt/ctng/bin:$PATH' >> /etc/profile
ENTRYPOINT [ "/usr/local/bin/dumb-init", "--" ]

# Login with user 
USER ctng
WORKDIR /home/ctng
# Download and install the latest version of crosstool-ng
RUN git clone -b master --single-branch --depth 1 \
    https://github.com/crosstool-ng/crosstool-ng.git ct-ng
WORKDIR /home/ctng/ct-ng
RUN ./bootstrap
ENV PATH=/home/ctng/.local/bin:$PATH
COPY ${CONFIG_FILE} config
# Build ct-ng
RUN ./configure --enable-local

ENV TOOLCHAIN_PATH=/home/dev/x-tools/${CONFIG_FILE}
ENV PATH=${TOOLCHAIN_PATH}/bin:$PATH

CMD ["bash"]
