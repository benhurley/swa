#!/bin/sh
#rollback.sh

# This script handles the rollback process automatically for the east and west regions.
# The script will check to see if a revert is necessary, and if so, will perform the revert
# on the codebase (effectively rolling back to the last commit). If a revert has already been
# done, it will deploy the rollback build to the target environment. It will also pause for log
# validation and terminate if the user finds an error.

echo --------------------
echo Initiating Rollback
echo --------------------
echo
# Determine Region
#TODO hard-coding west for now, need to read param
myRegion="west"

otherRegion=""

echo Current Region: $myRegion
echo

# determine other region
if [[ $myRegion = "west" ]];
then 
    otherRegion="east"
    else
    otherRegion="west"
fi

# Pick a branch to switch to
echo Switching to master branch
echo
git checkout master

echo Pulling updates from remote repository
echo
git pull

echo Checking last commit message for Revert
revertCheck="$(git log -1 --format=%s)"
echo Last Commit: $revertCheck
if [[ $revertCheck = *Revert* ]] ;
then
    echo
    echo REVERT FOUND: Codebase has already reverted, deploying HEAD to $myRegion
    #deploy HEAD to current environment

    else    
    echo No revert found.
    echo

    if [[ $revertCheck = *Merge* ]] ;
    then
        echo Merge found. Reverting branch merge. (most-recent commit):
        echo
        git log -1
        echo
        git revert -m 1 HEAD
        echo Pushing changes to remote repository
        echo
        git push
    else
        echo
        echo No merge found.
    fi
fi

# else we are in east region (edge case)

# echo
# echo Routing 10% of traffic to $myRegion
# TODO add that functionality
# echo
# echo Pause for examining CloudWatch Logs, enter 'y' to continue
# read ans1
# if [[ $ans1 = y ]]; 
# then 
#    echo
#    echo Routing 100% of traffic to $myRegion
#    #TODO add that functionality
#    echo
#    echo Pause for examining CloudWatch Logs, enter 'y' to continue
#    read ans2

#    if [[ $ans2 = y ]]; 
#    then 
#        echo Rollback complete, re-routing 100% of traffic back to $otherRegion.
        #TODO add that functionality
#    else
#        echo Error found. Re-routing 100% of traffic back to $otherRegion for manual debug.
        #TODO add that functionality
#    fi
#else   
#    echo Error found. Re-routing 100% of traffic back to $otherRegion for manual debug.
    #TODO add that functionality
#fi