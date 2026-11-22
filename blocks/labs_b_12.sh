sudo fio --name=randread --filename=/data/testfile --size=200M --rw=randread \
     --bs=4k --direct=1 --runtime=30 --time_based --group_reporting
