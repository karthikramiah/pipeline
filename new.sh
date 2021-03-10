#!/bin/bash

if [ "$1" == "Both" ]; then
   dirs='internal external'
else
   dirs=$1
fi

for i in $dirs
do
  echo $i
  if [ "$i" == "internal" ]; then
     file=accounts_internal.txt
  elif [ "$i" == "external" ]; then
     file=accounts_external.txt
  fi
  echo $file
  while read -r line
  do  
    echo $line
  done < $file
done
