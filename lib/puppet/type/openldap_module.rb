Puppet::Type.newtype(:openldap_module) do
  @doc = "Manages OpenLDAP modules."

  ensurable

  newparam(:name) do
    desc "The default namevar."
  end

  newparam(:target) do
  end

  newproperty(:confdir) do
    desc "Openldap config directory."
  end
end

