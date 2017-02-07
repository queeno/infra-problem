FROM quay.io/queeno/tw-common

WORKDIR /infra-problem/build

ENV APP_PORT 8081

HEALTHCHECK --interval=5s --timeout=3s \
    CMD curl -f http://localhost:8081/ping || exit 1

EXPOSE 8081

CMD ["java", "-jar", "quotes.jar"]
