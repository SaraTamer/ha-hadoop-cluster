#!/bin/bash

# Configure ZooKeeper
cat > /opt/zookeeper/conf/zoo.cfg << EOF
tickTime=2000
dataDir=/tmp/zookeeper
clientPort=2181
initLimit=5
syncLimit=2
server.1=nn1:2888:3888
server.2=nn2:2888:3888
server.3=datanode1:2888:3888
EOF

# Set myid based on hostname
case $(hostname) in
    nn1)
        echo 1 > /tmp/zookeeper/myid
        ;;
    nn2)
        echo 2 > /tmp/zookeeper/myid
        ;;
    datanode1)
        echo 3 > /tmp/zookeeper/myid
        ;;
esac