#!/bin/bash

set -uxe

if [ $# -ne 2 ]; then
	echo "expected two arguments given $#"
	exit 1
fi

VCAP_REPO=$1
CLONE_BASE=$2
CLONE_PATH=$(mktemp -d "$CLONE_BASE/vcap.XXX")

git clone $VCAP_REPO $CLONE_PATH
cd $CLONE_PATH
for c in common cloud_controller dea health_manager router staging stager package_cache package_cache_client; do
	git checkout --quiet origin/master
	git checkout -b small_$c
	git filter-branch -f --prune-empty --subdirectory-filter $c --index-filter "git rm --quiet --cached --ignore-unmatch -r -f vendor/cache"
	git push -v --dry-run git@github.com:d/vcap-$c.git HEAD:master
done

# warden and friends
git checkout --quiet origin/master
git checkout -b warden-and-friends
git filter-branch -f --prune-empty --index-filter "git rm --quiet --cached --ignore-unmatch -r -f !(warden|warden-client|em-warden-client)"
git push -v git@github.com:d/vcap-warden-and-friends.git HEAD:master

git branch -v
