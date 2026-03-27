#!/bin/bash

git remote set-url origin "git@github.com:${GITHUB_REPOSITORY}.git"

git submodule sync --recursive && git submodule update --init --recursive