#! /usr/bin/env bash

if [ $# -lt 1 ]; then
	printf "no input increment flag captured\n"
	exit 1
fi

if [ ! -e CHANGELOG ]; then
	printf "no CHANGELOG file found in directory"
	exit 1
fi

flag=$1

year=$(date +%y)
month=$(date +%m)
major_version=$year$month
minor_version=0
patch_version=0

awk_script=$(
	cat <<-'EOF'
		match($0, /^([0-9]+\.[0-9]+\.[0-9]+) - [0-9]{4}\.[0-9]{2}\.[0-9]{2}$/, m) {print m[1]; exit;}
	EOF
)

version=$(awk -e "$awk_script" CHANGELOG)

captured_major_version=
captured_minor_version=
captured_patch_version=

version_regex="([0-9]+)\.([0-9]+)\.([0-9]+)"
if [[ $version =~ $version_regex ]]; then
	captured_major_version=${BASH_REMATCH[1]}
	captured_minor_version=${BASH_REMATCH[2]}
	captured_patch_version=${BASH_REMATCH[3]}
else
	printf "no match\n"
	exit 1
fi

echo old version $captured_major_version.$captured_minor_version.$captured_patch_version

last_commit_msg=$(git log -1 --format=%B)

if [ $((major_version)) -ne $((captured_major_version)) ]; then
	captured_patch_version=0
	captured_minor_version=0
	printf "new major"
fi

if [ $flag = "-p" ]; then
	patch_version=$(($captured_patch_version + 1))
	printf "%s" $patch_version
elif [ $flag = "-m" ]; then
	minor_version=$(($captured_minor_version + 1))
	printf "%s" $minor_version
fi

next_version=$major_version.$minor_version.$patch_version

sed_script=$(
	cat <<-EOF
		/^[U|u]nreleased[[:space:]]*$/a $next_version - $(date +%Y.%m.%d)\n$last_commit_msg
		1G
	EOF
)

sed -e "$sed_script" CHANGELOG >CHANGELOG.tmp && mv CHANGELOG.tmp CHANGELOG
