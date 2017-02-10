FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV USER root

RUN apt-get update && \
    apt-get install -y git python3

RUN git clone https://github.com/queeno/infra-problem /infra-problem

WORKDIR /infra-problem/front-end/public

EXPOSE 8000

CMD ["./serve.py"]
