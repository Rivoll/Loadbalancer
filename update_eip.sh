#!/bin/bash
REGION=`cat instance_region`
aws ec2 describe-addresses --region $REGION --filters 'Name=tag:Name,Values=lb' --query Addresses[].NetworkInterfaceId[] > eip

if [[ `cat eip` == "[]"  ]] ;
then
        echo "cle non alloue. Allocation en cours ..."
        ALLOC_ID=`aws ec2 describe-addresses --region $REGION --filters 'Name=tag:Name,Values=lb' --query Addresses[].AllocationId --output text`
        INSTANCE_ID=`cat instance_id`
         aws ec2 associate-address --region eu-west-2 --instance-id $INSTANCE_ID --allocation-id $ALLOC_ID
        echo "alloc id = $ALLOC_ID, instance id = $INSTANCE_ID"
else
        echo "cle deja alloue"
fi
