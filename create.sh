#!/bin/bash

# Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

templatebucket=$1
templateprefix=$2
stackname=$3
region=$4
SCRIPTDIR=`dirname $0`
if [ "$templatebucket" == "" ]
then
    echo "Usage: $0 <template bucket> <template prefix> <stack name> <region>"
    exit 1
fi
if [ "$templateprefix" == "" ]
then
    echo "Usage: $0 <template bucket> <template prefix> <stack name> <region>"
    exit 1
fi
if [ "$stackname" == "" ]
then
    echo "Usage: $0 <template bucket> <template prefix> <stack name> <region>"
    exit 1
fi
if [ "$region" == "" ]
then
    echo "Usage: $0 <template bucket> <template prefix> <stack name> <region>"
    exit 1
fi

# Check if we need to append region to S3 URL
TEMPLATE_URL=https://s3.amazonaws.com/$templatebucket/$templateprefix/master.yaml
if [ "$region" != "us-east-1" ]
then
    TEMPLATE_URL=https://s3-$region.amazonaws.com/$templatebucket/$templateprefix/master.yaml
fi

aws s3 cp master.yaml s3://$templatebucket/$templateprefix/master.yaml --region $region
aws s3 cp network.yaml s3://$templatebucket/$templateprefix/network.yaml --region $region
aws s3 cp secgroups.yaml s3://$templatebucket/$templateprefix/secgroups.yaml --region $region
aws s3 cp aurora.yaml s3://$templatebucket/$templateprefix/aurora.yaml --region $region
aws s3 cp proxysql.yaml s3://$templatebucket/$templateprefix/proxysql.yaml --region $region

aws cloudformation create-stack --stack-name $stackname \
    --template-url $TEMPLATE_URL \
    --parameters \
    ParameterKey=TemplateBucketName,ParameterValue=$templatebucket \
    ParameterKey=TemplateBucketPrefix,ParameterValue=$templateprefix \
    ParameterKey=ProjectTag,ParameterValue=proxysqlblog \
    ParameterKey=vpccidr,ParameterValue="10.20.0.0/16" \
    ParameterKey=AllowedCidrIngress,ParameterValue="0.0.0.0/0" \
    ParameterKey=AppPrivateCIDRA,ParameterValue="10.20.3.0/24" \
    ParameterKey=AppPrivateCIDRB,ParameterValue="10.20.4.0/24" \
    ParameterKey=AppPrivateCIDRC,ParameterValue="10.20.5.0/24" \
    ParameterKey=AppPrivateCIDRD,ParameterValue="10.20.6.0/24" \
    ParameterKey=AppPublicCIDRA,ParameterValue="10.20.1.0/24" \
    ParameterKey=AppPublicCIDRB,ParameterValue="10.20.2.0/24" \
    ParameterKey=DatabaseName,ParameterValue="proxysqlexample" \
    ParameterKey=DatabaseUser,ParameterValue="proxysqluser" \
    ParameterKey=DatabasePassword,ParameterValue="pr0xySQL01Cred" \
    ParameterKey=DbInstanceSize,ParameterValue="db.r4.large" \
    ParameterKey=keyname,ParameterValue="ProxySQLDemo" \
    --tags Key=Project,Value=proxysqlblog \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --region $region
