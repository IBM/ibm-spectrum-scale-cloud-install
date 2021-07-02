#!/usr/bin/env bash

mkdir -p logs

echo "Executing aws vpc only testcases."
go test -timeout 40m -v aws_vpc_only_test.go | tee logs/aws_vpc_only_test.go
echo "Executing aws vpc + bastion only testcases."
go test -timeout 40m -v aws_bastion_only_test.go | tee logs/aws_bastion_only_test.log
echo "Executing aws new vpc 1AZ remote setup testcases."
go test -timeout 2h -v aws_new_vpc_1AZ_remote_test.go | tee logs/aws_new_vpc_1AZ_remote_test.log
echo "Executing aws new vpc 1AZ compute cluster only testcases."
go test -timeout 1h -v aws_new_vpc_compute_only.go | tee logs/aws_new_vpc_compute_only.log
