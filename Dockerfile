# Please update this skeleton 
# Don't forget to write commentaries in English instead of French for you would be asked to in a work environment!
# Based on Ubuntu "" x.y => Your version of Ubuntu or else!
FROM Centos:7 as ynov-ctng-focal	#initialisation of the image from Centos kernel, version 7

# LABEL about the custom image
LABEL maintainer="anthony.raffeneau@ynov.com" # Your Ynov Bordeaux Campus student email address
LABEL version="0.1" # First version, nothing to change!
LABEL description="this is a image docker, contain tools" # Add a relevant description of the image here! (Recommended)

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
# Help : https://phoenixnap.com/kb/how-to-create-sudo-user-on-ubuntu
# https://phoenixnap.com/kb/how-to-create-sudo-user-on-ubuntu
RUN groupadd -g $CTNG_GID ctng && useradd -d /home/ctng -m -g $CTNG_GID -u $CTNG_UID -s /bin/bash ctng  # creation of a new user and give sudo' s access
# You will need to update the repository list before updating your system in order to install some of the packages
# Use the sources.list provided with the lab materials
# On ubuntu, lookup the command add-apt-repository and the repos universe and multiverse?
RUN sudo add-apt-repository universe && sudo add-apt-repository multiverse # packages' installation

# Install necessary packages to run crosstool-ng
# You don't remember the previous lectures on the crosstool-ng?
# Use google : install crosstool-ng <Your distribution>??
RUN apt-get install -y autoconf gperf bison file flex texinfo help2man gcc-c++ libtool make patch ncurses-devel python36-devel perl-Thread-Queue bzip2 git wget which xz unzip rsync #install crosstool-ng
# Install Dumb-init
# https://github.com/Yelp/dumb-init
RUN wget -O /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64   #install bumb init
RUN chmod a+x /sbin/dumb-init   #give file's permissions
RUN echo 'export PATH=/opt/ctng/bin:$PATH' >> /etc/profile
ENTRYPOINT [ "/usr/local/bin/dumb-init", "--" ]

# Login with user 
USER ctng
WORKDIR /home/ctng
# Download and install the latest version of crosstool-ng
# https://github.com/crosstool-ng/crosstool-ng.git
RUN git clone -b master --single-branch --depth 1 \
    https://github.com/crosstool-ng/crosstool-ng.git ct-ng
WORKDIR /home/ctng/ct-ng
RUN ./bootstrap
ENV PATH=/home/ctng/.local/bin:$PATH
COPY ${CONFIG_FILE} config
# Build ct-ng
RUN ct-ng build

ENV TOOLCHAIN_PATH=/home/dev/x-tools/${CONFIG_FILE}
ENV PATH=${TOOLCHAIN_PATH}/bin:$PATH

CMD ["bash"]
