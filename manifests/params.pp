# == Class: graphite::params
#
# This class exists to
# 1. Declutter the default value assignment for class parameters.
# 2. Manage internally used module variables in a central place.
#
# Therefore, many operating system dependent differences (names, paths, ...)
# are addressed in here.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class is not intended to be used directly.
#
#
# === Links
#
# * {Puppet Docs: Using Parameterized Classes}[http://j.mp/nVpyWY]
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
class graphite::params {

  #### Default values for the parameters of the main module class, init.pp

  # ensure
  $ensure = 'present'

  # autoupgrade
  $autoupgrade = false

  # service status
  $status = 'enabled'

  #### Internal module values

  # packages
  case $facts['os']['name'] {
    'CentOS', 'Fedora', 'Scientific', 'RedHat': {
      # main application
      $package_carbon  = [ 'python-carbon' ]
      $package_whisper = [ 'python-whisper' ]
      $package_web     = [ 'graphite-web']
    }
    'Ubuntu': {
      # main application
      $package_carbon  = [ 'graphite-carbon' ]
      $package_web     = [ 'graphite-web' ]
      if versioncmp($facts['os']['distro']['release']['full'], '20.04') < 0 {
        $package_whisper = [ 'python-whisper' ]
      }
      else {
        $package_whisper = [ 'python3-whisper' ]
      }
    }
    default: {
      fail("\"${module_name}\" provides no package default value
            for \"${facts['os']['name']}\"")
    }
  }

  # service parameters
  case $facts['os']['name'] {
    'CentOS', 'Fedora', 'Scientific', 'RedHat': {
      $service_default_path     = '/etc/sysconfig'
      $service_default_user     = undef
      $service_default_group    = undef

      $service_cache_name       = 'carbon-cache'
      $service_cache_hasrestart = true
      $service_cache_hasstatus  = true
      $service_cache_pattern    = $service_cache_name

      $service_relay_name       = 'carbon-relay'
      $service_relay_hasrestart = true
      $service_relay_hasstatus  = true
      $service_relay_pattern    = $service_relay_name

      $service_aggregator_name       = 'carbon-aggregator'
      $service_aggregator_hasrestart = true
      $service_aggregator_hasstatus  = true
      $service_aggregator_pattern    = $service_aggregator_name

      $web_config_path = '/etc/graphite-web'
    }
    'Ubuntu': {
      $service_default_path     = '/etc/default'
      $service_default_user     = '_graphite'
      $service_default_group    = '_graphite'

      $service_cache_name       = 'carbon-cache'
      $service_cache_hasrestart = true
      $service_cache_hasstatus  = true
      $service_cache_pattern    = $service_cache_name

      $service_relay_name       = 'carbon-relay'
      $service_relay_hasrestart = true
      $service_relay_hasstatus  = true
      $service_relay_pattern    = $service_relay_name

      $service_aggregator_name       = 'carbon-aggregator'
      $service_aggregator_hasrestart = true
      $service_aggregator_hasstatus  = true
      $service_aggregator_pattern    = $service_aggregator_name

      $web_config_path = '/etc/graphite'
    }
    default: {
      fail("\"${module_name}\" provides no service parameters
            for \"${facts['os']['name']}\"")
    }
  }

}
