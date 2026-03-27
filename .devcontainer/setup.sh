#!/bin/bash

git remote set-url origin https://github.com/abretz-mimacom/flowable-deploy-template.git

git submodule sync --recursive && git submodule update --init --recursive