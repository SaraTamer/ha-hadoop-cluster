# when compose down and up:

docker cp scripts/setup.sh nn1:/setup.sh
docker cp scripts/setup.sh nn2:/setup.sh

docker cp scripts/setup.sh datanode1:/setup.sh
docker cp scripts/setup.sh datanode2:/setup.sh
docker cp scripts/setup.sh datanode3:/setup.sh
docker cp scripts/configure-hadoop.sh datanode3:/configure-hadoop.sh
docker cp scripts/configure-hadoop.sh datanode2:/configure-hadoop.sh
docker cp scripts/configure-hadoop.sh datanode1:/configure-hadoop.sh
docker cp scripts/configure-hadoop.sh nn1:/configure-hadoop.sh
docker cp scripts/configure-hadoop.sh nn2:/configure-hadoop.sh
docker cp scripts/configure-zookeeper.sh nn1:/configure-zookeeper.sh
docker cp scripts/configure-zookeeper.sh nn2:/configure-zookeeper.sh
docker cp scripts/configure-zookeeper.sh datanode1:/configure-zookeeper.sh
docker cp scripts/configure-zookeeper.sh datanode2:/configure-zookeeper.sh
docker cp scripts/configure-zookeeper.sh datanode3:/configure-zookeeper.sh
docker exec nn1 chmod +x /setup.sh /configure-hadoop.sh /configure-zookeeper.sh
docker exec nn2 chmod +x /setup.sh /configure-hadoop.sh /configure-zookeeper.sh
docker exec datanode1 chmod +x /setup.sh /configure-hadoop.sh /configure-zookeeper.sh
docker exec datanode2 chmod +x /setup.sh /configure-hadoop.sh /configure-zookeeper.sh
docker exec datanode3 chmod +x /setup.sh /configure-hadoop.sh /configure-zookeeper.sh

docker exec nn1 sed -i 's/\r$//' /setup.sh
docker exec nn2 sed -i 's/\r$//' /setup.sh
docker exec datanode1 sed -i 's/\r$//' /setup.sh
docker exec datanode2 sed -i 's/\r$//' /setup.sh
docker exec datanode3 sed -i 's/\r$//' /setup.sh

docker exec -it nn1 /configure-hadoop.sh
docker exec -it nn2 /configure-hadoop.sh
docker exec -it datanode1 /configure-hadoop.sh
docker exec -it datanode2 /configure-hadoop.sh
docker exec -it datanode3 /configure-hadoop.sh

docker exec -it nn1 /configure-zookeeper.sh
docker exec -it nn2 /configure-zookeeper.sh
docker exec -it datanode1 /configure-zookeeper.sh

# start cluster:
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

# Test jps
docker exec nn1 jps
docker exec nn2 jps
docker exec datanode1 jps
docker exec datanode2 jps
docker exec datanode3 jps

docker exec nn1 /opt/hadoop/bin/hdfs haadmin -getServiceState nn1
docker exec nn1 /opt/hadoop/bin/hdfs haadmin -getServiceState nn2

# Test automatic failover for hdfs:
# if nn1 is the active:
docker stop nn1
docker exec nn2 /opt/hadoop/bin/hdfs haadmin -getServiceState nn1
docker exec nn2 /opt/hadoop/bin/hdfs haadmin -getServiceState nn2

docker start nn1
docker exec nn1 /opt/zookeeper/bin/zkServer.sh start
docker exec nn1 /opt/hadoop/bin/hdfs --daemon start journalnode
docker exec nn1 /opt/hadoop/bin/hdfs --daemon start zkfc
docker exec nn1 /opt/hadoop/bin/hdfs --daemon start namenode
docker exec nn1 jps
# else:
docker stop nn2
docker exec nn1 /opt/hadoop/bin/hdfs haadmin -getServiceState nn1
docker exec nn1 /opt/hadoop/bin/hdfs haadmin -getServiceState nn2

docker start nn2

docker exec nn1 /opt/hadoop/bin/hdfs haadmin -getServiceState nn1
docker exec nn1 /opt/hadoop/bin/hdfs haadmin -getServiceState nn2
#or
docker exec -it datanode1 bash
hdfs haadmin -getAllServiceState

# test yarn failover:
# stop datanode1 from docker
# after stopping datanode1, test:
docker exec datanode1 /opt/hadoop/bin/yarn rmadmin -getServiceState rm1
docker exec datanode2 /opt/hadoop/bin/yarn rmadmin -getServiceState rm1
docker exec datanode1 /opt/hadoop/bin/yarn rmadmin -getServiceState rm2

# restart datanode1 from docker and then:
docker exec datanode1 /opt/zookeeper/bin/zkServer.sh start
docker exec datanode1 /opt/hadoop/bin/hdfs --daemon start journalnode
docker exec datanode1 /opt/hadoop/bin/hdfs --daemon start datanode
docker exec datanode1 /opt/hadoop/bin/yarn --daemon start resourcemanager
docker exec datanode1 /opt/hadoop/bin/yarn --daemon start nodemanager
docker exec datanode1 jps | findstr ResourceManager

# before ingest data into hdfs
#check hdfs mounted directories
docker inspect nn2 | Select-String -Pattern "Mounts|Source|Destination" -Context 2,8
docker exec nn2 ls -la /shared/
#or
root@nn1:/# ls -la /shared/
# make directories for mapreduce job
hdfs dfs -mkdir /data/mr_input
hdfs dfs -mkdir /data/mr_output
# ingest data into hdfs
hdfs dfs -put /shared/weather_dataset/hourly/[12] /data/mr_input

#test yarn with simple built-in job
yarn jar /opt/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-*.jar pi 2 10
# run my mapreduce job
hadoop jar shared/mapreduce.jar /data/mr_input /data/mr_output/1

