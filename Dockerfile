FROM hyperized/alpine as trigger

FROM openjdk:8-alpine as builder

ENV branch "2.0.0.2"
ENV git_url "https://github.com/yahoo/kafka-manager.git"

RUN apk -U add git bash zip
RUN git clone --depth=1 --branch=$branch $git_url kafka-manager

WORKDIR kafka-manager

RUN ./sbt clean dist

WORKDIR target/universal

RUN unzip kafka-manager-$branch.zip

RUN mv /kafka-manager/target/universal/kafka-manager-$branch /kafka-manager/target/universal/kafka-manager
RUN chmod +x /kafka-manager/target/universal/kafka-manager/bin/kafka-manager

FROM openjdk:8-alpine

LABEL maintainer="Gerben Geijteman <gerben@hyperized.net>"
LABEL description="A basic Kafka Manager docker instance"

RUN apk -U add bash
COPY --from=builder /kafka-manager/target/universal/kafka-manager /kafka-manager
WORKDIR /kafka-manager/bin

ENTRYPOINT ["./kafka-manager"]
