# aws-sagemaker-orb

# AWS Sagemaker Orb [![CircleCI Build Status](https://circleci.com/gh/CircleCI-Public/aws-sagemaker-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/CircleCI-Public/aws-sagemaker-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/circleci/aws-sagemaker.svg)](https://circleci.com/orbs/registry/orb/circleci/aws-sagemaker) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/circleci-public/aws-sagemaker-orb/main/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

This repository has the code for the the CircleCI [AWS Sagemaker Orb](https://github.com/CircleCI-Public/aws-sagemaker-orb). Please note that this version is currently in beta. Explore, understand, and experiment, but proceed with caution when integrating it into practical applications. 🛠✨

## Usage

### Setup

In order to use the AWS Sagemaker Orb on CircleCI you will need to setup environment variables either in context or project env vars. Required variables are SAGEMAKER_EXECUTION_ROLE_ARN.
This Orb uses the circleci provided job token called CIRCLE_OIDC_TOKEN to get authenticated with your AWS sagemaker service.

### Use In Config

For full usage guidelines, see the [Orb Registry listing](http://circleci.com/orbs/registry/orb/circleci/aws-sagemaker).

---

## FAQ

View the [FAQ in the wiki](https://github.com/CircleCI-Public/aws-sagemaker-orb/wiki/FAQ)

## Contributing

We welcome [issues](https://github.com/CircleCI-Public/aws-sagemaker-orb/issues) to and [pull requests](https://github.com/CircleCI-Public/aws-sagemaker-orb/pulls) against this repository!

For further questions/comments about this or other orbs, visit [CircleCI's orbs discussion forum](https://discuss.circleci.com/c/orbs).
