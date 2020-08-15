FROM mongo:4.4.0-bionic

RUN apt-get update && apt-get install -y netcat inetutils-ping

ENV CONFIG_REPLICA_SET 'configset1'
ENV CONFIG_SERVER_NODES ''
ENV ADD_SHARD_REPLICA_SET_PREFIX 'shard'
ENV ADD_SHARD_1_NODES ''
ENV ADD_SHARD_2_NODES ''

ADD /startup.sh /
ADD /health.sh /
ADD /config.sh /

HEALTHCHECK CMD [ "/health.sh" ]

EXPOSE 27017

CMD [ "/startup.sh" ]

