# flowable-deploy-template

This repository is #2 of 3 that is meant to serve as a "Best Practice Example" when it comes to Flowable DevOps. Below is the architecture and prescribed Git Branching stratgey for the 3 repositories:

![Pipeline Diagram](assets/Pipeline.drawio.svg)

# Introduction

Zooming into the second portion of the diagram, we can focus on the purpuse of this repository: Flowable deployments via Helm.

![Deploy Diagram](assets/deploy-pipeline.png)


## Getting started
Thise Best Practices guide on DevOps with Flowable delivered as working code to give functional exmaples to explain these concepts more thoroughly. The easiest way to get started is to create your own project off of this project template, then open the project inside GitHub Codespaces - they are free with a GitHub account and they contain all the  software and configurations to get this example running in as few steps as possible.

1) Create your own repo using this repo as a template: [click here] (https://github.com/new?template_name=flowable-deploy-template&template_owner=abretz-mimacom)
2) Add secret env variables to your repo by going to Settings->Secrets and Variables->Codespaces in your repo and add secrets for:
```
FLOWABLE_LICENSE_KEY=<REPLACE_WITH_RAW_TEXT_VALUE_OF_FLOWABLE_LICENSE>
FLOWABLE_REPO_USER=<REPLACE_WITH_EMAIL_ASSOCIATED_WITH_FLOWABLE_ARTIFACTORY>
FLOWABLE_REPO_PASSWORD=<REPLACE_WITH_PASSWORD_ASSOCIATED_WITH_FLOWABLE_ARTIFACTORY>
```
2) Return to the index/home page of your newly created repo and create a new Codespace for your new project.
3) Open the terminal and execute:
    Install brew (to install kind&k9s)
        `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`
        `echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc`
        `eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)`
    Install kind and k9s
        `brew install kind derailed/k9s/k9s`
    Run the create-env script
        `./create-env.sh`
        You can optionally supply ./create.sh with an argument to set the namespace of the Flowable deployment, default=dev
        `export NAMESPACE=prod && ./create-env.sh $NAMESPACE`
        NOTE: you must create a directory inside `helm/` that matches your $NAMESPACE and suppply a `values.yaml` that supports the Helm Chart deployment.
    Observe the deployment
        `k9s -n $NAMESPACE`
4) Get coffee and wait. It will take about 5 minutes for this micro-cluster to full standup.
5) Once all the