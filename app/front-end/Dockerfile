FROM quay.io/queeno/tw-common

WORKDIR /infra-problem/build

ENV APP_PORT 8083
ENV STATIC_URL http://tw-static-assets:8000
ENV QUOTE_SERVICE_URL http://tw-quotes:8081
ENV NEWSFEED_SERVICE_URL http://tw-newsfeed:8082
ENV NEWSFEED_SERVICE_TOKEN 'T1&eWbYXNWG1w1^YGKDPxAWJ@^et^&kX'

EXPOSE 8083

CMD ["java", "-jar", "front-end.jar"]
