wn_opentsdb Cookbook
====================
Installs and configures the OpenTSDB time series database

Any included scripts probably came from (https://github.com/OpenTSDB/opentsdb)

Requirements
------------
- This requires a working instance of Apache HBase, running either in standalone
or distributed mode.

Attributes
----------
* node['wn_opentsdb']['conf']['tsd.core.auto_create_metrics']
* node['wn_opentsdb']['conf']['tsd.http.cachedir']
* node['wn_opentsdb']['conf']['tsd.http.staticroot']
* node['wn_opentsdb']['conf']['tsd.network.port']
* node['wn_opentsdb']['conf']['tsd.storage.hbase.zk_quorum']

Usage
-----
Include `wn_opentsdb` into your node's role or recipe. This will create an
OpenTSDB service listening on TCP port 4242.

By default this cookbook assumes you're running OpenTSDB on the same host
as your HBase master server (e.g. for evaluation). If using a remote HBase
server, you'll need to set the `tsd.storage.hbase.zk_quorum` attribute as
mentioned below.

`node['wn_opentsdb']['conf']` is a hash of key=>value attributes for
configuring the OpenTSDB daemon (i.e. written to `opentsdb.conf`). Three
attributes are required for operation:

`node['wn_opentsdb']['conf']['tsd.http.cachedir']` - Path where TSD will
write cached files for the web UI. Defaults to `/dev/shm/tsd-cache`.

`node['wn_opentsdb']['conf']['tsd.http.staticroot']` - Path to assets for
TSD's web UI. Defaults to `/usr/share/opentsdb/static`.

`node['wn_opentsdb']['conf']['tsd.network.port']` - Port on which TSD
will listen for TCP and HTTP requests. Defaults to `4242`.

Additional configuration options for OpenTSDB may be added to the 'conf' hash,
using the property name as specified in the OpenTSDB configuration guide. For
example:

`node['wn_opentsdb']['conf']['tsd.core.auto_create_metrics']`:
Automatically create new metric names in the database. `true` will accept
all metric names sent from tcollector. `false` means new metrics must be
created by the OpenTSDB administrator before the metrics will be accepted.

`node['wn_opentsdb']['conf']['tsd.storage.hbase.zk_quorum']`: The
network address for Zookeeper so your HBase instances can be found. By default
the cookbook assumes you're running OpenTSDB on the same host as your HBase
master (e.g. standalone mode) and sets this to `127.0.0.1`.

If you're using a remote HBase server setup, set this attribute to the IP
address where ZooKeeper is located. If specifying an IPv6 address, you need to
surround the address in brackets and include the port number,
e.g. `[1:2:3:4:5:6:7:8]:2181`.

`node['wn_opentsdb']['sysconfig']`: A hash of key=>value attributes for
daemon defaults (i.e. `/etc/sysconfig/opentsdb`). By default this cookbook does
not write use any defaults here, instead using their OpenTSDB configuration
file equivalents.

### Runbook

* Web interface: http://hostname:4242/

* TCP/HTTP endpoint for tcollectors: hostname, port 4242

* Logs for OpenTSDB are located in `/var/log/opentsdb`.

* On successful startup of OpenTSDB, you should see this in the log:
`INFO  [main] TSDMain: Ready to serve on /0.0.0.0:4242`

* Checking health, connect to port 4242 and issue `version` or `stats`
```
$ echo version | nc localhost 4242
net.opentsdb.tools 2.2.0 built at revision  (MODIFIED)
Built on 2016/02/14 13:22:24 +0000 by root@centos.localhost:/root/rpmbuild/BUILD/opentsdb-2.2.0
```

* Error `org.hbase.async.TableNotFoundException: "tsdb"`: This means the tsdb
tables were not found in HBase. Run the `tools/create_table.sh` script on the
HBase server to create them. Restart OpenTSDB after creating the tables.

e.g.
```env COMPRESSION=NONE HBASE_HOME=/opt/hbase tools/create_table.sh```

* Error `[OpenTSDB I/O Worker #5] HBaseClient: Need to find the .META. region`:
the HBase server went away or else lost connection.

