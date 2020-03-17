#!/bin/bash

source_host=yemekumbara
source_port=6379
source_db=1
target_host=10.1.5.102
target_port=6379
target_db=1

#copy all keys without preserving ttl!
redis-cli -h $source_host -p $source_port -n $source_db keys \* | while read key; do echo "Copying $key"; redis-cli --raw -h $source_host -p $source_port -n $source_db DUMP "$key" | head -c -1|redis-cli -x -h $target_host -p $target_port -n $target_db RESTORE "$key" 0; done
