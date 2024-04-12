#! /bin/bash

while getopts e:c: flag
do
    case "${flag}" in
        e) env=${OPTARG};;
        c) cmd=${OPTARG};;
    esac
done

export TF_DATA_DIR="./environments/$env/.terraform"

case $cmd in
init)
  terraform init -backend-config ./environments/$env/backend-config.tfvars;;
plan)
  terraform plan -var-file ./environments/$env/env-config.tfvars;;
apply)
  terraform apply -var-file ./environments/$env/env-config.tfvars;;
show)
  terraform show;;
*)
  echo "invalid command: $cmd.  Must be init, plan, or apply.";;
esac

  