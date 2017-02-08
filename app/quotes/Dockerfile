FROM ubuntu:16.04

ENV LEIN_ROOT true
ENV DEBIAN_FRONTEND noninteractive
ENV USER root

RUN apt-get update && \
    apt-get install -y openjdk-8-jdk git wget make

RUN wget -O /bin/lein https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein && \
    chmod +x /bin/lein

RUN git clone https://github.com/queeno/infra-problem /infra-problem

RUN cd /infra-problem && \
    make libs && \
    make clean all

WORKDIR /infra-problem/build

ENV APP_PORT 8081

EXPOSE 8081

CMD ["java", "-jar", "quotes.jar"]
