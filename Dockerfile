FROM jenkins

USER root

RUN apt-get update && \
    apt-get install -y default-jre-headless python-tk python-pip python-dev \
    libxml2-dev libxslt-dev zlib1g-dev net-tools

RUN pip install bzt

WORKDIR /opt

RUN wget http://www.openssl.org/source/openssl-1.0.2g.tar.gz && \
    tar zxvf openssl-1.0.2g.tar.gz

WORKDIR openssl-1.0.2g

RUN ./config && make depend && make install

WORKDIR /opt

RUN wget http://download.joedog.org/siege/siege-4.0.4.tar.gz && \
    tar zxvf siege-4.0.4.tar.gz

WORKDIR siege-4.0.4

RUN ./configure --with-ssl && make && make install

COPY taurus.yml /var/jenkins_home/
