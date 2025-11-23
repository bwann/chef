wn_exabgp Cookbook
==================
Installs and manages ExaBGP, the BGP swiss army knife of networking

Requirements
------------

Attributes
----------
* node['wn_exabgp']
* node['wn_exabgp']['neighbor']
* node['wn_exabgp']['process']

Usage
-----

Include this recipe in your node's run_list or other recipe. The cookbook
installs the exabgp and python scripts packages, configures exabgp, and
starts the service.

`node['wn_exabgp']` is a key-value hash of configuration directives and
may contain hash-of-hashes or hash-of-arrays to represent nested sections
of configuration.

`node['wn_exabgp']['neighbor']` contains a hash of BGP neighbors, keyed
by the neighbor IP address. It supports nesting of extra sections. Examples:

```ruby
node.default['wn_exabgp']['neighbor']['192.168.1.1'] = { ...details...}

node.default['wn_exabgp']['neighbor']['2001:0db8::1'] = {
  'local-address' => '2001:0db8::abcd',
  'router-id' => '192.168.1.15',
  'local-as' => '65400',
  'peer-as' => '65413',
  'family' => {
    'ipv6' => 'unicast',
  },
  'api' => {
    'process' => [
      'my-healthcheck-script'
    ],
  },
}
```

`node['wn_exabgp']['process']` is similar:

```ruby
node.default['wn_exabgp']['process']['my-healthcheck-script'] = {
  'run' => 'python -m exabgp healthcheck ...',
  'encoder' => 'text',
}
```
