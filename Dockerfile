FROM ubuntu:16.04
MAINTAINER "Christian Kniep <christian@qnib.org>"

ARG DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm

RUN apt-get update \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 923F6CA9 \
 && echo "deb http://ppa.launchpad.net/ethereum/ethereum/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/ethereum.list  \
 && apt-get update \
 && apt install -qy geth bind9-host

CMD ["geth", "--rpc", "--rpcapi", "db,eth,net,web3,personal,shh", "--shh"]
