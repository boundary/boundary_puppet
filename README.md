Boundary module
=

This is the boundary module.

To use it:

    include boundary

You need need to specify your Organisation ID and API key in the boundary::params
class (manifests/params.pp).

To remove a meter change your include to:

    include boundary::delete

To specify a stand-alone probe you can use the `boundary_meter` resource:

    boundary_meter { "nameofprobe":
      ensure  => present,
      id      => '1234556789',
      apikey  => 'abcdef123456',
      tags    => [ "production", "web", "cluster" ],
    }

Dashboard Support
==

It is possible to use this module from Puppet Dashboard (aka Console). To use
the module add `boundary` to the list of classes. Then add the `boundary`
class directly to a node or a group. The following dashboard parameters are
supported:

- `boundary_apikey`
- `boundary_id`
- `boundary_collector`
- `boundary_collector_port`
- `boundary_tags`

The `boundary_tags` parameter is a comma separated list of tag names to apply
to this bprobe (e.g., 'a, list, of, tags'). Whitespace is fine. If you want to
tag nodes indivdually you should at the `boundary` class directly to each
node. Similarly you can tag at the group level. Currently you cannot tag at
both the node and group level.

Report processor
==

The module also contains a report processor that can send the results of
Puppet runs as Boundary annotations. Reports will only be created for
Puppet runs that had changes or failed. To use it:

1.  Install puppet-boundary as a module in your Puppet master's module
    path.

2.  Update the `boundary_orgid` and `boundary_apikey` variables in the `boundary.yaml`
    file with your Boundary connection details.

3.  Enable pluginsync and reports on your master and clients in `puppet.conf`

        [master]
        report = true
        reports = boundary
        pluginsync = true
        [agent]
        report = true
        pluginsync = true

4.  Run the Puppet client and sync the report as a plugin

Author
---

James Turnbull <james@puppetlabs.com>

The `boundary_meter` type and provider is heavily based on work by Joe Williams and Ben Black from Boundary.

Copyright
---

Puppet Labs 2011-2012

License
---

Apache 2.0


