#!/usr/bin/env bash

STAGED_GO_FILES=$(git diff --cached --name-only | grep ".go$")

if [[ "$STAGED_GO_FILES" = "" ]]; then
    exit 0
fi

GOLINT=$GOPATH/bin/golint

# Check for golint
if [[ ! -x "$GOLINT" ]]; then
    printf "\t\033[41mPlease install golint\033[0m (go get -u golang.org/x/lint/golint)"
    exit 1
fi

PASS=true

for FILE in $STAGED_GO_FILES
do
    # Run golint on the staged file and check the exit status
    $GOLINT "-set_exit_status" $FILE
    if [[ $? == 1 ]]; then
        printf "\t\033[31mgolint $FILE\033[0m \033[0;30m\033[41mFAILURE!\033[0m\n"
        PASS=false
    else
        printf "\t\033[32mgolint $FILE\033[0m \033[0;30m\033[42mpass\033[0m\n"
    fi
done

if ! $PASS; then
    printf "\033[0;30m\033[41mCOMMIT FAILED\033[0m\n"
    exit 1
else
    printf "\033[0;30m\033[42mCOMMIT SUCCEEDED\033[0m\n"
fi

exit 0
