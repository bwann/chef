wn_isc_stork Cookbook
=====================

Configures the ISC Stork web-based graphical dashboard for Kea DHCP 
and BIND 9 servers.

Stork has two components, a centralized server `stork-server` backed by
Postgresql, and `stork-agent` which runs on hosts that have the Kea DHCP
and/or BIND 9 DNS servers running.

Requirements
------------
* Server requires Postgresql

Attributes
----------

Usage
-----

## Stork Agent

By default this cookbook installs only the Stork agent when included by
another role or cookbook.

## Stork Server

Include the recipe `wn_isc_stork::server` to install the Stork server component.
