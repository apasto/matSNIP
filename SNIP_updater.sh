#!/usr/bin/env bash
# Call to UpdateCONTENTS.sh after commits, using CI
# This is called by .travis.yml

GH_REPO="@github.com/$GH_USER/$GH_REPONAME.git"
FULL_REPO="https://$GH_TOKEN$GH_REPO"

# setup REPO and checkout gh-pages branch
git init
#git remote add origin "$FULL_REPO"
git remote set-url origin "$FULL_REPO"
git fetch
git config user.name "rapporter-travis"
git config user.email "travis"
git checkout master

# call
bash ./UpdateCONTENTS.sh

# commit and push changes
git add README.md
git add "./+SNIP/DispContents.m"
git commit -m "Contents update by travis after $TRAVIS_COMMIT"
git push origin master
