Puppet::Type.newtype(:boundary_meter) do

  @doc = 'Manage creation/deletion of BoundaryMeter meters'

  ensurable
  newparam(:meter, :namevar => true) do
    desc 'The BoundaryMeter meter name, usually based off the $::fqdn of the node'

  end

  newparam(:token) do
    desc 'The BoundaryMeter Installation Token.'
  end

  newproperty(:tags, :array_matching => :all) do
    desc 'Tags to be added to the BoundaryMeter meter. Specify a tag or an array of tags.'
    def insync?(is)
      is.sort == @should.sort
    end
  end

  autorequire(:package) { catalog.resource(:package, 'boundary-meter')}
end
