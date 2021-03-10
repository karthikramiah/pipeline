#!/bin/bash

AWSBIN="$1 --region us-east-1"
std_role='Cloud-Services-Ops-Role cloud-custodian cloud-workers cloudhealth-service-role itrms-cyber-security-role itrms-dsp-eng-role master-role mcs-readonly-role network-role remedy-eng-role sevone-user srv-addm ip-deny-policy mcs-organisation-account-access-role-policy mcs-costoptimization-role prisma-cloud-role'

function run_stackset(){
  echo $1
  
  $AWSBIN cloudformation describe-stack-set --stack-set-name $2 --stack-instance-account $1 2> /tmp/$$.check || true
  grep "not found" /tmp/$$.check
  if [ $? == 0 ]; then
     STACK_SET_OPERATION=create-stack-set
  else
     STACK_SET_OPERATION=update-stack-set
  fi
  echo $STACK_SET_OPERATION

  grep PasswordParameter stacksets/$2/template.yml
    if [ $? == 0 ]; then
        # password is required for iam users - keep quiet - use federation resetPassword URL to reset
        echo 'Generating password'
        set +x
        STRONG_PASSWORD=`gpg --gen-random --armor 1 14 | head -1 | awk '{print $1}'`
        $AWSBIN cloudformation $STACK_SET_OPERATION \
        --stack-set-name $2 \
        --template-body "$TEMPLATE_BODY" \
        --parameters ParameterKey=PasswordParameter,ParameterValue=$STRONG_PASSWORD \
        --region us-east-1 \
        --capabilities CAPABILITY_NAMED_IAM
        set -x
    else
        echo 'Not generating password'
        $AWSBIN cloudformation $STACK_SET_OPERATION \
        --stack-set-name $1 \
        --template-body "$TEMPLATE_BODY" \
        --region us-east-1 \
        --capabilities CAPABILITY_NAMED_IAM
    fi
}

while read p; do
  echo "$p"
  for i in $std_role
  do
    run_stackset $p $i
  done
done < accounts.txt
