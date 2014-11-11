Boundary module
=

This is the Boundary module.

To use it with Boundary Premium:

    class { 'boundary':
      token => 'api_token'
    }

To use it with Boundary Enterprise:

    class { 'boundary':
      token => 'org_id:api_key',
      tags  => [ 'these', 'are', 'tags' ]
    }

Or, as of Boundary Meter 3.1, you can use it with both at the same time:

    class { 'boundary':
      token => 'api_token,org_id:api_key',
      tags  => [ 'these', 'are', 'tags' ]
    }

To remove a meter change your include to:

    class { 'boundary::delete' }

To specify a stand-alone meter you can use the `boundary_meter` resource:

    boundary_meter { "name_of_meter":
      ensure => present,
      token  => ['api_token'],
      tags   => [ "production", "web", "cluster" ],
    }

You can also use the `proxy_addr` and `proxy_port` options to specify an HTTPS
proxy server if required.

Requirements
==

APT based distros will require the puppetlabs-apt module which requires wget. This
has not been added as dependency because yum based distros shouldn't have to install
an apt module.

Dashboard Support
==

It is possible to use this module from Puppet Dashboard (aka Console). To use
the module add `boundary` to the list of classes. Then add the `boundary`
class directly to a node or a group. The following dashboard parameters are
supported:

- `token`
- `tags`

The `tags` parameter is an array of tag names to apply to this meter
(e.g., [ 'a', 'list', 'of', 'tags' ] ).

Authors
---

Zachary Schneider <ops@boundary.com>

James Turnbull <james@puppetlabs.com>

The `boundary_meter` type and provider is heavily based on work by Joe Williams and Ben Black from Boundary.

Copyright
---

Puppet Labs 2011-2013

Boundary 2014

License
---

Apache 2.0


