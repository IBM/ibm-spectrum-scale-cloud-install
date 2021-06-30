#!/usr/bin/env bash

mkdir -p logs

#echo "Executing aws vpc only testcases."
#go test -timeout 40m -v aws_vpc_only_test.go | tee logs/aws_vpc_only_test.go
#echo "Executing aws vpc + bastion only testcases."
#go test -timeout 40m -v aws_bastion_only_test.go | tee logs/aws_bastion_only_test.log
echo "Executing aws new vpc only testcases."
go test -timeout 2h -v aws_new_vpc_minimal_test.go | tee logs/aws_new_vpc_minimal_test.log
