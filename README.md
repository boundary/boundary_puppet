Boundary probe module
===

This is the bprobe module.

To use it:

    include bprobe

You need need to specify your username and API key in the bprobe::params
class (manifests/params.pp).

To remove a meter change your include to:

    include bprobe::delete

Author
---

James Turnbull <james@puppetlabs.com>

Copyright
---

Puppet Labs 2011

License
---

Apache 2.0


