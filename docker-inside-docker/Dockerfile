FROM ubuntu:24.04

ENV DOCKER_COMPOSE_VERSION=v2.27.1

RUN apt-get -y update  
RUN apt-get -y install python3-pip \
    ca-certificates \
    sudo \
    bash \
    git \
    wget curl iptables supervisor iputils-ping \
    software-properties-common apt-transport-https \
    && rm -rf /var/lib/apt/list/*
    

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
RUN add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
RUN apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


RUN curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-$(uname -m)" -o /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose


COPY supervisor/ /etc/supervisor/conf.d/

VOLUME /var/lib/docker
EXPOSE 2375 2376

WORKDIR /app

COPY ./docker-compose-1.yml ./docker-compose.yml

CMD ["/usr/bin/supervisord"]
