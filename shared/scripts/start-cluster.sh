#!/bin/bash
docker exec nn1 /opt/zookeeper/bin/zkServer.sh start
docker exec nn2 /opt/zookeeper/bin/zkServer.sh start
docker exec datanode1 /opt/zookeeper/bin/zkServer.sh start

docker exec nn1 /opt/hadoop/bin/hdfs --daemon start journalnode
docker exec nn2 /opt/hadoop/bin/hdfs --daemon start journalnode
docker exec datanode1 /opt/hadoop/bin/hdfs --daemon start journalnode

docker exec nn1 /opt/hadoop/bin/hdfs --daemon start zkfc
docker exec nn2 /opt/hadoop/bin/hdfs --daemon start zkfc

docker exec nn1 /opt/hadoop/bin/hdfs --daemon start namenode
docker exec nn2 /opt/hadoop/bin/hdfs --daemon start namenode

docker exec datanode1 /opt/hadoop/bin/hdfs --daemon start datanode
docker exec datanode2 /opt/hadoop/bin/hdfs --daemon start datanode
docker exec datanode3 /opt/hadoop/bin/hdfs --daemon start datanode


docker exec datanode1 /opt/hadoop/bin/yarn --daemon start resourcemanager
docker exec datanode2 /opt/hadoop/bin/yarn --daemon start resourcemanager

docker exec datanode1 /opt/hadoop/bin/yarn --daemon start nodemanager
docker exec datanode2 /opt/hadoop/bin/yarn --daemon start nodemanager
docker exec datanode3 /opt/hadoop/bin/yarn --daemon start nodemanager