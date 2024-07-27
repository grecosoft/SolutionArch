#! /bin/bash

while getopts e:c:s:t:o:p: flag
do
    case "${flag}" in
        e) env=${OPTARG};;
        c) cmd=${OPTARG};;
        s) azSubId=${OPTARG};;
        t) azTenId=${OPTARG};;
        o) azOrgUrl=${OPTARG};;
        p) azPat=${OPTARG};;
    esac
done

if [ ! "$env" ]; then
    echo "e: Environment not specified"
    exit 1
fi

if [ ! "$azSubId" ]; then
    echo "s: Azure Subscription not Specified"
    exit 1
fi

if [ ! "$azTenId" ]; then
    echo "t: Azure Tenant not Specified"
    exit 1
fi

if [ ! "$azOrgUrl" ]; then
    echo "o: DevOps Orgization Url not Specified"
    exit 1
fi

if [ ! "$azPat" ]; then
    echo "p: DevOps Personal Access Token not Specified"
    exit 1
fi

export TF_DATA_DIR="./environments/$env/.terraform"
export AZDO_ORG_SERVICE_URL=$azOrgUrl
export AZDO_PERSONAL_ACCESS_TOKEN=$azPat

case $cmd in
init)
  terraform init -backend-config ./environments/$env/backend-config.tfvars;;
plan)
  terraform plan -var-file ./environments/$env/env-config.tfvars -var "subscriptionId=${azSubId}" -var "tenantid=${azTenId}";;
apply)
  terraform apply -auto-approve -var-file ./environments/$env/env-config.tfvars -var "subscriptionId=${azSubId}" -var "tenantid=${azTenId}";;
show)
  terraform show;;
*)
  echo "invalid command: $cmd.  Must be init, plan, or apply.";;
esac