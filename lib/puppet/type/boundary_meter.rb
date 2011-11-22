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

  newparam(:tags) do
    desc "Tags to be added to the Boundary meter. Specify a tag or an array of tags."
  end
end
