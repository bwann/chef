wn_containerd Cookbook
======================

Installs and manages the containerd container runtime

The cookbook sets minimal containerd defaults, to use for Kubernetes some
configuration options will need to be set.

Requirements
------------

Attributes
----------
* node['wn_containerd']['config']
* node['wn_containerd']['config']['_global']

Usage
-----

Include this cookbook in your node's `run_list` or include from another recipe.
This cookbook will download and install the containerd package.

`node['wn_containerd']['config']` is a key/value hash of configuration options.

`node['wn_containerd']['config']['_global']` defines configuration options at
the top of the configuration hierarchy, e.g. not in a table.

This cookbook attempts to output "good enough" TOML configuration because
Chef/Cinc doesn't have a built-in gem to output TOML like it does YAML/JSON.
Some tweaks to the template may need to be made as edge cases are discovered
in more complex configurations.

TODO: possibly improve nested tables support somehow to make it a bit more
friendly when setting attributes in the cookbook that result setting values
in deeply nested tables.

For example as the cookbook exists today, to set `runc.options` values for
Kubernetes, it looks like this in a recipe:

```ruby

node.default['wn_containerd']['config'][
  'plugins."io.containerd.grpc.v1.cri"'][
  'plugins."io.containerd.grpc.v1.cri".containerd.runtimes'][
  'plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc']['runtime_type'] = 'io.containerd.runc.v2'
node.default['wn_containerd']['config'][
  'plugins."io.containerd.grpc.v1.cri"'][
  'plugins."io.containerd.grpc.v1.cri".containerd.runtimes'][
  'plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc'][
  'plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options']['SystemdCgroup'] = true
```
