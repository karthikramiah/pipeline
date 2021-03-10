#!/bin/bash

while read -r line
do
  echo $line
  appname=$(echo $line | cut -d- -f1)
  echo $appname
  accounts=$(echo $line | cut -d: -f1 | cut -d- -f2)
  echo $accounts
  services=$(echo $line | cut -d: -f2)
  echo $services
  IFS=', ' read -r -a array <<< "$services"
  for service in "${array[@]}"
  do
     echo $service
  done
done < accounts.txt
