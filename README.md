bwann's chef cookbooks
======================

[![Continuous Integration](https://github.com/bwann/chef/actions/workflows/ci.yml/badge.svg)](https://github.com/bwann/chef/actions/workflows/ci.yml)
[![Kitchen Tests](https://github.com/bwann/chef/actions/workflows/kitchen.yml/badge.svg)](https://github.com/bwann/chef/actions/workflows/kitchen.yml)

These are some of the Chef cookbooks I use for managing my systems. Some
are fairly standard with modern CentOS and Ubuntu, some set up vintage,
forgotten technologies such as UUCP and modems.

This repo contains attribute-driven-API cookbooks that follow the [Meta/FB
API](https://github.com/facebook/chef-cookbooks) model, but are not maintained
by Meta.

Required reading:
* [Meta's Chef Philosophy](https://github.com/facebook/chef-utils/blob/main/Philosophy.md)
* [Meta's Chef Cookbook Suite README](https://github.com/facebook/chef-cookbooks/blob/main/README.md)

Testing
-------
Linting, unit tests, and Test Kitchen run in GitHub Actions using the
reusable workflows from
[facebook/chef-cookbooks](https://github.com/facebook/chef-cookbooks), see
[CREATING_UNIVERSE_REPOS.md](https://github.com/facebook/chef-cookbooks/blob/main/docs/CREATING_UNIVERSE_REPOS.md).

Cookbooks currently covered by Test Kitchen (via `test_services`):
* `wn_exabgp`
* `wn_kea`
* `wn_mgetty`
* `wn_squid`

The remaining cookbooks are linted but not yet converged in CI.

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to run the tests locally.

License
-------
See the LICENSE file in this directory.
