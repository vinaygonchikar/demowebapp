#!/bin/bash
set -xe
git pull --all
##count total number of branch
NO_LINES=$(git branch -r | wc -l)
NO_BRANCH_COUNT=$(($NO_LINES - 1))
# NO_BRANCH_COUNT=$(git branch -r | wc -l)
echo "number of branches in this repository is '$NO_BRANCH_COUNT"
##a first two branch repitative thats why starting from line 3
COUNT=2
while [ $COUNT -le $(($NO_BRANCH_COUNT + 1)) ]     
do
	echo "Welcone $(($COUNT-1)) branch"  
    BRANCH_NAME=$(git branch -r | cut -d'/' -f2 | head -$COUNT | tail -1)   
    echo "target branch is $BRANCH_NAME"
    git checkout master
    gh pr create --title "merge from master" --body "pull request sent by GitHub action" --base $BRANCH_NAME
    pullrequeststatus=$(echo $?)
    if [ $pullrequeststatus == 0 ]
    then
        PULLREQUEST_NO=$(gh pr view $BRANCH_NAME | head -10 | grep "number:" | cut -d':' -f2 | xargs echo -n)
        echo "$PULLREQUEST_NO"
        gh pr merge $PULLREQUEST_NO --auto -m
        mergerequeststatus=$(echo $?)
        if [ $mergerequeststatus != 0 ]
        then
            echo "sending slack message for fail to send merge pull request"
        fi
    else
    echo "sending slack message for fail to send pull request"
    fi
	(( COUNT++ ))
done