Boundary module
=

This is the Boundary module.

To use it:

    class { 'boundary':
      id     => 'organisation_id',
      apikey => 'apikey',
      tags   => [ 'these', 'are', 'tags' ]
    } 

To remove a meter change your include to:

    class { 'boundary::delete':
      id     => 'organisation_id',
      apikey => 'apikey',
    }

To specify a stand-alone probe you can use the `boundary_meter` resource:

    boundary_meter { "nameofprobe":
      ensure  => present,
      id      => '1234556789',
      apikey  => 'abcdef123456',
      tags    => [ "production", "web", "cluster" ],
    }

You can also use the `proxy_addr` and `proxy_port` options to specify a
proxy server if required.

Requirements
==

APT based distros will require the puppetlabs-apt module which requires wget. This
has not been added as dependency because yum based distros shouldn't have to install
and apt module.

Dashboard Support
==

It is possible to use this module from Puppet Dashboard (aka Console). To use
the module add `boundary` to the list of classes. Then add the `boundary`
class directly to a node or a group. The following dashboard parameters are
supported:

- `apikey`
- `id`
- `collector`
- `collector_port`
- `tags`

The `tags` parameter is an array of tag names to apply to this bprobe
(e.g., [ 'a', 'list', 'of', 'tags' ] ). 

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

Puppet Labs 2011-2013
Boundary 2014

License
---

Apache 2.0


