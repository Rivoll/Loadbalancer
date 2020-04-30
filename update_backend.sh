#!/bin/bash
REGION=`cat instance_region`
aws ec2 describe-instances --region $REGION --filters 'Name=tag:Name,Values=public' --query 'Reservations[].Instances[].PrivateIpAddress[]' --output text > new_IPs.txt
sed -i 's/\s/\n/g' new_IPs.txt
sort -o new_IPs.txt  new_IPs.txt

while read o; do
  if [[ `curl -o /dev/null -s -w "%{http_code}\n" "$o"`  == 200 ]]
  then echo "$o" >> New_working_IPs.txt
  else
    echo "$o is unavailaible"
 fi
done < new_IPs.txt

sort New_working_IPs.txt | uniq > tmp
cat tmp  > New_working_IPs.txt
rm tmp
DIFF=$(diff IPs.txt New_working_IPs.txt)
if [[ "$DIFF" != "" ]] ;
then
        echo "Updating backend IPs"
        cat New_working_IPs.txt > IPs.txt
        rm New_working_IPs.txt
        sed '=' IPs.txt | sed 'N; s/\n/ /' > formated_IPs.txt
        sed -ie 's/^/    server public/' formated_IPs.txt
        sed -ie 's/$/:80/' formated_IPs.txt
        cat config_template > haproxy.cfg
        cat formated_IPs.txt >> haproxy.cfg
        sudo mv -f haproxy.cfg /etc/haproxy/haproxy.cfg
        sudo service haproxy restart
        else
                echo "Everything is up to date"
fi
