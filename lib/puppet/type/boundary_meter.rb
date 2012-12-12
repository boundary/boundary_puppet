Puppet::Type.newtype(:boundary_meter) do

  @doc = "Manage creation/deletion of Boundary meters."

  ensurable

  newparam(:meter, :namevar => true) do
    desc "The Boundary meter name."
  end

  newparam(:id) do
    desc "Your Boundary Organisation ID."
  end

  newparam(:apikey) do
    desc "The Boundary API key."
  end

  newproperty(:tags, :array_matching => :all) do
    desc "Tags to be added to the Boundary meter. Specify a tag or an array of tags."

    def insync?(is)
      is.sort == @should.sort
    end
  end

  newparam(:proxy_addr) do
    desc "Proxy meter management through this host"
  end

  newparam(:proxy_port) do
    desc "Proxy meter management through this port"
  end
end
