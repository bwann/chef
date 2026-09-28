Contributing to bwann's chef cookbooks
======================================

Our Development Process
-----------------------

Pull requests are welcome. Every pull request runs the same lint, unit, and
Test Kitchen workflows that [facebook/chef-cookbooks](https://github.com/facebook/chef-cookbooks)
provides for universe repos, so please make sure those pass.

We use Cookstyle for Chef correctness testing and Rubocop for Ruby style
linting, using the upstream rule sets.

Developer Certificate of Origin ("DCO")
---------------------------------------

In lieu of a CLA, we use Chef's
[DCO](https://www.chef.io/blog/introducing-developer-certificate-of-origin)
system (which is based on the Linux Kernel DCO system). Sign off your commits
with `git commit -s`.

Pre-requisites
--------------

Before sending a pull request to this repo it's important to remember that the
attribute-driven APIs here are a very different model than other community
cookbooks. In order to build that model, there's a specific way cookbooks need
to be written.

We highly recommend you read the upstream
[README.md](https://github.com/facebook/chef-cookbooks/blob/main/README.md) and
[Philosophy.md](https://github.com/facebook/chef-utils/blob/main/Philosophy.md)
as well as their
[CONTRIBUTING.md](https://github.com/facebook/chef-cookbooks/blob/main/CONTRIBUTING.md).

Testing Locally
---------------

Check out [facebook/chef-cookbooks](https://github.com/facebook/chef-cookbooks)
next to this repo (as `../chef-cookbooks`), then run the upstream tooling
against this repo with:

```shell
./scripts/run_upstream_script run_cookstyle
./scripts/run_upstream_script run_chefspec
```

Test Kitchen runs the `test_services` cookbook, which includes every cookbook
that is covered by CI. If you add a cookbook, add it there too.

License
-------

By contributing to this repository, you agree that your contributions will be
licensed under its Apache 2.0 license.
