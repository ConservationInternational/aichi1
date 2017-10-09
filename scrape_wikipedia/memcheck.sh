while true
do
echo "---------------------------------" >> /tmp/mem_usage
date >> /tmp/mem_usage
ps u >> /tmp/mem_usage
sleep 600
done
