#! /usr/bin/bash

readarray -t branches < <(git fetch --all | git branch --remote | grep -vE 'master|main')
branches_to_delete=()
for branch in ${branches[@]}; do
	branch_name=$(echo $branch | sed 's/origin\///')
	echo "branch: $branch_name"
	open_pr=$(gh pr list --head $branch_name --json number | jq length)
	if [ $open_pr -eq 0 ]; then
		branches_to_delete+=$branch_name
		echo "$branch_name added to delete list"
		echo $branch_name >> $GITHUB_STEP_SUMMARY
	else
		echo "no open pull requests for $branch_name"
	fi
done
