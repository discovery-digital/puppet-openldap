Puppet::Type.newtype(:openldap_access) do
  @doc = 'Manages OpenLDAP ACPs/ACLs'

  ensurable

  newparam(:name) do
    desc "The default namevar"
  end

  newparam(:target) do
    desc "The slapd.conf file"
  end

  newparam(:what, :namevar => true) do
    desc "The entries and/or attributes to which the access applies"
  end

  newparam(:suffix, :namevar => true) do
    desc "The suffix to which the access applies"
  end

  def self.title_patterns
    [
      [
        /^(\{(\d+)\}to\s+(\S+)\s+on\s+(\S+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :position, lambda{|x| x} ],
          [ :what, lambda{|x| x} ],
          [ :suffix, lambda{|x| x} ],
        ],
      ],
      [
        /^(to\s+(\S+)\s+on\s+(\S+))$/,
        [
          [ :name, lambda{|x| x} ],
          [ :what, lambda{|x| x} ],
          [ :suffix, lambda{|x| x} ],
        ],
      ],
      [
        /(.*)/,
        [
          [ :name, lambda{|x| x} ],
        ],
      ],
    ]
  end

  newparam(:position, :namevar => true) do
    desc "Where to place the new entry"
  end

  newproperty(:access, :array_matching => :all) do
    validate do |access|
      raise Puppet::Error, 'access should be an array of strings' unless [ String ].include? access.class
    end
  end

  newproperty(:confdir) do
    desc "Openldap config directory."
  end

  autorequire(:openldap_database) do
    [ value(:suffix) ]
  end

end
