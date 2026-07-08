wn_kea Cookbook
===============

Installs and configures the Kea DHCP v4 and v6 servers.

Requirements
------------
- `fb_users` to manage the kea user and group

Attributes
----------
- node['wn_kea']['dhcp4']
- node['wn_kea']['dhcp4']['subnet4']
- node['wn_kea']['dhcp4']['option-data']
- node['wn_kea']['dhcp6']
- node['wn_kea']['dhcp6']['option-data']
- node['wn_kea']['dhcp6']['subnet6']

Usage
-----
Include `wn_kea::default` to manage Kea. By default it expects to listen for requests on `eth0`
and uses a local `memfile` for the CSV lease database on disk.

Kea is highly customizable and all configuration directives should be possible with this cookbook
provided the attributes are structured properly. DHCPv4 and DHCPv6 server directives are configured
by setting attributes under `node['wn_kea']['dhcp4']` and `node['wn_kea']['dhcp6']`, respectively.
These are hashes and follow the same layering as the YAML map.

For example to configure the network interface on which the DHCPv4 and DHCPv6 servers listen:
```ruby
node.default['wn_kea']['dhcp4']['interfaces-config']['interfaces'] = ['eth0']
node.default['wn_kea']['dhcp6']['interfaces-config']['interfaces'] = ['eth0']
```
## Subnets

This is the list of subnets for which the server will be leasing addresses. They can have single
or multiple pools, as well as host reservations.

Kea requires each subnet to have a unique subnet identifier (subnet-id) that is associated with
the lease database. These can be manually specified or managed by Kea, however if subnet-ids are
changed on a pool with existing leases, unwanted consequences can happen. For this reason the
cookbook hashes the actual subnet prefix internally to a 32-bit number so subnets can be added
or removed without breaking existing leases.

**MAC/Hardware addresses in DHCPv6****

It is often necessary to assign IPv6 addresses based upon the MAC address of a host, similar to
how reservations are done with IPv4. The DHCPv6 protocol doesn't officially support this but Kea
has a few mechanisms that assist in making this possible. This cookbook by default sets the
DHCPv6 server option `mac-sources` preference order to `['duid','rfc6939','ipv6-link-local']`,
trying to pull the MAC address out of DUID-LL/LLT, then using RFC6939 relay information, and
finally trying to dervice the MAC address from a EUI-64 link-local address.

These are customizable and different networks and topologies may require different methods. Refer
to the 'Host Reservation in DHCPv6' section of the Kea Administrator Reference Manual for more
information.

### Example subnet configurations


**Example 1, DHCPv4:**

A DHCP configuration for the subnet `192.168.15.0/24`, setting the DHCP Options 3 and 6 for
`routers` and `name-servers`:

```ruby
node.default['wn_kea']['dhcp4']['subnet4']['192.168.15.0/24'] = {
  'option-data' => [
    {
      'name' => 'domain-name-servers',
      'data' => '10.255.1.53, 10.255.2.53',
    },
    {
      'name' => 'routers',
      'data' => '192.168.15.1',
    },
  ],
  'pools' => ['192.168.15.72 - 192.168.15.254'],
  'reservations' => [
    # One line for compactness
    { 'hostname' => 'dhcphealthcheck.example.com', 'hw-address' => 'de:ad:be:ef:04:04', 'ip-address' => '192.168.15.254' },
    { 'hostname' => 'host1.example.com', 'hw-address' => '00:c9:45:15:11:98', 'ip-address' => '192.168.15.10' },
  ],
}

```

**Example 2, DHCPv6:**

For example, here is DHCPv6 configuration for the subnet `2001:0db8:1234::/64`, carving out
a /80 `2001:0db8:1234:0000:0000:0000:0000:0000 - 2001:db8:1234:0000:0000:ffff:ffff:ffff`
for a pool of leasable addresses, and reservations in and outside of the pool, as well as
setting Option 23 for advertising DNS servers to clients:

```ruby
node.default['wn_kea']['dhcp6']['subnet6']['2001:db8:1234::/64'] = {
  'pools' => ['2001:db8:1234:ffff:ffff::/80'],
  'option-data' => [
    {
      'name' => 'dns-servers',
      'data' => '2001:db8:ffff::a53,2001:db8:ffff::b53',
    },
  ],
  'reservations-out-of-pool' => true,
  'reservations' => [
    {
      'hostname' => 'dhcphealthcheck.example.com',
      'hw-address' => 'de:ad:be:ef:06:06',
      'ip-addresses' => ['2001:db8:1234::beef:0606'],
    },
    {
      'hostname' => 'host1.example.com',
      'hw-address' => 'de:ad:be:ef:06:06',
      'ip-addresses' => ['2001:db8:1234:5678:1515:feca:1212:3'],
    },
  ],
}

```
