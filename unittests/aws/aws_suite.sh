#!/usr/bin/env bash

mkdir -p logs

echo "(1) Executing aws vpc only testcases."
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
go test -timeout 0 -v aws_vpc_only_test.go | tee logs/aws_vpc_only_test.go
echo "(2) Executing aws vpc + bastion only testcase."
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
go test -timeout 0 -v aws_bastion_only_test.go | tee logs/aws_bastion_only_test.log
echo "(3) Executing aws new vpc 1AZ minimal remote mount setup testcase."
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
go test -timeout 0 -v aws_new_vpc_1AZ_remote_test.go | tee logs/aws_new_vpc_1AZ_remote_test.log
echo "(4) Executing aws new vpc 1AZ compute cluster only testcase."
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
go test -timeout 0 -v aws_new_vpc_1AZ_compute_test.go | tee logs/aws_new_vpc_1AZ_compute_test.log
echo "(5) Executing aws new vpc 1AZ storage cluster only testcase."
echo "+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+"
go test -timeout 0 -v aws_new_vpc_1AZ_storage_test.go | tee logs/aws_new_vpc_1AZ_storage_test.log
echo "(6) Executing aws new vpc 1AZ storage cluster with dual disks only testcase."
go test -timeout 0 -v aws_new_vpc_1AZ_storage_2disk_test.go | tee logs/aws_new_vpc_1AZ_storage_2disk_test.log
echo "(7) Executing aws new vpc 3AZ minimal remote mount setup testcases."
go test -timeout 0 -v aws_new_vpc_3AZ_remote_test.go | tee logs/aws_new_vpc_3AZ_remote_test.log
