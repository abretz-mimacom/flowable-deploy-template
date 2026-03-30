#!/bin/bash

git remote add origin x
git fetch
git checkout dev

git submodule sync --recursive && git submodule update --init --recursive

chmod +x scripts/*

