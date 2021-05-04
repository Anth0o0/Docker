FROM focal	#initialisation of the image based on focal

# LABEL about the custom image
LABEL maintainer="anthony.raffeneau@ynov.com"
LABEL version="0.1" # First version
LABEL description="this is a image docker, contain tools" 

# Make the creation of docker images easier
ARG CTNG_UID=1000
ARG CTNG_GID=1000

# File to configure for our raspberry pi version
ARG CONFIG_FILE

# creation of a user and added to the sudoer group
RUN groupadd -g $CTNG_GID crosstool-ng
RUN useradd -d /home/crosstool-ng -m -g $CTNG_GID -u $CTNG_UID -s /bin/bash crosstool-ng

# install the ad-apt commands
RUN apt-get -y install software-properties-common 

# packages' installation
RUN add-apt-repository universe
RUN add-apt-repository multiverse

# update and upgrade the packages
RUN apt-get -y update && apt-get -y upgrade

# Installion of the necessary packages so as to be able to run crosstool-ng
RUN apt-get install -y gcc g++ bison texinfo flex install-info info make \
libncurses5-dev python3-dev autoconf automake libtool libtool-bin gawk bzip2 xz-utils patch libstdc++6 rsync git unzip help2man curl wget

# install dumb init and giving him file's permissions
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 && \
echo "057ecd4ac1d3c3be31f82fc0848bf77b1326a975b4f8423fe31607205a0fe945  /usr/local/bin/dumb-init" | sha256sum -c - && \
chmod 755 /usr/local/bin/dumb-init 

RUN echo 'export PATH=/opt/crosstool-ng/bin:$PATH' >> /etc/profile
ENTRYPOINT [ "/usr/local/bin/dumb-init", "--" ]

# Login with user crosstool-ng
USER crosstool-ng
WORKDIR /home/crosstool-ng

# Download and install the latest version of crosstool-ng
RUN git clone -b master --single-branch --depth 1 \
    https://github.com/crosstool-ng/crosstool-ng.git ct-ng
WORKDIR /home/crosstool-ng/ct-ng
RUN ./bootstrap
ENV PATH=/home/crosstool-ng/.local/bin:$PATH
COPY ${CONFIG_FILE} config

# Build user crosstool-ng
RUN ./configure --prefix=/home/crosstool-ng/.local
RUN make 
RUN make install 
ENV TOOLCHAIN_PATH=/home/dev/x-tools/${CONFIG_FILE}
ENV PATH=${TOOLCHAIN_PATH}/bin:$PATH

CMD ["bash"]
