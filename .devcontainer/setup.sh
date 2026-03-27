#!/bin/bash

git remote set-url origin "https://github.com/${GITHUB_REPOSITORY}.git"

git submodule sync --recursive && git submodule update --init --recursive