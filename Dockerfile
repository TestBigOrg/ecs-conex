FROM ubuntu

# Installations
RUN apt-get update -qq && apt-get install -y curl git python-pip parallel
RUN pip install awscli
RUN curl -s https://s3.amazonaws.com/mapbox/apps/install-node/v2.0.0/run | NV=4.4.2 NP=linux-x64 OD=/usr/local sh

# Setup watchbot for logging and env var decryption
RUN npm install -g watchbot@^1.0.3 decrypt-kms-env@^2.0.1

# Setup application directory
RUN mkdir -p /usr/local/src/ecs-conex
WORKDIR /usr/local/src/ecs-conex

# Install docker binary matching EC2 version
RUN curl -sL https://get.docker.com/builds/Linux/x86_64/docker-1.12.6.tgz > docker-1.12.6.tgz
RUN tar -xzf docker-1.12.6.tgz && cp docker/docker /usr/local/bin/docker && chmod 755 /usr/local/bin/docker

# Copy files into the container
COPY ./*.sh ./

# Use docker on the host instead of running docker-in-docker
# https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/
VOLUME /var/run/docker.sock

# tmp data written to the host
VOLUME /mnt/data

# Run the worker
CMD eval $(decrypt-kms-env) && ./ecs-conex.sh
