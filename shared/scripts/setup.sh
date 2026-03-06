#!/bin/bash

# Install Java and utilities
apt-get update
apt-get install -y openjdk-11-jdk ssh pdsh wget vim net-tools dnsutils

# Setup SSH
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# SSH config to avoid host key checking
cat > ~/.ssh/config << EOF
Host *
   StrictHostKeyChecking no
   UserKnownHostsFile=/dev/null
EOF

# Setup Hadoop directories
mkdir -p /opt/hadoop
cp -r /shared/hadoop-3.4.2/* /opt/hadoop/

# Setup environment variables
cat >> ~/.bashrc << EOF
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/opt/hadoop
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin
export HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop
export HDFS_NAMENODE_USER=root
export HDFS_DATANODE_USER=root
export HDFS_JOURNALNODE_USER=root
export HDFS_ZKFC_USER=root
export YARN_RESOURCEMANAGER_USER=root
export YARN_NODEMANAGER_USER=root
EOF

source ~/.bashrc

# Setup ZooKeeper directories
mkdir -p /opt/zookeeper
cp -r /shared/apache-zookeeper-3.8.6-bin/* /opt/zookeeper/
mkdir -p /tmp/zookeeper