FROM ubuntu:16.04
MAINTAINER "Christian Kniep <christian@qnib.org>"

ARG DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm \
    GETH_TEST_DATABASE=false

RUN apt-get update \
 && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 923F6CA9 \
 && echo "deb http://ppa.launchpad.net/ethereum/ethereum/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/ethereum.list  \
 && apt-get update \
 && apt install -qy geth bind9-host

ADD db /opt/db/
ADD genesis.json \
    baseContract.sol \
    contracts.sol \
    payment.sol \
    RegisterFetchHashContract.sol \
    ServiceRegisteryContract.sol \
    checkAllBalances.js \
    /opt/
ADD start.sh \
    bootstrap.sh \
    /opt/
VOLUME ["/data/"]
CMD ["/opt/start.sh"]
