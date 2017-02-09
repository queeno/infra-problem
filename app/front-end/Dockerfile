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

ENV APP_PORT 8083
ENV STATIC_URL http://tw-static-assets
ENV QUOTE_SERVICE_URL http://tw-quotes
ENV NEWSFEED_SERVICE_URL http://tw-newsfeed
ENV NEWSFEED_SERVICE_TOKEN 'T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX'

EXPOSE 8083

CMD ["java", "-jar", "front-end.jar"]
