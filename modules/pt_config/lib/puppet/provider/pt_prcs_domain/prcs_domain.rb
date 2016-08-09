def pre_create 
  super()

  domain_name = resource[:domain_name]
  cfg_home_dir = resource[:ps_cfg_home_dir]

  # PS_CFG_HOME Fix Begin
  if Facter.value(:osfamily) == 'windows'
    ps_cfg_home_dir_norm = resource[:ps_cfg_home_dir].gsub('/', '\\')
  else
    ps_cfg_home_dir_norm = resource[:ps_cfg_home_dir]
  end

  ENV['PS_CFG_HOME'] = ps_cfg_home_dir_norm
  Puppet.notice("     PS_CFG_HOME=#{ps_cfg_home_dir_norm}")
  # PS_CFG_HOME Fix End

  domain_dir = File.join(cfg_home_dir, 'appserv', 'prcs', domain_name)
  if File.exist?(domain_dir)
    Puppet.debug("Removing Process Scheduler domain directory: #{domain_dir}")
    FileUtils.rm_rf(domain_dir)
  end

end