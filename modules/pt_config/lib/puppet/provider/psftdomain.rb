def create pre_create()

  domain_name = resource[:domain_name]
  domain_type = get_domain_type()
  template_type = get_template_type()

  Puppet.debug("Creating domain: #{domain_name}")
  Puppet.debug("     with attributes #{resource.to_hash.inspect}")

  # PS_CFG_HOME Fix Begin
  if Facter.value(:osfamily) == 'windows'
    ps_cfg_home_dir_norm = resource[:ps_cfg_home_dir].gsub('/', '\\')
  else
    ps_cfg_home_dir_norm = resource[:ps_cfg_home_dir]
  end

  ENV['PS_CFG_HOME'] = ps_cfg_home_dir_norm
  Puppet.notice("     PS_CFG_HOME=#{ps_cfg_home_dir_norm}")
  # PS_CFG_HOME Fix End

  begin
    psadmin_cmd = File.join(resource[:ps_home_dir], 'appserv', 'psadmin')
    if Facter.value(:osfamily) == 'windows'

      command = "#{psadmin_cmd} #{domain_type} create -d #{domain_name} #{template_type} #{get_startup_settings} #{get_env_settings}"
      execute_command(command)
    else 
      domain_cmd('-m', '-s', '/bin/bash', '-l',  resource[:os_user], '-c',
                 "#{psadmin_cmd} #{domain_type} create -d #{domain_name} " +
                 "#{template_type} #{get_startup_settings} #{get_env_settings}")
    end

  rescue Puppet::ExecutionFailure => e
    raise Puppet::Error,
        "Unable to create domain #{domain_name}: #{e.message}"
  end

  post_create()
  @property_hash[:ensure] = :present

end