#!/usr/bin/env bash
set -eux

cd $HOME/tfrt

git fetch origin
git fetch rocm_fork

git branch master --set-upstream-to rocm_fork/master
git merge origin/master --ff-only
git push rocm_fork master


