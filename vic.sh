#!/bin/bash
# Copyright 2015, Yahoo Inc.
# Licensed under the terms of the Apache License 2.0. Please see LICENSE file in the project root for terms.
set -o pipefail
set -o errtrace
set -o nounset
set -o errexit


    run "START_ZK"
"$STORM_DIR/bin/storm" dev-zookeeper



    run "START_REDIS"
"$REDIS_DIR/src/redis-server"


    run "START_KAFKA"

"$KAFKA_DIR/bin/kafka-server-start.sh" "$KAFKA_DIR/config/server.properties"

    run "START_SPARK"

$SPARK_DIR/sbin/start-master.sh -h localhost -p 7077
$SPARK_DIR/sbin/start-slave.sh spark://localhost:7077

    run "START_SPARK_PROCESSING"

 "$SPARK_DIR/bin/spark-submit" --master spark://localhost:7077 --class spark.benchmark.KafkaRedisAdvertisingStream ./spark-benchmarks/target/spark-benchmarks-0.1.0.jar "$CONF_FILE" &
    sleep 5





    run "START_LOAD"


 cd data
    =$LEIN run -r -t $LOAD --configPath ../$CONF_FILE
    cd ..


    sleep $TEST_TIME
    run "STOP_LOAD"


     stop_if_needed leiningen.core.main "Load Generation"
    cd data
    $LEIN run -g --configPath ../$CONF_FILE || true
    cd ..


    run "STOP_SPARK_PROCESSING"
    run "STOP_SPARK"
    run "STOP_KAFKA"
    run "STOP_REDIS"
    run "STOP_ZK"


    redis.clients.jedis.exceptions.JedisConnectionException: Could not get a resource from the pool


    redis.clients.jedis.exceptions.JedisConnectionException: java.net.ConnectException: Connection refused