# mongo-cluster-router

Mongo cluster router service

This is meant to be used along with [http://github.com/stutzlab/mongo-cluster-configsrv](mongo-cluster-configsrv) and [http://github.com/stutzlab/mongo-cluster-shard](mongo-cluster-shard).

**Check http://github.com/stutzlab/mongo-cluster for more details and examples**

## ENVs

* CONFIG_REPLICA_SET - replica set to configure router to. defaults to 'replica-set1'
* SHARD_REPLICA_SET_PREFIX - shard name prefix for multiple shards. According to SHARD_NODES_N variables, it will be used replica sets for each shard identified by this name. For example, env SHARD_NODES_1 will associate shard "1" to replica set "${SHARD_NAME_PREFIX}1" and associate node address to this shard. defaults to 'shard'
* SHARD_NODES_1 - shard instances associated with this shard group''. required
ENV SHARD_NODES_2 ''
ENV SHARD_NODES_3 ''
