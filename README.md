Boundary module
=

This is the boundary module.

To use it:

    include boundary

You need need to specify your Organisation ID and API key in the boundary::params
class (manifests/params.pp).

To remove a meter change your include to:

    include boundary::delete

Report processor
==

The module also contains a report processor that can send the results of
Puppet runs as Boundary annotations. Reports will only be created for
Puppet runs that had changes or failed. To use it:

1.  Install puppet-boundary as a module in your Puppet master's module
    path.

2.  Update the `boundary_orgid` and `boundary_apikey` variables in the `boundary.yaml` 
    file with your Boundary connection details. Specify the `github_user` and `github_token` 
    options the report processor to create the Gist containing the log output from the run. 
    The Gist will be linked in the Boundary annotation.

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

The boundary_meter type and provider is heavily based on work by Joe Williams and Ben Black from Boundary.

Copyright
---

Puppet Labs 2011-2012

License
---

Apache 2.0


