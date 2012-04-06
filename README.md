Boundary module
===

This is the boundary module.

To use it:

    include boundary

You need need to specify your Organisation ID and API key in the boundary::params
class (manifests/params.pp).

To remove a meter change your include to:

    include boundary::delete

Author
---

James Turnbull <james@puppetlabs.com>

The boundary_meter type and provider is heavily based on work by Joe Williams and Ben Black from Boundary.

Copyright
---

Puppet Labs 2011-2012

License
---

Apache 2.0


