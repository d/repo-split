#!/bin/bash

set -uxe

if [ $# -ne 2 ]; then
	echo "expected two arguments given $#"
	exit 1
fi

VCAP_REPO=$1
CLONE_BASE=$2
CLONE_PATH=$(mktemp -d "$CLONE_BASE/vcap.XXX")
SCRIPT_DIR=$(cd $(dirname $0) && pwd)

git clone $VCAP_REPO $CLONE_PATH
cd $CLONE_PATH
for c in router staging stager; do
	git checkout --quiet origin/master
	git checkout -b small_$c
	git filter-branch -f --prune-empty --subdirectory-filter $c --index-filter "git rm --quiet --cached --ignore-unmatch -r -f vendor/cache"
	git push -v git@github.com:d/vcap-$c.git HEAD:master
done

# package_cache and friends
git checkout --quiet origin/master
git checkout -b package_cache-and-friends
INDEX_FILTER="git rm -r -f --cached --quiet --ignore-unmatch \$(git ls-tree --name-only \$GIT_COMMIT | egrep -v '^package_cache|package_cache_client|.gitignore' ) \*/vendor/cache/\*"
git filter-branch -f --prune-empty \
	--index-filter "$INDEX_FILTER" \
	--parent-filter $SCRIPT_DIR/parent-filter.rb
git push -v git@github.com:d/package_cache-and-friends.git HEAD:master

git checkout --quiet origin/master
git checkout -b cchm
INDEX_FILTER="git rm -r -f --cached --quiet --ignore-unmatch \$(git ls-tree --name-only \$GIT_COMMIT | egrep -v '^cloud_controller|health_manager|.gitignore' ) \*/vendor/cache/\*"
git filter-branch -f --prune-empty \
	--index-filter "$INDEX_FILTER" \
	--parent-filter $SCRIPT_DIR/parent-filter.rb
git push -v git@github.com:d/cchm.git HEAD:master


git branch -v
