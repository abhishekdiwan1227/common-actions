#! /usr/bin/bash

readarray -t branches < <(git fetch --all | git branch --remote | grep -vE 'master|main')
echo "# deleted branches" >> $GITHUB_STEP_SUMMARY
for branch in ${branches[@]}; do
	branch_name=$(echo $branch | sed 's/origin\///')
	echo "branch: $branch_name"
	open_pr=$(gh pr list --head $branch_name --json number | jq length)
	if [ $open_pr -eq 0 ]; then
		echo "deleting $branch_name"
		git push origin --delete $branch_name
		echo "- $branch_name" >> $GITHUB_STEP_SUMMARY
	else
		echo "no open pull requests for $branch_name"
	fi
done
