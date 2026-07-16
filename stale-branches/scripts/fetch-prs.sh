#! /usr/bin/bash

readarray -t branches < <(git branch --remote | grep -vE 'master|main')
for branch in $branches; do
	branch_name=$(echo $branch | sed 's/origin\///')
	echo "branch: $branch_name"
	open_pr=$(gh pr list --head $branch_name --json number)
	echo "open_pr=$open_pr" >>$GITHUB_OUTPUT
done
