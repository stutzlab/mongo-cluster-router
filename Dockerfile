FROM mongo:4.2.8-bionic

RUN apt-get update && apt-get install -y netcat

ENV CONFIG_REPLICA_SET 'replica-set1'
ENV CONFIG_SERVER_NODES ''
ENV ADD_SHARD_REPLICA_SET_PREFIX 'shard'
ENV ADD_SHARD_1_NODES ''
ENV ADD_SHARD_2_NODES ''

ADD /startup.sh /
ADD /config.sh /

EXPOSE 27017

CMD [ "/startup.sh" ]

