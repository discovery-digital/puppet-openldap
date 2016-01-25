Puppet::Type.newtype(:openldap_global_conf) do

  ensurable

  newparam(:name) do
  end

  newparam(:target) do
  end

  newproperty(:value, :array_matching => :all) do
    validate do |value|
      raise Puppet::Error, 'value should be a String' unless [ String ].include? value.class
    end
  end

end
