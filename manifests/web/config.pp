# == Class: graphite::web::config
#
# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'graphite::carbon::config': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
class graphite::web::config (
  $secret_key,

  $database_name,
  $database_username,
  $database_password,
  $database_host,
  $database_port,
  $database_backend,

  $carbonlink_hosts,
  $cluster_servers,
  $memcache_servers,
  $cache_duration,
)
{

  #### Configuration
  file { $graphite::params::web_config_path:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  file { "${graphite::params::web_config_path}/local_settings.py":
    ensure  => present,
    content => template("${module_name}/etc/graphite-web/local_settings.py.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$graphite::params::web_config_path]
  }

  file { "${graphite::params::web_config_path}/dashboard.conf":
    ensure  => present,
    source  => $graphite::web::dashboard_config_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File[$graphite::params::web_config_path]
  }

  file { '/var/lib/graphite':
    ensure => directory,
    owner  => $graphite::params::service_default_user,
    group  => $graphite::params::service_default_group,
    mode   => '0755'
  }
}
