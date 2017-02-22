require 'tempfile'

Puppet::Type.type(:openldap_global_conf).provide(:olc) do

  # TODO: Use ruby bindings (can't find one that support IPC)

  defaultfor :osfamily => :debian, :osfamily => :redhat

  commands :slapcat => 'slapcat', :ldapmodify => 'ldapmodify'

  mk_resource_methods

  def self.instances(confdir)
    items = slapcat(
      '-F',
      confdir,
      '-b',
      'cn=config',
      '-H',
      'ldap:///???(objectClass=olcGlobal)'
    )
    values = {}
    i = []
    items.gsub("\n ", "").split("\n").select{|e| e =~ /^olc/}.collect do |line|
      name, value = line.match(/^olc(.+): (?:\{[-\d]+\})?(.+)$/).captures
      values[name] = [] unless values[name].is_a? Array
      values[name] << value
    end

    # initialize @property_hash
    values.each do |name, value|
      i << new(
        :name   => name,
        :ensure => :present,
        :value  => value,
        :confdir => confdir
      )
    end

    i
  end

  def self.prefetch(resources)
    items = instances(resources.first[1]["confdir"])
    resources.keys.each do |name|
      if provider = items.find{ |item| item.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    t = Tempfile.new('openldap_global_conf')
    t << "dn: cn=config\n"
    t << "add: olc#{resource[:name]}\n"
    resource[:value].each do |v|
      t << "olc#{resource[:name]}: #{v}\n"
    end
    t.close
    Puppet.debug(IO.read t.path)
    begin
      ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    @property_hash[:ensure] = :present
  end

  def destroy
    t = Tempfile.new('openldap_global_conf')
    t << "dn: cn=config\n"
    t << "delete: olc#{name}\n"
    t.close
    Puppet.debug(IO.read t.path)
    begin
      ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    @property_hash.clear
  end

  def value
    @property_hash[:value]
  end

  def value=(value)
    t = Tempfile.new('openldap_global_conf')
    t << "dn: cn=config\n"
    t << "replace: olc#{name}\n" + value.collect { |x| "olc#{resource[:name]}: #{x}" }.join("\n")
    t.close
    Puppet.debug(IO.read t.path)
    begin
      ldapmodify('-Y', 'EXTERNAL', '-H', 'ldapi:///', '-f', t.path)
    rescue Exception => e
      raise Puppet::Error, "LDIF content:\n#{IO.read t.path}\nError message: #{e.message}"
    end
    @property_hash[:value] = value
  end

end
