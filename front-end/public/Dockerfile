FROM quay.io/queeno/tw-common

WORKDIR /infra-problem/front-end/public

RUN apt-get update && \
    apt-get install -y python3

CMD ["python", "serve.py"]
