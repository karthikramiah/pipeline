#!/bin/bash

AWSBIN="aws --region us-east-1"
file="accounts.txt"
dirs='internal external'
#mainfile=mcs-delegated-admin-$j-permission-boundary.yml

function run_stackset(){
  echo $1
  
  TEMPLATE_BODY=`cat cdn_stacksets/$2/$3`
  application=$4

  $AWSBIN cloudformation describe-stack-set --stack-set-name $2 2> /tmp/$$.check || true
  grep "not found" /tmp/$$.check
  if [ $? == 0 ]; then
     STACK_SET_OPERATION=create-stack-set
     echo " Stack not found...Creating new Stack"
     $AWSBIN cloudformation $STACK_SET_OPERATION \
        --stack-set-name $2 \
        --template-body "$TEMPLATE_BODY" \
        --region us-east-1 \
        --parameters ParameterKey=ApplicationName,ParameterValue=$application ParameterKey=Exception,ParameterValue='false' \
        --capabilities CAPABILITY_NAMED_IAM
  else
     STACK_SET_OPERATION=update-stack-set
     echo "Stack already exists...Updating......"
     $AWSBIN cloudformation $STACK_SET_OPERATION \
        --stack-set-name $2 \
        --template-body "$TEMPLATE_BODY" \
        --region us-east-1 \
        --accounts $1 \
        --regions '["us-east-1"]' \
        --parameters ParameterKey=ApplicationName,ParameterValue=$application ParameterKey=Exception,ParameterValue='false' \
        --capabilities CAPABILITY_NAMED_IAM
  fi   
  sleep 10

  set -e
  $AWSBIN cloudformation describe-stack-instance --region us-east-1 --stack-set-name $2 --stack-instance-account $1 --stack-instance-region us-east-1 2> /tmp/$$.check || true
  cat /tmp/$$.check
  set +e
  grep "not found" /tmp/$$.check
  if [ $? == 0 ]; then
    STACK_INSTANCE_OPERATION=create-stack-instances
  else
    STACK_INSTANCE_OPERATION=update-stack-instances
  fi
  rm /tmp/$$.check

  while [ true ]
  do
    echo "CHECKING_STATUS"
    $AWSBIN cloudformation list-stack-set-operations --stack-set-name $2 > /tmp/$$.check || true
    set +e
      grep -i "running" /tmp/$$.check
      if [ $? != 0 ]; then
	  break
      fi
      cat /tmp/$$.check
      rm /tmp/$$.check
      # $AWSBIN cloudformation describe-stack-instance --region us-east-1 --stack-set-name $1 --stack-instance-account $a --stack-instance-region us-east-1 
      sleep 5s
    done

    $AWSBIN cloudformation $STACK_INSTANCE_OPERATION \
      --stack-set-name $2 \
      --accounts $1 \
      --region us-east-1 \
      --regions '["us-east-1"]' \
      --operation-preferences "FailureToleranceCount=0,MaxConcurrentCount=2"
}

while read -r line
do
  applicationname=$(echo $line | cut -d- -f1)
  accounts=$(echo $line | cut -d: -f1)
  services=$(echo $line | cut -d: -f2)
  #cp -rp stacksets/internal/* cdn_stacksets/internal/.
  #cp -rp stacksets/external/* cdn_stacksets/external/.
  IFS=', ' read -r -a array <<< "$services"
  for service in "${array[@]}"
  do
     for j in $dirs
     do
       if [ $j == "internal" ]; then
         sfile='mcs-delegated-admin-internal-permission-boundary.yml mcs-delegated-user-internal-permission-boundary.yml'
       elif [ $j == "external" ]; then
         sfile='mcs-delegated-admin-external-permission-boundary.yml mcs-delegated-user-external-permission-boundary.yml'
       fi
       cd ./snippets
       if [ -s "$service.yml" ]; then
	      echo "$service snippet file exists and is not empty....Appending"
         cd ../cdn_stacksets/$j
         for mainfile in $sfile
         do
            python3 ../../file_con.py $mainfile ../../snippets/$service.yml
         done
         cd ../..
       else
         echo "$service snippet doesn't exists or is empty"
         exit
       fi
     done
  done
  for ssets in $dirs
  do 
      if [ "$ssets" == "internal" ]; then
         sfile='mcs-delegated-admin-internal-permission-boundary.yml mcs-delegated-user-internal-permission-boundary.yml'
      elif [ "$ssets" == "external" ]; then
         sfile='mcs-delegated-admin-external-permission-boundary.yml mcs-delegated-user-external-permission-boundary.yml'
      fi
      for mainfile in $sfile
      do
	if [[ "$mainfile" == *"admin"* ]]; then
	    ssprefix="admin"
         else
	    ssprefix="user"
	fi
        run_stackset $accounts $ssets $mainfile $applicationname
        #echo $accounts $ssets-$ssprefix $mainfile $applicationname
      done
  done
done < accounts.txt
