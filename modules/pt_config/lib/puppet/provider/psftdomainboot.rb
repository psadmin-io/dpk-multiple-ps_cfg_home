def execute_psadmin_action(action) 
  domain_name = resource[:domain_name] domain_type = get_domain_type()

  Puppet.debug("Performing action #{action} on domain #{domain_name}")

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

      db_type = get_db_type()
      if db_type == 'ORACLE'
        set_user_env()
      end
      command = "#{psadmin_cmd} #{domain_type} #{action} -d #{domain_name}"
      command_output = execute_command(command)

    else
      os_user = resource[:os_user]
      if os_user_exists?(os_user) == false
        command_output="ERROR: os user #{os_user} does not exists"
      else
        command_output = domain_cmd('-m', '-s', '/bin/bash', '-',  os_user, '-c',
          "#{psadmin_cmd} #{domain_type} #{action} " + "-d #{domain_name}")
      end
    end
    return command_output

  rescue Puppet::ExecutionFailure => e
    raise Puppet::ExecutionFailure, "Unable to perform action #{action}: #{e.message}"
  end

end