test_services Cookbook
======================
Simple cookbook to collect the cookbooks in this repo for Test Kitchen.

Requirements
------------

Attributes
----------

Usage
-----
NOT MEANT FOR USAGE. Just here for our kitchen setup.

It is the run list of the `local` suite in `.kitchen.local.yml`, and also
provides the minimal site setup that the upstream `fb_init` would normally do
(`FB::Users` UID/GID maps, `fb_users`, `fb_systemd` reload resources) plus
any third-party package repositories the cookbooks under test expect.
