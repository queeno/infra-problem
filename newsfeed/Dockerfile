FROM quay.io/queeno/tw-common

WORKDIR /infra-problem/build

ENV APP_PORT 8082

HEALTHCHECK --interval=5s --timeout=3s \
    CMD curl -f http://localhost:8082/ping || exit 1

EXPOSE 8082

CMD ["java", "-jar", "newsfeed.jar"]
