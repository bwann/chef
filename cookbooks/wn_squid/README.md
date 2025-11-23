wn_squid Cookbook
=================
Installs the Squid caching proxy

Requirements
------------

Attributes
----------
* node['wn_squid']
* node['wn_squid']['acl'][$ACLNAME]

Usage
-----
Include this cookbook in your node's `run_list` or include from another
recipe. This cookbook will download and install the squid package.

This cookbook was not specifically designed to fully manage disk caching,
as its applicability has declined in a HTTPS-first world.. You
can configure the `cache_dir` directive using the cookbook, but you'll need
to take care of creating the directory and making it writable by the squid
user.

`node['wn_squid']` is a key/value hash of configuration options. Things
like named ACLs can be a nested hash of arrays. For example, an ACL called
"myacl" can be defined like this, containing an array of ACL statements:

```ruby
node.default['wn_squid']['acl']['myacl'] = [
  'src 192.168.1.0/24',
  'src 192.168.250.0/24',
  'src fe80::/16',
]
```

This can then be referenced in other directives such as `http_access`.

By default the cookbook contains ACLs defining a set of RFC 1918 local
networks, "safe" destination ports", taken from the Squid example
configuration file.

By default the `http_access` access permissions blocks access to
"unsafe" ports, deny the CONNECT method to non-SSL/TLS ports, allows
localhost access to the cache manager inteface, allows local networks
to access the cache, and denies the rest.

Because `http_access` is defined as an array it can be difficult to
insert/remove directives in the middle of the array. If you wish to
customize for your site or a node, you can rewrite the existing ruleset
with this example:

```ruby
node.default['wn_squid']['http_access'] = [
  'deny !Safe_ports',
  'allow myacl',
  'allow another_acl custom_port',
  'allow localnet',
  'deny all',
]
```
