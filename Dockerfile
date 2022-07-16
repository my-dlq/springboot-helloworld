FROM registry.cn-shanghai.aliyuncs.com/mydlq/openjdk:8u201-jdk-alpine3.9

EXPOSE 8080

RUN mkdir -p /opt/helloword

COPY target/springboot-helloworld-0.0.1.jar /opt/helloword/

RUN chmod 777 /opt/helloword/* -R

WORKDIR /opt/helloword/

ENV JAVA_OPTS="-Xmx512M -Xms256M -Xss256k -Duser.timezone=Asia/Shanghai"

ENTRYPOINT java $JAVA_OPTS -jar /opt/helloword/springboot-helloworld-0.0.1.jar
